<#
.SYNOPSIS
    Debloatranium 2025 - Professional Windows Debloat & Browser Installer
    Version: 1.2.0
    Author: Emre1001 (Optimized for i7-4790k / 1050 Ti)

.DESCRIPTION
    Ein hochgradig interaktives und sicherheitsorientiertes PowerShell-Skript zur Optimierung von Windows 10/11.
    Features: Restore Point Verification, DryRun, JSON Action Export, Whitelist-based App Removal.
#>

[CmdletBinding()]
Param(
    [Parameter(HelpMessage="Simuliert alle Aktionen ohne Änderungen vorzunehmen.")]
    [switch]$DryRun,

    [Parameter(HelpMessage="Erforderlich, um schreibende/destruktive Aktionen zu erlauben.")]
    [switch]$Confirm,

    [Parameter(HelpMessage="Fragt vor jedem Schritt einzeln nach.")]
    [switch]$Interactive,

    [Parameter(HelpMessage="Pfad für den JSON-Export des Aktionsplans.")]
    [string]$PlannedExportPath = "DebloatPlan_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
)

# --- KONFIGURATION & GLOBALE VARIABLEN ---
$ErrorActionPreference = "Stop"
$LogPath = "$PSScriptRoot\Debloatranium_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$ActionQueue = @()
$AppWhitelist = @(
    "Microsoft.WindowsCalculator",
    "Microsoft.WindowsStore",
    "Microsoft.Paint",
    "Microsoft.WindowsPhotos",
    "Microsoft.DesktopAppInstaller", # Wichtig für Winget
    "Microsoft.VP9VideoExtensions"
)

# --- HILFSFUNKTIONEN ---
function Write-Log {
    param([string]$Message, [ValidateSet("INFO", "WARN", "ERROR")]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Entry = "[$Timestamp] [$Level] $Message"
    $Color = switch($Level) { "ERROR" {"Red"} "WARN" {"Yellow"} Default {"Cyan"} }
    Write-Host $Entry -ForegroundColor $Color
    $Entry | Out-File -FilePath $LogPath -Append
}

function Register-PlannedAction {
    param([string]$Category, [string]$Target, [string]$Description, [scriptblock]$Script)
    $script:ActionQueue += [PSCustomObject]@{
        Category    = $Category
        Target      = $Target
        Description = $Description
        Action      = $Script
    }
}

# --- SICHERHEITS-MODULE ---
function Test-AdminPrivileges {
    $Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $Principal = New-Object Security.Principal.WindowsPrincipal($Identity)
    if (-not $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Log "Skript muss als Administrator ausgeführt werden!" "ERROR"
        exit
    }
}

function Set-RestorePoint {
    if ($DryRun) {
        Write-Log "[DryRun] System-Wiederherstellungspunkt wird übersprungen."
        return $true
    }

    Write-Log "Versuche System-Wiederherstellungspunkt zu erstellen..."
    try {
        Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
        # Wir unterdrücken die spezifische Warnung über die Häufigkeit, da wir manuell prüfen
        Checkpoint-Computer -Description "Debloatranium_PreExecution" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
        
        # Verifizierung: Schauen ob IRGENDEIN Punkt existiert (da Windows oft blockt, wenn einer erst kürzlich erstellt wurde)
        $LastPoint = Get-ComputerRestorePoint | Select-Object -Last 1
        if ($LastPoint) {
            Write-Log "Ein Wiederherstellungspunkt wurde gefunden/verifiziert (Stand: $($LastPoint.CreationTime))."
            return $true
        }
    } catch {
        Write-Log "Fehler beim Erstellen des Wiederherstellungspunkts: $($_.Exception.Message)" "WARN"
    }
    
    # Wenn wir hier landen, konnte kein neuer Punkt erstellt werden (z.B. wegen des 24h Limits)
    Write-Log "Hinweis: Windows verhindert oft die Erstellung mehrerer Punkte innerhalb von 24h." "WARN"
    $Choice = Read-Host "Kein neuer Punkt erstellt. Mit vorhandenen Sicherungen fortfahren? (y/n)"
    return ($Choice -eq 'y')
}

# --- DEBLOAT MODULE DEFINITIONEN ---
function Plan-AppxDebloat {
    Write-Log "Analysiere installierte Apps (Whitelist-Verfahren)..."
    try {
        $Packages = Get-AppxPackage -AllUsers | Where-Object { $_.Name -notin $AppWhitelist -and $_.NonRemovable -eq $false }
        foreach ($Pkg in $Packages) {
            Register-PlannedAction "AppRemoval" $Pkg.Name "Entfernt Bloatware App: $($Pkg.Name)" {
                Get-AppxPackage -Name $using:Pkg.Name -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
            }
        }
    } catch {
        Write-Log "Fehler bei der App-Analyse: $($_.Exception.Message)" "ERROR"
    }
}

function Plan-ServiceOptimizations {
    # Dienste, die auf älteren CPUs wie dem i7-4790k oft unnötig Last erzeugen
    $Services = @(
        @{Name="SysMain"; Desc="Superfetch (Deaktivieren kann HDD-Last senken, bei SSD optional)"},
        @{Name="DiagTrack"; Desc="Telemetrie / Connected User Experiences"},
        @{Name="XblAuthManager"; Desc="Xbox Live Auth (wenn nicht genutzt)"}
    )

    foreach ($Svc in $Services) {
        if (Get-Service -Name $Svc.Name -ErrorAction SilentlyContinue) {
            Register-PlannedAction "Service" $Svc.Name $Svc.Desc {
                Set-Service -Name $using:Svc.Name -StartupType Disabled
                Stop-Service -Name $using:Svc.Name -Force -ErrorAction SilentlyContinue
            }
        }
    }
}

function Plan-BrowserInstall {
    # Beispielhafter Browser Installer (Firefox)
    $BrowserUrl = "https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=de"
    
    Register-PlannedAction "Browser" "Firefox" "Installiert den Firefox Browser (Stable x64)" {
        $TempPath = "$env:TEMP\FirefoxSetup.exe"
        Write-Log "Downloade Firefox..."
        Invoke-WebRequest -Uri $using:BrowserUrl -OutFile $TempPath -UseBasicParsing
        Write-Log "Starte Silent-Installation..."
        Start-Process -FilePath $TempPath -ArgumentList "/S" -Wait
        Remove-Item $TempPath
    }
}

# --- EXECUTION ENGINE ---
function Invoke-DebloatEngine {
    Write-Log "Exportiere geplanten Aktionsplan nach $PlannedExportPath..."
    $ActionQueue | Select-Object Category, Target, Description | ConvertTo-Json | Out-File $PlannedExportPath
    
    if ($DryRun) {
        Write-Log "DryRun beendet. Prüfe die JSON-Datei für Details."
        return
    }

    # Sicherheits-Check: Falls -Confirm vergessen wurde, fragen wir jetzt aktiv nach
    $CurrentConfirm = $Confirm
    if (-not $CurrentConfirm) {
        Write-Log "WARNUNG: -Confirm Schalter fehlt!" "WARN"
        $ManualConfirm = Read-Host "Möchten Sie destruktive Aktionen manuell freischalten? (y/n)"
        if ($ManualConfirm -eq 'y') {
            $CurrentConfirm = $true
        } else {
            Write-Log "Kritisch: Keine Bestätigung erhalten. Destruktive Aktionen blockiert." "ERROR"
            return
        }
    }

    Write-Log "Starte Ausführung der $($ActionQueue.Count) geplanten Aktionen..."
    
    foreach ($Task in $ActionQueue) {
        $Proceed = $true
        # Wir erzwingen Interaktivität, wenn -Confirm nicht von Anfang an dabei war ODER -Interactive gesetzt ist
        if ($Interactive -or ($Confirm -eq $false)) {
            Write-Host "`n[BESTÄTIGUNG ERFORDERLICH]" -ForegroundColor Magenta
            Write-Host "Aktion: $($Task.Description)"
            $Ans = Read-Host "Ausführen? (y/n)"
            if ($Ans -ne 'y') { $Proceed = $false; Write-Log "Übersprungen: $($Task.Target)" }
        }

        if ($Proceed) {
            try {
                Write-Log "Führe aus: $($Task.Description)..."
                & $Task.Action
            } catch {
                Write-Log "Fehler bei $($Task.Target): $($_.Exception.Message)" "ERROR"
            }
        }
    }
}

# --- MAIN ENTRY POINT ---
Clear-Host
Write-Host @"
#############################################################
# Debloatranium 2025 - Professional Guide Logic             #
# System: i7-4790k | 1050 Ti | Hardened Mode                #
#############################################################
"@ -ForegroundColor Green

Test-AdminPrivileges

# Prüfung des Wiederherstellungspunkts mit Fehler-Abfangung für das 24h Limit
if (-not (Set-RestorePoint)) {
    Write-Log "Abbruch durch Benutzer: Kein Wiederherstellungspunkt verfügbar." "ERROR"
    exit
}

# 1. Planung
Plan-AppxDebloat
Plan-ServiceOptimizations

# Browser-Planung abfragen
$InBrowser = Read-Host "Optional: Browser-Installation planen? (y/n)"
if ($InBrowser -eq 'y') { Plan-BrowserInstall }

# 2. Ausführung
Invoke-DebloatEngine

Write-Log "Debloatranium Vorgang abgeschlossen."
Write-Host "`nLog-Datei: $LogPath" -ForegroundColor Gray
