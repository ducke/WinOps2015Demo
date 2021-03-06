#region Initialize

function Initialize
{
    $script:TempPath = "$env:LOCALAPPDATA\Temp\{0}" -f [Guid]::NewGuid().ToString()
    $script:pendingSec = 20

    # Enum for Ensure
    Add-Type -TypeDefinition @"
        public enum EnsureType
        {
            Present,
            Absent
        }
"@ -ErrorAction SilentlyContinue

    # Enum for RebootTrigger
    Add-Type -TypeDefinition @"
        public enum RebootTriggerType
        {
            ComponentBasedServicing,
            WindowsUpdate,
            PendingFileRename,
            PendingComputerRename,
            CcmClientSDK
        }
"@ -ErrorAction SilentlyContinue
}

Initialize

#endregion

#region Message Definition

$verboseMessages = Data {
    ConvertFrom-StringData -StringData @"
        SetLCMStatus = Setting the DSCMachineStatus global variable to 1.
        WaitTimeSecDetect = WaitTimeSec detected. Waiting {0}sec before enable reboot flag.
        PendingRebootUntilDSCReboot = Pending Reboot for {0}sec for when RebootIfNeeded is $true. Even $false will reboot until time past.
"@
}

$debugMessages = Data {
    ConvertFrom-StringData -StringData @"
        ChangeLCMRebootNodeIfNeeded = Changing Local Configuration Manager RebootNodeIfNeeded status from '{0}' to '{1}'
        PendingRebootDetect = A pending reboot was found for : {0}.
        SCCMCanNotQueryException = Unable to query CCM_ClientUtilities: {0}
        SkipTriggerChecking = {0}Trigger detect $false. Skipping Trigger check.
"@
}

$errorMessages = Data {
    ConvertFrom-StringData -StringData @"
"@
}

#endregion

#region *-TargetResource

function Get-TargetResource
{
    [OutputType([System.Collections.Hashtable])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]$Name,

        [parameter(Mandatory = $false)]
        [System.UInt32]$WaitTimeSec = 0,

        [parameter(Mandatory = $false)]
        [System.Boolean]$Force = $true,

        [parameter(Mandatory = $false)]
        [System.Boolean]$WhatIf = $false,

        [parameter(Mandatory = $false)]
        [System.Boolean]$TriggerComponentBasedServicing = $true,

        [parameter(Mandatory = $false)]
        [System.Boolean]$TriggerWindowsUpdate = $true,

        [parameter(Mandatory = $false)]
        [System.Boolean]$TriggerPendingFileRename = $true,

        [parameter(Mandatory = $false)]
        [System.Boolean]$TriggerPendingComputerRename = $true,

        [parameter(Mandatory = $false)]
        [System.Boolean]$TriggerCcmClientSDK = $true
    )

    # return hash
    $returnValue = @{
        Name = $Name
        WaitTimeSec = $WaitTimeSec
        Force = $Force
        WhatIf = $WhatIf
        TriggerComponentBasedServicing = $TriggerComponentBasedServicing
        TriggerWindowsUpdate = $TriggerWindowsUpdate
        TriggerPendingFileRename = $TriggerPendingFileRename
        TriggerPendingComputerRename = $TriggerPendingComputerRename
        TriggerCcmClientSDK = $TriggerCcmClientSDK
    }

    # initialize
    $scriptBlocks = @()

    # Windows Component Reboot Check
    if ($TriggerComponentBasedServicing)
    {
        $scriptBlocks += @{
            [RebootTriggerType]::ComponentBasedServicing.ToString() = {
                (Split-Path (Get-ChildItem 'registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\').Name -Leaf) -contains "RebootPending"
            }
        }
    }
    else
    {
        Write-Debug ($debugMessages.SkipTriggerChecking -f [RebootTriggerType]::ComponentBasedServicing.ToString())
        $returnValue.([RebootTriggerType]::ComponentBasedServicing.ToString()) = $false
    }

    # Windows Update Reboot Check
    if ($TriggerWindowsUpdate)
    {
        $scriptBlocks += @{
            [RebootTriggerType]::WindowsUpdate.ToString() = {
                (Split-Path (Get-ChildItem 'registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\').Name -Leaf) -contains "RebootRequired"
            }
        }
    }
    else
    {
        Write-Debug ($debugMessages.SkipTriggerChecking -f [RebootTriggerType]::WindowsUpdate.ToString())
        $returnValue.([RebootTriggerType]::WindowsUpdate.ToString()) = $false
    }

    # PendingFileRename
    if ($TriggerPendingFileRename)
    {
        $scriptBlocks += @{
            [RebootTriggerType]::PendingFileRename.ToString() = {
                (Get-ItemProperty 'registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\').PendingFileRenameOperations.Length -gt 0
            }
        }
    }
    else
    {
        Write-Debug ($debugMessages.SkipTriggerChecking -f [RebootTriggerType]::PendingFileRename.ToString())
        $returnValue.([RebootTriggerType]::PendingFileRename.ToString()) = $false
    }

    # Computer Name Reboot Check
    if ($TriggerPendingComputerRename)
    {
        $scriptBlocks += @{
            [RebootTriggerType]::PendingComputerRename.ToString() = {
                $ActiveComputerName = (Get-ItemProperty 'registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName').ComputerName
                $PendingComputerName = (Get-ItemProperty 'registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName').ComputerName
                $ActiveComputerName -ne $PendingComputerName
            }
        }
    }
    else
    {
        Write-Debug ($debugMessages.SkipTriggerChecking -f [RebootTriggerType]::PendingComputerRename.ToString())
        $returnValue.([RebootTriggerType]::PendingComputerRename.ToString()) = $false
    }

    # System Center Reboot Check
    if ($TriggerCcmClientSDK)
    {
        $scriptBlocks += @{
            [RebootTriggerType]::CcmClientSDK.ToString() = {
                try
                {
                    $CCMSplat = @{
                        NameSpace='ROOT\ccm\ClientSDK'
                        Class='CCM_ClientUtilities'
                        Name='DetermineIfRebootPending'
                        ErrorAction='Stop'
                    }
                    $CCMClientSDK = Invoke-WmiMethod @CCMSplat
                    ($CCMClientSDK.ReturnValue -eq 0) -and ($CCMClientSDK.IsHardRebootPending -or $CCMClientSDK.RebootPending)
                }
                catch
                {
                    $false
                    Write-Debug ($debugMessages.SCCMCanNotQueryException -f $_)
                }
            }
        }
    }
    else
    {
        Write-Debug ($debugMessages.SkipTriggerChecking -f [RebootTriggerType]::CcmClientSDK.ToString())
        $returnValue.([RebootTriggerType]::CcmClientSDK.ToString()) = $false
    }

    # execute Each Parameter
    $ensure = [EnsureType]::Present
    if (($scriptBlocks | measure).Count -ne 0)
    {
        foreach ($script in $scriptBlocks.Keys)
        {
            $returnValue.$script = & $scriptBlocks."$script"
            If ($returnValue.$script)
            {
                Write-Debug ($debugMessages.PendingRebootDetect -f $script)
                $Ensure = [EnsureType]::Absent
            }
        }
    }
   
    # ensure
    $returnValue.Ensure = $ensure

    # return
    return $returnValue
}


function Set-TargetResource
{
    [OutputType([Void])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]$Name,

        [parameter(Mandatory = $false)]
        [System.UInt32]$WaitTimeSec = 0,

        [parameter(Mandatory = $false)]
        [System.Boolean]$Force = $true,

        [parameter(Mandatory = $false)]
        [System.Boolean]$WhatIf = $false,

        [parameter(Mandatory = $false)]
        [System.Boolean]$TriggerComponentBasedServicing = $true,

        [parameter(Mandatory = $false)]
        [System.Boolean]$TriggerWindowsUpdate = $true,

        [parameter(Mandatory = $false)]
        [System.Boolean]$TriggerPendingFileRename = $true,

        [parameter(Mandatory = $false)]
        [System.Boolean]$TriggerPendingComputerRename = $true,

        [parameter(Mandatory = $false)]
        [System.Boolean]$TriggerCcmClientSDK = $true
    )

    # Sleep for WaitTimeSec
    SleepWaitTimeSec -WaitTimeSec $WaitTimeSec

    # Set DSCMachineStatus
    Write-Verbose $verboseMessages.SetLCMStatus
    $global:DSCMachineStatus = 1

    # Manual Reboot
    ManualReboot -Force $Force -WhatIf $WhatIf
}


function Test-TargetResource
{
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]$Name,

        [parameter(Mandatory = $false)]
        [System.UInt32]$WaitTimeSec = 0,

        [parameter(Mandatory = $false)]
        [System.Boolean]$Force = $true,

        [parameter(Mandatory = $false)]
        [System.Boolean]$WhatIf = $false,

        [parameter(Mandatory = $false)]
        [System.Boolean]$TriggerComponentBasedServicing = $true,

        [parameter(Mandatory = $false)]
        [System.Boolean]$TriggerWindowsUpdate = $true,

        [parameter(Mandatory = $false)]
        [System.Boolean]$TriggerPendingFileRename = $true,

        [parameter(Mandatory = $false)]
        [System.Boolean]$TriggerPendingComputerRename = $true,

        [parameter(Mandatory = $false)]
        [System.Boolean]$TriggerCcmClientSDK = $true
    )

    return (Get-TargetResource -Name $Name -WaitTime $WaitTime -Force $Force -WhatIf $WhatIf -TriggerComponentBasedServicing $TriggerComponentBasedServicing -TriggerWindowsUpdate $TriggerWindowsUpdate -TriggerPendingFileRename $TriggerPendingFileRename -TriggerPendingComputerRename $TriggerPendingComputerRename -TriggerCcmClientSDK $TriggerCcmClientSDK).Ensure -eq [EnsureType]::Present.ToString()
}

#endregion

#region Set Helper

function SleepWaitTimeSec ([Uint32]$WaitTimeSec)
{
    if ($WaitTimeSec -ne 0)
    {
        Write-Verbose ($verboseMessages.WaitTimeSecDetect -f $WaitTimeSec)
        [System.Threading.Thread]::Sleep([TimeSpan]::FromSeconds($WaitTimeSec))
    }
}

function ManualReboot ($Force, $WhatIf)
{
    if (-not $WhatIf)
    {
        Write-Verbose ($verboseMessages.PendingRebootUntilDSCReboot -f $script:pendingSec)
        [System.Threading.Thread]::Sleep([TimeSpan]::FromSeconds($script:pendingSec))
    }
    Restart-Computer -Force:$Force -WhatIf:$WhatIf
}

#endregion

Export-ModuleMember -Function *-TargetResource
