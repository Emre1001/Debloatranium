# Debloatranium 2025 — Interactive Guide (English)

Professional Windows Debloat & Browser Installer — now more interactive

## Summary

Debloatranium 2025 is an enterprise-grade PowerShell automation tool for optimizing Windows 10/11. It removes preinstalled apps, disables telemetry and unnecessary background services, and provides an interactive browser installation experience. This README explains interactive usage step-by-step and shows examples for both guided and automated runs.

---

## Quickstart — Interactive (recommended)

1. Open PowerShell as Administrator.
2. Copy and paste this command (fetches the script from GitHub and runs it interactively):

```powershell
iwr -UseBasicParsing https://raw.githubusercontent.com/Emre1001/Debloatranium/main/Debloatranium.ps1 | iex
```

Note: You will be prompted to choose language, answer "Fresh Windows?" and select the debloat level interactively. Always review remote scripts before executing them.

---

## Short Commands / Modes

- Interactive default: runs with step-by-step prompts.
- Non-interactive / unattended (for automation):
  - Example (use with caution):  
    ```powershell
    pwsh -NoProfile -ExecutionPolicy Bypass -Command "& { iwr -useb https://raw.githubusercontent.com/Emre1001/Debloatranium/main/Debloatranium.ps1 | iex }" -Preset "High" -Confirm:$false -InstallBrowsers "chrome,firefox" -Language "en" -FreshWindows $false
    ```
  - Warning: These flags require the script to implement parameters like `-Preset`, `-Language`, `-InstallBrowsers`, `-Confirm`. Verify the script signature before use.

---

## Interactive Flow — Example (what you will see)

1. Console is cleared.
2. Language selection:
   - `1` = English, `2` = Deutsch, `3` = Türkçe
3. Question: "Is this a fresh Windows installation?" (y/n)
4. Pre-debloat warning: "Microsoft Edge may be removed. Do you already have another browser?" (y/n)
   - If `n`, the script recommends and offers immediate browser installation.
5. Debloat level menu:
   - `1` Minimum
   - `2` Light
   - `3` Medium
   - `4` High
   - `5` Extreme
   - `6` Custom (step-by-step per-component selection)
6. Summary of selected actions → final confirmation (y/n).
7. Debloat process begins; progress and error messages are displayed.
8. After completion: optional browser installation and restart prompt.

---

## Custom Mode — Step-by-step Selection

In Custom mode you'll be prompted per module (answer `y`/`n`):

- Disable telemetry
- Adjust system services (e.g., SysMain, Delivery Optimization)
- Remove common apps (Xbox, OneDrive, Solitaire, YourPhone, etc.)
- Aggressive removals (Store, Defender, SmartScreen, System Restore, Hibernation) — contains explicit warnings
- Post-debloat browser installation (Chrome, Firefox, Opera, Opera GX)

Tip: Enable protective options like creating a system restore point before aggressive actions.

---

## Example Dialog (English — possible inputs)

- Choose language: `1`
- Fresh Windows?: `y`
- Do you have another browser?: `n` → recommends browser installation (e.g., `Chrome`)
- Choose Debloat Level: `3` (Medium)
- Confirm: `y`
- After completion: "Would you like to install browsers now?" → `y` → `1` for Chrome, `2` for Firefox, ...

---

## Feature Matrix (usage summary)

Level     | Telemetry | Common Apps | Aggressive Apps | Services | Defender | Browser Selection
--------- | --------- | ----------- | --------------- | ------- | -------- | -----------------
Minimum   | ✓         | -           | -               | ✓       | -        | ✓ (Optional)
Light     | ✓         | ✓           | -               | ✓       | -        | ✓ (Optional)
Medium    | ✓         | ✓           | ✓               | ✓       | -        | ✓ (Optional)
High      | ✓         | ✓           | ✓               | ✓       | -        | ✓ (Optional)
Extreme   | ✓         | ✓           | ✓               | ✓       | ✓        | ✓ (Optional)
Custom    | ✓/× user  | ✓/× user    | ✓/× user        | ✓/× user| ✓/× user | ✓ (Optional)

---

## Advanced Flags & Automation Ideas

- -Preset "Minimum|Light|Medium|High|Extreme|Custom"
- -Language "en|de|tr"
- -InstallBrowsers "chrome,firefox,opera"
- -FreshWindows $true|$false
- -Confirm $true|$false (if false, skips interactive confirmations)

Note: These CLI flags are only available if implemented as script parameters. The README recommends using the interactive mode or validating flags against the script.

---

## Security & Best Practices

- Backup: Always create a restore point or full system image before running system-modifying scripts.
- Review: Inspect the script content before running `iwr | iex`.
- Test: Run in a VM or staging environment first.
- Privileges: Script requires Administrator rights — confirm elevated session.

---

## Extensibility & Contribution

- Add Modules: Implement new functions named `Debloat-<Module>` and integrate them into Custom Mode and presets.
- Localization: Extend the `$Lang` hashtable to add more languages.
- Logging: Enable `Start-Transcript` or write logs to a file for auditing.
- GUI: Build a WPF/WinForms or Electron frontend that calls the existing functions for a friendlier UI.
- CI/CD: Add GitHub Actions for testing and releases.

---

## Example helper function (for local testing)

```powershell
function Start-DebloatraniumInteractive {
    param([string]$ScriptUrl = "https://raw.githubusercontent.com/Emre1001/Debloatranium/main/Debloatranium.ps1")
    Write-Host "Downloading Debloatranium..."
    iwr -UseBasicParsing $ScriptUrl | iex
}
```

Use this helper locally after you have downloaded and reviewed the script.

---

## Safety Reminders

- Aggressive options can remove functionality and security features. Read all warnings and understand consequences before proceeding.
- If you rely on Microsoft Store apps or Defender, avoid Extreme or aggressive options.
- Reboot only when instructed after reviewing the summary and completed actions.

---

## License

This project is licensed under the Emre Asik Non-Commercial Public License v1.0 (EANPL-1.0).

You are free to use, modify, and share the code for non-commercial purposes. See the LICENSE file for full terms.
