configuration DemoConfiguration {
  param (
    [Parameter(Mandatory)]
    [System.Collections.IDictionary] $OctopusParameters
  )

  Import-DscResource -ModuleName cPSDesiredStateConfiguration
  Import-DscResource -ModuleName PSDesiredStateConfiguration
  Import-DSCResource -ModuleName xSystemVirtualMemory
  Import-DscResource -Modulename GraniResource

  node localhost {
    $roles = $OctopusParameters['Octopus.Machine.Roles'] -split ','

    write $roles

    if ($roles -contains 'XenAppSessionHost') {
#region WindowsFeature
      WindowsFeature AspNetFramework
      {
        Name = 'AS-Net-Framework'
        Ensure = 'Present'
      }

      WindowsFeature RDSRDServer
      {
      Name = 'RDS-RD-Server'
      Ensure = 'Present'
      }

      WindowsFeature IHInkSupport
      {
      #IH-Ink-Support
      Name = 'InkAndHandwritingServices' 
      Ensure = 'Present'
      }

      WindowsFeature DesktopExperience
      {
      Name = 'Desktop-Experience' 
      Ensure = 'Present'
      }

      WindowsFeature ServerMediaFoundation
      {
      Name = 'Server-Media-Foundation' 
      Ensure = 'Present'
      }
#endregion
#region Pagefile

      Registry Dump_AutoReboot
      {
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl'
        ValueName = 'AutoReboot'
        Force = $true
        ValueData = '1'
        ValueType = 'Dword'
      }
      Registry Dump_Overwrite
      {
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl'
        ValueName = 'Overwrite'
        Force = $true
        ValueData = '1'
        ValueType = 'Dword'
      }
      Registry Dump_SendAlert
      {
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl'
        ValueName = 'SendAlert'
        Force = $true
        ValueData = '0'
        ValueType = 'Dword'
      }
      Registry Dump_LogEvent
      {
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl'
        ValueName = 'LogEvent'
        Force = $true
        ValueData = '1'
        ValueType = 'Dword'
      }
      Registry Dump_MinidumpDir
      {
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl'
        ValueName = 'MinidumpDir'
        Force = $true
        ValueData = 'C:\'
        ValueType = 'String'
      }
      Registry Dump_DumpFile
      {
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl'
        ValueName = 'DumpFile'
        Force = $true
        ValueData = 'C:\MEMORY.DMP'
        ValueType = 'String'
      }
      xSystemVirtualMemory AdjustVirtualMemory
      {
          ConfigureOption = "CustomSize"
          InitialSize = 1000
          MaximumSize = 2000
          DriveLetter = "C:"
      }
#endregion
#region Services
      Service BITS
      {
	      Name = 'BITS'
	      StartupType = 'Disabled'
	      State = 'Stopped'
      }
<# GIbt es bei Windows 2012 r2 nicht
      Service UxSms
      {
	      Name = 'UxSms'
	      StartupType = 'Disabled'
	      State = 'Stopped'
      }
#>
      Service FDResPub
      {
	      Name = 'FDResPub'
	      StartupType = 'Disabled'
	      State = 'Stopped'
      }
      Service CscService
      {
	      Name = 'CscService'
	      StartupType = 'Disabled'
	      State = 'Stopped'
      }
      Service SysMain
      {
	      Name = 'SysMain'
	      StartupType = 'Disabled'
	      State = 'Stopped'
      }
      Service ALG
      {
	      Name = 'ALG'
	      StartupType = 'Disabled'
	      State = 'Stopped'
      }
      Service Browser
      {
	      Name = 'Browser'
	      StartupType = 'Disabled'
	      State = 'Stopped'
      }
      Service DPS
      {
	      Name = 'DPS'
	      StartupType = 'Disabled'
	      State = 'Stopped'
      }
      Service defragsvc
      {
	      Name = 'defragsvc'
	      StartupType = 'Disabled'
	      State = 'Stopped'
      }
      Service TrkWks
      {
	      Name = 'TrkWks'
	      StartupType = 'Disabled'
	      State = 'Stopped'
      }
      Service EFS
      {
	      Name = 'EFS'
	      StartupType = 'Disabled'
	      State = 'Stopped'
      }
      Service fdPHost
      {
	      Name = 'fdPHost'
	      StartupType = 'Disabled'
	      State = 'Stopped'
      }
      Service msiscsi
      {
	      Name = 'msiscsi'
	      StartupType = 'Disabled'
	      State = 'Stopped'
      }
      Service swprv
      {
	      Name = 'swprv'
	      StartupType = 'Disabled'
	      State = 'Stopped'
      }
      Service ShellHWDetection
      {
	      Name = 'ShellHWDetection'
	      StartupType = 'Disabled'
	      State = 'Stopped'
      }
      Service SNMPTRAP
      {
	      Name = 'SNMPTRAP'
	      StartupType = 'Disabled'
	      State = 'Stopped'
      }
      Service SSDPSRV
      {
	      Name = 'SSDPSRV'
	      StartupType = 'Disabled'
	      State = 'Stopped'
      }
      Service TabletInputService
      {
	      Name = 'TabletInputService'
	      StartupType = 'Disabled'
	      State = 'Stopped'
      }
      Service TapiSrv
      {
	      Name = 'TapiSrv'
	      StartupType = 'Disabled'
	      State = 'Stopped'
      }
      Service upnphost
      {
	      Name = 'upnphost'
	      StartupType = 'Disabled'
	      State = 'Stopped'
      }
      Service WcsPlugInService
      {
	      Name = 'WcsPlugInService'
	      StartupType = 'Disabled'
	      State = 'Stopped'
      }
      Service WerSvc
      {
	      Name = 'WerSvc'
	      StartupType = 'Disabled'
	      State = 'Stopped'
      }
#endregion
#region Customizing Registry
      Registry fPromptForPassword_ICA-Tcp
      {
        #Always prompt client for password upon connection
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-Tcp'
        ValueName = 'fPromptForPassword'
        Force =$true
        ValueData = '0'
        ValueType = 'DWORD'
      }
      Registry fInheritMaxDisconnectionTime_ICA-Tcp
      {
        #Timeout settings for disconnection
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-Tcp'
        ValueName = 'fInheritMaxDisconnectionTime'
        Force =$true
        ValueData = '0'
        ValueType = 'DWORD'
      }
      Registry MaxDisconnectionTime_ICA-Tcp
      {
        #Maximum disconnection time (msec, 0 = unlimited)
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-Tcp'
        ValueName = 'MaxDisconnectionTime'
        Force =$true
        ValueData = '43200000'
        ValueType = 'DWORD'
      }
      Registry fInheritMaxIdleTime_ICA-Tcp
      {
        #Timeout settings for idle time
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-Tcp'
        ValueName = 'fInheritMaxIdleTime'
        Force =$true
        ValueData = '0'
        ValueType = 'DWORD'
      }
      Registry MaxIdleTime_ICA-Tcp
      {
        #Maximum idle time (msec, 0 = unlimited)
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-Tcp'
        ValueName = 'MaxIdleTime'
        Force =$true
        ValueData = '172800000'
        ValueType = 'DWORD'
      }
      Registry fDisableExe_ICA-Tcp
      {
        #Run only published applications
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-Tcp'
        ValueName = 'fDisableExe'
        Force =$true
        ValueData = '1'
        ValueType = 'DWORD'
      }
      Registry fPromptForPassword_RDP-Tcp
      {
        #Always prompt client for password upon connection
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'
        ValueName = 'fPromptForPassword'
        Force =$true
        ValueData = '0'
        ValueType = 'DWORD'
      }
      Registry fInheritMaxDisconnectionTime_RDP-Tcp
      {
        #Timeout settings for disconnection
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'
        ValueName = 'fInheritMaxDisconnectionTime'
        Force =$true
        ValueData = '0'
        ValueType = 'DWORD'
      }
      Registry MaxDisconnectionTime_RDP-Tcp
      {
        #Maximum disconnection time (msec, 0 = unlimited)
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'
        ValueName = 'MaxDisconnectionTime'
        Force =$true
        ValueData = '43200000'
        ValueType = 'DWORD'
      }
      Registry fInheritMaxIdleTime_RDP-Tcp
      {
        #Timeout settings for idle time
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'
        ValueName = 'fInheritMaxIdleTime'
        Force =$true
        ValueData = '0'
        ValueType = 'DWORD'
      }
      Registry MaxIdleTime_RDP-Tcp
      {
        #Maximum idle time (msec, 0 = unlimited)
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'
        ValueName = 'MaxIdleTime'
        Force =$true
        ValueData = '172800000'
        ValueType = 'DWORD'
      }
      Registry fDisableExe_RDP-Tcp
      {
        #Run only published applications
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'
        ValueName = 'fDisableExe'
        Force =$true
        ValueData = '1'
        ValueType = 'DWORD'
      }
      Registry fPromptForPassword_ICA-CGP
      {
        #Always prompt client for password upon connection
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-CGP'
        ValueName = 'fPromptForPassword'
        Force =$true
        ValueData = '0'
        ValueType = 'DWORD'
      }
      Registry fInheritMaxDisconnectionTime_ICA-CGP
      {
        #Timeout settings for disconnection
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-CGP'
        ValueName = 'fInheritMaxDisconnectionTime'
        Force =$true
        ValueData = '0'
        ValueType = 'DWORD'
      }
      Registry MaxDisconnectionTime_ICA-CGP
      {
        #Maximum disconnection time (msec, 0 = unlimited)
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-CGP'
        ValueName = 'MaxDisconnectionTime'
        Force =$true
        ValueData = '43200000'
        ValueType = 'DWORD'
      }
      Registry fInheritMaxIdleTime_ICA-CGP
      {
        #Timeout settings for idle time
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-CGP'
        ValueName = 'fInheritMaxIdleTime'
        Force =$true
        ValueData = '0'
        ValueType = 'DWORD'
      }
      Registry MaxIdleTime_ICA-CGP
      {
        #Maximum idle time (msec, 0 = unlimited)
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-CGP'
        ValueName = 'MaxIdleTime'
        Force =$true
        ValueData = '172800000'
        ValueType = 'DWORD'
      }
      Registry fDisableExe_ICA-CGP
      {
        #Run only published applications
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-CGP'
        ValueName = 'fDisableExe'
        Force =$true
        ValueData = '1'
        ValueType = 'DWORD'
      }
      Registry fPromptForPassword_ICA-CGP-1
      {
        #Always prompt client for password upon connection
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-CGP-1'
        ValueName = 'fPromptForPassword'
        Force =$true
        ValueData = '0'
        ValueType = 'DWORD'
      }
      Registry fInheritMaxDisconnectionTime_ICA-CGP-1
      {
        #Timeout settings for disconnection
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-CGP-1'
        ValueName = 'fInheritMaxDisconnectionTime'
        Force =$true
        ValueData = '0'
        ValueType = 'DWORD'
      }
      Registry MaxDisconnectionTime_ICA-CGP-1
      {
        #Maximum disconnection time (msec, 0 = unlimited)
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-CGP-1'
        ValueName = 'MaxDisconnectionTime'
        Force =$true
        ValueData = '43200000'
        ValueType = 'DWORD'
      }
      Registry fInheritMaxIdleTime_ICA-CGP-1
      {
        #Timeout settings for idle time
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-CGP-1'
        ValueName = 'fInheritMaxIdleTime'
        Force =$true
        ValueData = '0'
        ValueType = 'DWORD'
      }
      Registry MaxIdleTime_ICA-CGP-1
      {
        #Maximum idle time (msec, 0 = unlimited)
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-CGP-1'
        ValueName = 'MaxIdleTime'
        Force =$true
        ValueData = '172800000'
        ValueType = 'DWORD'
      }
      Registry fDisableExe_ICA-CGP-1
      {
        #Run only published applications
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-CGP-1'
        ValueName = 'fDisableExe'
        Force =$true
        ValueData = '1'
        ValueType = 'DWORD'
      }
      Registry fPromptForPassword_ICA-CGP-2
      {
        #Always prompt client for password upon connection
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-CGP-2'
        ValueName = 'fPromptForPassword'
        Force =$true
        ValueData = '0'
        ValueType = 'DWORD'
      }
      Registry fInheritMaxDisconnectionTime_ICA-CGP-2
      {
        #Timeout settings for disconnection
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-CGP-2'
        ValueName = 'fInheritMaxDisconnectionTime'
        Force =$true
        ValueData = '0'
        ValueType = 'DWORD'
      }
      Registry MaxDisconnectionTime_ICA-CGP-2
      {
        #Maximum disconnection time (msec, 0 = unlimited)
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-CGP-2'
        ValueName = 'MaxDisconnectionTime'
        Force =$true
        ValueData = '43200000'
        ValueType = 'DWORD'
      }
      Registry fInheritMaxIdleTime_ICA-CGP-2
      {
        #Timeout settings for idle time
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-CGP-2'
        ValueName = 'fInheritMaxIdleTime'
        Force =$true
        ValueData = '0'
        ValueType = 'DWORD'
      }
      Registry MaxIdleTime_ICA-CGP-2
      {
        #Maximum idle time (msec, 0 = unlimited)
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-CGP-2'
        ValueName = 'MaxIdleTime'
        Force =$true
        ValueData = '172800000'
        ValueType = 'DWORD'
      }
      Registry fDisableExe_ICA-CGP-2
      {
        #Run only published applications
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-CGP-2'
        ValueName = 'fDisableExe'
        Force =$true
        ValueData = '1'
        ValueType = 'DWORD'
      }
      Registry fPromptForPassword_ICA-CGP-3
      {
        #Always prompt client for password upon connection
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-CGP-3'
        ValueName = 'fPromptForPassword'
        Force =$true
        ValueData = '0'
        ValueType = 'DWORD'
      }
      Registry fInheritMaxDisconnectionTime_ICA-CGP-3
      {
        #Timeout settings for disconnection
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-CGP-3'
        ValueName = 'fInheritMaxDisconnectionTime'
        Force =$true
        ValueData = '0'
        ValueType = 'DWORD'
      }
      Registry MaxDisconnectionTime_ICA-CGP-3
      {
        #Maximum disconnection time (msec, 0 = unlimited)
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-CGP-3'
        ValueName = 'MaxDisconnectionTime'
        Force =$true
        ValueData = '43200000'
        ValueType = 'DWORD'
      }
      Registry fInheritMaxIdleTime_ICA-CGP-3
      {
        #Timeout settings for idle time
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-CGP-3'
        ValueName = 'fInheritMaxIdleTime'
        Force =$true
        ValueData = '0'
        ValueType = 'DWORD'
      }
      Registry MaxIdleTime_ICA-CGP-3
      {
        #Maximum idle time (msec, 0 = unlimited)
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-CGP-3'
        ValueName = 'MaxIdleTime'
        Force =$true
        ValueData = '172800000'
        ValueType = 'DWORD'
      }
      Registry fDisableExe_ICA-CGP-3
      {
        #Run only published applications
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-CGP-3'
        ValueName = 'fDisableExe'
        Force =$true
        ValueData = '1'
        ValueType = 'DWORD'
      }
      Registry fPromptForPassword_ICA-HTML5
      {
        #Always prompt client for password upon connection
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-HTML5'
        ValueName = 'fPromptForPassword'
        Force =$true
        ValueData = '0'
        ValueType = 'DWORD'
      }
      Registry fInheritMaxDisconnectionTime_ICA-HTML5
      {
        #Timeout settings for disconnection
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-HTML5'
        ValueName = 'fInheritMaxDisconnectionTime'
        Force =$true
        ValueData = '0'
        ValueType = 'DWORD'
      }
      Registry MaxDisconnectionTime_ICA-HTML5
      {
        #Maximum disconnection time (msec, 0 = unlimited)
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-HTML5'
        ValueName = 'MaxDisconnectionTime'
        Force =$true
        ValueData = '43200000'
        ValueType = 'DWORD'
      }
      Registry fInheritMaxIdleTime_ICA-HTML5
      {
        #Timeout settings for idle time
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-HTML5'
        ValueName = 'fInheritMaxIdleTime'
        Force =$true
        ValueData = '0'
        ValueType = 'DWORD'
      }
      Registry MaxIdleTime_ICA-HTML5
      {
        #Maximum idle time (msec, 0 = unlimited)
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-HTML5'
        ValueName = 'MaxIdleTime'
        Force =$true
        ValueData = '172800000'
        ValueType = 'DWORD'
      }
      Registry fDisableExe_ICA-HTML5
      {
        #Run only published applications
        Ensure = 'Present'
        Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ICA-HTML5'
        ValueName = 'fDisableExe'
        Force =$true
        ValueData = '1'
        ValueType = 'DWORD'
      }
#endregion
#region ScheduleTask
    cScheduleTask ScheduledDefrag
    {
        #Disable Disk Defragmenter Service
        Ensure = "Present"
        TaskName = "ScheduledDefrag"
        TaskPath = "\Microsoft\Windows\Defrag\"
        Disable = $true
    }
    cScheduleTask AitAgent
    {
        #
        Ensure = "Present"
        TaskName = "AitAgent"
        TaskPath = "\microsoft\windows\Application Experience\"
        Disable = $true
    }
    cScheduleTask ProgramDataUpdater
    {
        #
        Ensure = "Present"
        TaskName = "ProgramDataUpdater"
        TaskPath = "\microsoft\windows\Application Experience\"
        Disable = $true
    }
    cScheduleTask Proxy
    {
        #
        Ensure = "Present"
        TaskName = "Proxy"
        TaskPath = "\microsoft\windows\Autochk\"
        Disable = $true
    }
    cScheduleTask Consolidator
    {
        #
        Ensure = "Present"
        TaskName = "Consolidator"
        TaskPath = "\microsoft\windows\Customer Experience Improvement Program\"
        Disable = $true
    }
    cScheduleTask KernelCeipTask
    {
        #
        Ensure = "Present"
        TaskName = "KernelCeipTask"
        TaskPath = "\microsoft\windows\Customer Experience Improvement Program\"
        Disable = $true
    }
    cScheduleTask UsbCeip
    {
        #
        Ensure = "Present"
        TaskName = "UsbCeip"
        TaskPath = "\microsoft\windows\Customer Experience Improvement Program\"
        Disable = $true
    }
    cScheduleTask Microsoft-Windows-DiskDiagnosticDataCollector
    {
        #
        Ensure = "Present"
        TaskName = "Microsoft-Windows-DiskDiagnosticDataCollector"
        TaskPath = "\microsoft\windows\DiskDiagnostic\"
        Disable = $true
    }
    cScheduleTask Microsoft-Windows-DiskDiagnosticResolver
    {
        #
        Ensure = "Present"
        TaskName = "Microsoft-Windows-DiskDiagnosticResolver"
        TaskPath = "\microsoft\windows\DiskDiagnostic\"
        Disable = $true
    }
    cScheduleTask AnalyzeSystem
    {
        #
        Ensure = "Present"
        TaskName = "AnalyzeSystem"
        TaskPath = "\microsoft\windows\Power Efficiency Diagnostics\"
        Disable = $true
    }
    cScheduleTask RacTask
    {
        #
        Ensure = "Present"
        TaskName = "RacTask"
        TaskPath = "\microsoft\windows\RAC\"
        Disable = $true
    }
    cScheduleTask MobilityManager
    {
        #
        Ensure = "Present"
        TaskName = "MobilityManager"
        TaskPath = "\microsoft\windows\Ras\"
        Disable = $true
    }
    cScheduleTask RegIdleBackup
    {
        #
        Ensure = "Present"
        TaskName = "RegIdleBackup"
        TaskPath = "\microsoft\windows\Registry\"
        Disable = $true
    }
    cScheduleTask ResolutionHost
    {
        #
        Ensure = "Present"
        TaskName = "ResolutionHost"
        TaskPath = "\microsoft\windows\WDI\"
        Disable = $true
    }
    cScheduleTask BfeOnServiceStartTypeChange
    {
        #
        Ensure = "Present"
        TaskName = "BfeOnServiceStartTypeChange"
        TaskPath = "\microsoft\windows\Windows Filtering Platform\"
        Disable = $true
    }
    cScheduleTask Maintenance_Configurator
    {
        #http://www.petri.com/windows-server-2012-disable-automatic-maintenance-using-psexec.htm
        Ensure = "Present"
        TaskName = "Maintenance Configurator"
        TaskPath = "\Microsoft\Windows\TaskScheduler\"
        Disable = $true
    }
#endregion
    }

    if ($roles -contains 'Database') {
      File dbFlag
      {
          DestinationPath = 'C:\DscFile.txt'
          Contents        = $OctopusParameters['Stage']
      }
    }
  }
}
