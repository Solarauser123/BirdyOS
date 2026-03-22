#Requires -RunAsAdministrator

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

function Disable-Telemetry {
    Write-Host ""
    Write-Host "  Disabling telemetry..." -ForegroundColor Cyan
    $keys = @(
        @{Path='HKCU:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name='AllowTelemetry'; Value=0},
        @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name='AllowTelemetry'; Value=0},
        @{Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection'; Name='AllowTelemetry'; Value=0},
        @{Path='HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection'; Name='AllowTelemetry'; Value=0},
        @{Path='HKLM:\SOFTWARE\Microsoft\PolicyManager\default\System\AllowTelemetry'; Name='value'; Value=0},
        @{Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CPSS\DevicePolicy\AllowTelemetry'; Name='DefaultValue'; Value=0},
        @{Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CPSS\Store\AllowTelemetry'; Name='Value'; Value=0},
        @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name='AllowCommercialDataPipeline'; Value=0},
        @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name='AllowDeviceNameInTelemetry'; Value=0},
        @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name='DisableEnterpriseAuthProxy'; Value=1},
        @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name='MicrosoftEdgeDataOptIn'; Value=0},
        @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name='DisableTelemetryOptInChangeNotification'; Value=1},
        @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name='DisableTelemetryOptInSettingsUx'; Value=1},
        @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name='DoNotShowFeedbackNotifications'; Value=1},
        @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name='LimitDiagnosticLogCollection'; Value=1},
        @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name='LimitDumpCollection'; Value=1},
        @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name='AllowBuildPreview'; Value=0},
        @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name='LimitEnhancedDiagnosticDataWindowsAnalytics'; Value=0},
        @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds'; Name='EnableConfigFlighting'; Value=0},
        @{Path='HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\System'; Name='AllowExperimentation'; Value=0},
        @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat'; Name='AITEnable'; Value=0},
        @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat'; Name='DisableUAR'; Value=1},
        @{Path='HKLM:\Software\Policies\Microsoft\SQMClient\Windows'; Name='CEIPEnable'; Value=0},
        @{Path='HKLM:\SOFTWARE\Policies\Microsoft\AppV\CEIP'; Name='CEIPEnable'; Value=0},
        @{Path='HKLM:\Software\Policies\Microsoft\Internet Explorer\SQM'; Name='DisableCustomerImprovementProgram'; Value=1},
        @{Path='HKLM:\Software\Policies\Microsoft\Messenger\Client'; Name='CEIP'; Value=2},
        @{Path='HKLM:\Software\Microsoft\Windows NT\CurrentVersion\UnattendSettings\SQMClient'; Name='CEIPEnabled'; Value=0},
        @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting'; Name='Disabled'; Value=1},
        @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting'; Name='LoggingDisabled'; Value=1},
        @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting'; Name='DontSendAdditionalData'; Value=1},
        @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting'; Name='DontShowUI'; Value=1},
        @{Path='HKLM:\Software\Microsoft\Windows\Windows Error Reporting\Consent'; Name='DefaultConsent'; Value=0},
        @{Path='HKLM:\Software\Microsoft\Windows\Windows Error Reporting\Consent'; Name='DefaultOverrideBehavior'; Value=1},
        @{Path='HKLM:\SYSTEM\ControlSet001\Control\WMI\Autologger\Diagtrack-Listener'; Name='Start'; Value=0},
        @{Path='HKLM:\SYSTEM\ControlSet001\Control\WMI\Autologger\SQMLogger'; Name='Start'; Value=0},
        @{Path='HKLM:\SYSTEM\ControlSet001\Control\WMI\Autologger\SetupPlatformTel'; Name='Start'; Value=0}
    )
    foreach ($entry in $keys) {
        if (-not (Test-Path $entry.Path)) { New-Item -Path $entry.Path -Force | Out-Null }
        New-ItemProperty -Path $entry.Path -Name $entry.Name -PropertyType DWORD -Value $entry.Value -Force | Out-Null
    }
    Write-Host "  [+] Done." -ForegroundColor Green
    Write-Host ""
    Start-Sleep -Seconds 1
}

function Show-Privacy {
    while ($true) {
        Show-Logo
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host "          PRIVACY TWEAKS          " -ForegroundColor White
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host ""
        Write-Host "  [1]  Disable Telemetry" -ForegroundColor Yellow
        Write-Host "  [0]  Back" -ForegroundColor Red
        Write-Host ""
        Write-Host " =================================" -ForegroundColor DarkCyan
        Write-Host ""
        $choice = Read-Host "  Select an option"
        switch ($choice) {
            '1' { Disable-Telemetry }
            '0' { return }
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
    Write-Host "  [1]  Privacy Tweaks" -ForegroundColor Yellow
    Write-Host "  [0]  Exit" -ForegroundColor Red
    Write-Host ""
    Write-Host " =================================" -ForegroundColor DarkCyan
    Write-Host ""
    $choice = Read-Host "  Select an option"
    switch ($choice) {
        '1' { Show-Privacy }
        '0' { Clear-Host; exit }
        default { Write-Host ""; Write-Host "  [!] Invalid option, try again" -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
}
