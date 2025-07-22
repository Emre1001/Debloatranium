# ----------------------------------------
# Debloatranium 2025 – Multi-level Debloat Tool
# Modular, multilingual, with browser installation
# by Emre's AI Helper
# ----------------------------------------

# ------------------------------
# 1. Spracheinstellungen & Texte
# ------------------------------
$Lang = @{
    "en" = @{
        "Welcome"           = "Welcome to Debloatranium 2025!"
        "ChooseLang"        = "Choose language (en/de):"
        "ChooseLevel"       = "Select debloat level:"
        "Options"           = @(
            "1) Minimum - Disable telemetry only",
            "2) Medium - Remove common bloatware apps",
            "3) High - Aggressive system cleanup",
            "4) Maximum - Full Windows debloat + browser install"
        )
        "InvalidChoice"     = "Invalid choice. Exiting."
        "Confirm"           = "Are you sure you want to continue? (Y/N):"
        "Aborted"           = "Operation aborted by user."
        "Running"           = "Running debloat level:"
        "DownloadingBrowsers"= "Downloading and installing browsers..."
        "Done"              = "Debloatranium finished successfully."
        "Error"             = "An error occurred:"
        "NeedAdmin"         = "Please run this script as Administrator!"
    }
    "de" = @{
        "Welcome"           = "Willkommen bei Debloatranium 2025!"
        "ChooseLang"        = "Sprache wählen (en/de):"
        "ChooseLevel"       = "Wähle Debloat-Stufe:"
        "Options"           = @(
            "1) Minimum - Nur Telemetrie deaktivieren",
            "2) Mittel - Übliche Bloatware entfernen",
            "3) Hoch - Aggressive Systembereinigung",
            "4) Maximum - Volle Bereinigung + Browser-Installation"
        )
        "InvalidChoice"     = "Ungültige Eingabe. Programm wird beendet."
        "Confirm"           = "Bist du sicher, dass du fortfahren willst? (J/N):"
        "Aborted"           = "Vom Benutzer abgebrochen."
        "Running"           = "Starte Debloat-Stufe:"
        "DownloadingBrowsers"= "Browser werden heruntergeladen und installiert..."
        "Done"              = "Debloatranium wurde erfolgreich abgeschlossen."
        "Error"             = "Ein Fehler ist aufgetreten:"
        "NeedAdmin"         = "Bitte führe das Skript als Administrator aus!"
    }
}

# ------------------------------
# 2. Helfer-Funktionen
# ------------------------------

# Schreibe Logs farbig in die Konsole
function Write-Log {
    param([string]$Message, [string]$Color="White")
    Write-Host $Message -ForegroundColor $Color
}

# Prüfe Adminrechte (braucht man, um Bloatware zu entfernen)
function Check-Admin {
    if (-not ([Security.Principal.WindowsPrincipal] `
        [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltinRole]::Administrator)) {
        Write-Log $txt.NeedAdmin Red
        exit 1
    }
}

# Bestätigungsabfrage mit Mehrsprachigkeit
function Confirm-Action {
    param(
        [string]$prompt,
        [string]$lang
    )
    Write-Host $prompt -ForegroundColor Yellow
    $answer = Read-Host
    if ($lang -eq "de") {
        return $answer.ToLower() -eq "j"
    } else {
        return $answer.ToLower() -eq "y"
    }
}

# Entferne Windows-App & Provisioned Package sicher
function Remove-App {
    param([string]$packageName)
    try {
        # Entfernt App für aktuellen User
        Get-AppxPackage -Name $packageName -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
        # Entfernt Provisioned Package (für neue User)
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -EQ $packageName | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
        Write-Log "Removed package: $packageName" Green
    }
    catch {
        Write-Log "Failed to remove package: $packageName" Red
    }
}

# Deaktiviere Windows-Service sicher
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

# Download & Install Browser mit Fehlerbehandlung
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

# ------------------------------
# 3. Debloat Stufen Funktionen
# ------------------------------

function Debloat-Minimum {
    Write-Log "Disabling telemetry and data collection..." Yellow
    # Telemetry services deaktivieren
    Disable-Service -serviceName "DiagTrack"
    Disable-Service -serviceName "dmwappushservice"
    Disable-Service -serviceName "lfsvc"
}

function Debloat-Medium {
    Write-Log "Removing common bloatware apps..." Yellow
    Remove-App "Microsoft.XboxApp"
    Remove-App "Microsoft.XboxGamingOverlay"
    Remove-App "Microsoft.XboxSpeechToTextOverlay"
    Remove-App "Microsoft.OneDrive"
    Remove-App "Microsoft.MixedReality.Portal"
    Remove-App "Microsoft.MicrosoftSolitaireCollection"
    Remove-App "Microsoft.SkypeApp"
    Remove-App "Microsoft.YourPhone"
}

function Debloat-High {
    Write-Log "Performing aggressive cleanup..." Yellow
    Debloat-Medium
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

function Debloat-Maximum {
    Write-Log "Executing full debloat and installing browsers..." Yellow
    Debloat-High

    # Dienste deaktivieren
    Disable-Service -serviceName "WSearch" # Windows Search (Indizierung deaktivieren)

    Write-Log $txt.DownloadingBrowsers Cyan

    # Browser installieren
    Download-And-Install-Browser -name "Google Chrome" -url "https://dl.google.com/chrome/install/latest/chrome_installer.exe" -installerArgs "/silent /install"
    Download-And-Install-Browser -name "Mozilla Firefox" -url "https://download.mozilla.org/?product=firefox-stub&os=win&lang=en-US" -installerArgs "-ms"
    Download-And-Install-Browser -name "Opera GX" -url "https://download.opera.com/gx/installer/Opera_GX_Installer.exe" -installerArgs "/silent"
    Download-And-Install-Browser -name "Opera" -url "https://download.opera.com/ftp/pub/opera/desktop/installs/80.0.4170.16/win/Opera_80.0.4170.16_Setup.exe" -installerArgs "/silent"
}

# ------------------------------
# 4. Main Script Ablauf
# ------------------------------

try {
    Clear-Host

    # Admin check
    Check-Admin

    # Sprache auswählen
    Write-Host $Lang.en.ChooseLang -ForegroundColor Cyan
    $chosenLang = Read-Host
    if ($chosenLang -ne "de" -and $chosenLang -ne "en") { $chosenLang = "en" }
    $txt = $Lang[$chosenLang]

    # Begrüßung und Menü
    Write-Host "`n$($txt.Welcome)" -ForegroundColor Cyan
    Write-Host $txt.ChooseLevel -ForegroundColor Yellow
    foreach ($option in $txt.Options) {
        Write-Host $option -ForegroundColor Green
    }

    # Wahl einlesen
    $choice = Read-Host "Enter number / Nummer eingeben"
    if ($choice -notin "1","2","3","4") {
        Write-Host $txt.InvalidChoice -ForegroundColor Red
        exit
    }

    # Sicherheitsabfrage
    if (-not (Confirm-Action $txt.Confirm $chosenLang)) {
        Write-Host $txt.Aborted -ForegroundColor Red
        exit
    }

    Write-Host "$($txt.Running) $choice" -ForegroundColor Yellow

    # Debloat starten
    switch ($choice) {
        "1" { Debloat-Minimum }
        "2" { Debloat-Medium }
        "3" { Debloat-High }
        "4" { Debloat-Maximum }
    }

    Write-Host "`n$($txt.Done)" -ForegroundColor Cyan
}
catch {
    Write-Host "$($txt.Error) $_" -ForegroundColor Red
    exit 1
}
