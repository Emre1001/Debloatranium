# Debloatranium 2025

Professional Windows Debloat & Browser Installer

## 📌 Overview

Debloatranium 2025 is an enterprise-grade PowerShell automation tool that streamlines Windows 10/11 optimization by:

* Removing redundant pre-installed applications
* Disabling telemetry and unnecessary background services
* Offering interactive installation of leading web browsers

Designed for both IT professionals and advanced home users, it offers preset cleanup levels and a fully granular custom mode, with English, German, and Turkish UI support.

## 🚀 Key Features

### Multi-Level Debloating

* Minimum: Light tweaks, High Performance power plan, Dark Mode, removes Edge, cleans taskbar, and disables telemetry.
* Light: Removes ultra unnecessary apps (Xbox, OneDrive, Solitaire, YourPhone, Weather, Zune) + all from Minimum.
* Medium: Removes more apps (Outlook, Mail, Calendar, Maps, People, Camera, Calculator, Print3D) + many system & performance tweaks + all from Light.
* High: Removes ALL apps except Paint & Photos + very many tweaks + all from Medium.
* Extreme: Removes EVERYTHING possible (including Store, security features) for maximum performance + all from High.
* Custom: Step-by-step interactive prompts to select individual cleanup tasks.

### Intelligent Browser Management

* Pre-Debloat Warning: Warns you if Microsoft Edge might be removed and asks if you already have another browser. If not, it recommends and offers immediate browser installation.
* Post-Debloat Selection: After the debloat process, you'll always have the option to interactively choose and install popular browsers (Chrome, Firefox, Opera GX, Opera), or skip installation entirely.

### Localization

* English, German, and Turkish menu prompts and notifications.

### Security & Validation

* Verifies administrator privileges and confirms critical actions.

### Robust Error Handling

* Clear messages and safe fallbacks for uninterrupted execution.

## 🛠️ Architecture & Modules

### Configuration

* Centralized translation tables for multi-language support.

### Helper Functions

* Write-Log: Consistent colorized logging.
* Check-Admin: Ensures elevated execution.
* Confirm-Action & Read-YesNo: Standardized user prompts for Yes/No questions.
* Remove-App & Disable-Service: Encapsulated system modifications for apps and services.
* Download-And-Install-Browser: Unified download & silent installation logic for individual browsers.
* Choose-And-Install-Browsers: Manages interactive selection of browsers.

### Debloat Modules

* Telemetry: Disables DiagTrack, dmwappushservice, lfsvc.
* App Removal: Xbox, OneDrive, Mixed Reality, Solitaire, Skype, YourPhone, BingWeather, GetHelp, Getstarted, ZuneMusic, ZuneVideo, WindowsMaps, MSPaint, WindowsCamera, People, Print3D, Outlook, Mail, Calendar, Calculator.
* Microsoft Edge Removal: Dedicated function to uninstall Edge.
* System Tweaks: Delivery Optimization, Driver Updates, Tips/Tricks, Lock Screen Ads, Error Reporting, Game Bar.
* Performance Tweaks: Visual effects, Superfetch/SysMain, Windows Search service.
* Extreme Aggressive Actions: Removes Microsoft Store, disables Windows Defender and SmartScreen, disables System Restore and Hibernation, clears temporary files.

### Preset Levels & Custom Mode

* Predefined functions invoking combinations of modules.
* Custom mode for per-component selection.

### Main Execution Flow

* Clear console.
* Language selection.
* Initial Check: Prompts if it's a fresh Windows installation, warns about Edge, and offers early browser installation if needed.
* Debloat level menu presentation and choice validation.
* Final confirmation before execution.
* Execution of selected debloat level.
* Post-Debloat Browser Selection: Offers interactive browser installation if not already handled.
* Result summary & prompt for PC restart.

## 📥 Installation & Quickstart

Start PowerShell as Administrator, then paste the following command:

```
& ([scriptblock]::Create((irm "https://raw.githubusercontent.com/Emre1001/Debloatranium/refs/heads/main/Debloatranium.ps1")))
```

Follow the prompts to select language, respond to the fresh Windows/browser questions, choose your debloat level, and confirm actions. You will be guided through the process step-by-step.

## 🔍 Usage Matrix

| Level   | Telemetry | Common Apps | Aggressive Apps | Services | Defender | Browser Selection |
| ------- | --------- | ----------- | --------------- | -------- | -------- | ----------------- |
| Minimum | ✓         | -           | -               | ✓        | -        | ✓ (Optional)      |
| Light   | ✓         | ✓           | -               | ✓        | -        | ✓ (Optional)      |
| Medium  | ✓         | ✓           | ✓               | ✓        | -        | ✓ (Optional)      |
| High    | ✓         | ✓           | ✓               | ✓        | -        | ✓ (Optional)      |
| Extreme | ✓         | ✓           | ✓               | ✓        | ✓        | ✓ (Optional)      |
| Custom  | ✓/× user  | ✓/× user    | ✓/× user        | ✓/× user | ✓/× user | ✓ (Optional)      |

## 🔧 Extensibility

* Add New Modules: Create additional Debloat-<Module> functions and integrate them into custom mode or preset levels.
* Translate UI: Extend the \$Lang hashtable for more languages.
* Logging: Integrate Start-Transcript or write logs to a file for detailed execution records.
* CI/CD: Automate testing and releases via GitHub Actions.
* GUI Frontend: Wrap with WPF/WinForms or Electron for a more user-friendly graphical interface.

## 🛡️ Best Practices

* Backup: Always create a system restore point or a full backup before executing system modification scripts.
* Review Code: Audit script content when obtaining remotely to understand its full functionality.
* Test: Validate in a virtual or staging environment prior to applying to production systems.
* Update: Regularly fetch the latest script from the repository for improvements and fixes.

## 📜 License

This project is licensed under the MIT License. See LICENSE for details.
© 2025 Emre Asik. All rights reserved.
