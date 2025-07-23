# Debloatranium 2025 – Multi-level Windows Debloat Tool with Custom Mode
# by Emre's AI Helper
# Run as Administrator!

# ------------------------------
# 1. Spracheinstellungen & Texte
# ------------------------------
$Lang = @{
    "en" = @{
        "Welcome"            = "Welcome to Debloatranium 2025!"
        "ChooseLang"         = "Choose language (en/de/tr):"
        "ChooseLevel"        = "Select debloat level:"
        "Options"            = @(
            "1) Minimum - Disable telemetry only",
            "2) Medium - Remove common bloatware apps",
            "3) High - Aggressive system cleanup",
            "4) Extreme - Full Windows debloat + security & antivirus removal + browser install",
            "5) Custom - Choose what to remove"
        )
        "InvalidChoice"      = "Invalid choice. Exiting."
        "Confirm"            = "Are you sure you want to continue? (Y/N):"
        "Aborted"            = "Operation aborted by user."
        "Running"            = "Running debloat level:"
        "DownloadingBrowsers" = "Downloading and installing browsers..."
        "Done"               = "Debloatranium finished successfully."
        "Error"              = "An error occurred:"
        "NeedAdmin"          = "Please run this script as Administrator!"
        "YesNoPrompt"        = "Do you want to apply this? (Y/N):"
        "RestartPrompt"      = "System changes require restart. Press any key to restart or Ctrl+C to cancel."
        "FreshDetected"      = "Detected fresh Windows installation (<=10 days). Browsers will be installed."
        "FreshNotDetected"   = "Windows installation older than 10 days."
        "PressAnyKey"        = "Press any key to continue..."
        "AnswerYes"          = "y"
        "AnswerNo"           = "n"
    }
    "de" = @{
        "Welcome"            = "Willkommen bei Debloatranium 2025!"
        "ChooseLang"         = "Sprache wählen (en/de/tr):"
        "ChooseLevel"        = "Wähle Debloat-Stufe:"
        "Options"            = @(
            "1) Minimum - Nur Telemetrie deaktivieren",
            "2) Mittel - Übliche Bloatware entfernen",
            "3) Hoch - Aggressive Systembereinigung",
            "4) Extrem - Volle Bereinigung + Sicherheit & Antivirus Entfernen + Browser-Installation",
            "5) Benutzerdefiniert - Wähle einzeln, was entfernt wird"
        )
        "InvalidChoice"      = "Ungültige Eingabe. Programm wird beendet."
        "Confirm"            = "Bist du sicher, dass du fortfahren willst? (J/N):"
        "Aborted"            = "Vom Benutzer abgebrochen."
        "Running"            = "Starte Debloat-Stufe:"
        "DownloadingBrowsers" = "Browser werden heruntergeladen und installiert..."
        "Done"               = "Debloatranium wurde erfolgreich abgeschlossen."
        "Error"              = "Ein Fehler ist aufgetreten:"
        "NeedAdmin"          = "Bitte führe das Skript als Administrator aus!"
        "YesNoPrompt"        = "Willst du das anwenden? (J/N):"
        "RestartPrompt"      = "Systemänderungen erfordern einen Neustart. Beliebige Taste zum Neustart drücken oder Ctrl+C zum Abbrechen."
        "FreshDetected"      = "Frisches Windows erkannt (<=10 Tage). Browser werden installiert."
        "FreshNotDetected"   = "Windows-Installation älter als 10 Tage."
        "PressAnyKey"        = "Beliebige Taste zum Fortfahren drücken..."
        "AnswerYes"          = "j"
        "AnswerNo"           = "n"
    }
    "tr" = @{
        "Welcome"            = "Debloatranium 2025'e hoş geldiniz!"
        "ChooseLang"         = "Dil seçiniz (en/de/tr):"
        "ChooseLevel"        = "Temizleme seviyesi seçin:"
        "Options"            = @(
            "1) Minimum - Sadece telemetriyi devre dışı bırak",
            "2) Orta - Yaygın gereksiz uygulamaları kaldır",
            "3) Yüksek - Agresif sistem temizliği",
            "4) Aşırı - Tam Windows temizliği + güvenlik & antivirüs kaldırma + tarayıcı kurulumu",
            "5) Özel - Kaldırılacakları seç"
        )
        "InvalidChoice"      = "Geçersiz seçim. Çıkılıyor."
        "Confirm"            = "Devam etmek istediğinizden emin misiniz? (E/H):"
        "Aborted"            = "İşlem kullanıcı tarafından iptal edildi."
        "Running"            = "Temizleme seviyesi çalışıyor:"
        "DownloadingBrowsers" = "Tarayıcılar indiriliyor ve kuruluyor..."
        "Done"               = "Debloatranium başarıyla tamamlandı."
        "Error"              = "Bir hata oluştu:"
        "NeedAdmin"          = "Lütfen bu betiği Yönetici olarak çalıştırın!"
        "YesNoPrompt"        = "Uygulamak istiyor musunuz? (E/H):"
        "RestartPrompt"      = "Sistem değişiklikleri yeniden başlatma gerektirir. Yeniden başlatmak için bir tuşa basın veya iptal için Ctrl+C'ye basın."
        "FreshDetected"      = "Taze Windows kurulumu tespit edildi (<=10 gün). Tarayıcılar kurulacak."
        "FreshNotDetected"   = "Windows kurulumu 10 günden eski."
        "PressAnyKey"        = "Devam etmek için bir tuşa basın..."
        "AnswerYes"          = "e"
        "AnswerNo"           = "h"
    }
}

# ------------------------------
# 2. Hilfsfunktionen
# ------------------------------
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
    param([string]$Prompt)
    while ($true) {
        Write-Host $Prompt -ForegroundColor Yellow
        $answer = Read-Host
        if ($answer.ToLower() -eq $txt.AnswerYes) { return $true }
        elseif ($answer.ToLower() -eq $txt.AnswerNo) { return $false }
        else { Write-Host "Please answer with correct input." -ForegroundColor Red }
    }
}

function Read-YesNo {
    param([string]$Prompt)
    while ($true) {
        Write-Host $Prompt -ForegroundColor Cyan
        $answer = Read-Host
        if ($answer.ToLower() -eq $txt.AnswerYes) { return $true }
        elseif ($answer.ToLower() -eq $txt.AnswerNo) { return $false }
        else { Write-Host "Please answer with correct input." -ForegroundColor Red }
    }
}

function Remove-App {
    param([string]$PackageName)
    try {
        Get-AppxPackage -Name $PackageName -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -EQ $PackageName | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
        Write-Log "Removed app: $PackageName" Green
    }
    catch {
        Write-Log "Failed to remove app: $PackageName" Red
    }
}

function Disable-Service {
    param([string]$ServiceName)
    try {
        Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
        Set-Service -Name $ServiceName -StartupType Disabled
        Write-Log "Disabled service: $ServiceName" Green
    }
    catch {
        Write-Log "Failed to disable service: $ServiceName" Red
    }
}

function Download-And-Install-Browser {
    param(
        [string]$Name,
        [string]$Url,
        [string]$InstallerArgs = "/silent /install"
    )
    $tempInstaller = "$env:TEMP\$Name-installer.exe"
    try {
        Write-Log "Downloading $Name..." Cyan
        Invoke-WebRequest -Uri $Url -OutFile $tempInstaller -UseBasicParsing
        Write-Log "Installing $Name..." Cyan
        Start-Process -FilePath $tempInstaller -ArgumentList $InstallerArgs -Wait
        Remove-Item $tempInstaller -Force
        Write-Log "$Name installation completed." Green
    }
    catch {
        Write-Log "Failed to install $Name." Red
    }
}

# ------------------------------
# 3. Debloat Funktionen
# ------------------------------
function Debloat-Telemetry {
    Write-Log "Disabling telemetry and data collection..." Yellow
    Disable-Service -ServiceName "DiagTrack"
    Disable-Service -ServiceName "dmwappushservice"
    Disable-Service -ServiceName "lfsvc"
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
    Disable-Service -ServiceName "WSearch"
    Disable-Service -ServiceName "wuauserv"  # Windows Update Service for Extreme
    Disable-Service -ServiceName "SecurityHealthService" # Windows Security Center for Extreme
}

function Debloat-RemoveEdge {
    Write-Log "Removing Microsoft Edge..." Yellow
    $edgePath = "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"
    if (Test-Path $edgePath) {
        try {
            # Use Edge installer uninstall switch
            Start-Process -FilePath "$env:ProgramFiles\Microsoft\Edge\Application\90.0.818.66\Installer\setup.exe" -ArgumentList "--uninstall --system-level --verbose-logging --force-uninstall" -Wait -ErrorAction Stop
            Write-Log "Microsoft Edge removed." Green
        }
        catch {
            Write-Log "Failed to remove Microsoft Edge." Red
        }
    } else {
        Write-Log "Microsoft Edge not found or already removed." Yellow
    }
}

function Install-Browsers {
    Write-Log $txt.DownloadingBrowsers Cyan

    Download-And-Install-Browser -Name "Google Chrome" -Url "https://dl.google.com/chrome/install/latest/chrome_installer.exe" -InstallerArgs "/silent /install"
    Download-And-Install-Browser -Name "Mozilla Firefox" -Url "https://download.mozilla.org/?product=firefox-stub&os=win&lang=en-US" -InstallerArgs "-ms"
    Download-And-Install-Browser -Name "Opera GX" -Url "https://download.opera.com/gx/installer/Opera_GX_Installer.exe" -InstallerArgs "/silent"
    Download-And-Install-Browser -Name "Opera" -Url "https://download.opera.com/ftp/pub/opera/desktop/installs/80.0.4170.16/win/Opera_80.0.4170.16_Setup.exe" -InstallerArgs "/silent"
}

# ------------------------------
# 4. Debloat Profile
# ------------------------------
function Profile-Minimum {
    Debloat-Telemetry
}

function Profile-Medium {
    Profile-Minimum
    Debloat-XboxApps
    Debloat-OneDrive
    Debloat-MixedReality
    Debloat-CommonApps
}

function Profile-High {
    Profile-Medium
    Debloat-AggressiveApps
}

function Profile-Extreme {
    Profile-High
    Debloat-DisableServices
    Debloat-RemoveEdge
    Install-Browsers
}

# ------------------------------
# 5. Custom Mode - Einzelabfragen
# ------------------------------
function Custom-Debloat-Questions {
    if (Read-YesNo "Disable telemetry and data collection?") { Debloat-Telemetry }
    if (Read-YesNo "Remove Xbox related apps?") { Debloat-XboxApps }
    if (Read-YesNo "Remove OneDrive?") { Debloat-OneDrive }
    if (Read-YesNo "Remove Mixed Reality Portal?") { Debloat-MixedReality }
    if (Read-YesNo "Remove common bloatware apps (Solitaire, Skype, YourPhone)?") { Debloat-CommonApps }
    if (Read-YesNo "Remove aggressive bloatware apps (Weather, GetHelp, Paint, etc.)?") { Debloat-AggressiveApps }
    if (Read-YesNo "Disable extra services (Search, Update, Security)?") { Debloat-DisableServices }
    if (Read-YesNo "Remove Microsoft Edge?") { Debloat-RemoveEdge }
    if (Read-YesNo "Install browsers (Chrome, Firefox, Opera GX, Opera)?") { Install-Browsers }
}

# ------------------------------
# 6. Systemprüfung & Neustart
# ------------------------------
function Create-SystemRestorePoint {
    Write-Log "Creating system restore point..." Yellow
    try {
        $sr = Get-CimInstance -Namespace "root/default" -ClassName SystemRestore
        $result = $sr.CreateRestorePoint("Debloatranium Backup", 0, 100)
        if ($result -eq 0) {
            Write-Log "System restore point created successfully." Green
        } else {
            Write-Log "Failed to create system restore point. Error code: $result" Red
        }
    }
    catch {
        Write-Log "Error creating system restore point: $_" Red
    }
}

function Apply-RegistryTweaks {
    Write-Log "Applying registry tweaks for performance & privacy..." Yellow

    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoRebootWithLoggedOnUsers" -PropertyType DWord -Value 1 -Force | Out-Null
    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -PropertyType DWord -Value 1 -Force | Out-Null
    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "DoNotShowFeedbackNotifications" -PropertyType DWord -Value 1 -Force | Out-Null

    Write-Log "Registry tweaks applied." Green
}

function Optimize-PowerPlan {
    Write-Log "Optimizing power plan for best performance..." Yellow
    $plans = powercfg -list
    $highPerfPlan = ($plans | Where-Object { $_ -match "High performance" }) -split '\s+'
    if ($highPerfPlan.Length -ge 2) {
        $guid = $highPerfPlan[1]
        powercfg -setactive $guid
        Write-Log "Power plan set to High performance." Green
    } else {
        Write-Log "High performance power plan not found. Skipping." Yellow
    }
}

function Prompt-Restart {
    Write-Host "`n$($txt.RestartPrompt)" -ForegroundColor Cyan
    [void][System.Console]::ReadKey($true)
    Write-Log "Restarting system now..." Yellow
    Restart-Computer -Force
}

function Is-FreshWindows {
    try {
        $installDateStr = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").InstallDate
        if (-not $installDateStr) { return $false }
        $installDate = [DateTime]::UnixEpoch.AddSeconds([int]$installDateStr)
        $ageDays = (Get-Date) - $installDate
        return $ageDays.TotalDays -le 10
    } catch {
        return $false
    }
}

function Finalize-Debloat {
    Create-SystemRestorePoint
    Apply-RegistryTweaks
    Optimize-PowerPlan
    Prompt-Restart
}

# ------------------------------
# 7. Hauptskript Ablauf
# ------------------------------

Clear-Host
Check-Admin

$chosenLang = $null
do {
    Write-Host $Lang.en.ChooseLang -ForegroundColor Cyan
    $chosenLang = Read-Host
} while ($chosenLang -notin @("en","de","tr"))
$txt = $Lang[$chosenLang]

Write-Host "`n$($txt.Welcome)" -ForegroundColor Cyan

$freshWin = Is-FreshWindows
if ($freshWin) {
    Write-Host $txt.FreshDetected -ForegroundColor Green
} else {
    Write-Host $txt.FreshNotDetected -ForegroundColor Yellow
}

Write-Host "`n$($txt.ChooseLevel)" -ForegroundColor Yellow
foreach ($opt in $txt.Options) {
    Write-Host $opt -ForegroundColor Green
}

$choice = $null
do {
    $choice = Read-Host "Enter number / Nummer eingeben"
} while ($choice -notin "1","2","3","4","5")

if (-not (Confirm-Action $txt.Confirm)) {
    Write-Host $txt.Aborted -ForegroundColor Red
    exit
}

Write-Host "$($txt.Running) $choice" -ForegroundColor Yellow

switch ($choice) {
    "1" { Profile-Minimum }
    "2" { Profile-Medium }
    "3" { Profile-High }
    "4" { Profile-Extreme }
    "5" { Custom-Debloat-Questions }
}

if ($freshWin -and ($choice -in "2","3","4","5")) {
    Write-Host $txt.DownloadingBrowsers -ForegroundColor Cyan
    Install-Browsers
}

Write-Host "`n$($txt.Done)" -ForegroundColor Cyan

Finalize-Debloat
