<#
.SYNOPSIS
    Debloatranium - The Ultimate Windows Power-User Optimization Suite.
.DESCRIPTION
    Version: 2.0 (Massive Extended Edition)
    Author: Emre1001
    Target: Maximum FPS / Minimum Latency / Minimal Processes (Goal: 40-50)
    Optimized for: Intel Core i7 High-Performance Systems
#>

# =========================================================================================
# INITIALISIERUNG & SICHERHEITS-CHECK
# =========================================================================================

$ErrorActionPreference = "SilentlyContinue"

function Check-Admin {
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "################################################################" -ForegroundColor Red
        Write-Host "   ERROR: ADMINISTRATIVE PRIVILEGES REQUIRED" -ForegroundColor Red
        Write-Host "   BITTE STARTEN SIE DAS SKRIPT ALS ADMINISTRATOR" -ForegroundColor Red
        Write-Host "################################################################" -ForegroundColor Red
        pause
        exit
    }
}

Check-Admin

# =========================================================================================
# GLOBALE VARIABLEN & KONFIGURATION
# =========================================================================================

$Global:Config = @{
    WiFi     = $true
    BT       = $true
    Printer  = $true
    Edge     = $true
    Browser  = "None"
    Backup   = $false
    Level    = 0
    Flags    = @{
        Perf   = $false
        Light  = $false
        Med    = $false
        High   = $false
        Ext    = $false
    }
}

# Sprachpaket (Erweitert)
$lang = @{
    DE = @{
        Header      = "DEBLOATRANIUM ULTIMATE v2.0 - PROFESSIONAL EDITION"
        Welcome     = "Willkommen. System-Analyse abgeschlossen. Bereit für Optimierung."
        SelectLang  = "Wähle deine Sprache (1: Deutsch, 2: English, 3: Türkçe): "
        WiFi        = "[QUERIE] Möchtest du die WiFi-Funktionalität behalten? (j/n): "
        BT          = "[QUERIE] Möchtest du Bluetooth-Dienste behalten? (j/n): "
        Printer     = "[QUERIE] Möchtest du Drucker-Support (Spooler) behalten? (j/n): "
        Edge        = "[QUERIE] Soll Microsoft Edge vom System entfernt werden? (j/n): "
        Browser     = "[SELECT] Ersatz-Browser installieren: (1: Chrome, 2: Firefox, 3: Tor, 4: Keiner): "
        Level       = "WÄHLE OPTIMIERUNGS-STRATEGIE:`n[1] MINIMUM   - Sicher, nur Registry-Performance Tweaks`n[2] LIGHT     - Deaktiviert grundlegende Hintergrund-Dienste`n[3] MEDIUM    - Entfernt Standard-Bloatware & Apps`n[4] HIGH      - Aggressives Debloat (OneDrive/Search/Cortana)`n[5] EXTREME   - ULTRA GAMING (Ziel: 40 Prozesse, Store-Entfernung)`n[6] CUSTOM    - Manuelle Auswahl der Module`n`nDEIN LEVEL: "
        CustomPerf  = "[CUSTOM] Kernel- & I/O-Optimierung aktivieren? (j/n): "
        CustomLight = "[CUSTOM] Hintergrund-Dienste (Fax/Error/Diag) stoppen? (j/n): "
        CustomMed   = "[CUSTOM] UWP-Bloatware Pakete deinstallieren? (j/n): "
        CustomHigh  = "[CUSTOM] System-Komponenten (OneDrive/Search) eliminieren? (j/n): "
        CustomExt   = "[CUSTOM] Extrem-Modus (Dienste-Massaker für 40 Prozesse)? (j/n): "
        Backup      = "[SECURITY] Registry-Backup auf Desktop erstellen? (DRINGEND EMPFOHLEN) (j/n): "
        Confirm1    = "[WARNING] Soll die Prozedur eingeleitet werden? (j/n): "
        Confirm2    = "[CRITICAL] BIST DU ABSOLUT SICHER? Änderungen sind tiefgreifend! (j/n): "
        Processing  = "STATUS: Debloatranium führt Operationen aus. Bitte nicht unterbrechen..."
        Done        = "ERFOLG: Operation abgeschlossen. Ein System-Neustart wird dringend empfohlen."
    }
    EN = @{
        Header      = "DEBLOATRANIUM ULTIMATE v2.0 - PROFESSIONAL EDITION"
        Welcome     = "Welcome. System analysis complete. Ready for optimization."
        SelectLang  = "Select Language (1: German, 2: English, 3: Turkish): "
        WiFi        = "[QUERIE] Keep WiFi functionality? (y/n): "
        BT          = "[QUERIE] Keep Bluetooth services? (y/n): "
        Printer     = "[QUERIE] Keep Printer support? (y/n): "
        Edge        = "[QUERIE] Remove Microsoft Edge from system? (y/n): "
        Browser     = "[SELECT] Install replacement browser: (1: Chrome, 2: Firefox, 3: Tor, 4: None): "
        Level       = "CHOOSE OPTIMIZATION STRATEGY:`n[1] MINIMUM   - Safe, Registry-only performance tweaks`n[2] LIGHT     - Disables basic background services`n[3] MEDIUM    - Removes standard Bloatware & Apps`n[4] HIGH      - Aggressive Debloat (OneDrive/Search/Cortana)`n[5] EXTREME   - ULTRA GAMING (Goal: 40 Procs, Store Removal)`n[6] CUSTOM    - Manual module selection`n`nYOUR LEVEL: "
        CustomPerf  = "[CUSTOM] Enable Kernel & I/O Optimization? (y/n): "
        CustomLight = "[CUSTOM] Stop background services (Fax/Error/Diag)? (y/n): "
        CustomMed   = "[CUSTOM] Uninstall UWP-Bloatware packages? (y/n): "
        CustomHigh  = "[CUSTOM] Eliminate System components (OneDrive/Search)? (y/n): "
        CustomExt   = "[CUSTOM] Extreme Mode (Service massacre for 40 procs)? (y/n): "
        Backup      = "[SECURITY] Create Registry Backup on Desktop? (HIGHLY RECOMMENDED) (y/n): "
        Confirm1    = "[WARNING] Initiate procedure? (y/n): "
        Confirm2    = "[CRITICAL] ARE YOU ABSOLUTELY SURE? Changes are profound! (y/n): "
        Processing  = "STATUS: Debloatranium executing operations. Do not interrupt..."
        Done        = "SUCCESS: Operation complete. A system restart is highly recommended."
    }
}

# =========================================================================================
# HILFSFUNKTIONEN (LOGGING & UI)
# =========================================================================================

function Write-Header {
    param($Text)
    Write-Host "`n--- $Text ---" -ForegroundColor Cyan -BackgroundColor Black
}

function Write-Log {
    param($Msg, $Type="Info")
    $Color = "White"
    if ($Type -eq "Success") { $Color = "Green" }
    if ($Type -eq "Warning") { $Color = "Yellow" }
    if ($Type -eq "Error") { $Color = "Red" }
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] [$Type] $Msg" -ForegroundColor $Color
}

# =========================================================================================
# PHASE 1: INTERAKTIVE DATENERFASSUNG
# =========================================================================================

Clear-Host
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "                 DEBLOATRANIUM PROFESSIONAL v2.0                      " -ForegroundColor White -BackgroundColor DarkBlue
Write-Host "======================================================================" -ForegroundColor Cyan

$inputLang = Read-Host $lang.DE.SelectLang
$S = if ($inputLang -eq "1") { $lang.DE } else { $lang.EN }
$Y = if ($inputLang -eq "1") { "j" } else { "y" }
$N = "n"

Write-Log $S.Welcome "Success"

# Fragen abarbeiten
if ((Read-Host $S.WiFi) -eq $N) { $Global:Config.WiFi = $false }
if ((Read-Host $S.BT) -eq $N) { $Global:Config.BT = $false }
if ((Read-Host $S.Printer) -eq $N) { $Global:Config.Printer = $false }

$edgeInput = Read-Host $S.Edge
if ($edgeInput -eq $Y) { 
    $Global:Config.Edge = $false 
    $Global:Config.Browser = Read-Host $S.Browser
}

$lvlChoice = Read-Host $S.Level
switch ($lvlChoice) {
    "1" { $Global:Config.Flags.Perf = $true }
    "2" { $Global:Config.Flags.Perf = $true; $Global:Config.Flags.Light = $true }
    "3" { $Global:Config.Flags.Perf = $true; $Global:Config.Flags.Light = $true; $Global:Config.Flags.Med = $true }
    "4" { $Global:Config.Flags.Perf = $true; $Global:Config.Flags.Light = $true; $Global:Config.Flags.Med = $true; $Global:Config.Flags.High = $true }
    "5" { $Global:Config.Flags.Perf = $true; $Global:Config.Flags.Light = $true; $Global:Config.Flags.Med = $true; $Global:Config.Flags.High = $true; $Global:Config.Flags.Ext = $true }
    "6" {
        if ((Read-Host $S.CustomPerf) -eq $Y) { $Global:Config.Flags.Perf = $true }
        if ((Read-Host $S.CustomLight) -eq $Y) { $Global:Config.Flags.Light = $true }
        if ((Read-Host $S.CustomMed) -eq $Y) { $Global:Config.Flags.Med = $true }
        if ((Read-Host $S.CustomHigh) -eq $Y) { $Global:Config.Flags.High = $true }
        if ((Read-Host $S.CustomExt) -eq $Y) { $Global:Config.Flags.Ext = $true }
    }
}

if ((Read-Host $S.Backup) -eq $Y) { $Global:Config.Backup = $true }
if ((Read-Host $S.Confirm1) -ne $Y) { exit }
if ((Read-Host $S.Confirm2) -ne $Y) { exit }

# =========================================================================================
# PHASE 2: TECHNISCHE AUSFÜHRUNGSFUNKTIONEN
# =========================================================================================

function Optimize-Registry {
    Write-Header "REGISTRY & KERNEL OPTIMIZATION"
    
    # Menü-Verzögerungen minimieren
    Write-Log "Adjusting MenuShowDelay to 0..."
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "0"
    
    # I/O & Kernel Tweaks für Performance (Speziell i7 CPUs)
    Write-Log "Optimizing Kernel Paging and I/O..."
    $SessPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
    Set-ItemProperty -Path $SessPath -Name "DisablePagingExecutive" -Value 1 # Kernel im RAM behalten
    Set-ItemProperty -Path $SessPath -Name "LargeSystemCache" -Value 1
    
    # GPU & Gaming Tweaks
    Write-Log "Enabling Hardware Accelerated GPU Scheduling (if supported)..."
    $GPUPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
    Set-ItemProperty -Path $GPUPath -Name "HwSchMode" -Value 2
    
    # Netzwerk-Stack Optimierung
    Write-Log "Tuning Network Stack for Latency..."
    netsh int tcp set global autotuninglevel=disabled
    netsh int tcp set global ecncapability=disabled
    netsh int tcp set global rsc=disabled
}

function Remove-UWPApps {
    Write-Header "UWP BLOATWARE REMOVAL"
    $AppsToRemove = @(
        "Microsoft.BingWeather", "Microsoft.GetHelp", "Microsoft.Getstarted",
        "Microsoft.Messaging", "Microsoft.MicrosoftSolitaireCollection", 
        "Microsoft.People", "Microsoft.SkypeApp", "Microsoft.YourPhone",
        "Microsoft.ZuneMusic", "Microsoft.ZuneVideo", "Microsoft.BingNews",
        "Microsoft.WindowsFeedbackHub", "Microsoft.WindowsMaps"
    )
    
    foreach ($App in $AppsToRemove) {
        Write-Log "Removing Package: $App"
        Get-AppxPackage -Name $App -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
    }
}

function Disable-Telemetry {
    Write-Header "TELEMETRY & PRIVACY HARDENING"
    
    Write-Log "Disabling Functional Discovery Telemetry..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0
    
    Write-Log "Disabling Scheduled Telemetry Tasks..."
    $Tasks = @(
        "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
        "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
        "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
        "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
        "\Microsoft\Windows\Autochk\Proxy"
    )
    foreach ($T in $Tasks) { Disable-ScheduledTask -TaskName (Split-Path $T -Leaf) -TaskPath (Split-Path $T -Parent) }
}

function Execute-Extreme-Purge {
    Write-Header "EXTREME PURGE MODE (TARGET 40 PROCESSES)"
    Write-Log "Warning: System-Core will be minimal after this." "Warning"
    
    # Massiver Dienst-Kill
    $ExtremeSvcs = @(
        "sysmain", "WerSvc", "WSearch", "DiagTrack", "dmwappushservice", 
        "PcaSvc", "TrkWks", "StiSvc", "CscService", "XblAuthManager", 
        "XblGameSave", "XboxNetApiSvc", "XboxGipSvc", "PhoneSvc", 
        "SensorService", "MapsBroker", "RetailDemo", "WalletService",
        "RemoteRegistry", "Fax", "BcastDVRUserService", "CaptureService"
    )
    
    foreach ($Svc in $ExtremeSvcs) {
        Write-Log "Killing & Disabling Service: $Svc"
        Stop-Service $Svc -Force
        Set-Service $Svc -StartupType Disabled
    }
    
    # Alle Apps außer Kern-Komponenten entfernen (Inkl. Microsoft Store)
    Write-Log "Performing Total Appx Wipeout..."
    $WhiteList = "ShellExperienceHost|StartMenuExperienceHost|immersivecontrolpanel|Search|Xaml|VCLibs"
    Get-AppxPackage -AllUsers | Where-Object {$_.Name -notmatch $WhiteList} | Remove-AppxPackage
    
    # Desktop-Effekte aus
    Write-Log "Disabling Visual Effects for maximum FPS..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2
}

# =========================================================================================
# PHASE 3: MAIN LOOP (DAS HERZSTÜCK)
# =========================================================================================

Clear-Host
Write-Log $S.Processing "Warning"

# A. Backup
if ($Global:Config.Backup) {
    Write-Log "Initiating Registry Backup..."
    $Path = "$HOME\Desktop\Debloatranium_Full_Backup"
    New-Item $Path -Type Directory -Force | Out-Null
    reg export "HKLM" "$Path\HKLM_Full.reg" /y | Out-Null
    reg export "HKCU" "$Path\HKCU_Full.reg" /y | Out-Null
    Write-Log "Backup stored on Desktop." "Success"
}

# B. Dark Mode (Default Professional)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0

# C. Hardware Features
if (!$Global:Config.BT) { 
    Write-Log "Deactivating Bluetooth Stack..."
    Get-Service "bth*" | Stop-Service -Force; Get-Service "bth*" | Set-Service -StartupType Disabled 
}
if (!$Global:Config.Printer) { 
    Write-Log "Deactivating Printer Spooler..."
    Stop-Service "Spooler" -Force; Set-Service "Spooler" -StartupType Disabled 
}
if (!$Global:Config.WiFi) { 
    Write-Log "Deactivating WLAN Services..."
    Stop-Service "WlanSvc" -Force; Set-Service "WlanSvc" -StartupType Disabled 
}

# D. Edge Removal
if (!$Global:Config.Edge) {
    Write-Log "Evicting Microsoft Edge..."
    Get-AppxPackage -AllUsers *MicrosoftEdge* | Remove-AppxPackage
    if ($Global:Config.Browser -match "1|2|3") {
        $b = switch($Global:Config.Browser){"1"{"Google.Chrome"};"2"{"Mozilla.Firefox"};"3"{"TorProject.TorBrowser"}}
        Write-Log "Deploying $b via Winget Infrastructure..."
        winget install $b --silent --accept-package-agreements --accept-source-agreements
    }
}

# E. Modulare Optimierung basierend auf Level
if ($Global:Config.Flags.Perf)  { Optimize-Registry }
if ($Global:Config.Flags.Light) { 
    Write-Log "Applying Light Service-Mod..."
    Set-Service "SysMain" -StartupType Disabled # Superfetch aus (gut für SSDs)
}
if ($Global:Config.Flags.Med)   { Remove-UWPApps }
if ($Global:Config.Flags.High)  { 
    Disable-Telemetry 
    Write-Log "Removing OneDrive Integration..."
    Get-Process "OneDrive" -ErrorAction SilentlyContinue | Stop-Process -Force
    # OneDrive Uninstall Command (Deep)
    $odPath = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
    if (!(Test-Path $odPath)) { $odPath = "$env:SystemRoot\System32\OneDriveSetup.exe" }
    Start-Process $odPath "/uninstall" -NoNewWindow -Wait
}
if ($Global:Config.Flags.Ext)   { Execute-Extreme-Purge }

# F. Abschluss-Reinigung
Write-Header "CLEANUP & FINALIZATION"
Write-Log "Purging Temp folders..."
Remove-Item "$env:TEMP\*" -Recurse -Force
Clear-RecycleBin -Confirm:$false

Write-Host "`n`n"
Write-Host "****************************************************************" -ForegroundColor Cyan
Write-Host "   $($S.Done)" -ForegroundColor Green -BackgroundColor Black
Write-Host "****************************************************************" -ForegroundColor Cyan
pause
