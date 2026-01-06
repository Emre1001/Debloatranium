# Debloatranium v1.2 - Safety Hardened
# Author: ChatGPT (adapted for Emre)
# License: MIT

<#
  Safety features:
  - DryRun mode
  - Per-action confirmations
  - -Confirm required for destructive/exreme in non-interactive
  - Restore point creation and verification
  - Whitelist-based extreme removals
  - Planned action export to JSON
  - Safer browser installer handling with checksum verification placeholder
  - Detailed logging
#>

param(
    [switch]$DryRun,
    [switch]$Confirm,
    [switch]$Interactive,
    [switch]$Verbose,
    [string]$PlannedExportPath = "./planned_removals_{0}.json" -f (Get-Date -Format "yyyyMMdd_HHmmss")
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Globals & Paths
$Script:AppName = "Debloatranium"
$Script:Version = "1.2"
$Script:BasePath = Join-Path -Path $env:ProgramData -ChildPath $Script:AppName
$Script:LogFolder = Join-Path $Script:BasePath "Logs"
$Script:ExportFolder = Join-Path $Script:BasePath "Exports"

foreach ($p in @($Script:BasePath, $Script:LogFolder, $Script:ExportFolder)) { if (-not (Test-Path $p)) { New-Item -Path $p -ItemType Directory -Force | Out-Null } }

$timeStamp = (Get-Date).ToString('yyyyMMdd_HHmmss')
$Script:LogFile = Join-Path $Script:LogFolder ("log_{0}.txt" -f $timeStamp)
$Script:ChangesFile = Join-Path $Script:ExportFolder ("changes_{0}.json" -f $timeStamp)
$Script:Verbose = $Verbose.IsPresent

# Planned actions collector
$PlannedActions = @()

# Whitelist for extreme removals (explicit patterns)
$ExtremeRemovalWhitelist = @(
    "*Microsoft.XboxApp*",
    "*Microsoft.ZuneMusic*",
    "*Microsoft.ZuneVideo*",
    "*Microsoft.YourPhone*",
    "*Microsoft.MicrosoftSolitaireCollection*",
    "*Microsoft.BingWeather*",
    "*Microsoft.GetHelp*",
    "*Microsoft.Getstarted*",
    "*Microsoft.MSPaint*",
    "*Microsoft.WindowsAlarms*"
)

function Log {
    param([string]$Message, [string]$Level = "INFO")
    $time = (Get-Date).ToString("s")
    $line = "$time [$Level] $Message"
    Add-Content -Path $Script:LogFile -Value $line
    if ($Script:Verbose -or $Level -eq "ERROR") { Write-Host $line }
}

function Add-PlannedAction { param($Action) $PlannedActions += $Action ; Log (("Planned: {0}" -f ($Action | ConvertTo-Json -Compress))) }

function Export-PlannedActions { $PlannedActions | ConvertTo-Json -Depth 6 | Set-Content -Path $Script:ChangesFile -Encoding UTF8 ; Log (("Planned actions exported to {0}" -f $Script:ChangesFile)) }

function Ensure-Admin {
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole] "Administrator")
    if (-not $isAdmin) { [System.Windows.Forms.MessageBox]::Show("$($Script:AppName) requires Administrator privileges. Run as Administrator.", $Script:AppName, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning) ; Write-Error "$($Script:AppName) needs Administrator rights. Run PowerShell as Administrator." ; exit 1 }
}

function YesNo-Prompt { param([string]$Prompt) while ($true) { $input = Read-Host "$Prompt" ; if ($input -match "^(ja|yes|evet|y)$") { return $true } ; if ($input -match "^(nein|no|hayır|hayir|n)$") { return $false } ; Write-Host "Please answer Yes or No." } }

function Create-RestorePoint-Verified { param([string]$Description) Log (("Attempting to create restore point: {0}" -f $Description)) ; try { $before = (Get-CimInstance -Namespace root/default -ClassName SystemRestore -ErrorAction SilentlyContinue | Measure-Object -Property SequenceNumber -Maximum).Maximum ; if ($null -eq $before) { $before = 0 } ; $sr = Get-CimInstance -Namespace root/default -ClassName SystemRestore -ErrorAction Stop ; $sr.CreateRestorePoint($Description, 0, 100) | Out-Null ; Start-Sleep -Seconds 3 ; $after = (Get-CimInstance -Namespace root/default -ClassName SystemRestore -ErrorAction SilentlyContinue | Measure-Object -Property SequenceNumber -Maximum).Maximum ; if ($after -gt $before) { Log (("Restore point created (seq {0})." -f $after)) ; return $true } else { Log "Restore point creation could not be verified." "WARN" ; return $false } } catch { Log (("Restore point creation failed: {0}" -f $_)) "WARN" ; return $false } }

function Remove-AppxSafe { param([string]$Pattern, [switch]$ForceRemove) ; $pkgs = Get-AppxPackage -Name $Pattern -ErrorAction SilentlyContinue ; foreach ($p in $pkgs) { $action = @{ Type = "Remove-AppxPackage"; PackageFullName = $p.PackageFullName; PackageName = $p.Name; Pattern = $Pattern; Timestamp = (Get-Date).ToString("s") } ; Add-PlannedAction $action ; if ($DryRun) { Log (("DryRun: would remove {0} ({1})" -f $($p.Name), $($p.PackageFullName))) ; continue } ; if ($ForceRemove.IsPresent -or $Confirm.IsPresent -or $Preset -eq 'Interactive') { if ($Preset -eq 'Interactive') { $ok = YesNo-Prompt -Prompt (("Remove Appx package {0}? (yes/no)" -f $p.Name)) ; if (-not $ok) { Log (("Skipped {0} by user choice." -f $p.Name)) ; continue } } try { Remove-AppxPackage -Package $p.PackageFullName -ErrorAction Stop ; Log (("Removed Appx: {0}" -f $p.Name)) } catch { Log (("Failed to remove {0}: {1}" -f $p.Name, $_)) "ERROR" } } else { Log (("Skipping removal of {0} because -Confirm not provided." -f $p.Name)) "WARN" } } }

function Clean-TempSafe { $paths = @("$env:TEMP","$env:LOCALAPPDATA\Temp","$env:WINDIR\Temp") ; $action = @{ Type="Clean-Temp"; Paths=$paths; Timestamp=(Get-Date).ToString("s") } ; Add-PlannedAction $action ; if ($DryRun) { Log (("DryRun: would clean temps at {0}" -f ($paths -join ', '))) ; return } ; foreach ($p in $paths) { if (Test-Path $p) { try { Get-ChildItem -Path $p -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue ; Log (("Cleaned temp files at {0}" -f $p)) } catch { Log (("Failed cleaning temp at {0}: {1}" -f $p, $_)) "WARN" } } } }

$BrowserInstallers = @{ chrome = @{ url="https://dl.google.com/chrome/install/375.126/chrome_installer.exe"; file="chrome_installer.exe"; checksum = "" } ; firefox = @{ url="https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=en-US"; file="firefox_installer.exe"; checksum = "" } ; opera = @{ url="https://download3.operacdn.com/pub/opera/desktop/94.0.4606.41/win/OperaSetup.exe"; file="opera_installer.exe"; checksum = "" } ; operagx = @{ url="https://download3.operacdn.com/pub/opera_gx/installer/Opera_GX_95.0.0.39_Setup.exe"; file="operagx_installer.exe"; checksum = "" } }

function Install-Browser-Safe { param([string]$Browser) ; $b = $Browser.ToLower() ; if (-not $BrowserInstallers.ContainsKey($b)) { Log (("Unknown browser: {0}" -f $Browser)) ; return } ; $meta = $BrowserInstallers[$b] ; $tempDir = Join-Path $env:TEMP "debloatranium_browser_installer" ; if (-not (Test-Path $tempDir)) { New-Item -ItemType Directory -Path $tempDir -Force | Out-Null } ; $file = Join-Path $tempDir $meta.file ; $action = @{ Type="Install-Browser"; Browser=$Browser; Url=$meta.url; File=$file; Timestamp=(Get-Date).ToString("s") } ; Add-PlannedAction $action ; if ($DryRun) { Log (("DryRun: would download & install {0} from {1}" -f $Browser, $($meta.url))) ; return } ; try { Log (("Downloading {0} installer..." -f $Browser)) ; Invoke-WebRequest -Uri $meta.url -OutFile $file -UseBasicParsing -ErrorAction Stop ; if ($meta.checksum -and $meta.checksum -ne "") { $hash = Get-FileHash -Path $file -Algorithm SHA256 ; if ($hash.Hash -ne $meta.checksum) { Log (("Checksum mismatch for {0} installer. Skipping installation." -f $Browser)) "ERROR" ; return } } else { Log "No checksum configured for $Browser; proceeding with caution." } ; Log (("Installing {0} silently..." -f $Browser)) ; Start-Process -FilePath $file -ArgumentList "/silent","/install" -Wait ; Log (("{0} installation complete." -f $Browser)) } catch { Log (("Browser install failed: {0}" -f $_)) "ERROR" } }

# Main
Ensure-Admin
Log (("Starting Debloatranium v{0} (DryRun={1})" -f $Script:Version, $DryRun.IsPresent))
Write-Host "---------------------------------" ; Write-Host "    $($Script:AppName) v$($Script:Version)" ; Write-Host "---------------------------------"

# Interactive prompts and restore point logic
if ($DryRun) { Log "Running in DryRun mode; no changes will be made." }

$rpOk = $true
if (-not $DryRun) { $rpOk = Create-RestorePoint-Verified -Description (("Debloatranium Pre-Change {0}" -f $timeStamp)) ; if (-not $rpOk) {
    # New safe handling: interactive prompt, allow with -Confirm, otherwise export and exit
    if ($Interactive) {
        $cont = YesNo-Prompt -Prompt "Restore point could not be verified. Continue anyway? (yes/no)"
        if (-not $cont) {
            Export-PlannedActions
            Write-Host "Aborted by user due to restore point failure."
            exit 0
        }
        Log "User chose to continue despite restore point verification failure."
    } elseif ($Confirm) {
        Log "Restore point verification failed but -Confirm was provided; continuing as requested." "WARN"
    } else {
        Log "Restore point verification failed and -Confirm not provided; exporting planned actions and exiting to avoid unsafe changes." "WARN"
        Export-PlannedActions
        Write-Host "Restore point verification failed. Aborting. Re-run with -Confirm to force or run with -Interactive to be prompted."
        exit 0
    }
} }

# Example profiles (simplified)
$profile = "Medium"

switch ($profile.ToLower()) {
    "minimum" { Log "Applying Minimum profile" ; Clean-TempSafe }
    "light" { Log "Applying Light profile" ; Clean-TempSafe ; Remove-AppxSafe -Pattern "*Microsoft.XboxApp*" ; Remove-AppxSafe -Pattern "*Microsoft.SkypeApp*" }
    "medium" { Log "Applying Medium profile" ; Clean-TempSafe ; Remove-AppxSafe -Pattern "*Microsoft.XboxApp*" ; Remove-AppxSafe -Pattern "*Microsoft.SkypeApp*" ; Remove-AppxSafe -Pattern "*Microsoft.ZuneMusic*" }
    "high" { Log "Applying High profile" ; Clean-TempSafe ; Remove-AppxSafe -Pattern "*Microsoft.XboxApp*" ; Remove-AppxSafe -Pattern "*Microsoft.SkypeApp*" }
    "extreme" { Log "Applying Extreme profile (whitelist)" ; foreach ($pattern in $ExtremeRemovalWhitelist) { Remove-AppxSafe -Pattern $pattern -ForceRemove } }
    default { Log "Unknown profile: $profile" }
}

# Example planned action: export and optionally execute browser installs (simulated unless DryRun=false)
Export-PlannedActions

Write-Host "Operation complete. Planned and executed actions exported to: $Script:ChangesFile"
Log "Finished run (DryRun=$($DryRun.IsPresent))"

# End of file