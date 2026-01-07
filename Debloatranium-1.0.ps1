<#
.SYNOPSIS
    Debloatranium - Ein universeller Windows Debloater.
.DESCRIPTION
    Dieses Skript optimiert Windows strikt nach Benutzerpräferenzen.
    Reihenfolge: Sprache -> Features -> Edge/Browser -> DarkMode (Auto) -> Level -> Backup -> Confirm -> Execute.
#>

# --- Initialisierung & Admin Check ---
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Bitte starte das Skript als Administrator!" -ForegroundColor Red
    pause
    exit
}

# --- Variablen für Entscheidungen (Standard: False/No) ---
$doWiFi = $true
$doBT = $true
$doPrinter = $true
$keepEdge = $true
$newBrowser = "None"
$doBackup = $false
# Optimierungs-Flags
$optPerformance = $false # Minimum
$optLight = $false       # Leicht
$optMedium = $false      # Mittel
$optHigh = $false        # Hoch
$optExtreme = $false     # Extrem

# --- Sprach-Definitionen ---
$lang = @{
    DE = @{
        Welcome = "Willkommen bei Debloatranium!"
        SelectLang = "Wähle deine Sprache / Select Language / Dil Seçin (1: Deutsch, 2: English, 3: Türkçe): "
        WiFi = "Möchtest du WiFi behalten? (j/n): "
        BT = "Möchtest du Bluetooth behalten? (j/n): "
        Printer = "Möchtest du Drucker-Funktionen behalten? (j/n): "
        Edge = "Möchtest du Microsoft Edge behalten? (j/n): "
        Browser = "Welchen Browser möchtest du stattdessen? (1: Chrome, 2: Firefox, 3: Tor, 4: Keinen): "
        Level = "Wähle Optimierungsgrad (1: Minimum, 2: Leicht, 3: Mittel, 4: Hoch, 5: Extrem, 6: Custom): "
        CustomPerf = "Custom: Performance Tweaks aktivieren (Minimum)? (j/n): "
        CustomLight = "Custom: Unbenutzte Dienste deaktivieren (Leicht)? (j/n): "
        CustomMed = "Custom: Unnötige Apps entfernen (Mittel)? (j/n): "
        CustomHigh = "Custom: Harte Einstellungen & OneDrive weg (Hoch)? (j/n): "
        CustomExt = "Custom: System radikal bereinigen inkl. Store (Extrem)? (j/n): "
        Backup = "Möchtest du ein Registry-Backup auf dem Desktop erstellen? (j/n): "
        Confirm1 = "Sollen die Änderungen angewendet werden? (j/n): "
        Confirm2 = "Bist du absolut sicher? (j/n): "
        Processing = "Verarbeite... Bitte warten."
        Done = "Fertig! Bitte starte den PC neu."
    }
    EN = @{
        Welcome = "Welcome to Debloatranium!"
        SelectLang = "Select Language (1: German, 2: English, 3: Turkish): "
        WiFi = "Keep WiFi? (y/n): "
        BT = "Keep Bluetooth? (y/n): "
        Printer = "Keep Printer features? (y/n): "
        Edge = "Keep Microsoft Edge? (y/n): "
        Browser = "Which browser to install? (1: Chrome, 2: Firefox, 3: Tor, 4: None): "
        Level = "Select Level (1: Minimum, 2: Light, 3: Medium, 4: High, 5: Extreme, 6: Custom): "
        CustomPerf = "Custom: Enable Performance Tweaks (Minimum)? (y/n): "
        CustomLight = "Custom: Disable unused services (Light)? (y/n): "
        CustomMed = "Custom: Remove bloat apps (Medium)? (y/n): "
        CustomHigh = "Custom: Hard settings & OneDrive removal (High)? (y/n): "
        CustomExt = "Custom: Radical cleanup incl. Store (Extreme)? (y/n): "
        Backup = "Create a settings backup on Desktop? (y/n): "
        Confirm1 = "Apply changes? (y/n): "
        Confirm2 = "Are you absolutely sure? (y/n): "
        Processing = "Processing... Please wait."
        Done = "Done! Please restart your PC."
    }
    TR = @{
        Welcome = "Debloatranium'a Hoş Geldiniz!"
        SelectLang = "Dil Seçin (1: Almanca, 2: İngilizce, 3: Türkçe): "
        WiFi = "WiFi kalsın mı? (e/h): "
        BT = "Bluetooth kalsın mı? (e/h): "
        Printer = "Yazıcı özellikleri kalsın mı? (e/h): "
        Edge = "Microsoft Edge kalsın mı? (e/h): "
        Browser = "Hangi tarayıcıyı istersiniz? (1: Chrome, 2: Firefox, 3: Tor, 4: Hiçbiri): "
        Level = "Seviye Seçin (1: Minimum, 2: Hafif, 3: Orta, 4: Yüksek, 5: Ekstrem, 6: Özel): "
        CustomPerf = "Özel: Performans ayarları (Minimum)? (e/h): "
        CustomLight = "Özel: Kullanılmayan hizmetleri kapat (Hafif)? (e/h): "
        CustomMed = "Özel: Gereksiz uygulamaları sil (Orta)? (e/h): "
        CustomHigh = "Özel: Sert ayarlar & OneDrive sil (Yüksek)? (e/h): "
        CustomExt = "Özel: Radikal temizlik ve Mağaza sil (Ekstrem)? (e/h): "
        Backup = "Masaüstüne yedekleme yapılsın mı? (e/h): "
        Confirm1 = "Değişiklikler uygulansın mı? (e/h): "
        Confirm2 = "Emin misiniz? (e/h): "
        Processing = "İşleniyor... Lütfen bekleyin."
        Done = "Tamamlandı! Lütfen bilgisayarı yeniden başlatın."
    }
}

# --- 1. Sprachauswahl ---
Write-Host "-----------------------------" -ForegroundColor Cyan
Write-Host "      DEBLOATANIUM v1.0      " -ForegroundColor Cyan
Write-Host "-----------------------------" -ForegroundColor Cyan

$choice = Read-Host $lang.DE.SelectLang
switch ($choice) {
    "1" { $s = $lang.DE; $yes = "j"; $no = "n" }
    "2" { $s = $lang.EN; $yes = "y"; $no = "n" }
    "3" { $s = $lang.TR; $yes = "e"; $no = "h" }
    Default { $s = $lang.EN; $yes = "y"; $no = "n" }
}

Clear-Host
Write-Host $s.Welcome -ForegroundColor Green

# --- 2. Features behalten? ---
$inWiFi = Read-Host $s.WiFi
if ($inWiFi -eq $no) { $doWiFi = $false }

$inBT = Read-Host $s.BT
if ($inBT -eq $no) { $doBT = $false }

$inPrint = Read-Host $s.Printer
if ($inPrint -eq $no) { $doPrinter = $false }

# --- 3. Edge & Browser ---
$inEdge = Read-Host $s.Edge
if ($inEdge -eq $no) { 
    $keepEdge = $false 
    $newBrowser = Read-Host $s.Browser
}

# --- 4. Dark Mode (Automatisch gesetzt, keine Frage) ---
# Info: Wird im Ausführungsteil angewendet.

# --- 5. Level Auswahl ---
$lvlChoice = Read-Host $s.Level

# Logik für Level
if ($lvlChoice -eq "1") { # Minimum
    $optPerformance = $true
}
elseif ($lvlChoice -eq "2") { # Leicht
    $optPerformance = $true; $optLight = $true
}
elseif ($lvlChoice -eq "3") { # Mittel
    $optPerformance = $true; $optLight = $true; $optMedium = $true
}
elseif ($lvlChoice -eq "4") { # Hoch
    $optPerformance = $true; $optLight = $true; $optMedium = $true; $optHigh = $true
}
elseif ($lvlChoice -eq "5") { # Extrem
    $optPerformance = $true; $optLight = $true; $optMedium = $true; $optHigh = $true; $optExtreme = $true
}
elseif ($lvlChoice -eq "6") { # Custom
    $c1 = Read-Host $s.CustomPerf
    if ($c1 -eq $yes) { $optPerformance = $true }
    
    $c2 = Read-Host $s.CustomLight
    if ($c2 -eq $yes) { $optLight = $true }
    
    $c3 = Read-Host $s.CustomMed
    if ($c3 -eq $yes) { $optMedium = $true }
    
    $c4 = Read-Host $s.CustomHigh
    if ($c4 -eq $yes) { $optHigh = $true }
    
    $c5 = Read-Host $s.CustomExt
    if ($c5 -eq $yes) { $optExtreme = $true }
}

# --- 6. Backup ---
$inBackup = Read-Host $s.Backup
if ($inBackup -eq $yes) { $doBackup = $true }

# --- 7. Doppelbestätigung ---
Write-Host "`n"
$cConf1 = Read-Host $s.Confirm1
if ($cConf1 -ne $yes) { exit }

$cConf2 = Read-Host $s.Confirm2
if ($cConf2 -ne $yes) { exit }

# ==========================================
#        AUSFÜHRUNG (EXECUTION PHASE)
# ==========================================
Clear-Host
Write-Host $s.Processing -ForegroundColor Yellow

# A. Backup erstellen
if ($doBackup) {
    $backupPath = "$HOME\Desktop\Backup"
    if (!(Test-Path $backupPath)) { New-Item -ItemType Directory -Path $backupPath | Out-Null }
    Write-Host "[*] Creating Backup..."
    reg export "HKLM\SYSTEM\CurrentControlSet\Control" "$backupPath\System_Control.reg" /y | Out-Null
    reg export "HKCU\Software\Microsoft\Windows\CurrentVersion" "$backupPath\User_Config.reg" /y | Out-Null
}

# B. Dark Mode erzwingen (Immer)
Write-Host "[*] Applying Dark Mode..."
$RegPaths = @("HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize", "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize")
foreach ($path in $RegPaths) {
    if (!(Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
    Set-ItemProperty -Path $path -Name "AppsUseLightTheme" -Value 0 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $path -Name "SystemUsesLightTheme" -Value 0 -ErrorAction SilentlyContinue
}

# C. Feature Entfernung
if (!$doBT) {
    Write-Host "[*] Disabling Bluetooth..."
    Get-Service -Name "bthserv", "BTAGService" -ErrorAction SilentlyContinue | Stop-Service -PassThru | Set-Service -StartupType Disabled
}
if (!$doPrinter) {
    Write-Host "[*] Disabling Print Spooler..."
    Stop-Service -Name "Spooler" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled
}
if (!$doWiFi) {
    Write-Host "[*] Disabling WiFi Service..."
    Stop-Service -Name "WlanSvc" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled
}

# D. Edge & Browser
if (!$keepEdge) {
    Write-Host "[*] Removing Edge..." -ForegroundColor Yellow
    Get-AppxPackage -AllUsers *MicrosoftEdge* | Remove-AppxPackage -ErrorAction SilentlyContinue
    
    # Browser Install via Winget
    if ($newBrowser -ne "4") {
        Write-Host "[*] Installing selected Browser..."
        switch ($newBrowser) {
            "1" { winget install Google.Chrome --silent --accept-package-agreements --accept-source-agreements }
            "2" { winget install Mozilla.Firefox --silent --accept-package-agreements --accept-source-agreements }
            "3" { winget install TorProject.TorBrowser --silent --accept-package-agreements --accept-source-agreements }
        }
    }
}

# E. Level-basierte Optimierungen

# 1. MINIMUM (Performance Tweaks, Einstellungen die nix wegmachen)
if ($optPerformance) {
    Write-Host "[*] Applying Minimum/Performance Tweaks..."
    # Telemetrie reduzieren (ohne Dienste zu löschen)
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -ErrorAction SilentlyContinue
    # Game Mode an
    Write-Host " -> Activating Game Mode"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -Value 1 -ErrorAction SilentlyContinue
}

# 2. LEICHT (Minimum + unbenutzte Sachen aus)
if ($optLight) {
    Write-Host "[*] Applying Light Optimization..."
    # Disable Hibernation (Save Space)
    powercfg /h off
    # Disable Fax Service
    Get-Service "Fax" -ErrorAction SilentlyContinue | Stop-Service -PassThru | Set-Service -StartupType Disabled
}

# 3. MITTEL (Leicht + unnötige Apps + härtere Einstellungen)
if ($optMedium) {
    Write-Host "[*] Applying Medium Optimization (App Removal)..."
    $bloatList = @(
        "*bingweather*", "*bingnews*", "*gethelp*", "*getstarted*", "*messaging*", 
        "*solitaire*", "*people*", "*zunevideo*", "*zunemusic*"
    )
    foreach ($app in $bloatList) {
        Get-AppxPackage $app | Remove-AppxPackage -ErrorAction SilentlyContinue
    }
}

# 4. HOCH (Mittel + OneDrive + Cortana + noch mehr Apps)
if ($optHigh) {
    Write-Host "[*] Applying High Optimization (OneDrive/Cortana)..."
    # OneDrive (Versuch Deinstall)
    Get-AppxPackage *onedrive* | Remove-AppxPackage -ErrorAction SilentlyContinue
    # Cortana
    Get-AppxPackage *cortana* | Remove-AppxPackage -ErrorAction SilentlyContinue
    # Feedback Hub
    Get-AppxPackage *feedbackhub* | Remove-AppxPackage -ErrorAction SilentlyContinue
    # Maps
    Get-AppxPackage *windowsmaps* | Remove-AppxPackage -ErrorAction SilentlyContinue
}

# 5. EXTREM (Gaming pur, fast alles weg, Store weg, Essentials bleiben)
if ($optExtreme) {
    Write-Host "!!! EXTREME MODE ACTIVATED !!!" -ForegroundColor Red
    Write-Host "[*] Removing almost ALL System Apps..."
    
    # Whitelist Strategie: Wir löschen ALLES, außer was hier steht.
    $whiteList = @(
        "Microsoft.Windows.ShellExperienceHost",    # Start Menu / UI
        "Microsoft.Windows.StartMenuExperienceHost",
        "windows.immersivecontrolpanel",            # Settings App (Wichtig!)
        "Microsoft.Windows.Search",                 # Search bar
        "Microsoft.UI.Xaml",                        # UI Framework
        "Microsoft.VCLibs"                          # Libraries
    )
    
    $allApps = Get-AppxPackage -AllUsers
    foreach ($app in $allApps) {
        if ($whiteList -notcontains $app.Name) {
            # Extra Check: Windows Store wird hier auch gelöscht, da nicht in Whitelist
            Write-Host " -> Removing $($app.Name)"
            $app | Remove-AppxPackage -ErrorAction SilentlyContinue
        }
    }
    
    # Extra Härtung
    Write-Host "[*] Applying Ultra-Hardcore Registry Tweaks..."
    # Disable Background Apps Global
    $key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
    if (!(Test-Path $key)) { New-Item -Path $key -Force | Out-Null }
    Set-ItemProperty -Path $key -Name "GlobalUserDisabled" -Value 1
}

Write-Host "`n"
Write-Host $s.Done -ForegroundColor Green
pause
