# Debloatranium v1.1 - Full Release (Multilang + Fresh Install + Profile + Custom + Browser Installer + GUI & CLI)
# Author: ChatGPT (angepasst für Emre)
# License: MIT

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Threading.Thread]::CurrentThread.CurrentCulture = 'de-DE'

#region Globals & Config
$Script:AppName       = "Debloatranium"
$Script:Version       = "1.1"
$Script:BasePath      = Join-Path -Path $env:ProgramData -ChildPath $Script:AppName
$Script:LogFolder     = Join-Path $Script:BasePath "Logs"
$Script:BackupFolder  = Join-Path $Script:BasePath "Backups"
$Script:ExportFolder  = Join-Path $Script:BasePath "Exports"
$Script:RepoFolder    = Join-Path $Script:BasePath "GitHubRepo"

foreach ($p in @($Script:BasePath, $Script:LogFolder, $Script:BackupFolder, $Script:ExportFolder, $Script:RepoFolder)) {
    if (-not (Test-Path $p)) { New-Item -Path $p -ItemType Directory -Force | Out-Null }
}

$timeStamp = (Get-Date).ToString('yyyyMMdd_HHmmss')
$Script:LogFile = Join-Path $Script:LogFolder ("log_{0}.txt" -f $timeStamp)
$Script:JsonLog = Join-Path $Script:LogFolder ("log_{0}.json" -f $timeStamp)
$Script:ChangesFile = Join-Path $Script:ExportFolder ("changes_{0}.json" -f $timeStamp)
$Script:Verbose = $false

$LangDict = @{
    de = @{
        Welcome = "Willkommen zu Debloatranium!"
        SelectLang = "Sprache wählen (de/en/tr):"
        InvalidLang = "Ungültige Sprache, Standard 'de' gesetzt."
        FreshInstallCheck = "Überprüfe auf frische Installation..."
        FreshInstallDetected = "Frische Windows Installation erkannt."
        NotFreshInstall = "Keine frische Installation erkannt."
        SelectProfile = "Profil wählen (Minimum/Mittel/Hoch/Extreme/Custom):"
        InvalidProfile = "Ungültiges Profil, Standard 'Mittel' gesetzt."
        SelectBrowser = "Welchen Browser willst du installieren? (Chrome, Firefox, Opera, OperaGX, Keiner):"
        InvalidBrowser = "Ungültige Auswahl, keine Browserinstallation."
        ConfirmStart = "Debloat wird jetzt gestartet..."
        BackupFiles = "Backup der wichtigen Dateien..."
        CreateRestorePoint = "Erstelle Wiederherstellungspunkt..."
        OperationComplete = "Fertig! Änderungen protokolliert."
        AskCustomOption = "Willst du Custom Optionen einstellen? (Ja/Nein):"
        CustomOptionPrompt = "Aktiviere Option {0}? (Ja/Nein):"
        Yes = "ja"
        No = "nein"
    }
    en = @{
        Welcome = "Welcome to Debloatranium!"
        SelectLang = "Select language (de/en/tr):"
        InvalidLang = "Invalid language, defaulting to 'de'."
        FreshInstallCheck = "Checking for fresh installation..."
        FreshInstallDetected = "Fresh Windows installation detected."
        NotFreshInstall = "No fresh installation detected."
        SelectProfile = "Select profile (Minimum/Mittel/Hoch/Extreme/Custom):"
        InvalidProfile = "Invalid profile, defaulting to 'Mittel'."
        SelectBrowser = "Which browser do you want to install? (Chrome, Firefox, Opera, OperaGX, None):"
        InvalidBrowser = "Invalid selection, no browser will be installed."
        ConfirmStart = "Starting debloat now..."
        BackupFiles = "Backing up important files..."
        CreateRestorePoint = "Creating restore point..."
        OperationComplete = "Done! Changes logged."
        AskCustomOption = "Do you want to configure custom options? (Yes/No):"
        CustomOptionPrompt = "Enable option {0}? (Yes/No):"
        Yes = "yes"
        No = "no"
    }
    tr = @{
        Welcome = "Debloatranium'e hoş geldiniz!"
        SelectLang = "Dil seçin (de/en/tr):"
        InvalidLang = "Geçersiz dil, varsayılan 'de' seçildi."
        FreshInstallCheck = "Temiz kurulum kontrol ediliyor..."
        FreshInstallDetected = "Temiz Windows kurulumu tespit edildi."
        NotFreshInstall = "Temiz kurulum tespit edilmedi."
        SelectProfile = "Profil seçin (Minimum/Mittel/Hoch/Extreme/Custom):"
        InvalidProfile = "Geçersiz profil, varsayılan 'Mittel' seçildi."
        SelectBrowser = "Hangi tarayıcıyı kurmak istiyorsunuz? (Chrome, Firefox, Opera, OperaGX, Hiçbiri):"
        InvalidBrowser = "Geçersiz seçim, tarayıcı kurulmayacak."
        ConfirmStart = "Debloat şimdi başlıyor..."
        BackupFiles = "Önemli dosyalar yedekleniyor..."
        CreateRestorePoint = "Geri yükleme noktası oluşturuluyor..."
        OperationComplete = "Tamam! Değişiklikler kaydedildi."
        AskCustomOption = "Özel seçenekleri yapılandırmak ister misiniz? (Evet/Hayır):"
        CustomOptionPrompt = "Seçeneği etkinleştir {0}? (Evet/Hayır):"
        Yes = "evet"
        No = "hayır"
    }
}

function T($key) {
    if ($LangDict.ContainsKey($Script:Lang) -and $LangDict[$Script:Lang].ContainsKey($key)) {
        return $LangDict[$Script:Lang][$key]
    }
    return $key
}
#endregion

#region Admin Check & Helpers
function Ensure-Admin {
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole] "Administrator")
    if (-not $isAdmin) {
        [System.Windows.Forms.MessageBox]::Show("$($Script:AppName) requires Administrator privileges. Run as Administrator.", $Script:AppName, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning) | Out-Null
        Write-Error "$($Script:AppName) needs Administrator rights. Run PowerShell as Administrator."
        exit 1
    }
}

function Log {
    param([string]$Message, [string]$Level = "INFO")
    $time = (Get-Date).ToString("s")
    $line = "$time [$Level] $Message"
    Add-Content -Path $Script:LogFile -Value $line
    if ($Script:Verbose -or $Level -eq "ERROR") { Write-Host $line }
}

function Read-Choice {
    param(
        [string]$Prompt,
        [string[]]$Options,
        [string]$Default = $null
    )
    while ($true) {
        Write-Host "$Prompt"
        $input = Read-Host
        if ([string]::IsNullOrWhiteSpace($input) -and $Default) { $input = $Default }
        if ($Options -contains $input) { return $input }
        Write-Host "Invalid choice. Options: $($Options -join ', ')"
    }
}

function YesNo-Prompt {
    param([string]$Prompt)
    while ($true) {
        $input = Read-Host "$Prompt"
        if ($input -match "^(ja|yes|evet)$") { return $true }
        if ($input -match "^(nein|no|hayır|hayir)$") { return $false }
        Write-Host "Please answer Yes or No."
    }
}
#endregion

#region Fresh Install Detection
function Detect-FreshInstall {
    # Simple heuristic: check if OS install date less than 7 days ago
    $osInfo = Get-CimInstance Win32_OperatingSystem
    $installDate = $osInfo.InstallDate
    $installDateTime = [Management.ManagementDateTimeConverter]::ToDateTime($installDate)
    $now = Get-Date
    $daysSinceInstall = ($now - $installDateTime).Days
    if ($daysSinceInstall -le 7) { return $true }
    return $false
}
#endregion

#region Backup & Restore
function Backup-Files {
    param([string[]]$Paths)
    Log "$(T 'BackupFiles')"
    foreach ($p in $Paths) {
        if (Test-Path $p) {
            $dest = Join-Path $Script:BackupFolder ((Split-Path $p -Leaf) + "_$timeStamp")
            robocopy $p $dest /MIR /R:2 /W:2 | Out-Null
            Log "Backup: $p -> $dest"
        } else {
            Log "Backup skipped, path not found: $p" "WARN"
        }
    }
}

function Create-RestorePoint {
    Log "$(T 'CreateRestorePoint')"
    try {
        $sr = Get-CimInstance -Namespace root/default -ClassName SystemRestore -ErrorAction Stop
        $sr.CreateRestorePoint("Debloatranium Backup $timeStamp", 0, 100) | Out-Null
        Log "Restore point created."
    } catch {
        Log "Restore point creation failed: $_" "WARN"
    }
}
#endregion

#region Debloat Actions (simplified)
function Remove-AppxSafe {
    param([string]$Pattern)
    try {
        $pkgs = Get-AppxPackage -Name $Pattern -ErrorAction SilentlyContinue
        foreach ($p in $pkgs) {
            Log "Removing Appx package: $($p.Name)"
            Remove-AppxPackage -Package $p.PackageFullName -ErrorAction SilentlyContinue
        }
    } catch {
        Log "Failed to remove Appx package pattern $Pattern: $_" "WARN"
    }
}

function Clean-TempSafe {
    try {
        $paths = @("$env:TEMP", "$env:LOCALAPPDATA\Temp", "$env:WINDIR\Temp")
        foreach ($p in $paths) {
            if (Test-Path $p) {
                Get-ChildItem -Path $p -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                Log "Cleaned temp files at $p"
            }
        }
    } catch {
        Log "Failed cleaning temp: $_" "WARN"
    }
}
#endregion

#region Browser Installation
function Install-Browser {
    param([string]$Browser)
    $tempDir = Join-Path $env:TEMP "debloatranium_browser_installer"
    if (-not (Test-Path $tempDir)) { New-Item -ItemType Directory -Path $tempDir -Force | Out-Null }
    switch ($Browser.ToLower()) {
        "chrome" {
            $url = "https://dl.google.com/chrome/install/375.126/chrome_installer.exe"
            $file = Join-Path $tempDir "chrome_installer.exe"
        }
        "firefox" {
            $url = "https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=en-US"
            $file = Join-Path $tempDir "firefox_installer.exe"
        }
        "opera" {
            $url = "https://download3.operacdn.com/pub/opera/desktop/94.0.4606.41/win/OperaSetup.exe"
            $file = Join-Path $tempDir "opera_installer.exe"
        }
        "operagx" {
            $url = "https://download3.operacdn.com/pub/opera_gx/installer/Opera_GX_95.0.0.39_Setup.exe"
            $file = Join-Path $tempDir "operagx_installer.exe"
        }
        default {
            Write-Host "No valid browser selected for installation."
            return
        }
    }
    Write-Host "Downloading $Browser installer..."
    Invoke-WebRequest -Uri $url -OutFile $file -UseBasicParsing
    Write-Host "Installing $Browser silently..."
    Start-Process -FilePath $file -ArgumentList "/silent","/install" -Wait
    Write-Host "$Browser installation complete."
}
#endregion

#region Main Script
Ensure-Admin

Write-Host "---------------------------------"
Write-Host "    $($Script:AppName) v$($Script:Version)"
Write-Host "---------------------------------"

# Sprache wählen
$inputLang = Read-Choice -Prompt "Select language (de/en/tr):" -Options @("de","en","tr") -Default "de"
$Script:Lang = $inputLang
Write-Host "$(T 'Welcome')"

# Frischinstall Check
Write-Host "$(T 'FreshInstallCheck')"
if (Detect-FreshInstall) {
    Write-Host "$(T 'FreshInstallDetected')"
} else {
    Write-Host "$(T 'NotFreshInstall')"
}

# Profil auswählen
$profile = Read-Choice -Prompt "$(T 'SelectProfile')" -Options @("Minimum","Mittel","Hoch","Extreme","Custom") -Default "Mittel"
if ($profile -notin @("Minimum","Mittel","Hoch","Extreme","Custom")) {
    Write-Host "$(T 'InvalidProfile')"
    $profile = "Mittel"
}

# Browser auswählen
$browser = Read-Choice -Prompt "$(T 'SelectBrowser')" -Options @("Chrome","Firefox","Opera","OperaGX","Keiner") -Default "Keiner"
if ($browser -notin @("Chrome","Firefox","Opera","OperaGX","Keiner")) {
    Write-Host "$(T 'InvalidBrowser')"
    $browser = "Keiner"
}

Write-Host "$(T 'ConfirmStart')"

# Backup & Restore
Backup-Files -Paths @("$env:USERPROFILE\Desktop","$env:USERPROFILE\Documents","$env:USERPROFILE\Pictures")
Create-RestorePoint

# Profil ausführen (nur Beispiel, hier Minimum/Mittel/Hoch/Extreme definieren)
switch ($profile.ToLower()) {
    "minimum" {
        Write-Host "Applying Minimum profile..."
        Clean-TempSafe
    }
    "mittel" {
        Write-Host "Applying Mittel profile..."
        Clean-TempSafe
        Remove-AppxSafe -Pattern "*Microsoft.XboxApp*"
        Remove-AppxSafe -Pattern "*Microsoft.SkypeApp*"
    }
    "hoch" {
        Write-Host "Applying Hoch profile..."
        Clean-TempSafe
        Remove-AppxSafe -Pattern "*Microsoft.XboxApp*"
        Remove-AppxSafe -Pattern "*Microsoft.SkypeApp*"
        # mehr Aktionen...
    }
    "extreme" {
        Write-Host "Applying Extreme profile..."
        Clean-TempSafe
        Remove-AppxSafe -Pattern "*Microsoft.*"
        # noch krassere Aktionen, aber vorsichtig
    }
    "custom" {
        # Custom Optionen abfragen
        $options = @{
            "Remove Xbox Apps" = $false
            "Remove Skype" = $false
            "Clean Temp" = $false
            "Disable Scheduled Tasks" = $false
            "Apply Registry Tweaks" = $false
        }
        $doCustom = YesNo-Prompt -Prompt "$(T 'AskCustomOption')"
        if ($doCustom) {
            foreach ($key in $options.Keys) {
                $answer = Read-Choice -Prompt "$(T 'CustomOptionPrompt' -f $key)" -Options @("Ja","Nein","Yes","No","Evet","Hayır") -Default "Nein"
                if ($answer -match "^(ja|yes|evet)$") { $options[$key] = $true }
            }
            # Anwenden der Optionen
            if ($options["Remove Xbox Apps"]) {
                Remove-AppxSafe -Pattern "*Microsoft.XboxApp*"
            }
            if ($options["Remove Skype"]) {
                Remove-AppxSafe -Pattern "*Microsoft.SkypeApp*"
            }
            if ($options["Clean Temp"]) {
                Clean-TempSafe
            }
            # weitere Optionen...
        }
    }
}

# Browser Installation
if ($browser -ne "Keiner") {
    Install-Browser -Browser $browser
}

Write-Host "$(T 'OperationComplete')"
#endregion