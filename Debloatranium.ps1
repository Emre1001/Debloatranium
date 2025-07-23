$Lang = @{
    "en" = @{
        "Welcome" = "Welcome to Debloatranium 2025!"
        "ChooseLang" = "Choose language (en/de/tr):"
        "ChooseLevel" = "Select debloat level:"
        "Options" = @(
            "1) Minimum - Disable telemetry only",
            "2) Medium - Remove common bloatware apps",
            "3) High - Aggressive system cleanup",
            "4) Extreme - Full Windows debloat + remove security features + install browsers",
            "5) Custom - Choose what to remove"
        )
        "InvalidChoice" = "Invalid choice. Exiting."
        "Confirm" = "Are you sure you want to continue? (Y/N):"
        "Aborted" = "Operation aborted by user."
        "Running" = "Running debloat level:"
        "DownloadingBrowsers" = "Downloading and installing browsers..."
        "Done" = "Debloatranium finished successfully."
        "Error" = "An error occurred:"
        "NeedAdmin" = "Please run this script as Administrator!"
        "YesNoPrompt" = "Do you want to apply this? (Y/N):"
        "IsFreshWindows" = "Is this a fresh Windows installation? (Y/N):"
        "RestartPrompt" = "Press any key to restart the PC..."
    }
    "de" = @{
        "Welcome" = "Willkommen bei Debloatranium 2025!"
        "ChooseLang" = "Sprache wählen (en/de/tr):"
        "ChooseLevel" = "Wähle Debloat-Stufe:"
        "Options" = @(
            "1) Minimum - Nur Telemetrie deaktivieren",
            "2) Mittel - Übliche Bloatware entfernen",
            "3) Hoch - Aggressive Systembereinigung",
            "4) Extreme - Volle Bereinigung + Sicherheitsfeatures entfernen + Browser installieren",
            "5) Custom - Wähle einzeln, was entfernt wird"
        )
        "InvalidChoice" = "Ungültige Eingabe. Programm wird beendet."
        "Confirm" = "Bist du sicher, dass du fortfahren willst? (J/N):"
        "Aborted" = "Vom Benutzer abgebrochen."
        "Running" = "Starte Debloat-Stufe:"
        "DownloadingBrowsers" = "Browser werden heruntergeladen und installiert..."
        "Done" = "Debloatranium wurde erfolgreich abgeschlossen."
        "Error" = "Ein Fehler ist aufgetreten:"
        "NeedAdmin" = "Bitte führe das Skript als Administrator aus!"
        "YesNoPrompt" = "Willst du das anwenden? (J/N):"
        "IsFreshWindows" = "Ist das eine frische Windows-Installation? (J/N):"
        "RestartPrompt" = "Drücke eine Taste, um den PC neu zu starten..."
    }
    "tr" = @{
        "Welcome" = "Debloatranium 2025'e hoş geldiniz!"
        "ChooseLang" = "Dil seçiniz (en/de/tr):"
        "ChooseLevel" = "Temizlik seviyesini seçiniz:"
        "Options" = @(
            "1) Minimum - Sadece telemetriyi devre dışı bırak",
            "2) Orta - Yaygın gereksiz uygulamaları kaldır",
            "3) Yüksek - Agresif sistem temizliği",
            "4) Aşırı - Tam Windows temizliği + güvenlik özelliklerini kaldır + tarayıcıları yükle",
            "5) Özel - Kaldırılacakları seç"
        )
        "InvalidChoice" = "Geçersiz seçim. Çıkılıyor."
        "Confirm" = "Devam etmek istediğinizden emin misiniz? (E/H):"
        "Aborted" = "Kullanıcı tarafından iptal edildi."
        "Running" = "Temizlik seviyesi çalıştırılıyor:"
        "DownloadingBrowsers" = "Tarayıcılar indiriliyor ve kuruluyor..."
        "Done" = "Debloatranium başarıyla tamamlandı."
        "Error" = "Bir hata oluştu:"
        "NeedAdmin" = "Lütfen bu scripti Yönetici olarak çalıştırın!"
        "YesNoPrompt" = "Uygulamak ister misiniz? (E/H):"
        "IsFreshWindows" = "Bu yeni kurulmuş bir Windows mu? (E/H):"
        "RestartPrompt" = "Bilgisayarı yeniden başlatmak için bir tuşa basın..."
    }
}

function Write-Log {
    param([string]$Message, [ConsoleColor]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Check-Admin {
    if (-not ([Security.Principal.WindowsPrincipal] `
        [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltinRole]::Administrator)) {
        Write-Log $txt.NeedAdmin Red
        exit 1
    }
}

function Confirm-Action {
    param(
        [string]$prompt,
        [string]$lang
    )
    Write-Host $prompt -ForegroundColor Yellow
    $answer = Read-Host
    if ($lang -eq "de") {
        return $answer.ToLower() -eq "j"
    } elseif ($lang -eq "tr") {
        return $answer.ToLower() -eq "e"
    } else {
        return $answer.ToLower() -eq "y"
    }
}

function Read-YesNo {
    param(
        [string]$prompt,
        [string]$lang
    )
    while ($true) {
        Write-Host $prompt -ForegroundColor Cyan
        $answer = Read-Host
        if ($lang -eq "de") {
            if ($answer.ToLower() -eq "j") { return $true }
            elseif ($answer.ToLower() -eq "n") { return $false }
        } elseif ($lang -eq "tr") {
            if ($answer.ToLower() -eq "e") { return $true }
            elseif ($answer.ToLower() -eq "h") { return $false }
        } else {
            if ($answer.ToLower() -eq "y") { return $true }
            elseif ($answer.ToLower() -eq "n") { return $false }
        }
        Write-Host "Please answer with Y/N or J/N or E/H." -ForegroundColor Red
    }
}
function Remove-App {
    param([string]$packageName)
    try {
        Get-AppxPackage -Name $packageName -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -EQ $packageName | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
        Write-Log "Removed package: $packageName" Green
    }
    catch {
        Write-Log "Failed to remove package: $packageName" Red
    }
}

function Disable-Service {
    param([string]$serviceName)
    try {
        Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
        Set-Service -Name $serviceName -StartupType Disabled
        Write-Log "Disabled service: $serviceName" Green
    }
    catch {
        Write-Log "Failed to disable service: $serviceName" Red
    }
}

function Debloat-Telemetry {
    Write-Log "Disabling telemetry and data collection..." Yellow
    Disable-Service -serviceName "DiagTrack"
    Disable-Service -serviceName "dmwappushservice"
    Disable-Service -serviceName "lfsvc"
}

function Debloat-XboxApps {
    Write-Log "Removing Xbox related apps..." Yellow
    Remove-App "Microsoft.XboxApp"
    Remove-App "Microsoft.XboxGamingOverlay"
    Remove-App "Microsoft.XboxSpeechToTextOverlay"
}

function Debloat-OneDrive {
    Write-Log "Removing OneDrive..." Yellow
    Remove-App "Microsoft.OneDrive"
}

function Debloat-MixedReality {
    Write-Log "Removing Mixed Reality Portal..." Yellow
    Remove-App "Microsoft.MixedReality.Portal"
}

function Debloat-CommonApps {
    Write-Log "Removing common bloatware apps..." Yellow
    Remove-App "Microsoft.MicrosoftSolitaireCollection"
    Remove-App "Microsoft.SkypeApp"
    Remove-App "Microsoft.YourPhone"
}

function Debloat-AggressiveApps {
    Write-Log "Removing aggressive bloatware apps..." Yellow
    Remove-App "Microsoft.BingWeather"
    Remove-App "Microsoft.GetHelp"
    Remove-App "Microsoft.Getstarted"
    Remove-App "Microsoft.ZuneMusic"
    Remove-App "Microsoft.ZuneVideo"
    Remove-App "Microsoft.WindowsMaps"
    Remove-App "Microsoft.MSPaint"
    Remove-App "Microsoft.WindowsCamera"
    Remove-App "Microsoft.People"
    Remove-App "Microsoft.Print3D"
}

function Debloat-DisableServices {
    Write-Log "Disabling extra services..." Yellow
    Disable-Service -serviceName "WSearch" # Windows Search
}
function Remove-MicrosoftEdge {
    Write-Log "Removing Microsoft Edge..." Yellow
    $EdgePath = "$env:ProgramFiles(x86)\Microsoft\Edge\Application"
    if (Test-Path $EdgePath) {
        $InstallerPath = Join-Path $EdgePath "Installer\setup.exe"
        if (Test-Path $InstallerPath) {
            Start-Process -FilePath $InstallerPath -ArgumentList "--uninstall --system-level --verbose-logging --force-uninstall" -Wait -NoNewWindow
            Write-Log "Microsoft Edge removed." Green
        } else {
            Write-Log "Microsoft Edge installer not found." Red
        }
    } else {
        Write-Log "Microsoft Edge path not found." Red
    }
}

function Download-And-Install-Browser {
    param(
        [string]$name,
        [string]$url,
        [string]$installerArgs = "/silent /install"
    )
    $tempInstaller = "$env:TEMP\$name-installer.exe"
    try {
        Write-Log "Downloading $name..." Cyan
        Invoke-WebRequest -Uri $url -OutFile $tempInstaller -UseBasicParsing
        Write-Log "Installing $name..." Cyan
        Start-Process -FilePath $tempInstaller -ArgumentList $installerArgs -Wait
        Remove-Item $tempInstaller -Force
        Write-Log "$name installation completed." Green
    }
    catch {
        Write-Log "Failed to install $name." Red
    }
}

function Install-Browsers {
    Write-Log $txt.DownloadingBrowsers Cyan
    Download-And-Install-Browser -name "Google Chrome" -url "https://dl.google.com/chrome/install/latest/chrome_installer.exe" -installerArgs "/silent /install"
    Download-And-Install-Browser -name "Mozilla Firefox" -url "https://download.mozilla.org/?product=firefox-stub&os=win&lang=en-US" -installerArgs "-ms"
    Download-And-Install-Browser -name "Opera GX" -url "https://download.opera.com/gx/installer/Opera_GX_Installer.exe" -installerArgs "/silent"
    Download-And-Install-Browser -name "Opera" -url "https://download.opera.com/ftp/pub/opera/desktop/installs/80.0.4170.16/win/Opera_80.0.4170.16_Setup.exe" -installerArgs "/silent"
}

function Debloat-Minimum {
    Debloat-Telemetry
}

function Debloat-Medium {
    Debloat-Minimum
    Debloat-XboxApps
    Debloat-OneDrive
    Debloat-MixedReality
    Debloat-CommonApps
}

function Debloat-High {
    Debloat-Medium
    Debloat-AggressiveApps
    Remove-MicrosoftEdge
}

function Debloat-Extreme {
    Debloat-High
    Debloat-DisableServices
    # Entferne Defender & andere Sicherheitsfeatures
    Write-Log "Disabling Windows Defender and security features..." Yellow
    try {
        Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
        Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction SilentlyContinue
        Set-MpPreference -DisableOnAccessProtection $true -ErrorAction SilentlyContinue
        Write-Log "Windows Defender disabled." Green
    }
    catch {
        Write-Log "Failed to disable Windows Defender." Red
    }
    Install-Browsers
}
function Debloat-Custom {
    if (Read-YesNo "Telemetry & Data Collection" $chosenLang) { Debloat-Telemetry }
    if (Read-YesNo "Remove Xbox Apps" $chosenLang) { Debloat-XboxApps }
    if (Read-YesNo "Remove OneDrive" $chosenLang) { Debloat-OneDrive }
    if (Read-YesNo "Remove Mixed Reality Portal" $chosenLang) { Debloat-MixedReality }
    if (Read-YesNo "Remove Common Apps (Solitaire, Skype, YourPhone)" $chosenLang) { Debloat-CommonApps }
    if (Read-YesNo "Remove Aggressive Apps (Weather, GetHelp, Paint, etc.)" $chosenLang) { Debloat-AggressiveApps }
    if (Read-YesNo "Disable extra Services (Search)" $chosenLang) { Debloat-DisableServices }
    if (Read-YesNo "Remove Microsoft Edge" $chosenLang) { Remove-MicrosoftEdge }
    if (Read-YesNo "Disable Windows Defender and security features" $chosenLang) { 
        Write-Log "Disabling Windows Defender and security features..." Yellow
        try {
            Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
            Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction SilentlyContinue
            Set-MpPreference -DisableOnAccessProtection $true -ErrorAction SilentlyContinue
            Write-Log "Windows Defender disabled." Green
        }
        catch {
            Write-Log "Failed to disable Windows Defender." Red
        }
    }
    if (Read-YesNo "Install browsers (Chrome, Firefox, Opera GX, Opera)" $chosenLang) { Install-Browsers }
}

try {
    Clear-Host
    Check-Admin

    Write-Host $Lang.en.ChooseLang -ForegroundColor Cyan
    $chosenLang = Read-Host
    if ($chosenLang -ne "de" -and $chosenLang -ne "en" -and $chosenLang -ne "tr") { $chosenLang = "en" }
    $txt = $Lang[$chosenLang]

    Write-Host "`n$($txt.Welcome)" -ForegroundColor Cyan
    if (Confirm-Action $txt.IsFreshWindows $chosenLang) {
        Write-Log "Detected fresh Windows installation." Green
        Write-Host "Browsers (Chrome, Firefox, Opera GX, Opera) will be installed automatically." -ForegroundColor Yellow
        $autoInstallBrowsers = $true
    } else {
        $autoInstallBrowsers = $false
    }

    Write-Host $txt.ChooseLevel -ForegroundColor Yellow
    foreach ($option in $txt.Options) {
        Write-Host $option -ForegroundColor Green
    }

    $choice = Read-Host "Enter number / Nummer eingeben"
    if ($choice -notin "1","2","3","4","5") {
        Write-Host $txt.InvalidChoice -ForegroundColor Red
        exit
    }

    if (-not (Confirm-Action $txt.Confirm $chosenLang)) {
        Write-Host $txt.Aborted -ForegroundColor Red
        exit
    }

    Write-Host "$($txt.Running) $choice" -ForegroundColor Yellow

    switch ($choice) {
        "1" { Debloat-Minimum }
        "2" { Debloat-Medium }
        "3" { Debloat-High }
        "4" { 
            Debloat-Extreme
            if ($autoInstallBrowsers) {
                Install-Browsers
            }
        }
        "5" { Debloat-Custom }
    }

    if ($autoInstallBrowsers -and $choice -ne "4") {
        Write-Host "Automatically installing browsers for fresh Windows." -ForegroundColor Yellow
        Install-Browsers
    }

    Write-Host "`n$($txt.Done)" -ForegroundColor Cyan
    Write-Host $txt.RestartPrompt -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Restart-Computer -Force
}
catch {
    Write-Host "$($txt.Error) $_" -ForegroundColor Red
    exit 1
}
$Lang = @{
    "en" = @{
        "Welcome"            = "Welcome to Debloatranium 2025!"
        "ChooseLang"         = "Choose language (en/de/tr):"
        "ChooseLevel"        = "Select debloat level:"
        "Options"            = @(
            "1) Minimum - Disable telemetry only",
            "2) Medium - Remove common bloatware apps",
            "3) High - Aggressive system cleanup including Microsoft Edge removal",
            "4) Extreme - Full system cleanup including disabling security features",
            "5) Custom - Choose what to remove"
        )
        "InvalidChoice"      = "Invalid choice. Exiting."
        "Confirm"            = "Are you sure you want to continue? (Y/N):"
        "Aborted"            = "Operation aborted by user."
        "Running"            = "Running debloat level:"
        "DownloadingBrowsers"= "Downloading and installing browsers..."
        "Done"               = "Debloatranium finished successfully."
        "Error"              = "An error occurred:"
        "NeedAdmin"          = "Please run this script as Administrator!"
        "YesNoPrompt"        = "Do you want to apply this? (Y/N):"
        "IsFreshWindows"     = "Is this a fresh Windows installation? (Y/N):"
        "RestartPrompt"      = "Press any key to restart your PC..."
    }
    "de" = @{
        "Welcome"            = "Willkommen bei Debloatranium 2025!"
        "ChooseLang"         = "Sprache wählen (en/de/tr):"
        "ChooseLevel"        = "Wähle Debloat-Stufe:"
        "Options"            = @(
            "1) Minimum - Nur Telemetrie deaktivieren",
            "2) Mittel - Übliche Bloatware entfernen",
            "3) Hoch - Aggressive Systembereinigung inkl. Microsoft Edge Entfernen",
            "4) Extrem - Volle Systembereinigung inkl. Sicherheitsfeatures deaktivieren",
            "5) Benutzerdefiniert - Wähle einzeln, was entfernt wird"
        )
        "InvalidChoice"      = "Ungültige Eingabe. Programm wird beendet."
        "Confirm"            = "Bist du sicher, dass du fortfahren willst? (J/N):"
        "Aborted"            = "Vom Benutzer abgebrochen."
        "Running"            = "Starte Debloat-Stufe:"
        "DownloadingBrowsers"= "Browser werden heruntergeladen und installiert..."
        "Done"               = "Debloatranium wurde erfolgreich abgeschlossen."
        "Error"              = "Ein Fehler ist aufgetreten:"
        "NeedAdmin"          = "Bitte führe das Skript als Administrator aus!"
        "YesNoPrompt"        = "Willst du das anwenden? (J/N):"
        "IsFreshWindows"     = "Ist dies eine frische Windows-Installation? (J/N):"
        "RestartPrompt"      = "Drücke eine Taste, um den PC neu zu starten..."
    }
    "tr" = @{
        "Welcome"            = "Debloatranium 2025'e hoş geldiniz!"
        "ChooseLang"         = "Dil seçin (en/de/tr):"
        "ChooseLevel"        = "Temizleme seviyesini seçin:"
        "Options"            = @(
            "1) Minimum - Sadece telemetriyi devre dışı bırak",
            "2) Orta - Yaygın gereksiz uygulamaları kaldır",
            "3) Yüksek - Microsoft Edge kaldırma dahil agresif sistem temizliği",
            "4) Aşırı - Güvenlik özellikleri devre dışı bırakma dahil tam temizlik",
            "5) Özel - Kaldırılacakları seçin"
        )
        "InvalidChoice"      = "Geçersiz seçim. Çıkılıyor."
        "Confirm"            = "Devam etmek istediğinizden emin misiniz? (E/H):"
        "Aborted"            = "Kullanıcı tarafından iptal edildi."
        "Running"            = "Temizleme seviyesi çalıştırılıyor:"
        "DownloadingBrowsers"= "Tarayıcılar indiriliyor ve kuruluyor..."
        "Done"               = "Debloatranium başarıyla tamamlandı."
        "Error"              = "Bir hata oluştu:"
        "NeedAdmin"          = "Lütfen bu betiği Yönetici olarak çalıştırın!"
        "YesNoPrompt"        = "Uygulamak ister misiniz? (E/H):"
        "IsFreshWindows"     = "Bu yeni bir Windows kurulumu mu? (E/H):"
        "RestartPrompt"      = "PC'nizi yeniden başlatmak için bir tuşa basın..."
    }
}

function Write-Log {
    param([string]$Message, [string]$Color="White")
    Write-Host $Message -ForegroundColor $Color
}

function Read-YesNo {
    param(
        [string]$prompt,
        [string]$lang
    )
    while ($true) {
        Write-Host $prompt -ForegroundColor Cyan
        $answer = Read-Host
        if ($lang -eq "de") {
            if ($answer.ToLower() -eq "j") { return $true }
            elseif ($answer.ToLower() -eq "n") { return $false }
        }
        elseif ($lang -eq "tr") {
            if ($answer.ToLower() -eq "e") { return $true }
            elseif ($answer.ToLower() -eq "h") { return $false }
        }
        else {
            if ($answer.ToLower() -eq "y") { return $true }
            elseif ($answer.ToLower() -eq "n") { return $false }
        }
        Write-Host "Please answer with Y/N or J/N or E/H." -ForegroundColor Red
    }
}
function Check-Admin {
    if (-not ([Security.Principal.WindowsPrincipal] `
        [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltinRole]::Administrator)) {
        Write-Log $txt.NeedAdmin Red
        exit 1
    }
}

function Disable-Service {
    param([string]$serviceName)
    try {
        Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
        Set-Service -Name $serviceName -StartupType Disabled
        Write-Log "Disabled service: $serviceName" Green
    }
    catch {
        Write-Log "Failed to disable service: $serviceName" Red
    }
}

function Debloat-Telemetry {
    Write-Log "Disabling telemetry and data collection..." Yellow
    Disable-Service -serviceName "DiagTrack"
    Disable-Service -serviceName "dmwappushservice"
    Disable-Service -serviceName "lfsvc"
}
function Remove-App {
    param([string]$packageName)
    try {
        Get-AppxPackage -Name $packageName -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -EQ $packageName | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
        Write-Log "Removed package: $packageName" Green
    }
    catch {
        Write-Log "Failed to remove package: $packageName" Red
    }
}

function Debloat-XboxApps {
    Write-Log "Removing Xbox related apps..." Yellow
    Remove-App "Microsoft.XboxApp"
    Remove-App "Microsoft.XboxGamingOverlay"
    Remove-App "Microsoft.XboxSpeechToTextOverlay"
}

function Debloat-OneDrive {
    Write-Log "Removing OneDrive..." Yellow
    Remove-App "Microsoft.OneDrive"
}

function Debloat-MixedReality {
    Write-Log "Removing Mixed Reality Portal..." Yellow
    Remove-App "Microsoft.MixedReality.Portal"
}

function Debloat-CommonApps {
    Write-Log "Removing common bloatware apps..." Yellow
    Remove-App "Microsoft.MicrosoftSolitaireCollection"
    Remove-App "Microsoft.SkypeApp"
    Remove-App "Microsoft.YourPhone"
}

function Debloat-AggressiveApps {
    Write-Log "Removing aggressive bloatware apps..." Yellow
    Remove-App "Microsoft.BingWeather"
    Remove-App "Microsoft.GetHelp"
    Remove-App "Microsoft.Getstarted"
    Remove-App "Microsoft.ZuneMusic"
    Remove-App "Microsoft.ZuneVideo"
    Remove-App "Microsoft.WindowsMaps"
    Remove-App "Microsoft.MSPaint"
    Remove-App "Microsoft.WindowsCamera"
    Remove-App "Microsoft.People"
    Remove-App "Microsoft.Print3D"
}

function Remove-MicrosoftEdge {
    Write-Log "Removing Microsoft Edge..." Yellow
    $edgePath = "$env:ProgramFiles(x86)\Microsoft\Edge\Application\msedge.exe"
    if (Test-Path $edgePath) {
        $uninstallPath = "$env:ProgramFiles(x86)\Microsoft\Edge\Application\$(Get-ChildItem $env:ProgramFiles(x86)\Microsoft\Edge\Application | Sort-Object Name -Descending | Select-Object -First 1)\Installer\setup.exe"
        Start-Process -FilePath $uninstallPath -ArgumentList "--uninstall --force-uninstall --system-level" -Wait -NoNewWindow
        Write-Log "Microsoft Edge removed." Green
    } else {
        Write-Log "Microsoft Edge not found." Yellow
    }
}
function Debloat-DisableServices {
    Write-Log "Disabling extra services..." Yellow
    Disable-Service -serviceName "WSearch" # Windows Search
    Disable-Service -serviceName "SysMain" # Superfetch
    Disable-Service -serviceName "WMPNetworkSvc" # Windows Media Player Network Sharing Service
}

function Download-And-Install-Browser {
    param(
        [string]$name,
        [string]$url,
        [string]$installerArgs = "/silent /install"
    )
    $tempInstaller = "$env:TEMP\$name-installer.exe"
    try {
        Write-Log "Downloading $name..." Cyan
        Invoke-WebRequest -Uri $url -OutFile $tempInstaller -UseBasicParsing
        Write-Log "Installing $name..." Cyan
        Start-Process -FilePath $tempInstaller -ArgumentList $installerArgs -Wait
        Remove-Item $tempInstaller -Force
        Write-Log "$name installation completed." Green
    }
    catch {
        Write-Log "Failed to install $name." Red
    }
}

function Install-Browsers {
    Write-Log $txt.DownloadingBrowsers Cyan

    Download-And-Install-Browser -name "Google Chrome" -url "https://dl.google.com/chrome/install/latest/chrome_installer.exe" -installerArgs "/silent /install"
    Download-And-Install-Browser -name "Mozilla Firefox" -url "https://download.mozilla.org/?product=firefox-stub&os=win&lang=en-US" -installerArgs "-ms"
    Download-And-Install-Browser -name "Opera GX" -url "https://download.opera.com/gx/installer/Opera_GX_Installer.exe" -installerArgs "/silent"
    Download-And-Install-Browser -name "Opera" -url "https://download.opera.com/ftp/pub/opera/desktop/installs/80.0.4170.16/win/Opera_80.0.4170.16_Setup.exe" -installerArgs "/silent"
}

function Debloat-Minimum {
    Debloat-Telemetry
}

function Debloat-Medium {
    Debloat-Minimum
    Debloat-XboxApps
    Debloat-OneDrive
    Debloat-MixedReality
    Debloat-CommonApps
}

function Debloat-High {
    Debloat-Medium
    Debloat-AggressiveApps
    Remove-MicrosoftEdge
}

function Debloat-Extreme {
    Debloat-High
    Debloat-DisableServices
    # Disable Windows Defender (Be careful!)
    try {
        Write-Log "Disabling Windows Defender (security risk)..." Yellow
        Set-MpPreference -DisableRealtimeMonitoring $true
        Set-MpPreference -DisableBehaviorMonitoring $true
        Set-MpPreference -DisableOnAccessProtection $true
        Set-MpPreference -DisableIOAVProtection $true
        Write-Log "Windows Defender disabled." Green
    }
    catch {
        Write-Log "Failed to disable Windows Defender." Red
    }
}
try {
    Clear-Host
    Check-Admin

    Write-Host $Lang.en.ChooseLang -ForegroundColor Cyan
    $chosenLang = Read-Host
    if ($chosenLang -ne "de" -and $chosenLang -ne "en") { $chosenLang = "en" }
    $txt = $Lang[$chosenLang]

    Write-Host "`n$($txt.Welcome)" -ForegroundColor Cyan
    Write-Host $txt.ChooseLevel -ForegroundColor Yellow
    foreach ($option in $txt.Options) {
        Write-Host $option -ForegroundColor Green
    }

    $choice = Read-Host "Enter number / Nummer eingeben"
    if ($choice -notin "1","2","3","4","5") {
        Write-Host $txt.InvalidChoice -ForegroundColor Red
        exit
    }

    if (-not (Confirm-Action $txt.Confirm $chosenLang)) {
        Write-Host $txt.Aborted -ForegroundColor Red
        exit
    }

    Write-Host "$($txt.Running) $choice" -ForegroundColor Yellow

    switch ($choice) {
        "1" { Debloat-Minimum }
        "2" { Debloat-Medium }
        "3" { Debloat-High }
        "4" { Debloat-Extreme }
        "5" { Debloat-Custom }
    }

    Write-Host "`n$($txt.Done)" -ForegroundColor Cyan

    Write-Host $txt.RestartPrompt -ForegroundColor Yellow
    Write-Host "Press any key to restart or Ctrl+C to cancel..." -ForegroundColor Cyan
    [void][System.Console]::ReadKey($true)
    Restart-Computer -Force
}
catch {
    Write-Host "$($txt.Error) $_" -ForegroundColor Red
    exit 1
}
