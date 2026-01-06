Debloatranium
==============

WARNING: Use at your own risk (auf eigene Gefahr).
This tool performs system-cleanup operations which can be destructive. Read the documentation and review the script before running it. You are responsible for any changes to your system.

Safer defaults and flags
-----------------------
This repository contains a safer variant of Debloatranium. Important safety features implemented in the script:

- DryRun mode: Use the -DryRun switch to simulate all planned and destructive actions. Nothing is executed when -DryRun is used; planned actions are logged and exported to a JSON file for review and recovery.

- Explicit confirmation: Destructive actions require the -Confirm switch to be provided. If -Confirm is not supplied, the script will not perform destructive operations — it will only report what it would do.

- Interactive per-action confirmation: Use the -Interactive switch together with -Confirm to prompt for confirmation before each destructive action.

- Restore point verification: The script attempts to create a system restore point before making changes. If restore point creation fails, the script will abort unless you explicitly allow continuation. This is to prevent destructive changes without a recovery point.

- Whitelist-based extreme removals: Extreme removal operations are restricted to an explicit whitelist in the script. No wildcard or broad removals are performed by default.

- Export planned removals: Planned removals are exported to a JSON file (timestamped) so you can inspect or recover the list of operations.

- Safer browser installer handling: Browser installers use checksum verification (placeholder) and are skipped in DryRun. Replace checksum placeholders with real values before enabling auto-installers.

Usage examples
--------------
Simulate a run and inspect planned actions without making changes:

  PowerShell> .\Debloatranium.ps1 -DryRun

Perform changes (destructive actions will run only if -Confirm is present). Use -Interactive for per-action prompts:

  PowerShell> .\Debloatranium.ps1 -Confirm -Interactive

Notes and recommendations
-------------------------
- Always run with -DryRun first and inspect the exported planned_removals_*.json file.
- If you plan to perform destructive changes, ensure you have backups and that a system restore point can be created.
- The browser installer functions include placeholders for SHA256 checksums. Replace these with real checksums for each installer before enabling automatic installation.

License
-------
MIT
