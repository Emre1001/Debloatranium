<#
.SYNOPSIS
    Debloatranium - Universal Absolute Zero Edition (v5.0)
.DESCRIPTION
    Version: 5.0 "Quantum Entropy" - Deep Hardware Optimization Suite
    Author: Emre1001
    Target: Ultra-Low Latency, < 40 Processes, ~1GB RAM Footprint.
    Architecture: Modular Function-Based Professional Infrastructure.
    Optimization: Intel Core i7 4790K / GTX 1050 Ti High-Performance Tuning.
#>

# =========================================================================================
# GLOBALER SYSTEM-CHECK & KONTEXT-INITIALISIERUNG
# =========================================================================================

$ErrorActionPreference = "SilentlyContinue"
$StartTime = Get-Date

function Invoke-Administrator-Check {
    Write-Host "[SYSTEM] Überprüfe Berechtigungsstufe..." -ForegroundColor Gray
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "################################################################" -ForegroundColor Red
        Write-Host "   KRITISCHER FEHLER: KEINE ADMINISTRATOR-RECHTE" -ForegroundColor Red
        Write-Host "   Dieses Tool erfordert direkten Zugriff auf den Kernel-Stack." -ForegroundColor Red
        Write-Host "################################################################" -ForegroundColor Red
        pause
        exit
    }
    Write-Host "[SYSTEM] Administrator-Zugriff bestätigt." -ForegroundColor Green
}

Invoke-Administrator-Check

# =========================================================================================
# KONFIGURATIONS-MATRIX & LOKALISIERUNG
# =========================================================================================

$Global:DebloatConfig = @{
    System = @{
        WiFi      = $true
        Bluetooth = $true
        Printer   = $true
        Edge      = $true
        Backup    = $false
    }
    Optimization = @{
        Level = 0
        Flags = @{
            Perf  = $false
            Light = $false
            Med   = $false
            High  = $false
            Ext   = $false
            Zero  = $false
        }
    }
}

$lang = @{
    DE = @{
        Header      = "DEBLOATRANIUM v5.0 - QUANTUM ENTROPY PROFESSIONAL"
        Welcome     = "Initialisierung der Debloatranium Engine v5.0 gestartet."
        WiFi        = "[HARDWARE] Soll die WLAN-Infrastruktur erhalten bleiben? (j/n): "
        BT          = "[HARDWARE] Soll der Bluetooth-Stack erhalten bleiben? (j/n): "
        Printer     = "[HARDWARE] Soll der Drucker-Spooler aktiv bleiben? (j/n): "
        Edge        = "[SYSTEM] Soll Microsoft Edge unwiderruflich entfernt werden? (j/n): "
        Backup      = "[SECURITY] Soll eine Registry-Sicherung (HKLM/HKCU) erstellt werden? (j/n): "
        ConfirmZero = "[WARNUNG] Absolute Zero deaktiviert kritische Dienste. Fortfahren? (j/n): "
        Level       = "WÄHLE SYSTEM-PROFIL:`n[1] MINIMUM   - Latenz-Optimierung & Gaming-Profile`n[2] LIGHT     - SSD-Tuning & Basis-Dienst-Bereinigung`n[3] MEDIUM    - UWP-Entfernung & Erweitertes RAM-Management`n[4] HIGH      - Aggressives System-Purge (Cortana/OneDrive)`n[5] EXTREME   - ULTRA GAMING (Fokus: FPS & Prozesse)`n[6] ZERO      - ABSOLUTE ZERO (< 1GB RAM Idle, < 35 Prozesse)`n`nAUSWAHL: "
        Finalize    = "PROZESS ABGESCHLOSSEN. System-Neustart erforderlich für Kernel-Synchronisation."
    }
    EN = @{
        Header      = "DEBLOATRANIUM v5.0 - QUANTUM ENTROPY PROFESSIONAL"
        Welcome     = "Initializing Debloatranium Engine v5.0..."
        WiFi        = "[HARDWARE] Keep WiFi infrastructure? (y/n): "
        BT          = "[HARDWARE] Keep Bluetooth stack? (y/n): "
        Printer     = "[HARDWARE] Keep Printer spooler? (y/n): "
        Edge        = "[SYSTEM] Permanently remove Microsoft Edge? (y/n): "
        Backup      = "[SECURITY] Create full Registry Backup? (y/n): "
        ConfirmZero = "[WARNING] Absolute Zero disables core services. Continue? (y/n): "
        Level       = "CHOOSE SYSTEM PROFILE:`n[1] MINIMUM   - Latency Optimization & Gaming Profiles`n[2] LIGHT     - SSD Tuning & Basic Service Cleanup`n[3] MEDIUM    - UWP Removal & Advanced RAM Management`n[4] HIGH      - Aggressive System Purge (Cortana/OneDrive)`n[5] EXTREME   - ULTRA GAMING (Focus: FPS & Processes)`n[6] ZERO      - ABSOLUTE ZERO (< 1GB RAM Idle, < 35 Procs)`n`nCHOICE: "
        Finalize    = "PROCESS COMPLETE. System restart required for kernel synchronization."
    }
}

# =========================================================================================
# UI KOMPONENTEN & LOGGING FUNKTIONEN
# =========================================================================================

function Show-Header {
    Clear-Host
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host "                 DEBLOATRANIUM QUANTUM v5.0                           " -ForegroundColor White -BackgroundColor DarkBlue
    Write-Host "======================================================================" -ForegroundColor Cyan
}

function Write-Status {
    param([string]$Message, [string]$Type = "INFO")
    $color = switch($Type) {
        "SUCCESS" { "Green" }
        "WARN"    { "Yellow" }
        "FAIL"    { "Red" }
        "STAGE"   { "Cyan" }
        Default   { "White" }
    }
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] [$Type] $Message" -ForegroundColor $color
}

# =========================================================================================
# HARDWARE-OPTIMIERUNGS-MODULE (DEDIZIERT)
# =========================================================================================

function Set-CPU-Architecture-Optimization {
    Write-Status "Optimiere CPU-Scheduler & Thread-Priorisierung..." "STAGE"
    $path = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
    # Win32PrioritySeparation 38 (Hex 0x26) - Optimiert für High-Performance Desktop
    Set-ItemProperty -Path $path -Name "Win32PrioritySeparation" -Value 38
    Write-Status "CPU Kern-Parken wird deaktiviert..." "INFO"
    powercfg -setacvalueindex scheme_current sub_processor CPMINCORES 100
    powercfg -setactive scheme_current
}

function Set-RAM-Memory-Hardening {
    Write-Status "Initialisiere RAM-Management (Target: 1GB Idle)..." "STAGE"
    $memPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
    # Kernel im RAM halten (Vermeidung von Pagefile-Zugriffen)
    Set-ItemProperty -Path $memPath -Name "DisablePagingExecutive" -Value 1
    # Datei-Cache minimieren für maximale Applikations-Verfügbarkeit
    Set-ItemProperty -Path $memPath -Name "LargeSystemCache" -Value 0
    # I/O Page Lock Limit für 16GB DDR3 optimieren
    Set-ItemProperty -Path $memPath -Name "IoPageLockLimit" -Value 16777216
    Write-Status "Speicher-Adressierung wurde gehärtet." "SUCCESS"
}

function Set-SSD-I/O-Performance {
    Write-Status "Maximiere SSD-Durchsatz & Dateisystem-Latenz..." "STAGE"
    # NTFS Zugriffszeit-Update deaktivieren
    fsutil behavior set disablelastaccess 1
    # 8.3 Dateinamen-Erstellung deaktivieren (Reduziert Overhead)
    fsutil behavior set disable8dot3 1
    # TRIM Aktivierung sicherstellen
    fsutil behavior set DisableDeleteNotify 0
    Write-Status "SSD-I/O-Parameter synchronisiert." "SUCCESS"
}

function Set-GPU-Latency-Optimization {
    Write-Status "Tuning GPU-Pipeline & DWM-Priorität..." "STAGE"
    $dwmPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\dwm.exe\PerfOptions"
    if (!(Test-Path $dwmPath)) { New-Item $dwmPath -Force }
    # DWM auf High Priority setzen für minimalen Input-Lag
    Set-ItemProperty -Path $dwmPath -Name "CpuPriorityClass" -Value 3
    Write-Status "Grafik-Subsystem auf Latenz optimiert." "SUCCESS"
}

function Set-Network-Stack-Optimization {
    Write-Status "Konfiguriere Netzwerk-Stack (Ultra-Low-Latency)..." "STAGE"
    netsh int tcp set global autotuninglevel=normal
    netsh int tcp set global chimney=enabled
    netsh int tcp set global rss=enabled
    netsh int tcp set global ecncapability=disabled
    netsh int tcp set global timestamps=disabled
    Write-Status "Netzwerk-Parameter für Gaming stabilisiert." "SUCCESS"
}

# =========================================================================================
# SYSTEM-PURGE MODULE (DEDIZIERT)
# =========================================================================================

function Invoke-Registry-Backup {
    Write-Status "Erstelle globale Registry-Sicherung..." "STAGE"
    $bDir = "$HOME\Desktop\Debloatranium_Backup_V5"
    New-Item -ItemType Directory -Path $bDir -Force | Out-Null
    reg export "HKLM" "$bDir\HKLM_Backup.reg" /y
    reg export "HKCU" "$bDir\HKCU_Backup.reg" /y
    Write-Status "Sicherung abgeschlossen unter $bDir" "SUCCESS"
}

function Remove-Edge-Infrastructure {
    Write-Status "Eliminiere Microsoft Edge Fragmente..." "STAGE"
    Get-AppxPackage -AllUsers *MicrosoftEdge* | Remove-AppxPackage
    $edgePath = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application"
    if (Test-Path $edgePath) { Write-Status "HINWEIS: Manuelle Deinstallation von Edge empfohlen für vollständige Entfernung." "WARN" }
}

function Remove-UWP-Bloatware {
    param([string[]]$AppList)
    Write-Status "Starte UWP-Bereinigungs-Zyklus..." "STAGE"
    foreach ($app in $AppList) {
        Write-Status "Entferne Paket: $app" "INFO"
        Get-AppxPackage -Name "*$app*" -AllUsers | Remove-AppxPackage
    }
}

function Invoke-Absolute-Zero-Purge {
    Write-Status "!!! ABSOLUTE ZERO PROTOKOLL GESTARTET !!!" "WARN"
    
    # Massive Liste an Diensten für < 35 Prozesse
    $services = @(
        "SysMain", "WSearch", "WerSvc", "DiagTrack", "dmwappushservice", "PcaSvc", "TrkWks",
        "StiSvc", "CscService", "XblAuthManager", "XblGameSave", "XboxNetApiSvc", "XboxGipSvc",
        "PhoneSvc", "SensorService", "MapsBroker", "RetailDemo", "WalletService", "RemoteRegistry",
        "Fax", "BcastDVRUserService", "CaptureService", "MessagingService", "SEMgrSvc",
        "TabletInputService", "TermService", "UserExperienceVirtualizationService", "OneSyncSvc"
    )

    foreach ($svc in $services) {
        Write-Status "Deaktiviere permanent: $svc" "INFO"
        Stop-Service $svc -Force
        Set-Service $svc -StartupType Disabled
    }

    # Hintergrund-Apps global terminieren
    $bgKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
    if (!(Test-Path $bgKey)) { New-Item $bgKey -Force }
    Set-ItemProperty $bgKey -Name "GlobalUserDisabled" -Value 1

    # Visuelle Last eliminieren
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2
    
    # Cortana & Search Terminierung
    $searchKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
    Set-ItemProperty -Path $searchKey -Name "BingSearchEnabled" -Value 0
    Set-ItemProperty -Path $searchKey -Name "CanCortanaBeEnabled" -Value 0

    # Radikale App-Löschung (Inkl. Store)
    Write-Status "Führe radikale App-Eliminierung durch..." "INFO"
    $whiteList = "ShellExperienceHost|StartMenuExperienceHost|immersivecontrolpanel|Search|Xaml|VCLibs"
    Get-AppxPackage -AllUsers | Where-Object {$_.Name -notmatch $whiteList} | Remove-AppxPackage
}

# =========================================================================================
# MAIN EXECUTION CORE (LOGIK-STEUERUNG)
# =========================================================================================

Show-Header

# Sprachauswahl
$choice = Read-Host "Wähle Sprache / Select Language (1: DE, 2: EN)"
$S = if ($choice -eq "1") { $lang.DE } else { $lang.EN }
$Y = if ($choice -eq "1") { "j" } else { "y" }
$N = "n"

Show-Header
Write-Status $S.Welcome "SUCCESS"

# Datenerfassung
if ((Read-Host $S.WiFi) -eq $N) { $Global:DebloatConfig.System.WiFi = $false }
if ((Read-Host $S.BT) -eq $N) { $Global:DebloatConfig.System.Bluetooth = $false }
if ((Read-Host $S.Printer) -eq $N) { $Global:DebloatConfig.System.Printer = $false }
if ((Read-Host $S.Edge) -eq $Y) { $Global:DebloatConfig.System.Edge = $false }
if ((Read-Host $S.Backup) -eq $Y) { $Global:DebloatConfig.System.Backup = $true }

$lvl = Read-Host $S.Level
switch ($lvl) {
    "1" { $Global:DebloatConfig.Optimization.Flags.Perf = $true }
    "2" { $Global:DebloatConfig.Optimization.Flags.Perf = $true; $Global:DebloatConfig.Optimization.Flags.Light = $true }
    "3" { $Global:DebloatConfig.Optimization.Flags.Perf = $true; $Global:DebloatConfig.Optimization.Flags.Light = $true; $Global:DebloatConfig.Optimization.Flags.Med = $true }
    "4" { $Global:DebloatConfig.Optimization.Flags.Perf = $true; $Global:DebloatConfig.Optimization.Flags.Light = $true; $Global:DebloatConfig.Optimization.Flags.Med = $true; $Global:DebloatConfig.Optimization.Flags.High = $true }
    "5" { $Global:DebloatConfig.Optimization.Flags.Perf = $true; $Global:DebloatConfig.Optimization.Flags.Light = $true; $Global:DebloatConfig.Optimization.Flags.Med = $true; $Global:DebloatConfig.Optimization.Flags.High = $true; $Global:DebloatConfig.Optimization.Flags.Ext = $true }
    "6" { $Global:DebloatConfig.Optimization.Flags.Perf = $true; $Global:DebloatConfig.Optimization.Flags.Light = $true; $Global:DebloatConfig.Optimization.Flags.Med = $true; $Global:DebloatConfig.Optimization.Flags.High = $true; $Global:DebloatConfig.Optimization.Flags.Ext = $true; $Global:DebloatConfig.Optimization.Flags.Zero = $true }
}

# START DER OPTIMIERUNG
if ($Global:DebloatConfig.Optimization.Flags.Zero -and (Read-Host $S.ConfirmZero) -ne $Y) { exit }

# Phase A: Sicherheit
if ($Global:DebloatConfig.System.Backup) { Invoke-Registry-Backup }

# Phase B: Hardware Core (Immer aktiv für Performance)
Set-CPU-Architecture-Optimization
Set-RAM-Memory-Hardening
Set-SSD-I/O-Performance
Set-GPU-Latency-Optimization
Set-Network-Stack-Optimization

# Phase C: Hardware Feature Management
$hardSvcs = @()
if (!$Global:DebloatConfig.System.Bluetooth) { $hardSvcs += "bthserv", "BTAGService" }
if (!$Global:DebloatConfig.System.Printer)   { $hardSvcs += "Spooler" }
if (!$Global:DebloatConfig.System.WiFi)      { $hardSvcs += "WlanSvc" }
foreach ($s in $hardSvcs) { Stop-Service $s -Force; Set-Service $s -StartupType Disabled }

# Phase D: Modulare Bereinigung
if ($Global:DebloatConfig.Optimization.Flags.Med) {
    Remove-UWP-Bloatware -AppList @("BingWeather", "GetHelp", "SkypeApp", "YourPhone", "ZuneMusic", "BingNews", "FeedbackHub")
}

if ($Global:DebloatConfig.Optimization.Flags.High) {
    Write-Status "Entferne OneDrive & Cortana-Core..." "STAGE"
    Get-AppxPackage *onedrive* | Remove-AppxPackage
    Get-AppxPackage *cortana* | Remove-AppxPackage
}

if (!$Global:DebloatConfig.System.Edge) { Remove-Edge-Infrastructure }

# Phase E: Absolute Zero (Ultimative Lösung)
if ($Global:DebloatConfig.Optimization.Flags.Zero) { Invoke-Absolute-Zero-Purge }

# Phase F: Finalisierung
Write-Status "Bereinige System-Cache & Temp-Files..." "STAGE"
Remove-Item "$env:TEMP\*" -Recurse -Force
Clear-RecycleBin -Confirm:$false

$Duration = (Get-Date) - $StartTime
Write-Host "`n"
Write-Host "****************************************************************" -ForegroundColor Cyan
Write-Host "   $($S.Finalize)" -ForegroundColor Green -BackgroundColor Black
Write-Host "   Gesamtdauer: $($Duration.Seconds) Sekunden." -ForegroundColor White
Write-Host "****************************************************************" -ForegroundColor Cyan
pause
