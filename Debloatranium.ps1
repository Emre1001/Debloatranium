# Debloatranium v1.1 - Safer Variant
# Author: ChatGPT (angepasst für Emre)
# License: MIT

<#
Safer Debloatranium features implemented here:
- -DryRun: simulate planned/destructive actions without executing them
- -Confirm: explicit required flag to allow destructive actions
- -Interactive: per-action confirmations when enabled
- Create-RestorePoint verification: abort if creation fails unless user explicitly confirms to proceed
- Whitelist-based extreme removals: only remove packages explicitly listed in whitelist
- Export planned removals to a JSON file for recovery/inspection
- Safer browser installer handling with a checksum placeholder; skip real installs on DryRun
- Logging of all planned and destructive actions
#>

param(
    [switch]$DryRun,
    [switch]$Confirm,
    [switch]$Interactive,
    [string]$PlannedExportPath = "./planned_removals_{0}.json" -f (Get-Date -Format "yyyyMMdd_HHmmss")
)

Set-StrictMode -Version Latest

# Initialization
$Timestamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
$LogFile = "./Debloatranium_log_$Timestamp.txt"
$PlannedRemovals = @()

function Log {
    param([string]$Message)
    $entry = "[$(Get-Date -Format 'u')] $Message"
    Write-Output $entry
    try { Add-Content -Path $LogFile -Value $entry } catch {}
}

function Add-PlannedRemoval {
    param(
        [string]$Name,
        [string]$Action,
        [string]$Reason
    )
    $obj = [PSCustomObject]@{
        Name   = $Name
        Action = $Action
        Reason = $Reason
        Time   = (Get-Date).ToString('u')
    }
    $script:PlannedRemovals += $obj
    Log "PLANNED: $Name | $Action | $Reason"
}

function Confirm-Action {
    param(
        [string]$Message
    )
    # If DryRun, only simulate
    if ($DryRun) {
        Log "DRYRUN: would prompt for confirmation for: $Message"
        return $false
    }

    # Require explicit -Confirm to allow destructive actions
    if (-not $Confirm) {
        Log "SKIP: destructive actions require -Confirm. Action skipped: $Message"
        return $false
    }

    if ($Interactive) {
        $response = Read-Host "$Message`nType Y to confirm, any other key to skip"
        if ($response -match '^[Yy]') { return $true } else { Log "User declined interactive confirmation: $Message"; return $false }
    }

    # Non-interactive but -Confirm provided: allow
    return $true
}

function Create-RestorePoint {
    param(
        [string]$Description = 'Debloatranium pre-cleanup'
    )

    if ($DryRun) {
        Log "DRYRUN: would attempt to create system restore point: $Description"
        return $true
    }

    Log "Attempting to create a system restore point: $Description"
    try {
        # On modern systems this cmdlet may require elevation and the System Restore feature
        Checkpoint-Computer -Description $Description -RestorePointType 'Modify_Settings' -ErrorAction Stop
        Log "Restore point created successfully."
        return $true
    } catch {
        Log "ERROR: Failed to create a restore point: $($_.Exception.Message)"
        # If -Confirm is not present, abort to be safe
        if (-not $Confirm) {
            throw "Restore point creation failed and -Confirm not provided. Aborting to avoid destructive actions without a restore point."
        }

        if ($Interactive) {
            $resp = Read-Host "Restore point creation failed. Proceed without a restore point? Type Y to proceed"
            if ($resp -match '^[Yy]') {
                Log "User chose to proceed despite restore point failure."
                return $true
            } else {
                throw "User aborted after restore point creation failed."
            }
        }

        # -Confirm present (user allowed destructive actions) but restore creation failed. Log and proceed.
        Log "Proceeding despite restore point failure because -Confirm was supplied."
        return $true
    }
}

# Example safe lists. Replace with desired real package names for your environment.
$StandardRemovals = @(
    # Common safe targets (examples)
    'Microsoft.GetHelp',
    'Microsoft.Getstarted'
)

# Extreme removals must be explicitly whitelisted here. No wildcards allowed.
$ExtremeRemoveWhitelist = @(
    # Only packages explicitly listed will be removed by 'extreme' mode
    'Contoso.ExampleApp'
)

$ExtremeCandidates = @(
    # Candidate list; only those also in whitelist will be removed
    'Contoso.ExampleApp',
    'Microsoft.LockApp'
)

# Plan removals (do not execute yet)
foreach ($pkg in $StandardRemovals) {
    Add-PlannedRemoval -Name $pkg -Action 'Remove-AppxPackage' -Reason 'Standard cleanup rule'
}

foreach ($pkg in $ExtremeCandidates) {
    if ($ExtremeRemoveWhitelist -contains $pkg) {
        Add-PlannedRemoval -Name $pkg -Action 'ExtremeRemove' -Reason 'Whitelisted extreme removal'
    } else {
        Log "SKIP (not whitelisted): $pkg would be an extreme removal but is not in the whitelist."
    }
}

# Export planned removals to a JSON file for recovery/inspection
try {
    $json = $PlannedRemovals | ConvertTo-Json -Depth 5
    Set-Content -Path $PlannedExportPath -Value $json -Force
    Log "Exported planned removals to: $PlannedExportPath"
} catch {
    Log "WARNING: Failed to export planned removals: $($_.Exception.Message)"
}

# Create restore point (verify)
try {
    $rpOk = Create-RestorePoint -Description 'Debloatranium pre-cleanup'
} catch {
    Log "ABORT: $($_)"
    throw $_
}

# Execute planned actions (only if Confirm-Action allows)
foreach ($action in $PlannedRemovals) {
    $name = $action.Name
    $act = $action.Action
    $reason = $action.Reason
    $msg = "About to perform [$act] on '$name' (Reason: $reason)"

    if (-not (Confirm-Action -Message $msg)) {
        Log "Action skipped by confirmation logic: $msg"
        continue
    }

    # Perform or simulate
    if ($DryRun) {
        Log "DRYRUN: Simulating action [$act] on $name"
        continue
    }

    try {
        switch ($act) {
            'Remove-AppxPackage' {
                Log "Executing Remove-AppxPackage for $name"
                # Example call (commented out for safety); replace with actual code if desired
                # Get-AppxPackage -Name $name | Remove-AppxPackage -ErrorAction Stop
                Log "(SIMULATED) Removed AppxPackage: $name"
            }
            'ExtremeRemove' {
                Log "Executing extreme removal for $name"
                # Extreme removals are sensitive. The whitelist logic above prevents accidental wildcard removal.
                # Example call (commented out):
                # Get-AppxPackage -Name $name | Remove-AppxPackage -ErrorAction Stop
                Log "(SIMULATED) Extreme removed: $name"
            }
            Default {
                Log "Unknown action type for $name: $act"
            }
        }
    } catch {
        Log "ERROR: Failed to execute $act for $name: $($_.Exception.Message)"
    }
}

# Safer browser installer example
function Install-Browser {
    param(
        [string]$Name,
        [string]$Url,
        [string]$ExpectedSHA256 # supply the expected checksum for verification
    )

    $msg = "About to download and install $Name from $Url"
    Add-PlannedRemoval -Name $Name -Action 'Install' -Reason 'Browser installer planned'

    if (-not (Confirm-Action -Message $msg)) {
        Log "Installer action skipped by confirmation logic for $Name"
        return
    }

    if ($DryRun) {
        Log "DRYRUN: would download and run installer for $Name from $Url"
        return
    }

    $tmp = Join-Path -Path $env:TEMP -ChildPath "$Name-installer-$($Timestamp).exe"
    try {
        Log "Downloading $Url to $tmp"
        Invoke-WebRequest -Uri $Url -OutFile $tmp -UseBasicParsing -ErrorAction Stop

        if ($ExpectedSHA256) {
            $actualHash = (Get-FileHash -Path $tmp -Algorithm SHA256).Hash.ToLower()
            if ($actualHash -ne $ExpectedSHA256.ToLower()) {
                throw "Checksum mismatch for $Name installer. Expected $ExpectedSHA256 but got $actualHash"
            }
            Log "Checksum verification passed for $Name"
        } else {
            Log "No expected checksum provided for $Name — skipping checksum verification (not recommended)."
        }

        Log "Running installer for $Name"
        # Start-Process -FilePath $tmp -ArgumentList '/silent' -Wait -ErrorAction Stop
        Log "(SIMULATED) Installer executed for $Name"
    } catch {
        Log "ERROR during browser installation for $Name: $($_.Exception.Message)"
    } finally {
        try { Remove-Item -Path $tmp -Force -ErrorAction SilentlyContinue } catch {}
    }
}

# Example usage of Install-Browser (commented out by default; update URL and checksum before enabling)
# Install-Browser -Name 'ExampleBrowser' -Url 'https://example.com/installer.exe' -ExpectedSHA256 'REPLACE_WITH_REAL_SHA256'

Log "Debloatranium run completed. DryRun=$DryRun, Confirm=$Confirm, Interactive=$Interactive"
Log "Planned removals JSON located at: $PlannedExportPath"

# Final note
if ($DryRun) { Log "DRYRUN mode: no destructive actions were executed." }
else {
    if (-not $Confirm) { Log "Note: Destructive actions were not executed because -Confirm was not provided." }
}

# End of script
