$Lang = @{
    "en" = @{
        "Welcome"           = "Welcome to Debloatranium 2025!"
        "ChooseLang"        = "Choose language (en/de/tr):"
        "ChooseLevel"       = "Select debloat level:"
        "Options"           = @(
            "1) Minimum - Disable telemetry only",
            "2) Medium - Remove common bloatware apps",
            "3) High - Aggressive system cleanup including Microsoft Edge removal",
            "4) Extreme - Full system cleanup including disabling security features",
            "5) Custom - Choose what to remove"
        )
        "InvalidChoice"     = "Invalid choice. Exiting."
        "Confirm"           = "Are you sure you want to continue? (Y/N):"
        "Aborted"           = "Operation aborted by user."
        "Running"           = "Running debloat level:"
        "DownloadingBrowsers"= "Downloading and installing browsers..."
        "Done"              = "Debloatranium finished successfully."
        "Error"             = "An error occurred:"
        "NeedAdmin"         = "Please run this script as Administrator!"
        "YesNoPrompt"       = "Do you want to apply this? (Y/N):"
        "IsFreshWindows"    = "Is this a fresh Windows installation? (Y/N):"
        "EdgeWarning"       = "WARNING: Microsoft Edge might be removed depending on your chosen debloat level (High, Extreme, or Custom). Ensure you have another browser or install one now."
        "AlreadyHaveBrowser"= "Do you already have another browser installed and prefer to use it? (Y/N):"
        "RecommendedInstallBrowser" = "It is highly recommended to install a browser now to ensure you have internet access after debloating."
        "InstallAnyBrowsers"= "Do you want to install any browsers?"
        "NoBrowsersInstalled" = "No browsers will be installed."
        "RestartPrompt"     = "Press any key to restart your PC..."
    }
    "de" = @{
        "Welcome"           = "Willkommen bei Debloatranium 2025!"
        "ChooseLang"        = "Sprache wählen (en/de/tr):"
        "ChooseLevel"       = "Wähle Debloat-Stufe:"
        "Options"           = @(
            "1) Minimum - Nur Telemetrie deaktivieren",
            "2) Mittel - Übliche Bloatware entfernen",
            "3) Hoch - Aggressive Systembereinigung inkl. Microsoft Edge Entfernen",
            "4) Extrem - Volle Systembereinigung inkl. Sicherheitsfeatures deaktivieren",
            "5) Benutzerdefiniert - Wähle einzeln, was entfernt wird"
        )
        "InvalidChoice"     = "Ungültige Eingabe. Programm wird beendet."
        "Confirm"           = "Bist du sicher, dass du fortfahren willst? (J/N):"
        "Aborted"           = "Vom Benutzer abgebrochen."
        "Running"           = "Starte Debloat-Stufe:"
        "DownloadingBrowsers"= "Browser werden heruntergeladen und installiert..."
        "Done"              = "Debloatranium wurde erfolgreich abgeschlossen."
        "Error"             = "Ein Fehler ist aufgetreten:"
        "NeedAdmin"         = "Bitte führe das Skript als Administrator aus!"
        "YesNoPrompt"       = "Willst du das anwenden? (J/N):"
        "IsFreshWindows"    = "Ist dies eine frische Windows-Installation? (J/N):"
        "EdgeWarning"       = "WARNUNG: Microsoft Edge wird möglicherweise je nach gewählter Debloat-Stufe (Hoch, Extrem oder Benutzerdefiniert) entfernt. Stelle sicher, dass du einen anderen Browser hast oder installiere jetzt einen."
        "AlreadyHaveBrowser"= "Hast du bereits einen anderen Browser installiert und möchtest diesen verwenden? (J/N):"
        "RecommendedInstallBrowser" = "Es wird dringend empfohlen, jetzt einen Browser zu installieren, um nach dem Debloating Internetzugang zu gewährleisten."
        "InstallAnyBrowsers"= "Möchtest du Browser installieren?"
        "NoBrowsersInstalled" = "Es werden keine Browser installiert."
        "RestartPrompt"     = "Drücke eine Taste, um deinen PC neu zu starten..."
    }
    "tr" = @{
        "Welcome"           = "Debloatranium 2025'e hoş geldiniz!"
        "ChooseLang"        = "Dil seçin (en/de/tr):"
        "ChooseLevel"       = "Temizleme seviyesini seçin:"
        "Options"           = @(
            "1) Minimum - Sadece telemetriyi devre dışı bırak",
            "2) Orta - Yaygın gereksiz uygulamaları kaldır",
            "3) Yüksek - Microsoft Edge kaldırma dahil agresif sistem temizliği",
            "4) Aşırı - Güvenlik özellikleri devre dışı bırakma dahil tam temizlik",
            "5) Özel - Kaldırılacakları seçin"
        )
        "InvalidChoice"     = "Geçersiz seçim. Çıkılıyor."
        "Confirm"           = "Devam etmek istediğinizden emin misiniz? (E/H):"
        "Aborted"           = "Kullanıcı tarafından iptal edildi."
        "Running"           = "Temizleme seviyesi çalıştırılıyor:"
        "DownloadingBrowsers"= "Tarayıcılar indiriliyor ve kuruluyor..."
        "Done"              = "Debloatranium başarıyla tamamlandı."
        "Error"             = "Bir hata oluştu:"
        "NeedAdmin"         = "Lütfen bu betiği Yönetici olarak çalıştırın!"
        "YesNoPrompt"       = "Uygulamak ister misiniz? (E/H):"
        "IsFreshWindows"    = "Bu yeni bir Windows kurulumu mu? (E/H):"
        "EdgeWarning"       = "UYARI: Seçtiğiniz temizleme seviyesine (Yüksek, Aşırı veya Özel) bağlı olarak Microsoft Edge kaldırılabilir. Başka bir tarayıcınız olduğundan emin olun veya şimdi bir tane yükleyin."
        "AlreadyHaveBrowser"= "Zaten başka bir tarayıcı yüklü ve onu kullanmayı tercih ediyor musunuz? (E/H):"
        "RecommendedInstallBrowser" = "Debloat işleminden sonra internet erişiminiz olduğundan emin olmak için şimdi bir tarayıcı yüklemeniz şiddetle tavsiye edilir."
        "InstallAnyBrowsers"= "Herhangi bir tarayıcı yüklemek ister misiniz?"
        "NoBrowsersInstalled" = "Hiçbir tarayıcı yüklenmeyecek."
        "RestartPrompt"     = "PC'nizi yeniden başlatmak için bir tuşa basın..."
    }
}

function Write-Log {
    param([string]$Message, [string]$Color="White")
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
        Write-Host "$prompt $($txt.YesNoPrompt)" -ForegroundColor Cyan
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
        Write-Host "Please answer with Y/N (en), J/N (de), or E/H (tr)." -ForegroundColor Red
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

function Remove-MicrosoftEdge {
    Write-Log "Removing Microsoft Edge..." Yellow
    $edgePath = "$env:ProgramFiles(x86)\Microsoft\Edge\Application\msedge.exe"
    if (Test-Path $edgePath) {
        $uninstallPath = Get-ChildItem -Path "$env:ProgramFiles(x86)\Microsoft\Edge\Application" -Directory |
                         Sort-Object Name -Descending | Select-Object -First 1 |
                         ForEach-Object { Join-Path $_.FullName "Installer\setup.exe" }

        if (Test-Path $uninstallPath) {
            Start-Process -FilePath $uninstallPath -ArgumentList "--uninstall --force-uninstall --system-level" -Wait -NoNewWindow
            Write-Log "Microsoft Edge removed." Green
        } else {
            Write-Log "Microsoft Edge installer not found." Red
        }
    } else {
        Write-Log "Microsoft Edge not found." Yellow
    }
}

function Debloat-DisableServices {
    Write-Log "Disabling extra services..." Yellow
    Disable-Service -serviceName "WSearch"
    Disable-Service -serviceName "SysMain"
    Disable-Service -serviceName "WMPNetworkSvc"
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
        Write-Log "Failed to install $name. Error: $($_.Exception.Message)" Red
    }
}

function Choose-And-Install-Browsers {
    param(
        [string]$lang,
        [bool]$forcePrompt = $false
    )
    if ($forcePrompt -or (Read-YesNo $txt.InstallAnyBrowsers $lang)) {
        Write-Log $txt.DownloadingBrowsers Cyan
        Write-Log "You can choose which browsers to install." Yellow

        if (Read-YesNo "Install Google Chrome?" $lang) {
            Download-And-Install-Browser -name "Google Chrome" -url "[https://dl.google.com/chrome/install/latest/chrome_installer.exe](https://dl.google.com/chrome/install/latest/chrome_installer.exe)" -installerArgs "/silent /install"
        }
        if (Read-YesNo "Install Mozilla Firefox?" $lang) {
            Download-And-Install-Browser -name "Mozilla Firefox" -url "[https://download.mozilla.org/?product=firefox-stub&os=win&lang=en-US](https://download.mozilla.org/?product=firefox-stub&os=win&lang=en-US)" -installerArgs "-ms"
        }
        if (Read-YesNo "Install Opera GX?" $lang) {
            Download-And-Install-Browser -name "Opera GX" -url "[https://download.opera.com/gx/installer/Opera_GX_Installer.exe](https://download.opera.com/gx/installer/Opera_GX_Installer.exe)" -installerArgs "/silent"
        }
        if (Read-YesNo "Install Opera?" $lang) {
            Download-And-Install-Browser -name "Opera" -url "[https://download.opera.com/ftp/pub/opera/desktop/installs/80.0.4170.16/win/Opera_80.0.4170.16_Setup.exe](https://download.opera.com/ftp/pub/opera/desktop/installs/80.0.4170.16/win/Opera_80.0.4170.16_Setup.exe)" -installerArgs "/silent"
        }
    } else {
        Write-Log $txt.NoBrowsersInstalled Yellow
    }
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
    try {
        Write-Log "Disabling Windows Defender (security risk)..." Yellow
        Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
        Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction SilentlyContinue
        Set-MpPreference -DisableOnAccessProtection $true -ErrorAction SilentlyContinue
        Set-MpPreference -DisableIOAVProtection $true -ErrorAction SilentlyContinue
        Write-Log "Windows Defender disabled." Green
    }
    catch {
        Write-Log "Failed to disable Windows Defender. Error: $($_.Exception.Message)" Red
    }
}

function Debloat-Custom {
    if (Read-YesNo "Disable Telemetry & Data Collection" $chosenLang) { Debloat-Telemetry }
    if (Read-YesNo "Remove Xbox Apps" $chosenLang) { Debloat-XboxApps }
    if (Read-YesNo "Remove OneDrive" $chosenLang) { Debloat-OneDrive }
    if (Read-YesNo "Remove Mixed Reality Portal" $chosenLang) { Debloat-MixedReality }
    if (Read-YesNo "Remove Common Apps (Solitaire, Skype, YourPhone)" $chosenLang) { Debloat-CommonApps }
    if (Read-YesNo "Remove Aggressive Apps (Weather, GetHelp, Paint, etc.)" $chosenLang) { Debloat-AggressiveApps }
    if (Read-YesNo "Disable extra Services (Search, Superfetch, WMP Network Sharing)" $chosenLang) { Debloat-DisableServices }
    if (Read-YesNo "Remove Microsoft Edge" $chosenLang) { Remove-MicrosoftEdge }
    if (Read-YesNo "Disable Windows Defender and security features (security risk)" $chosenLang) {
        Write-Log "Disabling Windows Defender and security features..." Yellow
        try {
            Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
            Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction SilentlyContinue
            Set-MpPreference -DisableOnAccessProtection $true -ErrorAction SilentlyContinue
            Set-MpPreference -DisableIOAVProtection $true -ErrorAction SilentlyContinue
            Write-Log "Windows Defender disabled." Green
        }
        catch {
            Write-Log "Failed to disable Windows Defender. Error: $($_.Exception.Message)" Red
        }
    }
}

try {
    Clear-Host
    Check-Admin

    # 1. Sprache auswählen
    Write-Host $Lang.en.ChooseLang -ForegroundColor Cyan
    $chosenLang = Read-Host
    if ($chosenLang -ne "de" -and $chosenLang -ne "en" -and $chosenLang -ne "tr") { $chosenLang = "en" }
    $txt = $Lang[$chosenLang]

    Write-Host "`n$($txt.Welcome)" -ForegroundColor Cyan

    # 2. Ob frische Windows Installation und Browser-Check
    $isFreshWindows = $false
    $browsersAlreadyHandled = $false

    if (Read-YesNo $txt.IsFreshWindows $chosenLang) {
        $isFreshWindows = $true
        Write-Log $txt.EdgeWarning Green
        if (-not (Read-YesNo $txt.AlreadyHaveBrowser $chosenLang)) {
            Write-Log $txt.RecommendedInstallBrowser Yellow
            Choose-And-Install-Browsers -lang $chosenLang -forcePrompt $true
            $browsersAlreadyHandled = $true
        }
    }

    # 3. Debloat Modi auswählen mit Custom
    Write-Host $txt.ChooseLevel -ForegroundColor Yellow
    foreach ($option in $txt.Options) {
        Write-Host $option -ForegroundColor Green
    }

    $choice = Read-Host "Enter number / Nummer eingeben"
    if ($choice -notin "1","2","3","4","5") {
        Write-Host $txt.InvalidChoice -ForegroundColor Red
        exit
    }

    # 4. Bestätigen
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

    # Browser-Installation, falls nicht schon am Anfang geschehen
    if (-not $browsersAlreadyHandled) {
        Choose-And-Install-Browsers -lang $chosenLang -forcePrompt $false
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
