if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    if ($PSCommandPath) {
        Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
        Exit
    } else {
        Write-Host ""
        Write-Host "  [!] BirdyOS requires Administrator rights." -ForegroundColor Red
        Write-Host "  [!] Please re-open PowerShell as Administrator and run again." -ForegroundColor Red
        Write-Host ""
        Start-Sleep -Seconds 5
        Exit
    }
}

$winBuild = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentBuild
if ([int]$winBuild -lt 22631) {
    Write-Host ""
    Write-Host "  [!] Warning: BirdyOS is designed for Windows 11 23H2 (build 22631) or newer." -ForegroundColor DarkYellow
    Write-Host "  Detected build: $winBuild - some tweaks may not apply correctly." -ForegroundColor DarkGray
    Write-Host "  For best results use 23H2 (22631) or 24H2 (26100)." -ForegroundColor DarkGray
    Write-Host ""
    Start-Sleep -Seconds 2
}

$script:LogPath = if ($PSScriptRoot) { "$PSScriptRoot\BirdyOS-Log.txt" } else { "$env:TEMP\BirdyOS-Log.txt" }
Start-Transcript -Path $script:LogPath -Append -Force | Out-Null

function Show-Logo {
    Clear-Host
    Write-Host ""
    Write-Host "  ____  _         _       ____  ____  " -ForegroundColor Cyan
    Write-Host " | __ )(_)_ __ __| |_   _/ __ \/ ___| " -ForegroundColor Cyan
    Write-Host " |  _ \| | '__/ _' | | | | |  | \___ \ " -ForegroundColor Cyan
    Write-Host " | |_) | | | | (_| | |_| | |__| |___) |" -ForegroundColor Cyan
    Write-Host " |____/|_|_|  \__,_|\__, |\____/|____/ " -ForegroundColor Cyan
    Write-Host "                    |___/               " -ForegroundColor Cyan
    Write-Host ""
    Write-Host " Version 0.1 - Test Build" -ForegroundColor DarkGray
    Write-Host ""
}

function Set-RegKey($path, $name, $value, $type = 'DWORD') {
    try {
        if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
        New-ItemProperty -Path $path -Name $name -PropertyType $type -Value $value -Force | Out-Null
        Write-Host "  SET  $name" -ForegroundColor DarkGray
    } catch {
        Write-Host "  FAIL $name" -ForegroundColor Red
    }
}

function Remove-RegKey($path, $name) {
    try {
        Remove-ItemProperty -Path $path -Name $name -Force -ErrorAction Stop | Out-Null
        Write-Host "  DEL  $name" -ForegroundColor DarkGray
    } catch {
        Write-Host "  SKIP $name (not found)" -ForegroundColor DarkGray
    }
}

$script:SilentMode = $false

function Show-Done {
    Write-Host ""
    Write-Host "  [+] Done." -ForegroundColor Green
    Write-Host "  [*] Some changes require a restart to fully apply." -ForegroundColor DarkYellow
    Write-Host ""
    if (-not $script:SilentMode) { Start-Sleep -Seconds 1 }
}

function Disable-DataCollection {
    Write-Host ""
    Write-Host "  Disabling Data Collection..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'AllowTelemetry' 0
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'AllowTelemetry' 0
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection' 'AllowTelemetry' 0
    Set-RegKey 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection' 'AllowTelemetry' 0
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\PolicyManager\default\System\AllowTelemetry' 'value' 0
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CPSS\DevicePolicy\AllowTelemetry' 'DefaultValue' 0
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CPSS\Store\AllowTelemetry' 'Value' 0
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'AllowCommercialDataPipeline' 0
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'AllowDeviceNameInTelemetry' 0
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'DisableEnterpriseAuthProxy' 1
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'MicrosoftEdgeDataOptIn' 0
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'DisableTelemetryOptInChangeNotification' 1
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'DisableTelemetryOptInSettingsUx' 1
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'DoNotShowFeedbackNotifications' 1
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'LimitDiagnosticLogCollection' 1
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'LimitDumpCollection' 1
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'AllowBuildPreview' 0
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'LimitEnhancedDiagnosticDataWindowsAnalytics' 0
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds' 'EnableConfigFlighting' 0
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\System' 'AllowExperimentation' 0
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat' 'AITEnable' 0
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat' 'DisableUAR' 1
    Show-Done
}

function Disable-CEIP {
    Write-Host ""
    Write-Host "  Disabling CEIP..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\Software\Policies\Microsoft\SQMClient\Windows' 'CEIPEnable' 0
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\AppV\CEIP' 'CEIPEnable' 0
    Set-RegKey 'HKLM:\Software\Policies\Microsoft\Internet Explorer\SQM' 'DisableCustomerImprovementProgram' 1
    Set-RegKey 'HKLM:\Software\Policies\Microsoft\Messenger\Client' 'CEIP' 2
    Set-RegKey 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\UnattendSettings\SQMClient' 'CEIPEnabled' 0
    Show-Done
}

function Disable-ErrorReporting {
    Write-Host ""
    Write-Host "  Disabling Windows Error Reporting..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting' 'Disabled' 1
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting' 'LoggingDisabled' 1
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting' 'DontSendAdditionalData' 1
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting' 'DontShowUI' 1
    Set-RegKey 'HKLM:\Software\Microsoft\Windows\Windows Error Reporting\Consent' 'DefaultConsent' 0
    Set-RegKey 'HKLM:\Software\Microsoft\Windows\Windows Error Reporting\Consent' 'DefaultOverrideBehavior' 1
    Show-Done
}

function Disable-WMIAutologgers {
    Write-Host ""
    Write-Host "  Disabling WMI Autologgers..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SYSTEM\ControlSet001\Control\WMI\Autologger\Diagtrack-Listener' 'Start' 0
    Set-RegKey 'HKLM:\SYSTEM\ControlSet001\Control\WMI\Autologger\SQMLogger' 'Start' 0
    Set-RegKey 'HKLM:\SYSTEM\ControlSet001\Control\WMI\Autologger\SetupPlatformTel' 'Start' 0
    Show-Done
}

function Disable-AllTelemetry {
    Disable-DataCollection
    Disable-CEIP
    Disable-ErrorReporting
    Disable-WMIAutologgers
}

function Show-Telemetry {
    while ($true) {
        Show-Logo
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host "           TELEMETRY              " -ForegroundColor White
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host ""
        Write-Host "  [1]  Disable Data Collection" -ForegroundColor Yellow
        Write-Host "  [2]  Disable CEIP" -ForegroundColor Yellow
        Write-Host "  [3]  Disable Error Reporting" -ForegroundColor Yellow
        Write-Host "  [4]  Disable WMI Autologgers" -ForegroundColor Yellow
        Write-Host "  [A]  Run All" -ForegroundColor Cyan
        Write-Host "  [0]  Back" -ForegroundColor Red
        Write-Host ""
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host ""
        $choice = Read-Host "  Select an option"
        switch ($choice.ToUpper()) {
            '1' { Disable-DataCollection }
            '2' { Disable-CEIP }
            '3' { Disable-ErrorReporting }
            '4' { Disable-WMIAutologgers }
            'A' { Disable-AllTelemetry }
            '0' { return }
            default { Write-Host ""; Write-Host "  [!] Invalid option, try again" -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}


function Disable-AdvertisingID {
    Write-Host ""
    Write-Host "  Disabling Advertising ID..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo' 'Enabled' 0
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo' 'DisabledByGroupPolicy' 1
    Show-Done
}

function Disable-ActivityHistory {
    Write-Host ""
    Write-Host "  Disabling Activity History..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'EnableActivityFeed' 0
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'PublishUserActivities' 0
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'UploadUserActivities' 0
    Remove-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'AllowClipboardHistory'
    Remove-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'AllowCrossDeviceClipboard'
    Remove-RegKey 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\System' 'AllowClipboardHistory'
    Show-Done
}


function Disable-Recall {
    Write-Host ""
    Write-Host "  Disabling Windows Recall..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'DisableAIDataAnalysis' 1
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'AllowRecallEnablement' 0
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'DisableClickToDo' 1
    Show-Done
}

function Disable-WifiSense {
    Write-Host ""
    Write-Host "  Disabling Wi-Fi Sense..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting' 'value' 0
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots' 'value' 0
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config' 'AutoConnectAllowedOEM' 0
    Show-Done
}

function Disable-VoiceActivation {
    Write-Host ""
    Write-Host "  Disabling Voice Activation..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps' 'AgentActivationEnabled' 0
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps' 'AgentActivationLastUsed' 0
    Show-Done
}

function Disable-AppLaunchTracking {
    Write-Host ""
    Write-Host "  Disabling App Launch Tracking..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_TrackProgs' 0
    Set-RegKey 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\EdgeUI' 'DisableMFUTracking' 1
    Show-Done
}

function Disable-LockScreenCamera {
    Write-Host ""
    Write-Host "  Disabling Lock Screen Camera..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization' 'NoLockScreenCamera' 1
    Show-Done
}

function Show-Privacy {
    while ($true) {
        Show-Logo
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host "          PRIVACY TWEAKS          " -ForegroundColor White
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host ""
        Write-Host "  [1]  Telemetry" -ForegroundColor Yellow
        Write-Host "  [2]  Harden App Permissions" -ForegroundColor Yellow
        Write-Host "  [3]  Block Telemetry via Hosts File" -ForegroundColor Yellow
        Write-Host "  [4]  Disable Advertising ID" -ForegroundColor Yellow
        Write-Host "  [5]  Disable Activity History" -ForegroundColor Yellow
        Write-Host "  [6]  Disable Windows Recall" -ForegroundColor Yellow
        Write-Host "  [7]  Disable Wi-Fi Sense" -ForegroundColor Yellow
        Write-Host "  [8]  Disable Voice Activation" -ForegroundColor Yellow
        Write-Host "  [9]  Disable App Launch Tracking" -ForegroundColor Yellow
        Write-Host "  [10] Disable Lock Screen Camera" -ForegroundColor Yellow
        Write-Host "  [A]  Run All" -ForegroundColor Cyan
        Write-Host "  [0]  Back" -ForegroundColor Red
        Write-Host ""
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host ""
        $choice = Read-Host "  Select an option"
        switch ($choice.ToUpper()) {
            '1'  { Show-Telemetry }
            '2'  { Set-AppPermissions }
            '3'  { Add-HostsTelemetryBlock }
            '4'  { Disable-AdvertisingID }
            '5'  { Disable-ActivityHistory }
            '6'  { Disable-Recall }
            '7'  { Disable-WifiSense }
            '8'  { Disable-VoiceActivation }
            '9'  { Disable-AppLaunchTracking }
            '10' { Disable-LockScreenCamera }
            'A'  {
                Disable-AllTelemetry
                Set-AppPermissions
                Add-HostsTelemetryBlock
                Disable-AdvertisingID
                Disable-ActivityHistory
                Disable-Recall
                Disable-WifiSense
                Disable-VoiceActivation
                Disable-AppLaunchTracking
                Disable-LockScreenCamera
            }
            '0'  { return }
            default { Write-Host ""; Write-Host "  [!] Invalid option, try again" -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}

function Disable-BitLockerEncryption {
    Write-Host ""
    Write-Host "  Disabling BitLocker Auto Encryption..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SYSTEM\ControlSet001\Control\BitLocker' 'PreventDeviceEncryption' 1
    Show-Done
}

function Disable-VBS {
    Write-Host ""
    Write-Host "  Disabling Virtualization Based Security..." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [!] Warning: This disables Credential Guard and HVCI." -ForegroundColor DarkYellow
    Write-Host "  These protect against credential theft and unsigned kernel drivers." -ForegroundColor DarkYellow
    Write-Host "  Only disable if you understand and accept the security tradeoff." -ForegroundColor DarkYellow
    Write-Host ""
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard' 'EnableVirtualizationBasedSecurity' 0
    Set-RegKey 'HKLM:\SYSTEM\Policies\Microsoft\Windows\DeviceGuard' 'HVCIMATRequired' 0
    Set-RegKey 'HKLM:\SYSTEM\ControlSet001\Control\DeviceGuard' 'Locked' 0
    Set-RegKey 'HKLM:\SYSTEM\ControlSet001\Control\DeviceGuard' 'RequirePlatformSecurityFeatures' 0
    Set-RegKey 'HKLM:\SYSTEM\ControlSet001\Control\DeviceGuard' 'EnableVirtualizationBasedSecurity' 0
    Set-RegKey 'HKLM:\SYSTEM\ControlSet001\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity' 'Enabled' 0
    Set-RegKey 'HKLM:\SYSTEM\ControlSet001\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity' 'HVCIMATRequired' 0
    Set-RegKey 'HKLM:\SYSTEM\ControlSet001\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity' 'Locked' 0
    Set-RegKey 'HKLM:\SYSTEM\ControlSet001\Control\Lsa' 'LsaCfgFlags' 0
    Remove-RegKey 'HKLM:\SYSTEM\ControlSet001\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity' 'ChangedInBootCycle'
    Remove-RegKey 'HKLM:\SYSTEM\ControlSet001\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity' 'WasEnabledBy'
    Show-Done
}

function Disable-SecurityNotifications {
    Write-Host ""
    Write-Host "  Disabling Security Notifications..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKCU:\Software\Microsoft\Windows Security Health\State' 'AccountProtection_MicrosoftAccount_Disconnected' 0
    Set-RegKey 'Registry::HKU\.DEFAULT\Software\Microsoft\Windows Security Health\State' 'AccountProtection_MicrosoftAccount_Disconnected' 0
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray' 'HideSystray' 1
    Remove-RegKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' 'SecurityHealth'
    Show-Done
}

function Disable-DefenderReporting {
    Write-Host ""
    Write-Host "  Disabling Defender Reporting..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\Software\Policies\Microsoft\Windows Defender\Reporting' 'DisableGenericRePorts' 1
    Set-RegKey 'HKLM:\Software\Policies\Microsoft\Windows Defender\Signature Updates' 'DisableScheduledSignatureUpdateOnBattery' 1
    Show-Done
}

function Disable-SmartScreen {
    Write-Host ""
    Write-Host "  Disabling SmartScreen..." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [!] Warning: SmartScreen blocks phishing sites and unrecognised executables." -ForegroundColor DarkYellow
    Write-Host "  Disabling it removes a layer of malware protection." -ForegroundColor DarkYellow
    Write-Host ""
    Set-RegKey 'HKLM:\Software\Policies\Microsoft\Windows Defender\SmartScreen' 'ConfigureAppInstallControlEnabled' 1
    Set-RegKey 'HKLM:\Software\Policies\Microsoft\Windows Defender\SmartScreen' 'ConfigureAppInstallControl' 'Anywhere' 'String'
    Set-RegKey 'HKLM:\Software\Policies\Microsoft\MicrosoftEdge\PhishingFilter' 'EnabledV9' 0
    Set-RegKey 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AppHost' 'EnableWebContentEvaluation' 0
    Show-Done
}

function Disable-AllSecurity {
    Disable-BitLockerEncryption
    Disable-VBS
    Disable-SecurityNotifications
    Disable-DefenderReporting
    Disable-SmartScreen
}

function Show-Security {
    while ($true) {
        Show-Logo
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host "          SECURITY TWEAKS         " -ForegroundColor White
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host ""
        Write-Host "  [1]  Disable BitLocker Auto Encryption" -ForegroundColor Yellow
        Write-Host "  [2]  Disable Virtualization Based Security" -ForegroundColor Yellow
        Write-Host "  [3]  Disable Security Notifications" -ForegroundColor Yellow
        Write-Host "  [4]  Disable Defender Reporting" -ForegroundColor Yellow
        Write-Host "  [5]  Disable SmartScreen" -ForegroundColor Yellow
        Write-Host "  [A]  Run All" -ForegroundColor Cyan
        Write-Host "  [0]  Back" -ForegroundColor Red
        Write-Host ""
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host ""
        $choice = Read-Host "  Select an option"
        switch ($choice.ToUpper()) {
            '1' { Disable-BitLockerEncryption }
            '2' { Disable-VBS }
            '3' { Disable-SecurityNotifications }
            '4' { Disable-DefenderReporting }
            '5' { Disable-SmartScreen }
            'A' { Disable-AllSecurity }
            '0' { return }
            default { Write-Host ""; Write-Host "  [!] Invalid option, try again" -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}

function Disable-ContentDelivery {
    Write-Host ""
    Write-Host "  Disabling Content Delivery Manager..." -ForegroundColor Cyan
    Write-Host ""
    $cdm = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
    Set-RegKey $cdm 'ContentDeliveryAllowed' 0
    Set-RegKey $cdm 'FeatureManagementEnabled' 0
    Set-RegKey $cdm 'SubscribedContentEnabled' 0
    Set-RegKey $cdm 'RemediationRequired' 0
    Set-RegKey $cdm 'OemPreInstalledAppsEnabled' 0
    Set-RegKey $cdm 'PreInstalledAppsEnabled' 0
    Set-RegKey $cdm 'PreInstalledAppsEverEnabled' 0
    Set-RegKey $cdm 'SilentInstalledAppsEnabled' 0
    Set-RegKey $cdm 'SubscribedContent-310093Enabled' 0
    Set-RegKey $cdm 'SubscribedContent-338393Enabled' 0
    Set-RegKey $cdm 'SubscribedContent-353694Enabled' 0
    Set-RegKey $cdm 'SubscribedContent-353696Enabled' 0
    Set-RegKey $cdm 'SystemPaneSuggestionsEnabled' 0
    Set-RegKey $cdm 'SubscribedContent-338387Enabled' 0
    Set-RegKey $cdm 'RotatingLockScreenOverlayEnabled' 0
    Set-RegKey $cdm 'SubscribedContent-338388Enabled' 0
    Set-RegKey $cdm 'SubscribedContent-338389Enabled' 0
    Set-RegKey $cdm 'SoftLandingEnabled' 0
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_IrisRecommendations' 0
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer' 'HideRecentlyAddedApps' 1
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Start' 'ShowRecentList' 0
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableWindowsConsumerFeatures' 1
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer' 'HideRecommendedSection' 1
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Start' 'HideRecommendedSection' 1
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_IrisRecommendations' 0
    Set-RegKey 'HKLM:\SYSTEM\Maps' 'AutoUpdateEnabled' 0
    Show-Done
}

function Set-StorageSense {
    Write-Host ""
    Write-Host "  Configuring Storage Sense..." -ForegroundColor Cyan
    Write-Host ""
    $ss = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy'
    Set-RegKey $ss '01' 1
    Set-RegKey $ss '1024' 1
    Set-RegKey $ss '2048' 30
    Set-RegKey $ss '04' 1
    Set-RegKey $ss '32' 0
    Set-RegKey $ss '02' 0
    Set-RegKey $ss '128' 0
    Set-RegKey $ss '08' 0
    Set-RegKey $ss '256' 0
    Show-Done
}

function Disable-ReservedStorage {
    Write-Host ""
    Write-Host "  Disabling Windows Reserved Storage..." -ForegroundColor Cyan
    Write-Host ""
    try {
        Start-Process "DISM.exe" -ArgumentList "/Online /Set-ReservedStorageState /State:Disabled" -Wait -WindowStyle Hidden
        Write-Host "  SET  ReservedStorageState = Disabled" -ForegroundColor DarkGray
    } catch {
        Write-Host "  FAIL ReservedStorage" -ForegroundColor Red
    }
    Show-Done
}

function Disable-ScheduledTelemetry {
    Write-Host ""
    Write-Host "  Disabling Scheduled Telemetry Tasks..." -ForegroundColor Cyan
    Write-Host ""
    $tasks = @(
        '\Microsoft\Windows\Application Experience\PcaPatchDbTask',
        '\Microsoft\Windows\AppxDeploymentClient\UCPD velocity',
        '\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector',
        '\Microsoft\Windows\Customer Experience Improvement Program\Consolidator',
        '\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip',
        '\Microsoft\Windows\Flighting\FeatureConfig\UsageDataReporting',
        '\Microsoft\Windows\Autochk\Proxy',
        '\Microsoft\Windows\Application Experience\StartupAppTask',
        '\Microsoft\Windows\Application Experience\MareBackup',
        '\Microsoft\Windows\Clip\License Validation',
        '\Microsoft\Windows\CloudExperienceHost\CreateObjectTask',
        '\Microsoft\Windows\HelloFace\FODCleanupTask'
    )
    foreach ($task in $tasks) {
        try {
            Disable-ScheduledTask -TaskName ($task.Split('\')[-1]) -TaskPath ($task.Substring(0, $task.LastIndexOf('\')+1)) -ErrorAction Stop | Out-Null
            Write-Host "  SET  Disabled: $($task.Split('\')[-1])" -ForegroundColor DarkGray
        } catch {
            Write-Host "  SKIP $($task.Split('\')[-1]) (not found)" -ForegroundColor DarkGray
        }
    }
    Remove-RegKey 'HKLM:\SYSTEM\CurrentControlSet\Control\Ubpm' 'CriticalMaintenance_UsageDataReporting'
    Show-Done
}

function Hide-SecurityPages {
    Write-Host ""
    Write-Host "  Hiding Unused Windows Security Pages..." -ForegroundColor Cyan
    Write-Host ""
    $base = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center'
    Set-RegKey "$base\Family options" 'UILockdown' 1
    Set-RegKey "$base\Device performance and health" 'UILockdown' 1
    Set-RegKey "$base\Account protection" 'UILockdown' 1
    Show-Done
}

function Optimise-All {
    Disable-ContentDelivery
    Set-StorageSense
    Disable-ReservedStorage
    Disable-ScheduledTelemetry
    Hide-SecurityPages
}

function Show-Optimisations {
    while ($true) {
        Show-Logo
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host "          OPTIMISATIONS           " -ForegroundColor White
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host ""
        Write-Host "  [1]  Disable Content Delivery Manager" -ForegroundColor Yellow
        Write-Host "  [2]  Configure Storage Sense" -ForegroundColor Yellow
        Write-Host "  [3]  Disable Reserved Storage" -ForegroundColor Yellow
        Write-Host "  [4]  Disable Scheduled Telemetry Tasks" -ForegroundColor Yellow
        Write-Host "  [5]  Hide Unused Security Pages" -ForegroundColor Yellow
        Write-Host "  [A]  Run All" -ForegroundColor Cyan
        Write-Host "  [0]  Back" -ForegroundColor Red
        Write-Host ""
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host ""
        $choice = Read-Host "  Select an option"
        switch ($choice.ToUpper()) {
            '1' { Disable-ContentDelivery }
            '2' { Set-StorageSense }
            '3' { Disable-ReservedStorage }
            '4' { Disable-ScheduledTelemetry }
            '5' { Hide-SecurityPages }
            'A' { Optimise-All }
            '0' { return }
            default { Write-Host ""; Write-Host "  [!] Invalid option, try again" -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}

function New-RestorePoint {
    Write-Host ""
    Write-Host "  Creating System Restore Point..." -ForegroundColor Cyan
    Write-Host ""
    try {
        Enable-ComputerRestore -Drive "C:\\" -ErrorAction SilentlyContinue
        Checkpoint-Computer -Description "BirdyOS Restore Point" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        Write-Host "  [+] Restore point created successfully." -ForegroundColor Green
    } catch {
        Write-Host "  FAIL Could not create restore point." -ForegroundColor Red
        Write-Host "  [*] Check that System Protection is enabled for C: in System Properties." -ForegroundColor DarkYellow
    }
    Write-Host ""
    Start-Sleep -Seconds 1
}


function Disable-AnimationsEffects {
    Write-Host ""
    Write-Host "  Disabling Animations and Visual Effects..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKCU:\Control Panel\Desktop' 'MenuShowDelay' 0
    Set-RegKey 'HKCU:\Control Panel\Desktop' 'AutoEndTasks' 1
    Set-RegKey 'HKCU:\Control Panel\Desktop' 'WaitToKillAppTimeout' 2000 'String'
    Set-RegKey 'HKCU:\Control Panel\Desktop' 'HungAppTimeout' 1000 'String'
    Set-RegKey 'HKCU:\Control Panel\Desktop' 'DragFullWindows' 0
    Set-RegKey 'HKCU:\Control Panel\Desktop\WindowMetrics' 'MinAnimate' 0
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' 'VisualFXSetting' 3
    New-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'UserPreferencesMask' -PropertyType Binary -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -Force | Out-Null
    Write-Host "  SET  UserPreferencesMask" -ForegroundColor DarkGray
    Set-RegKey 'HKLM:\SYSTEM\CurrentControlSet\Control' 'WaitToKillServiceTimeout' 2000 'String'
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Serialize' 'StartupDelayInMSec' 0
    Set-RegKey 'HKCU:\Control Panel\Desktop' 'LowLevelHooksTimeout' 1000 'String'
    Show-Done
}

function Disable-SearchIndexing {
    Write-Host ""
    Write-Host "  Disabling Search Indexing..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\Windows Search' 'SetupCompletedSuccessfully' 0
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\Windows Search' 'PreventIndexingOutlook' 1
    try {
        Stop-Service -Name WSearch -Force -ErrorAction Stop
        Set-Service -Name WSearch -StartupType Disabled -ErrorAction Stop
        Write-Host "  SET  WSearch service stopped and disabled" -ForegroundColor DarkGray
    } catch {
        Write-Host "  SKIP WSearch service (not found or already disabled)" -ForegroundColor DarkGray
    }
    Show-Done
}

function Disable-Superfetch {
    Write-Host ""
    Write-Host "  Disabling Superfetch (SysMain)..." -ForegroundColor Cyan
    Write-Host ""
    try {
        Stop-Service -Name SysMain -Force -ErrorAction Stop
        Set-Service -Name SysMain -StartupType Disabled -ErrorAction Stop
        Write-Host "  SET  SysMain stopped and disabled" -ForegroundColor DarkGray
    } catch {
        Write-Host "  SKIP SysMain (not found or already disabled)" -ForegroundColor DarkGray
    }
    Show-Done
}

function Disable-BackgroundApps {
    Write-Host ""
    Write-Host "  Disabling Background Apps..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' 'GlobalUserDisabled' 1
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' 'BackgroundAppGlobalToggle' 0
    Show-Done
}

function Disable-ExplorerAnimations {
    Write-Host ""
    Write-Host "  Disabling Explorer Animations..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarAnimations' 0
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'AnimateMinMax' 0
    Show-Done
}

function Optimize-NTFS {
    Write-Host ""
    Write-Host "  Optimizing NTFS..." -ForegroundColor Cyan
    Write-Host ""
    try { fsutil behavior set disablelastaccess 1 | Out-Null; Write-Host "  SET  DisableLastAccess = 1" -ForegroundColor DarkGray } catch { Write-Host "  FAIL DisableLastAccess" -ForegroundColor Red }
    try { fsutil 8dot3name set 1 | Out-Null; Write-Host "  SET  8dot3name disabled" -ForegroundColor DarkGray } catch { Write-Host "  FAIL 8dot3name" -ForegroundColor Red }
    Show-Done
}

function Set-ForegroundPriority {
    Write-Host ""
    Write-Host "  Prioritizing Foreground Applications..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl' 'Win32PrioritySeparation' 38
    Show-Done
}

function Disable-MemoryPaging {
    Write-Host ""
    Write-Host "  Optimizing Memory Paging..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' 'DisablePagingExecutive' 1
    Set-RegKey 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' 'DisablePageCombining' 1
    Show-Done
}

function Disable-SleepStudy {
    Write-Host ""
    Write-Host "  Disabling Modern Standby SleepStudy..." -ForegroundColor Cyan
    Write-Host ""
    try { & wevtutil.exe set-log "Microsoft-Windows-SleepStudy/Diagnostic" /e:false 2>&1 | Out-Null; Write-Host "  SET  SleepStudy/Diagnostic disabled" -ForegroundColor DarkGray } catch {}
    try { & wevtutil.exe set-log "Microsoft-Windows-Kernel-Processor-Power/Diagnostic" /e:false 2>&1 | Out-Null; Write-Host "  SET  Kernel-Processor-Power/Diagnostic disabled" -ForegroundColor DarkGray } catch {}
    try { & wevtutil.exe set-log "Microsoft-Windows-UserModePowerService/Diagnostic" /e:false 2>&1 | Out-Null; Write-Host "  SET  UserModePowerService/Diagnostic disabled" -ForegroundColor DarkGray } catch {}
    try { Disable-ScheduledTask -TaskName "AnalyzeSystem" -TaskPath "\Microsoft\Windows\Power Efficiency Diagnostics" -ErrorAction Stop | Out-Null; Write-Host "  SET  AnalyzeSystem task disabled" -ForegroundColor DarkGray } catch { Write-Host "  SKIP AnalyzeSystem (not found)" -ForegroundColor DarkGray }
    Show-Done
}

function Set-IFEOPriorities {
    Write-Host ""
    Write-Host "  Deprioritizing Background Processes via IFEO..." -ForegroundColor Cyan
    Write-Host ""
    $ifeoBase = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options'
    $processes = @(
        @{Name='SearchIndexer.exe'; Priority=6},
        @{Name='ctfmon.exe';        Priority=6},
        @{Name='fontdrvhost.exe';   Priority=6}
    )
    foreach ($proc in $processes) {
        $path = "$ifeoBase\$($proc.Name)\PerfOptions"
        Set-RegKey $path 'CpuPriorityClass' $proc.Priority
        Set-RegKey $path 'IoPriority' 0
    }
    Show-Done
}

function Invoke-AllPerformance {
    Disable-AnimationsEffects
    Disable-Superfetch
    Disable-BackgroundApps
    Disable-ExplorerAnimations
    Optimize-NTFS
    Set-ForegroundPriority
    Disable-MemoryPaging
    Disable-SleepStudy
    Set-IFEOPriorities
}

function Show-Performance {
    while ($true) {
        Show-Logo
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host "        PERFORMANCE TWEAKS        " -ForegroundColor White
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host ""
        Write-Host "  [1]  Disable Animations and Visual Effects" -ForegroundColor Yellow
        Write-Host "  [2]  Disable Search Indexing" -ForegroundColor Yellow
        Write-Host "  [3]  Disable Superfetch" -ForegroundColor Yellow
        Write-Host "  [4]  Disable Background Apps" -ForegroundColor Yellow
        Write-Host "  [5]  Disable Explorer Animations" -ForegroundColor Yellow
        Write-Host "  [6]  Optimize NTFS" -ForegroundColor Yellow
        Write-Host "  [7]  Prioritize Foreground Applications" -ForegroundColor Yellow
        Write-Host "  [8]  Optimize Memory Paging" -ForegroundColor Yellow
        Write-Host "  [9]  Disable SleepStudy" -ForegroundColor Yellow
        Write-Host "  [10] Deprioritize Background Processes" -ForegroundColor Yellow
        Write-Host "  [A]  Run All" -ForegroundColor Cyan
        Write-Host "  [0]  Back" -ForegroundColor Red
        Write-Host ""
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host ""
        $choice = Read-Host "  Select an option"
        switch ($choice.ToUpper()) {
            '1' { Disable-AnimationsEffects }
            '2' { Disable-SearchIndexing }
            '3' { Disable-Superfetch }
            '4' { Disable-BackgroundApps }
            '5' { Disable-ExplorerAnimations }
            '6' { Optimize-NTFS }
            '7' { Set-ForegroundPriority }
            '8' { Disable-MemoryPaging }
            '9' { Disable-SleepStudy }
            '10' { Set-IFEOPriorities }
            'A' { Invoke-AllPerformance }
            '0' { return }
            default { Write-Host ""; Write-Host "  [!] Invalid option, try again" -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}

function Disable-BingSearch {
    Write-Host ""
    Write-Host "  Disabling Bing Search..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' 'BingSearchEnabled' 0
    Show-Done
}

function Disable-CloudSearch {
    Write-Host ""
    Write-Host "  Disabling Cloud Search and History..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings' 'IsAADCloudSearchEnabled' 0
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings' 'IsDeviceSearchHistoryEnabled' 0
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings' 'IsMSACloudSearchEnabled' 0
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings' 'SafeSearchMode' 0
    Show-Done
}

function Apply-SearchPolicies {
    Write-Host ""
    Write-Host "  Applying Windows Search Policies..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'ConnectedSearchUseWeb' 0
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'DisableWebSearch' 1
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'AllowSearchToUseLocation' 0
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'EnableDynamicContentInWSB' 0
    Show-Done
}

function Disable-SearchSuggestions {
    Write-Host ""
    Write-Host "  Disabling Online Search Suggestions..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer' 'DisableSearchBoxSuggestions' 1
    Show-Done
}

function Set-SearchIcon {
    Write-Host ""
    Write-Host "  Setting Search Icon on Taskbar..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' 'SearchboxTaskbarMode' 1
    Show-Done
}

function Taskbar-All {
    Disable-BingSearch
    Disable-CloudSearch
    Apply-SearchPolicies
    Disable-SearchSuggestions
    Set-SearchIcon
}

function Show-TaskbarSearch {
    while ($true) {
        Show-Logo
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host "      TASKBAR SEARCH TWEAKS       " -ForegroundColor White
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host ""
        Write-Host "  [1]  Disable Bing Search" -ForegroundColor Yellow
        Write-Host "  [2]  Disable Cloud Search and History" -ForegroundColor Yellow
        Write-Host "  [3]  Apply Windows Search Policies" -ForegroundColor Yellow
        Write-Host "  [4]  Disable Online Search Suggestions" -ForegroundColor Yellow
        Write-Host "  [5]  Set Search Icon on Taskbar" -ForegroundColor Yellow
        Write-Host "  [A]  Run All" -ForegroundColor Cyan
        Write-Host "  [0]  Back" -ForegroundColor Red
        Write-Host ""
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host ""
        $choice = Read-Host "  Select an option"
        switch ($choice.ToUpper()) {
            '1' { Disable-BingSearch }
            '2' { Disable-CloudSearch }
            '3' { Apply-SearchPolicies }
            '4' { Disable-SearchSuggestions }
            '5' { Set-SearchIcon }
            'A' { Taskbar-All }
            '0' { return }
            default { Write-Host ""; Write-Host "  [!] Invalid option, try again" -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}


function Disable-RemoteDesktop {
    Write-Host ""
    Write-Host "  Disabling Remote Desktop..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' 'fDenyTSConnections' 1
    Set-RegKey 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' 'UserAuthentication' 1
    try {
        & netsh advfirewall firewall set rule group="Remote Desktop" new enable=No 2>&1 | Out-Null
        Write-Host "  SET  Remote Desktop firewall rule disabled" -ForegroundColor DarkGray
    } catch { Write-Host "  SKIP Remote Desktop firewall rule" -ForegroundColor DarkGray }
    Show-Done
}

function Disable-PrintSpooler {
    Write-Host ""
    Write-Host "  Disabling Print Spooler..." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [!] This will break shared network printers." -ForegroundColor DarkYellow
    Write-Host ""
    try {
        Stop-Service -Name Spooler -Force -ErrorAction Stop
        Set-Service -Name Spooler -StartupType Disabled -ErrorAction Stop
        Write-Host "  SET  Print Spooler stopped and disabled" -ForegroundColor DarkGray
    } catch {
        Write-Host "  SKIP Spooler (not found or already disabled)" -ForegroundColor DarkGray
    }
    Show-Done
}

function Block-AnonymousSAM {
    Write-Host ""
    Write-Host "  Blocking Anonymous Enumeration of SAM Accounts..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' 'RestrictAnonymousSAM' 1
    Show-Done
}

function Disable-RemoteAssistance {
    Write-Host ""
    Write-Host "  Disabling Remote Assistance..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance' 'fAllowFullControl' 0
    Set-RegKey 'HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance' 'fAllowToGetHelp' 0
    try {
        netsh advfirewall firewall set rule group="Remote Assistance" new enable=No | Out-Null
        Write-Host "  SET  Firewall rule: Remote Assistance disabled" -ForegroundColor DarkGray
    } catch {
        Write-Host "  FAIL Firewall rule: Remote Assistance" -ForegroundColor Red
    }
    Show-Done
}

function Set-MaxPerformancePower {
    Write-Host ""
    Write-Host "  Configuring Power for Maximum Performance..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' 'HiberbootEnabled' 0
    try {
        powercfg.exe /hibernate off
        Write-Host "  SET  Hibernation disabled" -ForegroundColor DarkGray
    } catch {
        Write-Host "  FAIL Hibernation" -ForegroundColor Red
    }
    Show-Done
}

function Disable-NetworkBloat {
    Write-Host ""
    Write-Host "  Disabling Unneeded Network Adapter Bindings..." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [!] Note: ms_server (File and Print Sharing) is excluded." -ForegroundColor DarkYellow
    Write-Host "      Disabling it would break shared drives and network printers." -ForegroundColor DarkYellow
    Write-Host ""
    $components = @('ms_msclient', 'ms_lldp', 'ms_lltdio', 'ms_rspndr')
    foreach ($c in $components) {
        try {
            Disable-NetAdapterBinding -Name "*" -ComponentID $c -ErrorAction Stop
            Write-Host "  SET  Disabled: $c" -ForegroundColor DarkGray
        } catch {
            Write-Host "  SKIP $c (not found)" -ForegroundColor DarkGray
        }
    }
    Show-Done
}

function SecPerf-All {
    Block-AnonymousSAM
    Disable-RemoteAssistance
    Disable-RemoteDesktop
    Set-MaxPerformancePower
    Disable-NetworkBloat
    Disable-PrintSpooler
}

function Show-SecPerf {
    while ($true) {
        Show-Logo
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host "     SECURITY & PERFORMANCE       " -ForegroundColor White
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host ""
        Write-Host "  [1]  Block Anonymous SAM Enumeration" -ForegroundColor Yellow
        Write-Host "  [2]  Disable Remote Assistance" -ForegroundColor Yellow
        Write-Host "  [3]  Disable Remote Desktop" -ForegroundColor Yellow
        Write-Host "  [4]  Set Max Performance Power" -ForegroundColor Yellow
        Write-Host "  [5]  Disable Unneeded Network Bindings" -ForegroundColor Yellow
        Write-Host "  [6]  Disable Print Spooler" -ForegroundColor Yellow
        Write-Host "  [A]  Run All" -ForegroundColor Cyan
        Write-Host "  [0]  Back" -ForegroundColor Red
        Write-Host ""
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host ""
        $choice = Read-Host "  Select an option"
        switch ($choice.ToUpper()) {
            '1' { Block-AnonymousSAM }
            '2' { Disable-RemoteAssistance }
            '3' { Disable-RemoteDesktop }
            '4' { Set-MaxPerformancePower }
            '5' { Disable-NetworkBloat }
            '6' { Disable-PrintSpooler }
            'A' { SecPerf-All }
            '0' { return }
            default { Write-Host ""; Write-Host "  [!] Invalid option, try again" -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}

function Run-Everything {
    $script:SilentMode = $true
    Write-Host ""
    Write-Host "  Running all tweaks..." -ForegroundColor Cyan
    Write-Host ""
    New-RestorePoint
    Disable-AllTelemetry
    Disable-AdvertisingID
    Disable-ActivityHistory
    Disable-Recall
    Disable-WifiSense
    Disable-VoiceActivation
    Disable-AppLaunchTracking
    Disable-LockScreenCamera
    Disable-BitLockerEncryption
    Disable-VBS
    Disable-SecurityNotifications
    Disable-DefenderReporting
    Disable-SmartScreen
    Disable-ContentDelivery
    Set-StorageSense
    Disable-ReservedStorage
    Disable-ScheduledTelemetry
    Hide-SecurityPages
    Invoke-AllPerformance
    Disable-BingSearch
    Disable-CloudSearch
    Apply-SearchPolicies
    Disable-SearchSuggestions
    Set-SearchIcon
    Block-AnonymousSAM
    Disable-RemoteAssistance
    Set-MaxPerformancePower
    Disable-NetworkBloat
    Invoke-AllGaming
    Invoke-AllQoL
    Invoke-AllWindowsUpdate
    Invoke-AllCleanup
    Disable-TaskbarExtras
    Disable-NetworkSecurity
    Disable-TelemetryServices
    Add-HostsTelemetryBlock
    Set-AppPermissions
    Set-OOBETweaks
    Remove-WindowsCapabilities
    Remove-Appx
    Remove-OneDrive
    Write-Host ""
    Write-Host "  [+] All tweaks applied." -ForegroundColor Green
    Write-Host "  [*] A restart is required for all changes to take effect." -ForegroundColor DarkYellow
    Write-Host ""
    $script:SilentMode = $false
    Start-Sleep -Seconds 2
}

function Disable-GameBar {
    Write-Host ""
    Write-Host "  Disabling Game Bar..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKCU:\System\GameConfigStore' 'GameDVR_Enabled' 0
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR' 'AppCaptureEnabled' 0
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\GameBar' 'GamePanelStartupTipIndex' 3
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\GameBar' 'ShowStartupPanel' 0
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\GameBar' 'UseNexusForGameBarEnabled' 0
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR' 'AllowGameDVR' 0
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR' 'value' 0
    Set-RegKey 'HKCU:\Control Panel\Keyboard' 'PrintScreenKeyForSnippingEnabled' 1
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'DisabledHotkeys' 0
    Show-Done
}

function Invoke-AllGaming {
    Disable-GameBar
    Set-GamingTweaks
}

function Show-Gaming {
    while ($true) {
        Show-Logo
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host "          GAMING TWEAKS           " -ForegroundColor White
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host ""
        Write-Host "  [1]  Disable Game Bar" -ForegroundColor Yellow
        Write-Host "  [2]  Advanced Gaming Tweaks" -ForegroundColor Yellow
        Write-Host "  [A]  Run All" -ForegroundColor Cyan
        Write-Host "  [0]  Back" -ForegroundColor Red
        Write-Host ""
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host ""
        $choice = Read-Host "  Select an option"
        switch ($choice.ToUpper()) {
            '1' { Disable-GameBar }
            '2' { Set-GamingTweaks }
            'A' { Invoke-AllGaming }
            '0' { return }
            default { Write-Host ""; Write-Host "  [!] Invalid option, try again" -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}

function Disable-AccessibilitySounds {
    Write-Host ""
    Write-Host "  Disabling Accessibility Sounds..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKCU:\Control Panel\Accessibility' 'Warning Sounds' 0
    Set-RegKey 'HKCU:\Control Panel\Accessibility' 'Sound on Activation' 0
    Set-RegKey 'HKCU:\Control Panel\Accessibility\SoundSentry' 'WindowsEffect' 0 'String'
    Show-Done
}

function Disable-AccessibilityShortcuts {
    Write-Host ""
    Write-Host "  Disabling Accessibility Shortcuts..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKCU:\Control Panel\Accessibility\HighContrast' 'Flags' 0
    Set-RegKey 'HKCU:\Control Panel\Accessibility\Keyboard Response' 'Flags' 0
    Set-RegKey 'HKCU:\Control Panel\Accessibility\MouseKeys' 'Flags' 0
    Set-RegKey 'HKCU:\Control Panel\Accessibility\StickyKeys' 'Flags' 0
    Set-RegKey 'HKCU:\Control Panel\Accessibility\ToggleKeys' 'Flags' 0
    Set-RegKey 'HKCU:\Keyboard Layout\Toggle' 'Layout Hotkey' 3
    Set-RegKey 'HKCU:\Keyboard Layout\Toggle' 'Language Hotkey' 3
    Set-RegKey 'HKCU:\Keyboard Layout\Toggle' 'Hotkey' 3
    Set-RegKey 'HKCU:\Software\Microsoft\Narrator\NoRoam' 'WinEnterLaunchEnabled' 0
    Show-Done
}

function Enable-VerboseStatus {
    Write-Host ""
    Write-Host "  Enabling Verbose Startup and Shutdown Status..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' 'verbosestatus' 1
    Show-Done
}

function Disable-UACSecureDesktop {
    Write-Host ""
    Write-Host "  Disabling UAC Secure Desktop..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' 'PromptOnSecureDesktop' 0
    Show-Done
}

function Disable-MouseAcceleration {
    Write-Host ""
    Write-Host "  Disabling Mouse Acceleration..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKCU:\Control Panel\Mouse' 'MouseSpeed' 0 'String'
    Set-RegKey 'HKCU:\Control Panel\Mouse' 'MouseThreshold1' 0 'String'
    Set-RegKey 'HKCU:\Control Panel\Mouse' 'MouseThreshold2' 0 'String'
    Show-Done
}

function Disable-SpellCheck {
    Write-Host ""
    Write-Host "  Disabling Spell Checking and Autocorrect..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\TabletTip\1.7' 'EnableAutocorrection' 0
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\TabletTip\1.7' 'EnableDoubleTapSpace' 0
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\TabletTip\1.7' 'EnablePredictionSpaceInsertion' 0
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\TabletTip\1.7' 'EnableSpellchecking' 0
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\TabletTip\1.7' 'EnableTextPrediction' 0
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\TabletTip\1.7' 'EnableAutoShiftEngage' 0
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\TabletTip\1.7' 'EnableKeyAudioFeedback' 0
    Show-Done
}

function Disable-WindowsSpotlight {
    Write-Host ""
    Write-Host "  Disabling Windows Spotlight..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableWindowsSpotlightFeatures' 1
    Set-RegKey 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableWindowsSpotlightWindowsWelcomeExperience' 1
    Set-RegKey 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableWindowsSpotlightOnActionCenter' 1
    Set-RegKey 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableWindowsSpotlightOnSettings' 1
    Set-RegKey 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableThirdPartySuggestions' 1
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableSoftLanding' 1
    Show-Done
}

function Disable-WindowsFeedback {
    Write-Host ""
    Write-Host "  Disabling Windows Feedback..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Siuf\Rules' 'NumberOfSIUFInPeriod' 0
    Remove-RegKey 'HKCU:\SOFTWARE\Microsoft\Siuf\Rules' 'PeriodInNanoSeconds'
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection' 'DoNotShowFeedbackNotifications' 1
    Show-Done
}

function Disable-SoundDucking {
    Write-Host ""
    Write-Host "  Disabling Sound Reduction During Calls..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Multimedia\Audio' 'UserDuckingPreference' 3
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Multimedia\Audio\DeviceCpl' 'ShowDisconnectedDevices' 0
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Multimedia\Audio\DeviceCpl' 'ShowHiddenDevices' 0
    Show-Done
}

function Disable-DynamicLighting {
    Write-Host ""
    Write-Host "  Disabling Dynamic Lighting..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKCU:\Software\Microsoft\Lighting' 'AmbientLightingEnabled' 0
    Show-Done
}

function Disable-SettingsTips {
    Write-Host ""
    Write-Host "  Disabling Settings Tips..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Settings\AllowOnlineTips' 'value' 0
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'AllowOnlineTips' 0
    Show-Done
}

function Set-WallpaperQuality {
    Write-Host ""
    Write-Host "  Setting Wallpaper to Full Quality..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKCU:\Control Panel\Desktop' 'JPEGImportQuality' 100
    Show-Done
}

function Disable-TouchFeedback {
    Write-Host ""
    Write-Host "  Disabling Touch Visual Feedback..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKCU:\Control Panel\Cursors' 'GestureVisualization' 0
    Set-RegKey 'HKCU:\Control Panel\Cursors' 'ContactVisualization' 0
    Show-Done
}

function Show-FileExtensions {
    Write-Host ""
    Write-Host "  Showing File Extensions..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'HideFileExt' 0
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Hidden' 1
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowSuperHidden' 0
    Show-Done
}


function Set-ExplorerToThisPC {
    Write-Host ""
    Write-Host "  Setting File Explorer to Open This PC..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'LaunchTo' 1
    Show-Done
}

function Hide-ExplorerHomeGallery {
    Write-Host ""
    Write-Host "  Hiding Explorer Home and Gallery..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKCU:\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}' 'System.IsPinnedToNameSpaceTree' 0
    Remove-RegKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}' '(Default)'
    Show-Done
}

function Disable-SnapAssist {
    Write-Host ""
    Write-Host "  Disabling Snap Assist..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'SnapAssist' 0
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'EnableTaskGroups' 0
    Show-Done
}

function Hide-TaskView {
    Write-Host ""
    Write-Host "  Hiding Task View Button..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowTaskViewButton' 0
    Show-Done
}

function Disable-WidgetsService {
    Write-Host ""
    Write-Host "  Disabling Widgets Service..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Dsh' 'AllowNewsAndInterests' 0
    try {
        Stop-Service -Name 'Widgets' -Force -ErrorAction Stop
        Set-Service -Name 'Widgets' -StartupType Disabled -ErrorAction Stop
        Write-Host "  SET  Widgets service stopped and disabled" -ForegroundColor DarkGray
    } catch {
        Write-Host "  SKIP Widgets service (not found)" -ForegroundColor DarkGray
    }
    Show-Done
}

function Disable-MemoryCompression {
    Write-Host ""
    Write-Host "  Disabling Memory Compression..." -ForegroundColor Cyan
    Write-Host ""
    try {
        Disable-MMAgent -MemoryCompression -ErrorAction Stop
        Write-Host "  SET  Memory compression disabled" -ForegroundColor DarkGray
    } catch {
        Write-Host "  SKIP Memory compression (may require restart)" -ForegroundColor DarkGray
    }
    Show-Done
}

function Invoke-AllQoL {
    Disable-AccessibilitySounds
    Disable-AccessibilityShortcuts
    Enable-VerboseStatus
    Disable-UACSecureDesktop
    Disable-MouseAcceleration
    Disable-SpellCheck
    Disable-WindowsSpotlight
    Disable-WindowsFeedback
    Disable-SoundDucking
    Disable-DynamicLighting
    Disable-SettingsTips
    Set-WallpaperQuality
    Disable-TouchFeedback
    Show-FileExtensions
    Set-ExplorerToThisPC
    Hide-ExplorerHomeGallery
    Disable-SnapAssist
    Hide-TaskView
    Disable-WidgetsService
    Disable-MemoryCompression
}

function Show-QoL {
    while ($true) {
        Show-Logo
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host "           QOL TWEAKS             " -ForegroundColor White
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host ""
        Write-Host "  [1]  Disable Accessibility Sounds" -ForegroundColor Yellow
        Write-Host "  [2]  Disable Accessibility Shortcuts" -ForegroundColor Yellow
        Write-Host "  [3]  Enable Verbose Startup and Shutdown" -ForegroundColor Yellow
        Write-Host "  [4]  Disable UAC Secure Desktop" -ForegroundColor Yellow
        Write-Host "  [5]  Disable Mouse Acceleration" -ForegroundColor Yellow
        Write-Host "  [6]  Disable Spell Check and Autocorrect" -ForegroundColor Yellow
        Write-Host "  [7]  Disable Windows Spotlight" -ForegroundColor Yellow
        Write-Host "  [8]  Disable Windows Feedback" -ForegroundColor Yellow
        Write-Host "  [9]  Disable Sound Reduction During Calls" -ForegroundColor Yellow
        Write-Host "  [10] Disable Dynamic Lighting" -ForegroundColor Yellow
        Write-Host "  [11] Disable Settings Tips" -ForegroundColor Yellow
        Write-Host "  [12] Set Wallpaper to Full Quality" -ForegroundColor Yellow
        Write-Host "  [13] Disable Touch Visual Feedback" -ForegroundColor Yellow
        Write-Host "  [14] Show File Extensions" -ForegroundColor Yellow
        Write-Host "  [15] Open File Explorer to This PC" -ForegroundColor Yellow
        Write-Host "  [16] Hide Explorer Home and Gallery" -ForegroundColor Yellow
        Write-Host "  [17] Disable Snap Assist" -ForegroundColor Yellow
        Write-Host "  [18] Hide Task View Button" -ForegroundColor Yellow
        Write-Host "  [19] Disable Widgets Service" -ForegroundColor Yellow
        Write-Host "  [20] Disable Memory Compression" -ForegroundColor Yellow
        Write-Host "  [A]  Run All" -ForegroundColor Cyan
        Write-Host "  [0]  Back" -ForegroundColor Red
        Write-Host ""
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host ""
        $choice = Read-Host "  Select an option"
        switch ($choice.ToUpper()) {
            '1'  { Disable-AccessibilitySounds }
            '2'  { Disable-AccessibilityShortcuts }
            '3'  { Enable-VerboseStatus }
            '4'  { Disable-UACSecureDesktop }
            '5'  { Disable-MouseAcceleration }
            '6'  { Disable-SpellCheck }
            '7'  { Disable-WindowsSpotlight }
            '8'  { Disable-WindowsFeedback }
            '9'  { Disable-SoundDucking }
            '10' { Disable-DynamicLighting }
            '11' { Disable-SettingsTips }
            '12' { Set-WallpaperQuality }
            '13' { Disable-TouchFeedback }
            '14' { Show-FileExtensions }
            '15' { Set-ExplorerToThisPC }
            '16' { Hide-ExplorerHomeGallery }
            '17' { Disable-SnapAssist }
            '18' { Hide-TaskView }
            '19' { Disable-WidgetsService }
            '20' { Disable-MemoryCompression }
            'A'  { Invoke-AllQoL }
            '0'  { return }
            default { Write-Host ""; Write-Host "  [!] Invalid option, try again" -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}

function Disable-WUAutoReboot {
    Write-Host ""
    Write-Host "  Disabling Windows Update Auto Reboot..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'AUPowerManagement' 0
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' 'NoAutoRebootWithLoggedOnUsers' 1
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' 'NoAUAsDefaultShutdownOption' 1
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings' 'HideMCTLink' 1
    Show-Done
}

function Disable-DeliveryOptimization {
    Write-Host ""
    Write-Host "  Disabling Delivery Optimization..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' 'DODownloadMode' 0
    Show-Done
}

function Disable-FeatureUpdates {
    Write-Host ""
    Write-Host "  Disabling Feature Updates..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'TargetReleaseVersion' 1
    try {
        $os = (Get-CimInstance -Class Win32_OperatingSystem).Caption
        $productVersion = if ($os -match '11') { 'Windows 11' } else { 'Windows 10' }
        New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name 'ProductVersion' -Value $productVersion -PropertyType String -Force | Out-Null
        Write-Host "  SET  ProductVersion = $productVersion" -ForegroundColor DarkGray
        $ver = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').DisplayVersion
        New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name 'TargetReleaseVersionInfo' -Value $ver -PropertyType String -Force | Out-Null
        Write-Host "  SET  TargetReleaseVersionInfo = $ver" -ForegroundColor DarkGray
    } catch { Write-Host "  FAIL Feature update version lock" -ForegroundColor Red }
    Show-Done
}

function Disable-WUInsider {
    Write-Host ""
    Write-Host "  Restricting Windows Insider..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'ManagePreviewBuilds' 1
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'ManagePreviewBuildsPolicyValue' 0
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds' 'AllowBuildPreview' 0
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds' 'EnableConfigFlighting' 0
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds' 'EnableExperimentation' 0
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility' 'HideInsiderPage' 1
    Show-Done
}

function Disable-MSRTTelemetry {
    Write-Host ""
    Write-Host "  Disabling MSRT Telemetry..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\MRT' 'DontReportInfectionInformation' 1
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\RemovalTools\MpGears' 'HeartbeatTrackingIndex' 0
    Show-Done
}

function Block-DevHomeOutlookReinstall {
    Write-Host ""
    Write-Host "  Blocking DevHome and Outlook Reinstall via WU..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator\UScheduler\DevHomeUpdate' 'workCompleted' 1
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator\UScheduler\OutlookUpdate' 'workCompleted' 1
    Show-Done
}

function Exclude-WUDrivers {
    Write-Host ""
    Write-Host "  Excluding Drivers from Windows Update..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Update' 'ExcludeWUDriversInQualityUpdate' 1
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Update' 'ExcludeWUDriversInQualityUpdate' 1
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings' 'ExcludeWUDriversInQualityUpdate' 1
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'ExcludeWUDriversInQualityUpdate' 1
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Update\ExcludeWUDriversInQualityUpdate' 'value' 1
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata' 'PreventDeviceMetadataFromNetwork' 1
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching' 'SearchOrderConfig' 0
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching' 'DontSearchWindowsUpdate' 1
    Show-Done
}

function Invoke-AllWindowsUpdate {
    Disable-WUAutoReboot
    Disable-DeliveryOptimization
    Disable-FeatureUpdates
    Disable-WUInsider
    Disable-MSRTTelemetry
    Block-DevHomeOutlookReinstall
    Exclude-WUDrivers
}

function Show-WindowsUpdate {
    while ($true) {
        Show-Logo
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host "        WINDOWS UPDATE            " -ForegroundColor White
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host ""
        Write-Host "  [1]  Disable Auto Reboot" -ForegroundColor Yellow
        Write-Host "  [2]  Disable Delivery Optimization" -ForegroundColor Yellow
        Write-Host "  [3]  Disable Feature Updates" -ForegroundColor Yellow
        Write-Host "  [4]  Restrict Windows Insider" -ForegroundColor Yellow
        Write-Host "  [5]  Disable MSRT Telemetry" -ForegroundColor Yellow
        Write-Host "  [6]  Block DevHome and Outlook Reinstall" -ForegroundColor Yellow
        Write-Host "  [7]  Exclude Drivers from Windows Update" -ForegroundColor Yellow
        Write-Host "  [A]  Run All" -ForegroundColor Cyan
        Write-Host "  [0]  Back" -ForegroundColor Red
        Write-Host ""
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host ""
        $choice = Read-Host "  Select an option"
        switch ($choice.ToUpper()) {
            '1' { Disable-WUAutoReboot }
            '2' { Disable-DeliveryOptimization }
            '3' { Disable-FeatureUpdates }
            '4' { Disable-WUInsider }
            '5' { Disable-MSRTTelemetry }
            '6' { Block-DevHomeOutlookReinstall }
            '7' { Exclude-WUDrivers }
            'A' { Invoke-AllWindowsUpdate }
            '0' { return }
            default { Write-Host ""; Write-Host "  [!] Invalid option, try again" -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}

function Disable-Copilot {
    Write-Host ""
    Write-Host "  Disabling Copilot..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot' 'TurnOffWindowsCopilot' 1
    Show-Done
}

function Disable-MeetNow {
    Write-Host ""
    Write-Host "  Hiding Meet Now..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'HideSCAMeetNow' 1
    Show-Done
}

function Disable-NewsInterests {
    Write-Host ""
    Write-Host "  Disabling News and Interests..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds' 'EnableFeeds' 0
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Dsh' 'AllowNewsAndInterests' 0
    Show-Done
}

function Disable-Chat {
    Write-Host ""
    Write-Host "  Disabling Windows Chat..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat' 'ChatIcon' 3
    Set-RegKey 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarMn' 0
    Show-Done
}

function Set-TaskbarLeft {
    Write-Host ""
    Write-Host "  Aligning Taskbar Left..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarAl' 0
    Show-Done
}

function Enable-EndTask {
    Write-Host ""
    Write-Host "  Enabling End Task on Taskbar..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings' 'TaskbarEndTask' 1
    Show-Done
}

function Disable-DesktopPeek {
    Write-Host ""
    Write-Host "  Disabling Desktop Peek..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'DisablePreviewDesktop' 1
    Show-Done
}

function Disable-CloudTaskbarContent {
    Write-Host ""
    Write-Host "  Disabling Cloud Optimized Taskbar Content..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableCloudOptimizedContent' 1
    Set-RegKey 'HKCU:\Software\Microsoft\Windows\CurrentVersion\PenWorkspace' 'PenWorkspaceAppSuggestionsEnabled' 0
    Show-Done
}

function Disable-TaskbarExtras {
    Write-Host ""
    Write-Host "  Applying Taskbar Extras..." -ForegroundColor Cyan
    Write-Host ""
    Disable-Copilot
    Disable-MeetNow
    Disable-NewsInterests
    Disable-Chat
    Set-TaskbarLeft
    Enable-EndTask
    Disable-DesktopPeek
    Disable-CloudTaskbarContent
}

function Disable-NullSessions {
    Write-Host ""
    Write-Host "  Restricting Null Session Access..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters' 'RestrictNullSessAccess' 1
    Show-Done
}

function Disable-AnonymousEnum {
    Write-Host ""
    Write-Host "  Restricting Anonymous Enumeration..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' 'RestrictAnonymous' 1
    Show-Done
}

function Disable-SMBThrottling {
    Write-Host ""
    Write-Host "  Disabling SMB Bandwidth Throttling..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters' 'DisableBandwidthThrottling' 1
    Show-Done
}

function Disable-LLMNR {
    Write-Host ""
    Write-Host "  Disabling LLMNR (DNS Multicast)..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient' 'EnableMulticast' 0
    Show-Done
}

function Set-NICInterruptModeration {
    Write-Host ""
    Write-Host "  Disabling NIC Interrupt Moderation..." -ForegroundColor Cyan
    Write-Host ""
    try {
        Get-NetAdapter -Physical | Set-NetAdapterAdvancedProperty -RegistryKeyword "ITR" -RegistryValue 0 -ErrorAction SilentlyContinue
        Write-Host "  SET  Interrupt moderation disabled on all physical adapters" -ForegroundColor DarkGray
    } catch {
        Write-Host "  SKIP NIC interrupt moderation (not supported on this adapter)" -ForegroundColor DarkGray
    }
    Show-Done
}

function Disable-NetworkSecurity {
    Disable-NullSessions
    Disable-AnonymousEnum
    Disable-SMBThrottling
    Disable-LLMNR
    Set-NICInterruptModeration
}


function Set-AppPermissions {
    Write-Host ""
    Write-Host "  Hardening App Permissions..." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [!] This denies all apps access to location, camera, mic, contacts, and more." -ForegroundColor DarkYellow
    Write-Host "  Apps that need these will stop working until you re-enable them in Settings." -ForegroundColor DarkYellow
    Write-Host ""
    $base = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore'
    Set-RegKey "$base\location" 'Value' 'Deny' 'String'
    Set-RegKey "$base\userAccountInformation" 'Value' 'Deny' 'String'
    Set-RegKey "$base\contacts" 'Value' 'Deny' 'String'
    Set-RegKey "$base\appointments" 'Value' 'Deny' 'String'
    Set-RegKey "$base\phoneCall" 'Value' 'Deny' 'String'
    Set-RegKey "$base\phoneCallHistory" 'Value' 'Deny' 'String'
    Set-RegKey "$base\email" 'Value' 'Deny' 'String'
    Set-RegKey "$base\userDataTasks" 'Value' 'Deny' 'String'
    Set-RegKey "$base\chat" 'Value' 'Deny' 'String'
    Set-RegKey "$base\radios" 'Value' 'Deny' 'String'
    Set-RegKey "$base\appDiagnostics" 'Value' 'Deny' 'String'
    Set-RegKey "$base\documentsLibrary" 'Value' 'Deny' 'String'
    Set-RegKey "$base\picturesLibrary" 'Value' 'Deny' 'String'
    Set-RegKey "$base\videosLibrary" 'Value' 'Deny' 'String'
    Set-RegKey "$base\broadFileSystemAccess" 'Value' 'Deny' 'String'
    $hkcu = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore'
    Set-RegKey "$hkcu\bluetoothSync" 'Value' 'Deny' 'String'
    Show-Done
}

function Set-OOBETweaks {
    Write-Host ""
    Write-Host "  Applying OOBE Tweaks..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE' 'SkipMachineOOBE' 1
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE' 'SkipUserOOBE' 1
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE' 'DisablePrivacyExperience' 1
    Set-RegKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE' 'DisablePrivacyExperience' 1
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' 'EnableFirstLogonAnimation' 0
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' 'EnableFirstLogonAnimation' 0
    Show-Done
}

function Disable-TelemetryServices {
    Write-Host ""
    Write-Host "  Disabling Telemetry Services..." -ForegroundColor Cyan
    Write-Host ""
    $services = @(
        @{Name='DiagTrack';       Desc='Connected User Experiences and Telemetry'},
        @{Name='WerSvc';          Desc='Windows Error Reporting'},
        @{Name='wisvc';           Desc='Windows Insider Service'},
        @{Name='PcaSvc';          Desc='Program Compatibility Assistant'},
        @{Name='DPS';             Desc='Diagnostic Policy Service'},
        @{Name='WdiServiceHost';  Desc='Diagnostic Service Host'},
        @{Name='WdiSystemHost';   Desc='Diagnostic System Host'},
        @{Name='dmwappushservice';Desc='WAP Push Message Routing'},
        @{Name='lfsvc';           Desc='Geolocation Service'},
        @{Name='RetailDemo';      Desc='Retail Demo Service'},
        @{Name='tcpipreg';        Desc='TCP/IP Port Sharing'},
        @{Name='diagnosticshub.standardcollector.service'; Desc='Microsoft Diagnostics Hub Standard Collector'}
    )
    Set-RegKey 'HKLM:\SYSTEM\CurrentControlSet\Services\UCPD' 'Start' 4
    Set-RegKey 'HKLM:\SYSTEM\CurrentControlSet\Services\NetBT' 'Start' 4
    Write-Host "  SET  Disabled: NetBIOS over TCP (via registry)" -ForegroundColor DarkGray
    foreach ($svc in $services) {
        try {
            Stop-Service -Name $svc.Name -Force -ErrorAction Stop
            Set-Service -Name $svc.Name -StartupType Disabled -ErrorAction Stop
            Write-Host "  SET  Disabled: $($svc.Desc)" -ForegroundColor DarkGray
        } catch {
            Write-Host "  SKIP $($svc.Desc) (not found)" -ForegroundColor DarkGray
        }
    }
    Show-Done
}

function Add-HostsTelemetryBlock {
    Write-Host ""
    Write-Host "  Blocking Telemetry Endpoints via Hosts File..." -ForegroundColor Cyan
    Write-Host ""
    $hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
    $endpoints = @(
        'telemetry.microsoft.com',
        'vortex.data.microsoft.com',
        'vortex-win.data.microsoft.com',
        'telecommand.telemetry.microsoft.com',
        'oca.telemetry.microsoft.com',
        'sqm.telemetry.microsoft.com',
        'watson.telemetry.microsoft.com',
        'redir.metaservices.microsoft.com',
        'choice.microsoft.com',
        'df.telemetry.microsoft.com',
        'reports.wes.df.telemetry.microsoft.com',
        'services.wes.df.telemetry.microsoft.com',
        'sqm.df.telemetry.microsoft.com',
        'watson.ppe.telemetry.microsoft.com',
        'statsfe2.ws.microsoft.com',
        'corpext.msitadfs.glbdns2.microsoft.com',
        'compatexchange.cloudapp.net',
        'settings-win.data.microsoft.com',
        'report.wes.df.telemetry.microsoft.com',
        'wes.df.telemetry.microsoft.com',
        'oca.microsoft.com',
        'kmwatsonc.events.data.microsoft.com',
        'v10.events.data.microsoft.com',
        'v20.events.data.microsoft.com'
    )
    $hostsContent = Get-Content $hostsPath -ErrorAction SilentlyContinue
    $added = 0
    foreach ($endpoint in $endpoints) {
        $entry = "0.0.0.0 $endpoint"
        if ($hostsContent -notcontains $entry) {
            try {
                Add-Content -Path $hostsPath -Value $entry -ErrorAction Stop
                Write-Host "  SET  Blocked: $endpoint" -ForegroundColor DarkGray
                $added++
            } catch {
                Write-Host "  FAIL $endpoint" -ForegroundColor Red
            }
        } else {
            Write-Host "  SKIP $endpoint (already blocked)" -ForegroundColor DarkGray
        }
    }
    Write-Host ""
    Write-Host "  Added $added new hosts file entries." -ForegroundColor DarkGray
    Show-Done
}

function Set-GamingTweaks {
    Write-Host ""
    Write-Host "  Applying Advanced Gaming Tweaks..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' 'HwSchMode' 2
    Set-RegKey 'HKCU:\System\GameConfigStore' 'GameDVR_FSEBehavior' 2
    Set-RegKey 'HKCU:\System\GameConfigStore' 'GameDVR_HonorUserFSEBehaviorMode' 1
    Set-RegKey 'HKCU:\System\GameConfigStore' 'GameDVR_DXGIHonorFSEWindowsCompatible' 1
    Set-RegKey 'HKCU:\System\GameConfigStore' 'GameDVR_EFSEFeatureFlags' 0
    try {
        & bcdedit /set useplatformtick yes 2>&1 | Out-Null
        & bcdedit /set disabledynamictick yes 2>&1 | Out-Null
        & bcdedit /deletevalue useplatformclock 2>&1 | Out-Null
        & bcdedit /set bootmenupolicy legacy 2>&1 | Out-Null
        Write-Host "  SET  Platform tick, dynamic tick, HPET and boot menu configured" -ForegroundColor DarkGray
    } catch { Write-Host "  FAIL bcdedit tick settings" -ForegroundColor Red }
    try {
        $existingScheme = & powercfg /list 2>&1 | Select-String 'Ultimate Performance' | ForEach-Object { ($_ -split '\s+')[3] }
        if (-not $existingScheme) {
            & powercfg /duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>&1 | Out-Null
            $existingScheme = & powercfg /list 2>&1 | Select-String 'Ultimate Performance' | ForEach-Object { ($_ -split '\s+')[3] }
        }
        if ($existingScheme) {
            & powercfg /setactive $existingScheme 2>&1 | Out-Null
            & powercfg /setacvalueindex $existingScheme SUB_PROCESSOR CPMINCORES 100 2>&1 | Out-Null
            & powercfg /setdcvalueindex $existingScheme SUB_PROCESSOR CPMINCORES 100 2>&1 | Out-Null
            & powercfg /setacvalueindex $existingScheme SUB_PROCESSOR CPMAXCORES 100 2>&1 | Out-Null
            & powercfg /setdcvalueindex $existingScheme SUB_PROCESSOR CPMAXCORES 100 2>&1 | Out-Null
            Write-Host "  SET  Ultimate Performance power plan activated with core parking disabled" -ForegroundColor DarkGray
        } else {
            Write-Host "  SKIP Ultimate Performance plan (not available on this edition)" -ForegroundColor DarkGray
        }
    } catch { Write-Host "  FAIL Power plan configuration failed" -ForegroundColor Red }
    Show-Done
}

function Remove-WindowsCapabilities {
    Write-Host ""
    Write-Host "  Removing Unnecessary Windows Capabilities..." -ForegroundColor Cyan
    Write-Host ""
    $caps = @(
        'App.StepsRecorder~~~~0.0.1.0',
        'App.Support.QuickAssist~~~~0.0.1.0',
        'Browser.InternetExplorer~~~~0.0.11.0',
        'MathRecognizer~~~~0.0.1.0',
        'Media.WindowsMediaPlayer~~~~0.0.12.0',
        'Hello.Face.17720~~~~0.0.10.0',
        'Hello.Face.Migration.17720~~~~0.0.10.0',
        'Microsoft.Windows.PowerShell.ISE~~~~0.0.1.0'
    )
    $total = $caps.Count
    $i = 0
    foreach ($cap in $caps) {
        $i++
        Write-Host "  [$i/$total] Checking: $cap" -ForegroundColor DarkGray
        try {
            $state = (Get-WindowsCapability -Online -Name $cap -ErrorAction Stop).State
            if ($state -eq 'Installed') {
                Remove-WindowsCapability -Online -Name $cap -ErrorAction Stop | Out-Null
                Write-Host "  SET  Removed: $cap" -ForegroundColor DarkGray
            } else {
                Write-Host "  SKIP $cap (not installed)" -ForegroundColor DarkGray
            }
        } catch {
            Write-Host "  SKIP $cap (not found)" -ForegroundColor DarkGray
        }
    }
    Show-Done
}

function Remove-Appx {
    Write-Host ""
    Write-Host "  Removing Bloat Apps..." -ForegroundColor Cyan
    Write-Host ""
    $apps = @(
        'Clipchamp.Clipchamp',
        'Microsoft.BingNews',
        'Microsoft.BingWeather',
        'Microsoft.GamingApp',
        'Microsoft.XboxSpeechToTextOverlay',
        'Microsoft.XboxGamingOverlay',
        'Microsoft.XboxIdentityProvider',
        'Microsoft.XboxGameCallableUI',
        'Microsoft.MixedReality.Portal',
        'Microsoft.People',
        'Microsoft.MicrosoftSolitaireCollection',
        'Microsoft.Todos',
        'Microsoft.WindowsAlarms',
        'Microsoft.WindowsMaps',
        'Microsoft.YourPhone',
        'MicrosoftTeams',
        'Microsoft.PowerAutomateDesktop',
        'Microsoft.Windows.DevHome',
        'Microsoft.WindowsFeedbackHub',
        'Microsoft.GetHelp',
        'Microsoft.Getstarted',
        'Microsoft.ZuneMusic',
        'Microsoft.ZuneVideo',
        'Microsoft.WindowsCommunicationsApps',
        'Microsoft.549981C3F5F10',
        'Microsoft.Cortana',
        'Microsoft.MicrosoftStickyNotes',
        'Microsoft.WindowsCamera',
        'Microsoft.SkypeApp',
        'Microsoft.OutlookForWindows',
        'MSTeams',
        'Microsoft.Windows.NarratorQuickStart',
        'Microsoft.BingFinance',
        'Microsoft.BingSports',
        'Microsoft.BingTranslator',
        'Microsoft.BingTravel',
        'Microsoft.NetworkSpeedTest',
        'MicrosoftWindows.Client.WebExperience',
        'Microsoft.Whiteboard',
        'MicrosoftCorporationII.MicrosoftFamily',
        'Microsoft.MicrosoftPowerBIForWindows',
        'Microsoft.Windows.SecureAssessmentBrowser',
        'Microsoft.MSPaint',
        'MicrosoftWindows.CrossDevice',
        'Microsoft.StartExperiencesApp',
        'MicrosoftWindows.Client.WebExperiencePlatform'
    )
    $total = $apps.Count
    $i = 0
    foreach ($app in $apps) {
        $i++
        Write-Host "  [$i/$total] $app" -ForegroundColor DarkGray
        try {
            Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like "*$app*" } | Remove-AppxProvisionedPackage -Online -ErrorAction Stop | Out-Null
            Write-Host "  SET  Removed provisioned: $app" -ForegroundColor DarkGray
        } catch {
            Write-Host "  SKIP provisioned: $app" -ForegroundColor DarkGray
        }
        try {
            Get-AppxPackage -AllUsers -Name "*$app*" | Remove-AppxPackage -ErrorAction Stop
        } catch {}
    }
    Show-Done
}

function Remove-OneDrive {
    Write-Host ""
    Write-Host "  Removing OneDrive..." -ForegroundColor Cyan
    Write-Host ""
    try { & taskkill /f /im OneDrive.exe 2>&1 | Out-Null } catch {}
    Start-Sleep -Seconds 2
    $uninstallers = @(
        "$env:SystemRoot\System32\OneDriveSetup.exe",
        "$env:SystemRoot\SysWOW64\OneDriveSetup.exe",
        "$env:LocalAppData\Microsoft\OneDrive\OneDriveSetup.exe"
    )
    foreach ($path in $uninstallers) {
        if (Test-Path $path) {
            try {
                Start-Process $path -ArgumentList "/uninstall" -Wait -WindowStyle Hidden
                Write-Host "  SET  Ran uninstaller: $path" -ForegroundColor DarkGray
            } catch { Write-Host "  FAIL $path" -ForegroundColor Red }
        }
    }
    Remove-RegKey 'Registry::HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}' 'System.IsPinnedToNameSpaceTree'
    Remove-RegKey 'Registry::HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}' 'System.IsPinnedToNameSpaceTree'
    Show-Done
}

function Remove-Edge {
    Write-Host ""
    Write-Host "  Removing Microsoft Edge..." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [!] Warning: Removing Edge may break some Windows Settings links." -ForegroundColor DarkYellow
    Write-Host ""
    $confirm = Read-Host "  Continue? (Y/N)"
    if ($confirm.ToUpper() -ne 'Y') {
        Write-Host "  Skipped." -ForegroundColor DarkGray
        return
    }
    try {
        $winget = Get-Command winget -ErrorAction Stop
        Write-Host "  SET  Running winget uninstall for Edge..." -ForegroundColor DarkGray
        & winget uninstall --id Microsoft.Edge --force --accept-source-agreements --accept-package-agreements 2>&1 | Out-Null
        Write-Host "  SET  Edge removed via winget" -ForegroundColor DarkGray
    } catch {
        Write-Host "  SKIP winget not available - install winget to remove Edge" -ForegroundColor DarkYellow
        Write-Host "  INFO Edge cannot be removed without winget on this system" -ForegroundColor DarkGray
    }
    Show-Done
}

function Show-ServicesModule {
    while ($true) {
        Show-Logo
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host "     DEBLOAT & HARDENING          " -ForegroundColor White
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host ""
        Write-Host "  [1]  Disable Telemetry Services" -ForegroundColor Yellow
        Write-Host "  [2]  Block Telemetry via Hosts File" -ForegroundColor Yellow
        Write-Host "  [3]  Harden App Permissions" -ForegroundColor Yellow
        Write-Host "  [4]  Apply OOBE Tweaks" -ForegroundColor Yellow
        Write-Host "  [5]  Remove Windows Capabilities" -ForegroundColor Yellow
        Write-Host "  [6]  Remove Bloat Apps" -ForegroundColor Yellow
        Write-Host "  [7]  Remove OneDrive" -ForegroundColor Yellow
        Write-Host "  [8]  Remove Microsoft Edge" -ForegroundColor Yellow
        Write-Host "  [A]  Run All" -ForegroundColor Cyan
        Write-Host "  [0]  Back" -ForegroundColor Red
        Write-Host ""
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host ""
        $choice = Read-Host "  Select an option"
        switch ($choice.ToUpper()) {
            '1' { Disable-TelemetryServices }
            '2' { Add-HostsTelemetryBlock }
            '3' { Set-AppPermissions }
            '4' { Set-OOBETweaks }
            '5' { Remove-WindowsCapabilities }
            '6' { Remove-Appx }
            '7' { Remove-OneDrive }
            '8' { Remove-Edge }
            'A' {
                Write-Host ""
                Write-Host "  [!] This will run all options including removing apps, OneDrive and Edge." -ForegroundColor DarkYellow
                Write-Host "  App removal is permanent. Create a restore point first if unsure." -ForegroundColor DarkYellow
                Write-Host ""
                $confirm = Read-Host "  Continue? (Y/N)"
                if ($confirm.ToUpper() -eq 'Y') {
                    Disable-TelemetryServices
                    Add-HostsTelemetryBlock
                    Set-AppPermissions
                    Set-OOBETweaks
                    Remove-WindowsCapabilities
                    Remove-Appx
                    Remove-OneDrive
                    Remove-Edge
                }
            }
            '0' { return }
            default { Write-Host ""; Write-Host "  [!] Invalid option, try again" -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}

function Show-TaskbarExtras {
    while ($true) {
        Show-Logo
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host "         TASKBAR EXTRAS           " -ForegroundColor White
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host ""
        Write-Host "  [1]  Disable Copilot" -ForegroundColor Yellow
        Write-Host "  [2]  Hide Meet Now" -ForegroundColor Yellow
        Write-Host "  [3]  Disable News and Interests" -ForegroundColor Yellow
        Write-Host "  [4]  Disable Windows Chat" -ForegroundColor Yellow
        Write-Host "  [5]  Align Taskbar Left" -ForegroundColor Yellow
        Write-Host "  [6]  Enable End Task on Taskbar" -ForegroundColor Yellow
        Write-Host "  [7]  Disable Desktop Peek" -ForegroundColor Yellow
        Write-Host "  [8]  Disable Cloud Taskbar Content" -ForegroundColor Yellow
        Write-Host "  [A]  Run All" -ForegroundColor Cyan
        Write-Host "  [0]  Back" -ForegroundColor Red
        Write-Host ""
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host ""
        $choice = Read-Host "  Select an option"
        switch ($choice.ToUpper()) {
            '1' { Disable-Copilot }
            '2' { Disable-MeetNow }
            '3' { Disable-NewsInterests }
            '4' { Disable-Chat }
            '5' { Set-TaskbarLeft }
            '6' { Enable-EndTask }
            '7' { Disable-DesktopPeek }
            '8' { Disable-CloudTaskbarContent }
            'A' { Disable-TaskbarExtras }
            '0' { return }
            default { Write-Host ""; Write-Host "  [!] Invalid option, try again" -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}

function Show-NetworkSecurity {
    while ($true) {
        Show-Logo
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host "        NETWORK SECURITY          " -ForegroundColor White
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host ""
        Write-Host "  [1]  Restrict Null Session Access" -ForegroundColor Yellow
        Write-Host "  [2]  Restrict Anonymous Enumeration" -ForegroundColor Yellow
        Write-Host "  [3]  Disable SMB Bandwidth Throttling" -ForegroundColor Yellow
        Write-Host "  [4]  Disable LLMNR" -ForegroundColor Yellow
        Write-Host "  [5]  Disable NIC Interrupt Moderation" -ForegroundColor Yellow
        Write-Host "  [A]  Run All" -ForegroundColor Cyan
        Write-Host "  [0]  Back" -ForegroundColor Red
        Write-Host ""
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host ""
        $choice = Read-Host "  Select an option"
        switch ($choice.ToUpper()) {
            '1' { Disable-NullSessions }
            '2' { Disable-AnonymousEnum }
            '3' { Disable-SMBThrottling }
            '4' { Disable-LLMNR }
            '5' { Set-NICInterruptModeration }
            'A' { Disable-NetworkSecurity }
            '0' { return }
            default { Write-Host ""; Write-Host "  [!] Invalid option, try again" -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}

function Clear-TempFiles {
    Write-Host ""
    Write-Host "  Clearing Temporary Files..." -ForegroundColor Cyan
    Write-Host ""
    Remove-Item -Path "$env:TEMP\*" -Force -Recurse -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\Temp\*" -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host "  SET  Temp files cleared" -ForegroundColor DarkGray
    Show-Done
}

function Clear-DNSCache {
    Write-Host ""
    Write-Host "  Flushing DNS Cache..." -ForegroundColor Cyan
    Write-Host ""
    Clear-DnsClientCache
    Write-Host "  SET  DNS cache flushed" -ForegroundColor DarkGray
    Show-Done
}

function Clear-Prefetch {
    Write-Host ""
    Write-Host "  Clearing Prefetch..." -ForegroundColor Cyan
    Write-Host ""
    Remove-Item -Path "C:\Windows\Prefetch\*" -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host "  SET  Prefetch cleared" -ForegroundColor DarkGray
    Show-Done
}

function Clear-BrowserCache {
    Write-Host ""
    Write-Host "  Clearing Browser Cache..." -ForegroundColor Cyan
    Write-Host ""
    $browserPaths = @(
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache",
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache",
        "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache",
        "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Code Cache",
        "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Cache",
        "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Code Cache",
        "$env:LOCALAPPDATA\Opera Software\Opera Stable\Cache",
        "$env:LOCALAPPDATA\Vivaldi\User Data\Default\Cache"
    )
    foreach ($p in $browserPaths) {
        Remove-Item -Path "$p\*" -Force -Recurse -ErrorAction SilentlyContinue
        Write-Host "  SET  Cleared: $($p.Split('\')[-1])" -ForegroundColor DarkGray
    }
    $ffProfilesRoot = "$env:APPDATA\Mozilla\Firefox\Profiles"
    if (Test-Path $ffProfilesRoot) {
        Get-ChildItem -Path $ffProfilesRoot -Directory | ForEach-Object {
            $cache = Join-Path $_.FullName "cache2"
            if (Test-Path $cache) {
                Remove-Item -Path "$cache\*" -Force -Recurse -ErrorAction SilentlyContinue
                Write-Host "  SET  Cleared Firefox cache2: $($_.Name)" -ForegroundColor DarkGray
            }
        }
    }
    Show-Done
}

function Clear-ThumbnailCache {
    Write-Host ""
    Write-Host "  Clearing Thumbnail Cache..." -ForegroundColor Cyan
    Write-Host ""
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\*.db" -Force -ErrorAction SilentlyContinue
    Write-Host "  SET  Thumbnail cache cleared" -ForegroundColor DarkGray
    Start-Process explorer
    Show-Done
}

function Clear-WindowsUpdateCache {
    Write-Host ""
    Write-Host "  Clearing Windows Update Cache..." -ForegroundColor Cyan
    Write-Host ""
    Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Force -Recurse -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\SoftwareDistribution\DeliveryOptimization\*" -Force -Recurse -ErrorAction SilentlyContinue
    Start-Service -Name wuauserv -ErrorAction SilentlyContinue
    Write-Host "  SET  Windows Update cache cleared" -ForegroundColor DarkGray
    Show-Done
}

function Clear-BuildArtifacts {
    Write-Host ""
    Write-Host "  Removing Build Artifacts..." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [!] This scans all of C:\ and deletes .pdb, .obj, .ilk and similar files" -ForegroundColor DarkYellow
    Write-Host "  everywhere on the drive, including active projects. This cannot be undone." -ForegroundColor DarkYellow
    Write-Host ""
    $confirm = Read-Host "  Continue? (Y/N)"
    if ($confirm.ToUpper() -ne 'Y') {
        Write-Host "  Skipped." -ForegroundColor DarkGray
        return
    }
    Write-Host "  [*] Scanning C:\ - this may take a moment..." -ForegroundColor DarkGray
    Get-ChildItem -Path "C:\" -Filter ".vs" -Recurse -Directory -Force -ErrorAction SilentlyContinue | ForEach-Object {
        Remove-Item -Path $_.FullName -Force -Recurse -ErrorAction SilentlyContinue
        Write-Host "  SET  Removed .vs: $($_.FullName)" -ForegroundColor DarkGray
    }
    $extensions = @("*.pdb", "*.tlog", "*.obj", "*.ilk", "*.iobj", "*.ipdb")
    foreach ($ext in $extensions) {
        Get-ChildItem -Path "C:\" -Filter $ext -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
        Write-Host "  SET  Cleared: $ext" -ForegroundColor DarkGray
    }
    Show-Done
}

function Invoke-DiskCleanup {
    Write-Host ""
    Write-Host "  Running Disk Cleanup..." -ForegroundColor Cyan
    Write-Host ""
    Start-Process cleanmgr -ArgumentList "/autoclean" -Wait -ErrorAction SilentlyContinue
    Write-Host "  SET  Disk cleanup complete" -ForegroundColor DarkGray
    Show-Done
}

function Invoke-MemoryOptimize {
    Write-Host ""
    Write-Host "  Optimizing Memory..." -ForegroundColor Cyan
    Write-Host ""
    rundll32.exe advapi32.dll,ProcessIdleTasks
    Write-Host "  SET  Memory optimization triggered" -ForegroundColor DarkGray
    Show-Done
}

function Invoke-RecycleBinEmpty {
    Write-Host ""
    Write-Host "  Emptying Recycle Bin..." -ForegroundColor Cyan
    Write-Host ""
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Write-Host "  SET  Recycle bin emptied" -ForegroundColor DarkGray
    Show-Done
}

function Invoke-AllCleanup {
    $script:SilentMode = $true
    Clear-TempFiles
    Clear-DNSCache
    Clear-Prefetch
    Clear-BrowserCache
    Clear-ThumbnailCache
    Clear-WindowsUpdateCache
    Invoke-DiskCleanup
    Invoke-MemoryOptimize
    Invoke-RecycleBinEmpty
    $script:SilentMode = $false
    Write-Host ""
    Write-Host "  [+] Cleanup complete." -ForegroundColor Green
    Write-Host ""
}

function Show-Cleanup {
    while ($true) {
        Show-Logo
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host "            CLEANUP               " -ForegroundColor White
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host ""
        Write-Host "  [1]  Clear Temporary Files" -ForegroundColor Yellow
        Write-Host "  [2]  Flush DNS Cache" -ForegroundColor Yellow
        Write-Host "  [3]  Clear Prefetch" -ForegroundColor Yellow
        Write-Host "  [4]  Clear Browser Cache" -ForegroundColor Yellow
        Write-Host "  [5]  Clear Thumbnail Cache" -ForegroundColor Yellow
        Write-Host "  [6]  Clear Windows Update Cache" -ForegroundColor Yellow
        Write-Host "  [7]  Remove Build Artifacts" -ForegroundColor Yellow
        Write-Host "  [8]  Run Disk Cleanup" -ForegroundColor Yellow
        Write-Host "  [9]  Optimize Memory" -ForegroundColor Yellow
        Write-Host "  [10] Empty Recycle Bin" -ForegroundColor Yellow
        Write-Host "  [A]  Run All" -ForegroundColor Cyan
        Write-Host "  [0]  Back" -ForegroundColor Red
        Write-Host ""
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host ""
        $choice = Read-Host "  Select an option"
        switch ($choice.ToUpper()) {
            '1'  { Clear-TempFiles }
            '2'  { Clear-DNSCache }
            '3'  { Clear-Prefetch }
            '4'  { Clear-BrowserCache }
            '5'  { Clear-ThumbnailCache }
            '6'  { Clear-WindowsUpdateCache }
            '7'  { Clear-BuildArtifacts }
            '8'  { Invoke-DiskCleanup }
            '9'  { Invoke-MemoryOptimize }
            '10' { Invoke-RecycleBinEmpty }
            'A'  { Invoke-AllCleanup }
            '0'  { return }
            default { Write-Host ""; Write-Host "  [!] Invalid option, try again" -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}

while ($true) {
    Show-Logo
    Write-Host " =================================" -ForegroundColor DarkCyan
    Write-Host "          BIRDYOS MAIN MENU       " -ForegroundColor White
    Write-Host " =================================" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "  [R]  Create Restore Point" -ForegroundColor Green
    Write-Host "  [A]  Run Everything" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "  [1]  Privacy Tweaks" -ForegroundColor Yellow
    Write-Host "  [2]  Security Tweaks" -ForegroundColor Yellow
    Write-Host "  [3]  Optimisations" -ForegroundColor Yellow
    Write-Host "  [4]  Performance Tweaks" -ForegroundColor Yellow
    Write-Host "  [5]  Taskbar and Search Tweaks" -ForegroundColor Yellow
    Write-Host "  [6]  Security and Performance" -ForegroundColor Yellow
    Write-Host "  [7]  Gaming Tweaks" -ForegroundColor Yellow
    Write-Host "  [8]  QoL Tweaks" -ForegroundColor Yellow
    Write-Host "  [9]  Cleanup" -ForegroundColor Yellow
    Write-Host "  [10] Windows Update" -ForegroundColor Yellow
    Write-Host "  [11] Taskbar Extras" -ForegroundColor Yellow
    Write-Host "  [12] Network Security" -ForegroundColor Yellow
    Write-Host "  [13] Debloat and Hardening" -ForegroundColor Yellow
    Write-Host "  [0]  Exit" -ForegroundColor Red
    Write-Host ""
    Write-Host " =================================" -ForegroundColor DarkCyan
    Write-Host ""
    $choice = Read-Host "  Select an option"
    switch ($choice.ToUpper()) {
        'R'  { New-RestorePoint }
        'A'  {
            Write-Host ""
            Write-Host "  This will apply every tweak in BirdyOS." -ForegroundColor DarkYellow
            Write-Host "  A restore point will be created first." -ForegroundColor DarkYellow
            Write-Host ""
            $confirm = Read-Host "  Are you sure? (Y/N)"
            if ($confirm.ToUpper() -eq 'Y') { Run-Everything }
        }
        '1'  { Show-Privacy }
        '2'  { Show-Security }
        '3'  { Show-Optimisations }
        '4'  { Show-Performance }
        '5'  { Show-TaskbarSearch }
        '6'  { Show-SecPerf }
        '7'  { Show-Gaming }
        '8'  { Show-QoL }
        '9'  { Show-Cleanup }
        '10' { Show-WindowsUpdate }
        '11' { Show-TaskbarExtras }
        '12' { Show-NetworkSecurity }
        '13' { Show-ServicesModule }
        '0'  { Clear-Host; Stop-Transcript | Out-Null; exit }
        default { Write-Host ""; Write-Host "  [!] Invalid option, try again" -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
}
