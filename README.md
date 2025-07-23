# Debloatranium 2025

**Professional Windows Debloat & Browser Installer**

Debloatranium 2025 is an enterprise-grade PowerShell tool designed to automate and streamline Windows 10 and 11 optimization. It removes unnecessary applications, disables telemetry, and offers interactive web browser installation. Fully multilingual, efficient, and secure — built for IT professionals and power users.

## Overview

Debloatranium 2025 simplifies Windows cleanup by:

* Removing redundant pre-installed apps
* Disabling telemetry and background services
* Interactive browser installation (Chrome, Firefox, Opera, Opera GX)
* Multi-language user interface: English, German, Turkish
* Five predefined debloat levels plus fully interactive custom mode

## Key Features

Debloat Levels:

* Minimum: Disables telemetry and diagnostics only
* Medium: Removes standard bloatware (Xbox, OneDrive, etc.)
* High: Also removes apps like Paint, Maps, Weather, and Microsoft Edge
* Extreme: Includes disabling of security features like Windows Defender (use with caution)
* Custom: Over 40 interactive questions for granular configuration

Browser Management:

* Pre-debloat warning if Microsoft Edge will be removed, offers immediate browser install
* Post-debloat: always offers interactive selection (Chrome, Firefox, Opera, Opera GX)

Multilingual Support:

* All prompts and menus are available in English, German, and Turkish
* Language selection on startup

Security & Stability:

* Verifies administrator privileges before running
* Confirms critical actions
* Built-in error handling and logging

## Architecture & Modules

Structure:

* All actions are modular, organized as Debloat-<Module> functions
* Multilingual text is handled through a centralized \$Lang hashtable
* Logging via Write-Log

Key Modules:

* Telemetry: Disables DiagTrack, dmwappushservice, lfsvc
* App Removal: Removes Xbox, OneDrive, Weather, Paint, Maps, Camera, Skype, and more
* Edge Removal: Fully removes Microsoft Edge
* Service Tuning: Disables Windows Search, Superfetch, WMP Network Sharing
* Defender Control: Disables core Defender features (Extreme level only)
* Browser Management: Easy selection and silent installation of major browsers

## Usage Matrix

| Level   | Telemetry | Standard Apps | Aggressive Apps | Services | Defender | Browser Selection |
| ------- | --------- | ------------- | --------------- | -------- | -------- | ----------------- |
| Minimum | ✅         | ❌             | ❌               | ❌        | ❌        | ✅ (Optional)      |
| Medium  | ✅         | ✅             | ❌               | ❌        | ❌        | ✅ (Optional)      |
| High    | ✅         | ✅             | ✅               | ❌        | ❌        | ✅ (Optional)      |
| Extreme | ✅         | ✅             | ✅               | ✅        | ✅        | ✅ (Optional)      |
| Custom  | ✅/❌ User  | ✅/❌ User      | ✅/❌ User        | ✅/❌ User | ✅/❌ User | ✅ (Optional)      |

## Installation & Quickstart

Launch PowerShell as Administrator, then paste the following command:

```
& ([scriptblock]::Create((irm "https://raw.githubusercontent.com/Emre1001/Debloatranium/refs/heads/main/Debloatranium.ps1")))
```

Note: Replace the URL with the actual raw GitHub URL of your script after uploading.

Step-by-step process:

1. Select your language
2. Answer whether it's a fresh Windows install and if another browser is present
3. Choose a debloat level (Minimum – Extreme or Custom)
4. Confirm actions
5. Script executes automatically
6. Optionally select and install a browser post-debloat
7. Displays results and optionally prompts for system reboot

## Extensibility

* Add new Debloat-XYZ functions as needed
* Extend language support by modifying the \$Lang hashtable
* Improve logging using Write-Log or Start-Transcript
* Integrate CI/CD with GitHub Actions
* Add a GUI layer via WPF, WinForms, or Electron

## Best Practices

* Always create a system restore point or full backup before running system-level scripts
* Review the source code when running scripts remotely
* Test in a virtual machine or staging environment before deploying to production
* Check the repository regularly for updates and improvements

## License

This project is licensed under the MIT License.
© 2025 Emre Asik. All rights reserved.

## GitHub Repository

[https://github.com/Emre1001/Debloatranium](https://github.com/Emre1001/Debloatranium)
