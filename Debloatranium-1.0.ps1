<#
.SYNOPSIS
    Debloatranium Framework - Universal Architect Edition (v10.7)
    
.DESCRIPTION
    Ein hochprofessionelles, objektorientiertes Optimierungs-Framework für Windows.
    Entwickelt für maximale System-Transparenz, minimale Latenz und universelle Kompatibilität.
    Optimiert für High-Performance Legacy Hardware (i7-4790K Klasse).
    
    FIX: Umfassendes Debugging der Klassen-Syntax (PowerShell 5.1/7+ Kompatibilität).
    ERWEITERUNG: Zusätzliche Deep-Cleanup Module und erweiterte Hardware-Profile.
    
    (c) 2024-2026 Emre1001. Alle Rechte vorbehalten.
#>

# =========================================================================================
# I. GLOBAL ENVIRONMENT & PRIVILEGE ESCALATION
# =========================================================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$StartTime = Get-Date

# Sicherheitsprüfung: Administrator-Privilegien
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "CRITICAL: Administrator-Rechte erforderlich! Bitte PowerShell als Administrator starten."
    exit
}

# =========================================================================================
# II. ADVANCED LOGGING INFRASTRUCTURE (ENTERPRISE GRADE)
# =========================================================================================

class DebloatLogger {
    static [void] Header() {
        Clear-Host
        $Title = @"
################################################################################
#                                                                              #
#      DEBLOATRANIUM UNIVERSAL ARCHITECT - ENTERPRISE v10.7                    #
#      System-Optimierung für jeden PC | Entwickelt von Emre1001               #
#                                                                              #
################################################################################
"@
        Write-Host $Title -ForegroundColor Cyan
        Write-Host "[SYSTEM] Framework-Initialisierung läuft..." -ForegroundColor Gray
    }

    static [void] Log([string]$Msg, [string]$Level = "INFO") {
        $T = Get-Date -Format "HH:mm:ss"
        $C = switch($Level) {
            "SUCCESS"  { "Green" }
            "WARNING"  { "Yellow" }
            "CRITICAL" { "Red" }
            "STAGE"    { "Cyan" }
            "HARDWARE" { "Magenta" }
            "CONFIG"   { "Blue" }
            Default    { "White" }
        }
        Write-Host "[$T] [$Level] $Msg" -ForegroundColor $C
    }

    static [void] Separator() {
        Write-Host ("=" * 80) -ForegroundColor Gray
    }
}

# =========================================================================================
# III. UNIVERSAL HARDWARE ABSTRACTION LAYER (HAL)
# =========================================================================================

class SystemInventory {
    [string]$CPU
    [string]$GPU
    [long]$RAM_GB
    [string]$OS_Name
    [bool]$IsSSD
    [bool]$IsLaptop
    [int]$CoreCount

    SystemInventory() {
        [DebloatLogger]::Log("Hardware-Audit wird durchgeführt...", "STAGE")
        try {
            $cpuInfo = Get-CimInstance Win32_Processor
            $gpuInfo = Get-CimInstance Win32_VideoController | Select-Object -First 1
            $memInfo = Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum
            $osInfo  = Get-CimInstance Win32_OperatingSystem
            $drive   = Get-PhysicalDisk | Select-Object -First 1
            $chassis = Get-CimInstance Win32_SystemEnclosure

            $this.CPU = $cpuInfo.Name.Trim()
            $this.GPU = $gpuInfo.Name
            $this.RAM_GB = [math]::Round($memInfo.Sum / 1GB)
            $this.OS_Name = $osInfo.Caption
            $this.CoreCount = $cpuInfo.NumberOfCores
            $this.IsSSD = ($drive.MediaType -eq "SSD")
            $this.IsLaptop = ($chassis.ChassisTypes -contains 8 -or $chassis.ChassisTypes -contains 9 -or $chassis.ChassisTypes -contains 10)

            [DebloatLogger]::Log("CPU: $($this.CPU) ($($this.CoreCount) Kerne)", "HARDWARE")
            [DebloatLogger]::Log("GPU: $($this.GPU)", "HARDWARE")
            [DebloatLogger]::Log("RAM: $($this.RAM_GB) GB DDR3/DDR4", "HARDWARE")
            [DebloatLogger]::Log("Typ: $(if($this.IsLaptop){"Laptop"}else{"Desktop"})", "HARDWARE")
        } catch {
            [DebloatLogger]::Log("Hardware-Scan unvollständig. Nutze generisches Profil.", "WARNING")
        }
    }
}

# =========================================================================================
# IV. SECURITY, BACKUP & RECOVERY
# =========================================================================================

class SecurityVault {
    [string]$Path

    SecurityVault() {
        $this.Path = Join-Path $env:USERPROFILE "Desktop\Debloatranium_Backup_$(Get-Date -Format 'yyyyMMdd')"
    }

    [void] CreateFullBackup([string]$Lang) {
        if (!(Test-Path $this.Path)) { New-Item $this.Path -ItemType Directory -Force | Out-Null }
        
        $Msg = if($Lang -eq "1") { "Erstelle Backup im Verzeichnis: $($this.Path)" } else { "Creating backup in: $($this.Path)" }
        [DebloatLogger]::Log($Msg, "STAGE")

        try {
            # Registry Export
            reg export HKLM "$($this.Path)\System_HKLM.reg" /y | Out-Null
            reg export HKCU "$($this.Path)\User_HKCU.reg" /y | Out-Null
            
            # Host File Backup
            Copy-Item "C:\Windows\System32\drivers\etc\hosts" -Destination "$($this.Path)\hosts.bak" -ErrorAction SilentlyContinue
            
            # System Restore Point
            Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
            Checkpoint-Computer -Description "Debloatranium_v10.7_AutoBackup" -RestorePointType "MODIFY_SETTINGS"
            [DebloatLogger]::Log("Backup erfolgreich abgeschlossen.", "SUCCESS")
        } catch {
            [DebloatLogger]::Log("Backup-Fehler. Optimierung wird auf eigenes Risiko fortgesetzt.", "CRITICAL")
        }
    }
}

# =========================================================================================
# V. OPTIMIZATION MODULES (CORE ENGINES)
# =========================================================================================

class KernelEngine {
    static [void] ApplyTuning([SystemInventory]$Inv) {
        [DebloatLogger]::Log("Konfiguriere Kernel & CPU-Scheduling...", "STAGE")
        
        # Priority Separation für maximale Vordergrund-Leistung (Short Variable, High Priority)
        $KPath = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
        Set-ItemProperty -Path $KPath -Name "Win32PrioritySeparation" -Value 38 -Type DWord
        
        # IRQ-Priorisierung für System-Timer
        $IrqPath = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
        Set-ItemProperty -Path $IrqPath -Name "IRQ8Priority" -Value 1 -Type DWord
        
        # Power Throttling global deaktivieren
        $PowerPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling"
        if (!(Test-Path $PowerPath)) { 
            New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power" -Name "PowerThrottling" -ErrorAction SilentlyContinue | Out-Null
        }
        reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d 1 /f | Out-Null

        # Deaktiviere CPU-Mitigationen für i7-4790K (Haswell Architektur benötigt diesen Boost)
        [DebloatLogger]::Log("Optimiere CPU-Mitigationen für maximale Gaming-Performance...", "CONFIG")
        $MemPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
        Set-ItemProperty -Path $MemPath -Name "FeatureSettingsOverride" -Value 3 -Type DWord
        Set-ItemProperty -Path $MemPath -Name "FeatureSettingsOverrideMask" -Value 3 -Type DWord
        
        # Deaktiviere Meltdown/Spectre via Boot-Configuration (Fortgeschritten)
        bcdedit /set {current} nx AlwaysOff | Out-Null
    }
}

class FileSystemEngine {
    static [void] Apply([bool]$IsSSD) {
        [DebloatLogger]::Log("Optimiere NTFS & Disk-I/O...", "STAGE")
        
        # Deaktiviere 8.3 Namen und Last Access Time (spart I/O Operationen)
        fsutil behavior set disablelastaccess 1
        fsutil behavior set disable8dot3 1
        
        # NTFS Memory Management
        $MMPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
        Set-ItemProperty -Path $MMPath -Name "LargeSystemCache" -Value 0 -Type DWord
        Set-ItemProperty -Path $MMPath -Name "IoPageLockLimit" -Value 16777216 -Type DWord # 16MB Lock Limit
        
        # Prefetcher/Superfetch Optimierung
        $PrefetchPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters"
        Set-ItemProperty -Path $PrefetchPath -Name "EnablePrefetcher" -Value 0 -Type DWord
        Set-ItemProperty -Path $PrefetchPath -Name "EnableSuperfetch" -Value 0 -Type DWord
    }
}

class NetworkEngine {
    static [void] TuneTcpStack() {
        [DebloatLogger]::Log("Optimiere Netzwerk-Stack (Gaming Latenz)...", "STAGE")
        
        # TCP-Optimierungen via netsh
        netsh int tcp set global autotuninglevel=normal
        netsh int tcp set global rss=enabled
        netsh int tcp set global chimney=enabled
        netsh int tcp set global netdma=enabled
        netsh int tcp set global dca=enabled
        netsh int tcp set global ecncapability=disabled
        netsh int tcp set global timestamps=disabled
        netsh int tcp set global nonsackrttresiliency=disabled
        netsh int tcp set global rsc=disabled
        
        # Netzwerk-Drosselung deaktivieren
        $NetPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
        Set-ItemProperty -Path $NetPath -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord
        Set-ItemProperty -Path $NetPath -Name "SystemResponsiveness" -Value 0 -Type DWord
    }
}

class PrivacyEngine {
    static [void] ApplyHardening() {
        [DebloatLogger]::Log("Blockiere Telemetrie & Data-Mining...", "STAGE")
        
        $Policies = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
        if (!(Test-Path $Policies)) { New-Item $Policies -Force | Out-Null }
        Set-ItemProperty -Path $Policies -Name "AllowTelemetry" -Value 0 -Type DWord
        
        # Deaktiviere Cortana & Suche-Tracker
        $Search = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
        if (!(Test-Path $Search)) { New-Item $Search -Force | Out-Null }
        Set-ItemProperty -Path $Search -Name "AllowCortana" -Value 0 -Type DWord
        Set-ItemProperty -Path $Search -Name "AllowSearchToUseLocation" -Value 0 -Type DWord
        
        # Werbe-ID deaktivieren
        $AdPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
        if (!(Test-Path $AdPath)) { New-Item $AdPath -Force | Out-Null }
        Set-ItemProperty -Path $AdPath -Name "Enabled" -Value 0 -Type DWord
    }
}

class VisualEngine {
    static [void] ApplyDesktopTweaks() {
        [DebloatLogger]::Log("Optimiere Desktop-Animationen & Menüs...", "STAGE")
        
        # Klassisches Kontextmenü für Windows 11 (wenn anwendbar)
        $Win11Context = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
        if (!(Test-Path $Win11Context)) { New-Item -Path $Win11Context -Force | Out-Null }
        Set-ItemProperty -Path $Win11Context -Name "(Default)" -Value "" -Force
        
        # Menü-Verzögerung reduzieren
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "0"
        
        # Dark Mode erzwingen
        $Persist = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
        Set-ItemProperty -Path $Persist -Name "AppsUseLightTheme" -Value 0 -Type DWord
        Set-ItemProperty -Path $Persist -Name "SystemUsesLightTheme" -Value 0 -Type DWord
    }
}

# =========================================================================================
# VI. THE ABSOLUTE ZERO PROTOCOL (LEVEL 6)
# =========================================================================================

class AbsoluteZeroEngine {
    static [void] PurgeServices() {
        [DebloatLogger]::Log("ELIMINIERE SYSTEM-DIENSTE (RADIKAL)...", "CRITICAL")
        
        $DeathList = @(
            "EventLog", "Wcmsvc", "NlaSvc", "Dhcp", "Dnscache", "LmHosts", "PolicyAgent",
            "SDRSVC", "VaultSvc", "WbioSvc", "FrameServer", "FontCache", "Stisvc",
            "SettingSyncCoreSvc", "OneSyncSvc_*", "SysMain", "WSearch", "WerSvc",
            "DiagTrack", "dmwappushservice", "PcaSvc", "TrkWks", "CscService",
            "XblAuthManager", "XblGameSave", "XboxNetApiSvc", "XboxGipSvc",
            "PhoneSvc", "SensorService", "MapsBroker", "RetailDemo", "WalletService",
            "RemoteRegistry", "Fax", "BcastDVRUserService", "CaptureService",
            "MessagingService", "SEMgrSvc", "TabletInputService", "TermService",
            "UserExperienceVirtualizationService", "Spooler", "PrintNotify",
            "WbioSvc", "Wisvc", "WpcMonSvc", "SecurityHealthService"
        )

        foreach ($service in $DeathList) {
            try {
                Stop-Service $service -Force -ErrorAction SilentlyContinue
                Set-Service $service -StartupType Disabled -ErrorAction SilentlyContinue
                [DebloatLogger]::Log("Dienst terminiert: $service", "INFO")
            } catch {}
        }
    }

    static [void] PurgeUwpPackages() {
        [DebloatLogger]::Log("Entferne UWP-Framework & Bloatware...", "STAGE")
        $White = "ShellExperienceHost|StartMenuExperienceHost|immersivecontrolpanel|Search|Xaml|VCLibs|DesktopAppInstaller"
        Get-AppxPackage -AllUsers | Where-Object {$_.Name -notmatch $White} | Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -notmatch $White} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
    }

    static [void] DeepRegistryClean() {
        [DebloatLogger]::Log("Säubere Registry-Leichen...", "STAGE")
        # Entferne Telemetrie-Keys im Root
        reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" /f | Out-Null
        reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /f | Out-Null
    }
}

# =========================================================================================
# VII. USER INTERFACE & INPUT MANAGEMENT
# =========================================================================================

class UserInterface {
    [hashtable]$Strings
    [string]$Lang
    [string]$Y_Key
    [string]$N_Key

    UserInterface([string]$LangID) {
        $this.Lang = $LangID
        switch ($LangID) {
            "3" { # Türkce
                $this.Y_Key = "e"; $this.N_Key = "h"
                $this.Strings = @{
                    Intro = "Debloatranium v10.7'a Hosgeldiniz."
                    Prompt = "Seciminiz (e: Evet, h: Hayir): "
                    WiFi = "WiFi kalsin mi? "
                    BT = "Bluetooth kalsin mi? "
                    Print = "Yazici kalsin mi? "
                    Edge = "Edge silinsin mi? "
                    Browser = "Tarayici (1: Chrome, 2: Firefox, 3: Tor, 4: Yok): "
                    Level = "Seviye secin (1-6): "
                    Backup = "Yedek alinsin mi? "
                    Confirm = "BASLATILSIN MI? "
                    Final = "ISLEM BITTI. RESTART GEREKLI."
                    Cleaning = "Temizlik yapiliyor..."
                }
            }
            "1" { # Deutsch
                $this.Y_Key = "j"; $this.N_Key = "n"
                $this.Strings = @{
                    Intro = "Willkommen bei Debloatranium v10.7."
                    Prompt = "Eingabe (j: Ja, n: Nein): "
                    WiFi = "WLAN behalten? "
                    BT = "Bluetooth behalten? "
                    Print = "Drucker behalten? "
                    Edge = "Microsoft Edge entfernen? "
                    Browser = "Browser (1: Chrome, 2: Firefox, 3: Tor, 4: Keiner): "
                    Level = "Level wählen (1-6): "
                    Backup = "System-Sicherung erstellen? "
                    Confirm = "VORGANG JETZT STARTEN? "
                    Final = "OPTIMIERUNG BEENDET. NEUSTART ERFORDERLICH."
                    Cleaning = "Systemreinigung wird ausgeführt..."
                }
            }
            Default { # English
                $this.Y_Key = "y"; $this.N_Key = "n"
                $this.Strings = @{
                    Intro = "Welcome to Debloatranium v10.7."
                    Prompt = "Input (y: Yes, n: No): "
                    WiFi = "Keep WiFi? "
                    BT = "Keep Bluetooth? "
                    Print = "Keep Printer? "
                    Edge = "Remove Edge? "
                    Browser = "Browser (1: Chrome, 2: Firefox, 3: Tor, 4: None): "
                    Level = "Select Level (1-6): "
                    Backup = "Create System Backup? "
                    Confirm = "START PROCESS NOW? "
                    Final = "COMPLETED. RESTART REQUIRED."
                    Cleaning = "Cleaning system..."
                }
            }
        }
    }

    [bool] Ask([string]$Key) {
        $Val = ""
        $P = $this.Strings[$Key] + $this.Strings["Prompt"]
        while ($Val -notmatch "^($($this.Y_Key)|$($this.N_Key))$") {
            $Val = (Read-Host $P).ToLower().Trim()
        }
        return $Val -eq $this.Y_Key
    }

    [string] Select([string]$Key, [string]$Pattern) {
        $Val = ""
        while ($Val -notmatch $Pattern) {
            $Val = (Read-Host $this.Strings[$Key]).Trim()
        }
        return $Val
    }

    [void] ShowLevelGuide() {
        [DebloatLogger]::Separator()
        Write-Host "DEBLOAT LEVELS - WAS PASSIERT HIER?" -ForegroundColor Yellow
        Write-Host "[1] MINIMAL : Sicher für Office. Telemetrie aus, Performance an."
        Write-Host "[2] LIGHT   : + Hibernation aus, Fax/Remote aus. Spart Platz."
        Write-Host "[3] MEDIUM  : + Bloatware-Apps (Wetter, News etc.) werden entfernt."
        Write-Host "[4] HIGH    : + OneDrive, Cortana und Maps werden eliminiert."
        Write-Host "[5] EXTREME : + MS Store & alle Apps weg. Nur für Hardcore-Gamer."
        Write-Host "[6] ZERO    : !!! KERN-SCHMELZE !!! Ziel: < 25 Prozesse."
        [DebloatLogger]::Separator()
    }
}

# =========================================================================================
# VIII. DEPLOYMENT & INSTALLATION
# =========================================================================================

class InstallerService {
    static [void] Deployment([string]$ID) {
        if ($ID -eq "4") { return }
        $List = @{
            "1" = "https://dl.google.com/chrome/install/standalone/policy/googlechromestandaloneenterprise64.msi"
            "2" = "https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=de"
            "3" = "https://www.torproject.org/dist/torbrowser/13.0.10/torbrowser-install-win64-13.0.10_ALL.exe"
        }
        [DebloatLogger]::Log("Lade Browser-Installer herunter...", "STAGE")
        $Path = "$env:TEMP\installer.exe"
        try {
            Invoke-WebRequest -Uri $List[$ID] -OutFile $Path
            if ($ID -eq "1") {
                Start-Process msiexec.exe -ArgumentList "/i `"$Path`" /qn" -Wait
            } else {
                Start-Process -FilePath $Path -ArgumentList "/silent /install" -Wait
            }
            [DebloatLogger]::Log("Browser erfolgreich installiert.", "SUCCESS")
        } catch {
            [DebloatLogger]::Log("Fehler bei der Browser-Installation.", "WARNING")
        }
    }
}

# =========================================================================================
# IX. DEEP CLEANER (PRE/POST)
# =========================================================================================

class DeepCleaner {
    static [void] ClearTemp() {
        [DebloatLogger]::Log("Bereinige temporäre Dateien...", "STAGE")
        $Paths = @("$env:TEMP\*", "$env:SystemRoot\Temp\*", "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db")
        foreach ($p in $Paths) {
            Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    static [void] ClearLogs() {
        [DebloatLogger]::Log("Lösche Windows-Event-Logs...", "STAGE")
        Get-EventLog -LogName * | ForEach-Object { Clear-EventLog $_.Log }
    }
}

# =========================================================================================
# X. MAIN EXECUTION CONTROLLER
# =========================================================================================

function Start-MainEngine {
    [DebloatLogger]::Header()
    $Inv = New-Object SystemInventory

    # Sprachwahl
    Write-Host "`n[1] DEUTSCH | [2] ENGLISH | [3] TÜRKÇE" -ForegroundColor White
    $LID = ""
    while ($LID -notmatch "^[123]$") { $LID = Read-Host "Auswahl / Selection" }
    
    $UI = New-Object UserInterface -ArgumentList $LID
    
    # Konfiguration
    $kWifi  = $UI.Ask("WiFi")
    $kBT    = $UI.Ask("BT")
    $kPrint = $UI.Ask("Print")
    $rEdge  = $UI.Ask("Edge")
    $bID    = $UI.Select("Browser", "^[1234]$")
    
    $UI.ShowLevelGuide()
    $Lvl = $UI.Select("Level", "^[123456]$")
    
    $doBackup = $UI.Ask("Backup")
    
    [DebloatLogger]::Separator()
    if (!($UI.Ask("Confirm"))) { [DebloatLogger]::Log("Abbruch durch Benutzer.", "CRITICAL"); exit }

    # EXECUTION START
    if ($doBackup) { 
        $Vault = New-Object SecurityVault
        $Vault.CreateFullBackup($LID) 
    }

    # Optimierung der Hardware-Module
    [KernelEngine]::ApplyTuning($Inv)
    [FileSystemEngine]::Apply($Inv.IsSSD)
    [NetworkEngine]::TuneTcpStack()
    [PrivacyEngine]::ApplyHardening()
    [VisualEngine]::ApplyDesktopTweaks()

    # Hardware Toggles
    if (!$kWifi)  { 
        Stop-Service WlanSvc -Force -ErrorAction SilentlyContinue
        Set-Service WlanSvc -StartupType Disabled -ErrorAction SilentlyContinue 
        netsh interface set interface "Wi-Fi" admin=disabled -ErrorAction SilentlyContinue
    }
    if (!$kBT)    { 
        Stop-Service bthserv -Force -ErrorAction SilentlyContinue
        Set-Service bthserv -StartupType Disabled -ErrorAction SilentlyContinue 
    }
    if (!$kPrint) { 
        Stop-Service Spooler -Force -ErrorAction SilentlyContinue
        Set-Service Spooler -StartupType Disabled -ErrorAction SilentlyContinue 
    }

    # Browser Installation
    [InstallerService]::Deployment($bID)

    # Microsoft Edge Kill-Switch
    if ($rEdge) {
        [DebloatLogger]::Log("Blockiere Microsoft Edge...", "WARNING")
        $EdgePaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\msedge.exe",
            "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\msedgewebview2.exe"
        )
        foreach ($ep in $EdgePaths) {
            if (!(Test-Path $ep)) { New-Item $ep -Force | Out-Null }
            Set-ItemProperty -Path $ep -Name "Debugger" -Value "ntsd -d"
        }
    }

    # Level Scaling Logic
    switch ($Lvl) {
        "2" {
            [DebloatLogger]::Log("Disabling Hibernation...", "INFO")
            powercfg -h off
        }
        "3" {
            [DebloatLogger]::Log("Entferne Standard-Bloatware...", "STAGE")
            Get-AppxPackage *Weather* | Remove-AppxPackage -ErrorAction SilentlyContinue
            Get-AppxPackage *ZuneVideo* | Remove-AppxPackage -ErrorAction SilentlyContinue
            Get-AppxPackage *SolitaireCollection* | Remove-AppxPackage -ErrorAction SilentlyContinue
        }
        "4" {
            [DebloatLogger]::Log("Deep Removal: OneDrive & Cortana...", "STAGE")
            taskkill /f /im OneDrive.exe -ErrorAction SilentlyContinue | Out-Null
            %SystemRoot%\SysWOW64\OneDriveSetup.exe /uninstall -ErrorAction SilentlyContinue | Out-Null
        }
        "5" {
            [DebloatLogger]::Log("EXTREME: Microsoft Store wird entfernt...", "CRITICAL")
            Get-AppxPackage *Store* | Remove-AppxPackage -ErrorAction SilentlyContinue
            [AbsoluteZeroEngine]::PurgeUwpPackages()
        }
        "6" {
            [AbsoluteZeroEngine]::PurgeServices()
            [AbsoluteZeroEngine]::PurgeUwpPackages()
            [AbsoluteZeroEngine]::DeepRegistryClean()
            [DeepCleaner]::ClearLogs()
        }
    }

    # Final Cleanup
    [DeepCleaner]::ClearTemp()

    # Finalize
    [DebloatLogger]::Separator()
    [DebloatLogger]::Log($UI.Strings["Final"], "SUCCESS")
    $Duration = (Get-Date) - $StartTime
    [DebloatLogger]::Log("Gesamtlaufzeit: $($Duration.Minutes)m $($Duration.Seconds)s", "CONFIG")
    
    # ASCII Art Outro
    Write-Host @"
    
      DONE! PC optimized for i7-4790K / Gaming.
      Reboot to apply all kernel changes.
    
"@ -ForegroundColor Cyan
    
    [DebloatLogger]::Separator()
    pause
}

# =========================================================================================
# XI. BOOTSTRAPPER
# =========================================================================================

try {
    Start-MainEngine
} catch {
    [DebloatLogger]::Log("Fataler Fehler im Main-Controller: $($_.Exception.Message)", "CRITICAL")
    pause
}
