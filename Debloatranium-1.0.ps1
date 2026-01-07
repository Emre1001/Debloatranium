<#
.SYNOPSIS
    Debloatranium Framework - Quantum Overlord Enterprise Edition (v8.0)
    
.DESCRIPTION
    Ein hochgradig modulares System-Optimierungs-Framework für Windows 10/11.
    Speziell kalibriert für die Haswell-Architektur (i7-4790K) und Pascal-GPUs.
    Zielsetzung: Absolute Prozess-Minimierung (< 25-30 Prozesse) und maximale RAM-Freigabe.
    
    Hardware-Target:
    - CPU: Intel Core i7-4790K (Haswell Refresh)
    - GPU: NVIDIA GeForce GTX 1050 Ti
    - RAM: 16GB DDR3-1600 Dual-Channel
    
    (c) 2024-2026 Emre1001. Enterprise Grade Optimization Suite.
#>

# =========================================================================================
# I. GLOBAL ENVIRONMENT & POLICY CONFIGURATION
# =========================================================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$StartTime = Get-Date

# =========================================================================================
# II. ADVANCED LOGGING & DIAGNOSTICS ARCHITECTURE
# =========================================================================================

class DebloatraniumCoreLogger {
    static [void] PrintHeader() {
        Clear-Host
        $Lines = @(
            "######################################################################",
            "#                                                                    #",
            "#      DEBLOATRANIUM QUANTUM OVERLORD - ENTERPRISE v8.0              #",
            "#      Developed by Emre1001 | High-Performance Computing            #",
            "#                                                                    #",
            "######################################################################"
        )
        foreach ($Line in $Lines) {
            Write-Host $Line -ForegroundColor Cyan
        }
        Write-Host "`n[SYSTEM] Initialisierung des Frameworks gestartet..." -ForegroundColor Gray
    }

    static [void] Log([string]$Message, [string]$Level = "INFO") {
        $TS = Get-Date -Format "HH:mm:ss"
        $Color = switch($Level) {
            "SUCCESS"  { "Green" }
            "WARNING"  { "Yellow" }
            "CRITICAL" { "Red" }
            "STAGE"    { "Blue" }
            "HARDWARE" { "Magenta" }
            Default    { "White" }
        }
        Write-Host "[$TS] [$Level] $Message" -ForegroundColor $Color
    }

    static [void] TraceProgress([int]$Current, [int]$Total) {
        $Percent = [math]::Round(($Current / $Total) * 100)
        Write-Progress -Activity "Optimierung läuft" -Status "$Percent% Abgeschlossen" -PercentComplete $Percent
    }
}

# =========================================================================================
# III. HARDWARE ABSTRACTION LAYER (HAL) - i7-4790K SPECIFIC
# =========================================================================================

class HardwareIntrospection {
    [string]$ProcessorName
    [string]$VideoAdapter
    [long]$PhysicalMemoryBytes
    [string]$Motherboard

    HardwareIntrospection() {
        [DebloatraniumCoreLogger]::Log("Scanne Hardware-Topologie...", "STAGE")
        try {
            $cpu = Get-CimInstance Win32_Processor
            $gpu = Get-CimInstance Win32_VideoController
            $mem = Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum
            
            $this.ProcessorName = $cpu.Name
            $this.VideoAdapter = $gpu.Name
            $this.PhysicalMemoryBytes = $mem.Sum
            
            [DebloatraniumCoreLogger]::Log("CPU: $($this.ProcessorName)", "HARDWARE")
            [DebloatraniumCoreLogger]::Log("GPU: $($this.VideoAdapter)", "HARDWARE")
            [DebloatraniumCoreLogger]::Log("RAM: $([math]::Round($this.PhysicalMemoryBytes / 1GB)) GB erkannt.", "HARDWARE")
        } catch {
            [DebloatraniumCoreLogger]::Log("Hardware-Scan unvollständig. Nutze Standard-Profile.", "WARNING")
        }
    }
}

# =========================================================================================
# IV. SPECIALIZED OPTIMIZATION MODULES
# =========================================================================================

class CpuOptimizationModule {
    <#
    Optimiert den CPU-Scheduler für geringstmögliche Latenz.
    Speziell für i7-4790K: Deaktivierung von Power-Throttling.
    #>
    static [void] Execute() {
        [DebloatraniumCoreLogger]::Log("Konfiguriere CPU-Interrupts und Scheduling...", "STAGE")
        
        # Win32PrioritySeparation: 38 (0x26) -> Fokus auf Desktop-Performance
        $path = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
        Set-ItemProperty -Path $path -Name "Win32PrioritySeparation" -Value 38 -Type DWord
        
        # Deaktivierung von Spectre & Meltdown Protections (ERHÖHT FPS AUF i7-4790K MASSIV)
        [DebloatraniumCoreLogger]::Log("Deaktiviere CPU-Mitigationen (Spectre/Meltdown) für maximale FPS...", "WARNING")
        $kernelPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
        Set-ItemProperty -Path $kernelPath -Name "FeatureSettingsOverride" -Value 3 -Type DWord
        Set-ItemProperty -Path $kernelPath -Name "FeatureSettingsOverrideMask" -Value 3 -Type DWord
        
        # High-Performance Power Plan forcieren
        powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    }
}

class MemoryOptimizationModule {
    <#
    Target: 1GB Idle Footprint.
    Optimiert den Pagefile-Handling und den System-Cache.
    #>
    static [void] Execute() {
        [DebloatraniumCoreLogger]::Log("Initialisiere Quantum-Memory-Hardenining...", "STAGE")
        $mmPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
        
        $RegistryMap = @{
            "DisablePagingExecutive" = 1  # Kernel immer im RAM
            "LargeSystemCache"       = 0  # RAM für Anwendungen reservieren
            "IoPageLockLimit"        = 16777216
            "SecondLevelDataCache"   = 1024 # i7-4790K L2 Cache Optimierung
            "ClearPageFileAtShutdown" = 0
        }

        foreach ($entry in $RegistryMap.GetEnumerator()) {
            Set-ItemProperty -Path $mmPath -Name $entry.Key -Value $entry.Value -Type DWord
        }
        
        # Aggressives Standby-List Cleaning vorbereiten
        [DebloatraniumCoreLogger]::Log("Memory-Stack erfolgreich gehärtet.", "SUCCESS")
    }
}

class StorageOptimizationModule {
    <#
    Reduziert Disk-I/O Overheads auf NTFS-Ebene.
    #>
    static [void] Execute() {
        [DebloatraniumCoreLogger]::Log("Bereinige Speicher-I/O Pipeline...", "STAGE")
        fsutil behavior set disablelastaccess 1
        fsutil behavior set disable8dot3 1
        fsutil behavior set DisableDeleteNotify 0
        
        # Deaktivierung des Defragmentierungs-Schedules für SSDs
        schtasks /change /tn "\Microsoft\Windows\Defrag\ScheduledDefrag" /disable
    }
}

class NetworkOptimizationModule {
    <#
    TCPIP-Stack Tuning für Gaming und Low-Latency.
    #>
    static [void] Execute() {
        [DebloatraniumCoreLogger]::Log("Tuning des Network-Stacks (Low-Latency)...", "STAGE")
        netsh int tcp set global autotuninglevel=normal
        netsh int tcp set global chimney=enabled
        netsh int tcp set global rss=enabled
        netsh int tcp set global netdma=enabled
        netsh int tcp set global ecncapability=disabled
        netsh int tcp set global timestamps=disabled
        netsh int tcp set global initialrto=2000
    }
}

class GpuOptimizationModule {
    <#
    GPU-Priorität für den Desktop Window Manager (DWM).
    #>
    static [void] Execute() {
        [DebloatraniumCoreLogger]::Log("Optimiere GPU-Treiber-Ansprache...", "STAGE")
        $dwmPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\dwm.exe\PerfOptions"
        if (!(Test-Path $dwmPath)) { New-Item $dwmPath -Force | Out-Null }
        Set-ItemProperty -Path $dwmPath -Name "CpuPriorityClass" -Value 3 -Type DWord
    }
}

# =========================================================================================
# V. THE ABSOLUTE ZERO INFINITY - 10X DEBLOAT PROTOCOL
# =========================================================================================

class AbsoluteZeroEngine {
    
    static [void] PurgeSystemServices() {
        [DebloatraniumCoreLogger]::Log("TERMINIERE SYSTEM-DIENSTE (EXTREM-MODUS)...", "CRITICAL")
        
        $ServiceBlacklist = @(
            "EventLog", "Wcmsvc", "NlaSvc", "Dhcp", "Dnscache", "LmHosts", "PolicyAgent",
            "SDRSVC", "VaultSvc", "WbioSvc", "FrameServer", "FontCache", "Stisvc",
            "SettingSyncCoreSvc", "OneSyncSvc_*", "SysMain", "WSearch", "WerSvc",
            "DiagTrack", "dmwappushservice", "PcaSvc", "TrkWks", "CscService",
            "XblAuthManager", "XblGameSave", "XboxNetApiSvc", "XboxGipSvc",
            "PhoneSvc", "SensorService", "MapsBroker", "RetailDemo", "WalletService",
            "RemoteRegistry", "Fax", "BcastDVRUserService", "CaptureService",
            "MessagingService", "SEMgrSvc", "TabletInputService", "TermService",
            "UserExperienceVirtualizationService", "DusmSvc", "Spooler"
        )

        foreach ($svc in $ServiceBlacklist) {
            try {
                Stop-Service $svc -Force -ErrorAction SilentlyContinue
                Set-Service $svc -StartupType Disabled -ErrorAction SilentlyContinue
                [DebloatraniumCoreLogger]::Log("Service eliminiert: $svc", "INFO")
            } catch {}
        }
    }

    static [void] WipeTelemetryAndUwp() {
        [DebloatraniumCoreLogger]::Log("Lösche Telemetrie-Cluster und UWP-Bloatware...", "STAGE")
        
        # Telemetrie-Hardening
        reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\AutoLogger-Diagtrack-Listener" /v Start /t REG_DWORD /d 0 /f | Out-Null
        reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f | Out-Null
        
        # UWP Wipe (Radikal)
        $whiteList = "ShellExperienceHost|StartMenuExperienceHost|immersivecontrolpanel|Search|Xaml|VCLibs"
        Get-AppxPackage -AllUsers | Where-Object {$_.Name -notmatch $whiteList} | Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -notmatch $whiteList} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
    }

    static [void] FreezeUserInterface() {
        [DebloatraniumCoreLogger]::Log("Deaktiviere GUI-Animationen und Transparenz...", "INFO")
        $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        Set-ItemProperty -Path $path -Name "ListviewAlphaSelect" -Value 0 -Type DWord
        Set-ItemProperty -Path $path -Name "TaskbarAnimations" -Value 0 -Type DWord
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "0"
        
        # Game Mode Aktivierung
        reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d 1 /f | Out-Null
    }
}

# =========================================================================================
# VI. BROWSER DEPLOYMENT UNIT
# =========================================================================================

class BrowserDeployment {
    static [void] Install([string]$Choice) {
        $Manifest = @{
            "1" = @{ Name="Google Chrome"; Url="https://dl.google.com/chrome/install/standalone/policy/googlechromestandaloneenterprise64.msi" }
            "2" = @{ Name="Mozilla Firefox"; Url="https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=de" }
            "3" = @{ Name="Tor Browser"; Url="https://www.torproject.org/dist/torbrowser/13.0.10/torbrowser-install-win64-13.0.10_ALL.exe" }
        }

        if ($Manifest.ContainsKey($Choice)) {
            $Target = $Manifest[$Choice]
            [DebloatraniumCoreLogger]::Log("Downloade $($Target.Name)...", "STAGE")
            $TempPath = "$env:TEMP\browser_setup.exe"
            Invoke-WebRequest -Uri $Target.Url -OutFile $TempPath
            [DebloatraniumCoreLogger]::Log("Installiere $($Target.Name) im Hintergrund...", "INFO")
            Start-Process -FilePath $TempPath -ArgumentList "/silent /install" -Wait
            [DebloatraniumCoreLogger]::Log("Installation abgeschlossen.", "SUCCESS")
        }
    }
}

# =========================================================================================
# VII. ORCHESTRATION & MAIN CONTROL FLOW
# =========================================================================================

function Invoke-MainFlow {
    [DebloatraniumCoreLogger]::PrintHeader()
    
    # Init Hardware HAL
    $HAL = New-Object HardwareIntrospection
    
    # 1. Sprachauswahl (TR, DE, EN)
    Write-Host "`n[1] DEUTSCH | [2] ENGLISH | [3] TÜRKÇE" -ForegroundColor White
    $langChoice = Read-Host "Sprache / Dil secin"
    
    $S = switch($langChoice) {
        "3" { @{ WiFi="WiFi kalsin mi? (e/h)"; BT="Bluetooth kalsin mi? (e/h)"; Printer="Yazici destegi? (e/h)"; Edge="Edge silinsin mi? (e/h)"; Browser="Tarayici (1:Chrome, 2:FF, 3:Tor, 4:Yok)?"; Level="Seviye (1-6)?"; Backup="Yedek?"; Confirm="Baslat?"; Done="TAMAMLANDI." } }
        "1" { @{ WiFi="WLAN behalten? (j/n)"; BT="Bluetooth behalten? (j/n)"; Printer="Drucker-Support? (j/n)"; Edge="Edge entfernen? (j/n)"; Browser="Browser (1:Chrome, 2:FF, 3:Tor, 4:Keine)?"; Level="Level (1-6)?"; Backup="Backup erstellen?"; Confirm="Vorgang starten?"; Done="ABGESCHLOSSEN." } }
        Default { @{ WiFi="Keep WiFi? (y/n)"; BT="Keep Bluetooth? (y/n)"; Printer="Keep Printer? (y/n)"; Edge="Remove Edge?"; Browser="Browser (1:Chrome, 2:FF, 3:Tor, 4:None)?"; Level="Level (1-6)?"; Backup="Create Backup?"; Confirm="Start optimization?"; Done="DONE." } }
    }

    # 2. Datenerfassung
    $Y = if ($langChoice -eq "3") { "e" } elseif ($langChoice -eq "1") { "j" } else { "y" }
    
    $configWiFi   = (Read-Host $S.WiFi) -eq $Y
    $configBT     = (Read-Host $S.BT) -eq $Y
    $configPrint  = (Read-Host $S.Printer) -eq $Y
    $configEdge   = (Read-Host $S.Edge) -eq $Y
    $configBrowser = Read-Host $S.Browser
    $configLevel  = Read-Host $S.Level
    $configBackup = (Read-Host $S.Backup) -eq $Y

    if ((Read-Host $S.Confirm) -ne $Y) { 
        [DebloatraniumCoreLogger]::Log("Abbruch durch Benutzer.", "CRITICAL")
        exit 
    }

    # 3. Execution Phase
    [DebloatraniumCoreLogger]::Log("Starte Optimierungs-Pipeline...", "STAGE")
    
    if ($configBackup) {
        $BPath = "$HOME\Desktop\Debloatranium_V8_Backup"
        New-Item $BPath -ItemType Directory -Force | Out-Null
        reg export HKLM "$BPath\HKLM.reg" /y | Out-Null
        reg export HKCU "$BPath\HKCU.reg" /y | Out-Null
        [DebloatraniumCoreLogger]::Log("Registry-Backup gesichert auf Desktop.", "SUCCESS")
    }

    # Core Tuning (Immer aktiv ab Level 1)
    [CpuOptimizationModule]::Execute()
    [MemoryOptimizationModule]::Execute()
    [StorageOptimizationModule]::Execute()
    [NetworkOptimizationModule]::Execute()
    [GpuOptimizationModule]::Execute()

    # Browser Deployment
    [BrowserDeployment]::Install($configBrowser)

    # Toggle Hardware Services
    if (!$configWiFi)  { Stop-Service WlanSvc -Force; Set-Service WlanSvc -StartupType Disabled }
    if (!$configBT)    { Stop-Service bthserv -Force; Set-Service bthserv -StartupType Disabled }
    if (!$configPrint) { Stop-Service Spooler -Force; Set-Service Spooler -StartupType Disabled }

    # Absolute Zero Execution
    if ($configLevel -eq "6") {
        [AbsoluteZeroEngine]::PurgeSystemServices()
        [AbsoluteZeroEngine]::WipeTelemetryAndUwp()
        [AbsoluteZeroEngine]::FreezeUserInterface()
    }

    # Finalisierung
    $Duration = (Get-Date) - $StartTime
    [DebloatraniumCoreLogger]::Log("$($S.Done) Dauer: $($Duration.Seconds)s", "SUCCESS")
    Write-Host "`nBITTE RECHNER NEU STARTEN!" -ForegroundColor Red -BackgroundColor Black
    pause
}

# Start Framework
Invoke-MainFlow
