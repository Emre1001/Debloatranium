# Debloatranium - Windows Debloat und Browser Installer Script
# Erfordert: Administratorrechte, PowerShell ExecutionPolicy RemoteSigned oder Bypass

# Fehlermeldungen immer auf Englisch
function Write-ErrorEnglish {
    param([string]$message)
    Write-Warning $message
}

# Admin-Rechte prüfen
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole] "Administrator")) {
    Write-ErrorEnglish "This script must be run as Administrator. Please restart PowerShell with administrative privileges."
    Write-Host "Bitte PowerShell als Administrator starten."
    Pause
    exit
}

# Execution Policy prüfen
$execPolicy = Get-ExecutionPolicy
if ($execPolicy -eq "Restricted" -or $execPolicy -eq "AllSigned") {
    Write-ErrorEnglish "Current ExecutionPolicy ($execPolicy) prevents script execution."
    Write-Host "Bitte in einer administrativen PowerShell diesen Befehl ausführen:"
    Write-Host "`n    Set-ExecutionPolicy RemoteSigned`n"
    Write-Host "Alternativ das Script so starten:"
    Write-Host "`n    powershell.exe -ExecutionPolicy Bypass -File `"<Pfad_zum_Script>`"`n"
    Pause
    exit
}

# Sprachtexte
$languages = @{
    "de" = @{
        "AskFreshWindows" = "Ist dies eine frische Windows-Installation? (1 = Ja, 2 = Nein)"
        "ChooseLang" = "Sprache wählen: 1 = Deutsch, 2 = Englisch, 3 = Türkisch"
        "InvalidInput" = "Ungültige Eingabe, bitte erneut versuchen."
        "Downloading" = "Lade herunter und installiere: "
        "Debloating" = "Starte Windows-Bereinigung..."
        "Done" = "Vorgang erfolgreich abgeschlossen."
        "NoDebloat" = "Keine Bereinigung notwendig."
        "PressKey" = "Beliebige Taste drücken zum Beenden..."
        "ErrorDownload" = "Fehler beim Herunterladen oder Installieren von"
        "SkippingInstall" = "Installation übersprungen."
        "NotFresh" = "Keine frische Windows-Installation; minimale Bereinigung wird durchgeführt."
        "ConfirmRun" = "Sind Sie sicher, dass Sie fortfahren möchten? (1 = Ja, 2 = Nein)"
        "ChooseCustom" = "Möchten Sie den benutzerdefinierten Modus verwenden? (1 = Ja, 2 = Nein)"
        "ChooseBrowsers" = "Wählen Sie Browser zum Installieren (durch Komma getrennt): 1=Chrome, 2=Firefox, 3=Opera GX, 4=Opera"
        "ChooseDebloat" = "Wählen Sie das Bereinigungslevel: 1=Minimal, 2=Maximal"
        "Abort" = "Vorgang vom Benutzer abgebrochen. Keine Änderungen vorgenommen."
    }
    "en" = @{
        "AskFreshWindows" = "Is this a fresh Windows installation? (1 = Yes, 2 = No)"
        "ChooseLang" = "Select language: 1 = German, 2 = English, 3 = Turkish"
        "InvalidInput" = "Invalid input, please try again."
        "Downloading" = "Downloading and installing: "
        "Debloating" = "Starting Windows debloat process..."
        "Done" = "Process completed successfully."
        "NoDebloat" = "No debloat actions were necessary."
        "PressKey" = "Press any key to exit..."
        "ErrorDownload" = "Error occurred during download or installation of"
        "SkippingInstall" = "Installation skipped."
        "NotFresh" = "Not a fresh Windows installation; performing minimal debloat."
        "ConfirmRun" = "Are you sure you want to proceed? (1 = Yes, 2 = No)"
        "ChooseCustom" = "Do you want to run custom mode? (1 = Yes, 2 = No)"
        "ChooseBrowsers" = "Select browsers to install (comma separated): 1=Chrome, 2=Firefox, 3=Opera GX, 4=Opera"
        "ChooseDebloat" = "Choose debloat level: 1=Minimal, 2=Maximal"
        "Abort" = "Operation aborted by user. No changes made."
    }
    "tr" = @{
        "AskFreshWindows" = "Bu temiz bir Windows kurulumu mu? (1 = Evet, 2 = Hayır)"
        "ChooseLang" = "Dil seçin: 1 = Almanca, 2 = İngilizce, 3 = Türkçe"
        "InvalidInput" = "Geçersiz giriş, lütfen tekrar deneyin."
        "Downloading" = "İndiriliyor ve yükleniyor: "
        "Debloating" = "Windows temizleme işlemi başlatılıyor..."
        "Done" = "İşlem başarıyla tamamlandı."
        "NoDebloat" = "Temizleme işlemi gerekli değil."
        "PressKey" = "Çıkmak için bir tuşa basın..."
        "ErrorDownload" = "İndirme veya yükleme sırasında hata oluştu"
        "SkippingInstall" = "Yükleme atlandı."
        "NotFresh" = "Temiz bir Windows kurulumu değil; minimum temizleme uygulanacak."
        "ConfirmRun" = "Devam etmek istediğinizden emin misiniz? (1 = Evet, 2 = Hayır)"
        "ChooseCustom" = "Özel modu kullanmak istiyor musunuz? (1 = Evet, 2 = Hayır)"
        "ChooseBrowsers" = "Yüklenecek tarayıcıları seçin (virgülle ayrılmış): 1=Chrome, 2=Firefox, 3=Opera GX, 4=Opera"
        "ChooseDebloat" = "Temizleme seviyesini seçin: 1=Minimum, 2=Maksimum"
        "Abort" = "İşlem kullanıcı tarafından iptal edildi. Değişiklik yapılmadı."
    }
}

function Choose-Language {
    while ($true) {
        Write-Host $languages["en"]["ChooseLang"]
        $langChoice = Read-Host
        switch ($langChoice) {
            "1" { return "de" }
            "2" { return "en" }
            "3" { return "tr" }
            default { Write-Host $languages["en"]["InvalidInput"] }
        }
    }
}

function Show-SystemInfo {
    Write-Host "System installation date is being retrieved..."
    $installDate = (Get-CimInstance Win32_OperatingSystem).InstallDate
    $formattedDate = [Management.ManagementDateTimeConverter]::ToDateTime($installDate)
    Write-Host "Windows installation date: $formattedDate"
}

function Ask-FreshWindows {
    param($lang)
    while ($true) {
        Write-Host $languages[$lang]["AskFreshWindows"]
        $answer = Read-Host "1 or 2"
        if ($answer -eq "1" -or $answer -eq "2") {
            return $answer
        }
        else {
            Write-Host $languages[$lang]["InvalidInput"]
        }
    }
}

function Ask-CustomMode {
    param($lang)
    while ($true) {
        Write-Host $languages[$lang]["ChooseCustom"]
        $answer = Read-Host "1 or 2"
        if ($answer -eq "1" -or $answer -eq "2") {
            return $answer
        }
        else {
            Write-Host $languages[$lang]["InvalidInput"]
        }
    }
}

function Ask-Browsers {
    param($lang)
    Write-Host $languages[$lang]["ChooseBrowsers"]
    while ($true) {
        $input = Read-Host "e.g. 1,3"
        if ($input -match "^[1-4](,[1-4])*$") {
            $selections = $input -split ","
            return $selections
        }
        else {
            Write-Host $languages[$lang]["InvalidInput"]
        }
    }
}

function Ask-DebloatLevel {
    param($lang)
    while ($true) {
        Write-Host $languages[$lang]["ChooseDebloat"]
        $answer = Read-Host "1 or 2"
        if ($answer -eq "1" -or $answer -eq "2") {
            return $answer
        }
        else {
            Write-Host $languages[$lang]["InvalidInput"]
        }
    }
}

function Confirm-Run {
    param($lang)
    while ($true) {
        Write-Host $languages[$lang]["ConfirmRun"]
        $answer = Read-Host "1 or 2"
        if ($answer -eq "1" -or $answer -eq "2") {
            return $answer
        }
        else {
            Write-Host $languages[$lang]["InvalidInput"]
        }
    }
}

function Debloat-Windows {
    param($lang, $level)
    Write-Host $languages[$lang]["Debloating"]

    if ($level -eq "1") {
        # Minimal debloat
        Get-Service -Name "DiagTrack","dmwappushservice" -ErrorAction SilentlyContinue | ForEach-Object {
            if ($_.Status -eq "Running") { Stop-Service $_ -Force }
            Set-Service $_ -StartupType Disabled
        }
        $appsMinimal = @(
            "Microsoft.3DBuilder",
            "Microsoft.XboxApp",
            "Microsoft.ZuneMusic",
            "Microsoft.ZuneVideo"
        )
        foreach ($app in $appsMinimal) {
            Get-AppxPackage -AllUsers | Where-Object { $_.Name -like "*$app*" } | Remove-AppxPackage -ErrorAction SilentlyContinue
            Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like "*$app*" } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
        }
    }
    elseif ($level -eq "2") {
        # Maximal debloat
        $appsMaximal = @(
            "*Xbox*",
            "*Zune*",
            "*3D*",
            "*Solitaire*",
            "*Bing*",
            "*MicrosoftPeople*",
            "*WindowsFeedback*",
            "*MicrosoftOfficeHub*",
            "*Messaging*",
            "*Skype*",
            "*MicrosoftStickyNotes*",
            "*GetHelp*",
            "*OneNote*",
            "*Wallet*",
            "*YourPhone*",
            "*MixedReality*"
        )
        foreach ($pattern in $appsMaximal) {
            Get-AppxPackage -AllUsers | Where-Object { $_.Name -like $pattern } | Remove-AppxPackage -ErrorAction SilentlyContinue
            Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $pattern } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
        }
        Get-Service -Name "DiagTrack","dmwappushservice" -ErrorAction SilentlyContinue | ForEach-Object {
            if ($_.Status -eq "Running") { Stop-Service $_ -Force }
            Set-Service $_ -StartupType Disabled
        }
    }
    else {
        Write-Host $languages[$lang]["NoDebloat"]
    }
}

$browserLinks = @{
    "1" = @{ "name" = "Chrome"; "url" = "https://dl.google.com/chrome/install/latest/chrome_installer.exe"; "args" = "/silent /install" }
    "2" = @{ "name" = "Firefox"; "url" = "https://download.mozilla.org/?product=firefox-latest&os=win64&lang=en-US"; "args" = "-ms" }
    "3" = @{ "name" = "Opera GX"; "url" = "https://download.opera.com/download/get/?id=59773&location=win&nothanks=yes&sub=marine"; "args" = "/silent /install" }
    "4" = @{ "name" = "Opera"; "url" = "https://download.opera.com/ftp/pub/opera/desktop/111.0.1661.44/win/Opera_111.0.1661.44_Setup_x64.exe"; "args" = "/silent /install" }
}

function Download-And-Install {
    param($name, $info, $lang)
    $tempPath = "$env:TEMP\$name-setup.exe"
    Write-Host "$($languages[$lang]['Downloading']) $name..."
    try {
        Invoke-WebRequest -Uri $info.url -OutFile $tempPath -UseBasicParsing -ErrorAction Stop
        Start-Process -FilePath $tempPath -ArgumentList $info.args -Wait
        Remove-Item $tempPath -Force
    }
    catch {
        Write-Host "Error occurred during download or installation of $name."
    }
}

function Main {
    $lang = Choose-Language
    Show-SystemInfo
    $fresh = Ask-FreshWindows -lang $lang

    $custom = Ask-CustomMode -lang $lang

    $selectedBrowsers = @()
    $debloatLevel = "1"  # default minimal

    if ($custom -eq "1") {
        $selectedBrowsers = Ask-Browsers -lang $lang
        $debloatLevel = Ask-DebloatLevel -lang $lang
    }
    else {
        if ($fresh -eq "1") {
            $debloatLevel = "2"
            $selectedBrowsers = @("1","2","3","4")
        }
        else {
            $debloatLevel = "1"
            $selectedBrowsers = @()
        }
    }

    $confirm = Confirm-Run -lang $lang
    if ($confirm -ne "1") {
        Write-Host $languages[$lang]["Abort"]
        Write-Host $languages[$lang]["PressKey"]
        $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit
    }

    Debloat-Windows -lang $lang -level $debloatLevel

    foreach ($b in $selectedBrowsers) {
        if ($browserLinks.ContainsKey($b)) {
            Download-And-Install -name $browserLinks[$b].name -info $browserLinks[$b] -lang $lang
        }
    }

    Write-Host $languages[$lang]["Done"]
    Write-Host $languages[$lang]["PressKey"]
    $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

Main
