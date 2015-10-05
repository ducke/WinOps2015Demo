configuration DemoConfiguration {
  param (
    [Parameter(Mandatory)]
    [System.Collections.IDictionary] $OctopusParameters
  )

  #Import-DscResource -ModuleName cPSDesiredStateConfiguration
  Import-DscResource -ModuleName PSDesiredStateConfiguration

  node localhost {
    $roles = $OctopusParameters['Octopus.Machine.Roles'] -split ','

    write $roles

    if ($roles -contains 'XenAppSessionHost') {
<#      WindowsFeature AspNetFramework
      {
        Name = 'AS-Net-Framework'
        Ensure = 'Present'
      }
#>
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

      Registry CryptoSignMenu
      {
        #http://support.microsoft.com/kb/829700/EN-US
        Ensure = 'Present'
        Key = 'HKCR:\*\shellex\PropertySheetHandlers\CryptoSignMenu'
        ValueName = 'SuppressionPolicy'
        Force = $true
        ValueData = '65536'
        ValueType = 'Dword'
      }
      Registry KB829700_SuppressionPolicy
      {
        #http://support.microsoft.com/kb/829700/EN-US
        Ensure = 'Present'
        Key = 'HKCR:\*\shellex\PropertySheetHandlers\{3EA48300-8CF6-101B-84FB-666CCB9BCD32}'
        ValueName = 'SuppressionPolicy'
        Force = $true
        ValueData = '65536'
        ValueType = 'Dword'
      }
      Registry KB829700_SuppressionPolicy_2
      {
        Ensure = 'Present'
        Key = 'HKCR:\*\shellex\PropertySheetHandlers\{883373C3-BF89-11D1-BE35-080036B11A03}'
        ValueName = 'SuppressionPolicy'
        Force = $true
        ValueData = '65536'
        ValueType = 'Dword'
      }
      Registry KB834350_InfoCacheLevel
      {
        #http://support.microsoft.com/kb/834350/en-us
        Ensure = 'Present'
        Key = 'HKLM:\System\CurrentControlSet\Services\MRXSmb\Parameters'
        ValueName = 'InfoCacheLevel'
        Force = $true
        ValueData = '16'
        ValueType = 'Dword'
    }
    Registry KB296264_OplocksDisabled
    {
      #http://support.microsoft.com/kb/296264/en-us
      Ensure = 'Present'
      Key = 'HKLM:\System\CurrentControlSet\Services\MRXSmb\Parameters'
      ValueName = 'OplocksDisabled'
      Force = $true
      ValueData = '1'
      ValueType = 'Dword'
    }
    Registry KB306850_SafeDllSearchMode
    {
      #http://support.microsoft.com/kb/306850/EN-US
      Ensure = 'Present'
      Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager'
      ValueName = 'SafeDllSearchMode'
      Force = $true
      ValueData = '1'
      ValueType = 'Dword'
    }
    Registry KB905890_SafeProcessSearchMode
    {
      #http://support.microsoft.com/kb/905890/en-us
      Ensure = 'Present'
      Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager'
      ValueName = 'SafeProcessSearchMode'
      Force = $true
      ValueData = '1'
      ValueType = 'Dword'
    }
    Registry RegistryLazyFlushInterval
    {
      Ensure = 'Present'
      Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager'
      ValueName = 'RegistryLazyFlushInterval'
      Force = $true
      ValueData = '30'
      ValueType = 'Dword'
    }
    Registry DisablePagingExecutive
    {
      Ensure = 'Present'
      Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management'
      ValueName = 'DisablePagingExecutive'
      Force = $true
      ValueData = '1'
      ValueType = 'Dword'
    }
    Registry UseOpportunisticLocking
    {
      #Disables Opportunistic Locking
      Ensure = 'Present'
      Key = 'HKLM:\SYSTEM\CurrentControlSet\Services\Lanmanworkstation\Parameters'
      ValueName = 'UseOpportunisticLocking'
      Force = $true
      ValueData = '0'
      ValueType = 'Dword'
    }
    Registry MaxCmds
    {
      Ensure = 'Present'
      Key = 'HKLM:\SYSTEM\CurrentControlSet\Services\Lanmanworkstation\Parameters'
      ValueName = 'MaxCmds'
      Force = $true
      ValueData = '800'
      ValueType = 'Dword'
    }
    Registry MaxThreads
    {
      Ensure = 'Present'
      Key = 'HKLM:\SYSTEM\CurrentControlSet\Services\Lanmanworkstation\Parameters'
      ValueName = 'MaxThreads'
      Force = $true
      ValueData = '11'
      ValueType = 'Dword'
    }
    Registry KeepAliveTime
    {
      #Determines how often TCP sends keep-alive transmissions
      #http://technet.microsoft.com/en-us/library/cc957549.aspx
      Ensure = 'Present'
      Key = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\parameters'
      ValueName = 'KeepAliveTime'
      Force = $true
      ValueData = '180000'
      ValueType = 'Dword'
    }
    Registry KeepAliveInterval
    {
      #Determines how often TCP repeats keep-alive transmissions when no response is received
      #http://technet.microsoft.com/en-us/library/cc957548.aspx
      Ensure = 'Present'
      Key = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\parameters'
      ValueName = 'KeepAliveInterval'
      Force = $true
      ValueData = '100'
      ValueType = 'Dword'
    }
    Registry TcpMaxDataRetransmissions
    {
      #Determines how many times TCP retransmits an unacknowledged data segment on an existing connection
      #http://technet.microsoft.com/en-us/library/cc938210.aspx
      Ensure = 'Present'
      Key = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\parameters'
      ValueName = 'TcpMaxDataRetransmissions'
      Force = $true
      ValueData = '10'
      ValueType = 'Dword'
    }
    Registry DeletePosix
    {
      Ensure = 'Absent'
      Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\SubSystems'
      ValueName = 'Posix'
      Force = $true
    }
    Registry DeleteRemoteAccessPerf
    {
      Ensure = 'Absent'
      Key = 'HKLM:\SYSTEM\CurrentControlSet\Services\RemoteAccess\Performance'
      ValueName = ''
      Force = $true
    }

    Service MSDTC
    {
      Name = 'MSDTC'
      StartupType = 'Automatic'
      State = 'Stopped'
    }
    Service HidServ
    {
      Name = 'HidServ'
      StartupType = 'Disabled'
      State = 'Stopped'
    }
    Service ALG
    {
      Name = 'ALG'
      StartupType = 'Disabled'
      State = 'Stopped'
    }
    Service sacsvr
    {
      Name = 'sacsvr'
      StartupType = 'Disabled'
      State = 'Stopped'
    }
    Service swprv
    {
      Name = 'swprv'
      StartupType = 'Disabled'
      State = 'Stopped'
    }
    Service RasMan
    {
      Name = 'RasMan'
      StartupType = 'Disabled'
      State = 'Stopped'
    }
    Service RemoteAccess
    {
      Name = 'RemoteAccess'
      StartupType = 'Disabled'
      State = 'Stopped'
    }
    Service Rpclocator
    {
      Name = 'Rpclocator'
      StartupType = 'Disabled'
      State = 'Stopped'
    }
    Service ShellHWDetection
    {
      Name = 'ShellHWDetection'
      StartupType = 'Disabled'
      State = 'Stopped'
    }
    Service SCardSvr
    {
      Name = 'SCardSvr'
      StartupType = 'Disabled'
      State = 'Stopped'
    }
    Service TapiSrv
    {
      Name = 'TapiSrv'
      StartupType = 'Disabled'
      State = 'Stopped'
    }
    Service TrkWks
    {
      Name = 'TrkWks'
      StartupType = 'Disabled'
      State = 'Stopped'
    }
    Service RasAuto
    {
      Name = 'RasAuto'
      StartupType = 'Disabled'
      State = 'Stopped'
    }
    Service VSS
    {
      Name = 'VSS'
      StartupType = 'Disabled'
      State = 'Stopped'
    }
    Service WebClient
    {
      Name = 'WebClient'
      StartupType = 'Disabled'
      State = 'Stopped'
    }
    Service AudioSrv
    {
      Name = 'AudioSrv'
      StartupType = 'Disabled'
      State = 'Stopped'
    }
    Service stisvc
    {
      Name = 'stisvc'
      StartupType = 'Disabled'
      State = 'Stopped'
    }
    Service SharedAccess
    {
      Name = 'SharedAccess'
      StartupType = 'Disabled'
      State = 'Stopped'
    }
    Service WinHttpAutoProxySvc
    {
      Name = 'WinHttpAutoProxySvc'
      StartupType = 'Disabled'
      State = 'Stopped'
    }
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
