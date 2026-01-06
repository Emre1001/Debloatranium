# Debloatranium 2025 — Interactive Guide (English)

Professional Windows Debloat & Browser Installer — interactive, safety-hardened and matched to the included script.

## Summary

Debloatranium 2025 automates common Windows 10/11 cleanup tasks and offers optional browser installation. This repository includes a safety-hardened PowerShell script that implements DryRun, per-action confirmations, restore-point verification, whitelist-based extreme removals, planned-action export, and logging. Read the Safety & Best Practices section before running.

---

## Quickstart — Interactive (recommended)

1. Open PowerShell as Administrator.
2. Download and run the script from the repository (interactive prompts & per-action confirmations):

```powershell
# Fetch and execute the latest script (review before running)
iwr -UseBasicParsing https://raw.githubusercontent.com/Emre1001/Debloatranium/main/Debloatranium.ps1 | iex
```

If you prefer to run a downloaded copy instead of piping from the web, download Debloatranium.ps1, inspect it, then run:

```powershell
powershell -ExecutionPolicy Bypass -File .\Debloatranium.ps1 -Interactive -Confirm
```

---

## Interactive Flow — what to expect

- Language and safety messages are shown.
- Script attempts to create and verify a system restore point before destructive operations.
- The script collects a planned action list and exports it to a JSON file for review.
- In interactive mode (-Interactive) the script prompts for confirmation before each destructive action.
- After confirmation the script executes the action (unless -DryRun was used).
- At the end the script prints the log location and the path to the exported planned actions JSON.

---

## Important Flags (script parameters)

- -DryRun
  - Simulates all planned actions and exports them to a JSON file. No destructive action is executed.

- -Confirm
  - Required to allow destructive actions. Without -Confirm, the script will NOT perform destructive operations. Use together with -Interactive for per-action prompts.

- -Interactive
  - Ask for confirmation before each destructive step.

- -PlannedExportPath
  - Optional path/file name for the exported JSON (defaults to a timestamped file in the current folder).

Examples:

- Preview planned changes (no changes made):

```powershell
.\Debloatranium.ps1 -DryRun
```

- Interactive execution with per-action prompts:

```powershell
.\Debloatranium.ps1 -Confirm -Interactive
```

- Non-interactive execution (destructive allowed because -Confirm provided):

```powershell
.\Debloatranium.ps1 -Confirm
```

---

## Custom & Extreme Actions

- Extreme removals are whitelist-based: the script will only remove packages explicitly listed in the script's whitelist. There are no wildcard "*Microsoft.*" removals.
- Custom actions (where supported) require explicit -Confirm to run in non-interactive automation.
- When using custom or extreme modes, always run -DryRun first and verify the exported JSON.

---

## Restore Points and Backups

- The script attempts to create a system restore point and verifies its creation. If creation cannot be verified, the script will abort unless you explicitly allow continuation (by using -Confirm and interactive acknowledgement).
- Despite the restore point attempt, create a full backup or system image before running destructive profiles on production machines.

---

## Browser Installation

- Browser installers are optional and handled carefully: downloads are skipped when -DryRun is used and installer checksums are supported (replace checksum placeholders with real hashes before enabling auto-install).
- If you want automatic browser installation, configure the Install-Browser section of the script (URLs and SHA256) and call the installer functions, or run interactively and accept the prompts.

---

## Logs and Action Export

- The script logs to a timestamped log file and exports planned/executed actions to a JSON file. Review these files after a run to audit changes.

---

## Best Practices — step-by-step

1. Review the script source. Do not run code you don't understand.
2. Run a DryRun and review the exported planned actions JSON.
3. Test in a VM with a snapshot/restore point.
4. Ensure System Restore is enabled or create other full backups.
5. Run interactively first: `.\Debloatranium.ps1 -Interactive -Confirm` and confirm each action.
6. For automation, use `-Confirm` and monitor logs and the exported JSON.

---

## Contributing

- Add new debloat modules as functions named `Debloat-<Module>` and register them in the script's profile mapping.
- Add additional languages by extending the script's localization dictionary.
- Add SHA256 checksums for installers and configure URLs in the browser installer section.

---

IMPORTANT: Use at your own risk (auf eigene Gefahr).

This tool modifies system components. Even with the safety features in place, accidental damage can occur. Always use -DryRun first, test in a VM, and have reliable backups before performing destructive actions.
