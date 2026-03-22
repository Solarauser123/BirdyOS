if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit
}

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

function Show-Done {
    Write-Host ""
    Write-Host "  [+] Done." -ForegroundColor Green
    Write-Host "  [*] Some changes require a restart to fully apply." -ForegroundColor DarkYellow
    Write-Host ""
    Start-Sleep -Seconds 1
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

function Show-Privacy {
    Show-Telemetry
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
        '\Microsoft\Windows\Flighting\FeatureConfig\UsageDataReporting'
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
    Set-RegKey 'HKCU:\Control Panel\Desktop' 'WaitToKillAppTimeout' 2000
    Set-RegKey 'HKCU:\Control Panel\Desktop' 'HungAppTimeout' 1000
    Show-Done
}

function Disable-SearchIndexing {
    Write-Host ""
    Write-Host "  Disabling Search Indexing..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\Windows Search' 'SetupCompletedSuccessfully' 0
    Set-RegKey 'HKLM:\SOFTWARE\Microsoft\Windows Search' 'PreventIndexingOutlook' 1
    Show-Done
}

function Disable-BackgroundApps {
    Write-Host ""
    Write-Host "  Disabling Background Apps..." -ForegroundColor Cyan
    Write-Host ""
    Set-RegKey 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' 'GlobalUserDisabled' 1
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

function Performance-All {
    Disable-AnimationsEffects
    Disable-SearchIndexing
    Disable-BackgroundApps
    Disable-ExplorerAnimations
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
        Write-Host "  [3]  Disable Background Apps" -ForegroundColor Yellow
        Write-Host "  [4]  Disable Explorer Animations" -ForegroundColor Yellow
        Write-Host "  [A]  Run All" -ForegroundColor Cyan
        Write-Host "  [0]  Back" -ForegroundColor Red
        Write-Host ""
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host ""
        $choice = Read-Host "  Select an option"
        switch ($choice.ToUpper()) {
            '1' { Disable-AnimationsEffects }
            '2' { Disable-SearchIndexing }
            '3' { Disable-BackgroundApps }
            '4' { Disable-ExplorerAnimations }
            'A' { Performance-All }
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
    try {
        powercfg.exe /setactive "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
        Write-Host "  SET  Power scheme: High Performance" -ForegroundColor DarkGray
    } catch {
        Write-Host "  FAIL Power scheme" -ForegroundColor Red
    }
    Show-Done
}

function Disable-NetworkBloat {
    Write-Host ""
    Write-Host "  Disabling Unneeded Network Adapter Bindings..." -ForegroundColor Cyan
    Write-Host ""
    $components = @('ms_msclient', 'ms_server', 'ms_lldp', 'ms_lltdio', 'ms_rspndr')
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
    Set-MaxPerformancePower
    Disable-NetworkBloat
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
        Write-Host "  [3]  Set Max Performance Power" -ForegroundColor Yellow
        Write-Host "  [4]  Disable Unneeded Network Bindings" -ForegroundColor Yellow
        Write-Host "  [A]  Run All" -ForegroundColor Cyan
        Write-Host "  [0]  Back" -ForegroundColor Red
        Write-Host ""
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host ""
        $choice = Read-Host "  Select an option"
        switch ($choice.ToUpper()) {
            '1' { Block-AnonymousSAM }
            '2' { Disable-RemoteAssistance }
            '3' { Set-MaxPerformancePower }
            '4' { Disable-NetworkBloat }
            'A' { SecPerf-All }
            '0' { return }
            default { Write-Host ""; Write-Host "  [!] Invalid option, try again" -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}

function Run-Everything {
    Write-Host ""
    Write-Host "  Running all tweaks..." -ForegroundColor Cyan
    Write-Host ""
    New-RestorePoint
    Disable-AllTelemetry
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
    Disable-AnimationsEffects
    Disable-SearchIndexing
    Disable-BackgroundApps
    Disable-ExplorerAnimations
    Disable-BingSearch
    Disable-CloudSearch
    Apply-SearchPolicies
    Disable-SearchSuggestions
    Set-SearchIcon
    Block-AnonymousSAM
    Disable-RemoteAssistance
    Set-MaxPerformancePower
    Disable-NetworkBloat
    Write-Host ""
    Write-Host "  [+] All tweaks applied." -ForegroundColor Green
    Write-Host "  [*] A restart is required for all changes to take effect." -ForegroundColor DarkYellow
    Write-Host ""
    Start-Sleep -Seconds 2
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
    Write-Host "  [5]  Taskbar Search Tweaks" -ForegroundColor Yellow
    Write-Host "  [6]  Security and Performance" -ForegroundColor Yellow
    Write-Host "  [0]  Exit" -ForegroundColor Red
    Write-Host ""
    Write-Host " =================================" -ForegroundColor DarkCyan
    Write-Host ""
    $choice = Read-Host "  Select an option"
    switch ($choice.ToUpper()) {
        'R' { New-RestorePoint }
        'A' {
            Write-Host ""
            Write-Host "  This will apply every tweak in BirdyOS." -ForegroundColor DarkYellow
            Write-Host "  A restore point will be created first." -ForegroundColor DarkYellow
            Write-Host ""
            $confirm = Read-Host "  Are you sure? (Y/N)"
            if ($confirm.ToUpper() -eq 'Y') { Run-Everything }
        }
        '1' { Show-Privacy }
        '2' { Show-Security }
        '3' { Show-Optimisations }
        '4' { Show-Performance }
        '5' { Show-TaskbarSearch }
        '6' { Show-SecPerf }
        '0' { Clear-Host; exit }
        default { Write-Host ""; Write-Host "  [!] Invalid option, try again" -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
}
