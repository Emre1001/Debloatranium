<#
.SYNOPSIS
    Debloatranium 2025 - Professional Windows Debloat & Browser Installer
    Version: 1.0.0
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
    "Microsoft.Windows.Photos",
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
        Checkpoint-Computer -Description "Debloatranium_PreExecution" -RestorePointType "MODIFY_SETTINGS"
        
        # Verifizierung
        $LastPoint = Get-ComputerRestorePoint | Select-Object -Last 1
        if ($LastPoint.Description -eq "Debloatranium_PreExecution") {
            Write-Log "Wiederherstellungspunkt erfolgreich verifiziert."
            return $true
        }
    } catch {
        Write-Log "Fehler beim Erstellen des Wiederherstellungspunkts: $($_.Exception.Message)" "WARN"
    }
    
    if ($Interactive) {
        $Choice = Read-Host "Wiederherstellungspunkt konnte nicht erstellt werden. Trotzdem fortfahren? (y/n)"
        return ($Choice -eq 'y')
    }
    return $false
}

# --- DEBLOAT MODULE DEFINITIONEN ---
function Plan-AppxDebloat {
    Write-Log "Analysiere installierte Apps (Whitelist-Verfahren)..."
    $Packages = Get-AppxPackage -AllUsers | Where-Object { $_.Name -notin $AppWhitelist -and $_.NonRemovable -eq $false }
    
    foreach ($Pkg in $Packages) {
        Register-PlannedAction "AppRemoval" $Pkg.Name "Entfernt Bloatware App: $($Pkg.Name)" {
            Get-AppxPackage -Name $using:Pkg.Name -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
        }
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
    # Hinweis: In einem echten Release sollten hier SHA256 Hashes geprüft werden.
    
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

    if (-not $Confirm) {
        Write-Log "Kritisch: -Confirm Schalter fehlt! Destruktive Aktionen blockiert." "ERROR"
        return
    }

    Write-Log "Starte Ausführung der $($ActionQueue.Count) geplanten Aktionen..."
    
    foreach ($Task in $ActionQueue) {
        $Proceed = $true
        if ($Interactive) {
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

if (-not (Set-RestorePoint)) {
    Write-Log "Abbruch: Sicherheits-Wiederherstellungspunkt nicht vorhanden." "ERROR"
    exit
}

# 1. Planung
Plan-AppxDebloat
Plan-ServiceOptimizations
if ($Interactive) {
    $InBrowser = Read-Host "Optional: Browser-Installation planen? (y/n)"
    if ($InBrowser -eq 'y') { Plan-BrowserInstall }
}

# 2. Ausführung
Invoke-DebloatEngine

Write-Log "Debloatranium Vorgang abgeschlossen."
Write-Host "`nLog-Datei: $LogPath" -ForegroundColor Gray
