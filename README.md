# Debloatranium 2025

![Debloatranium Logo](assets/logo.png)
**Professional Windows Debloat & Browser Installer**

---

## 📌 Overview

Debloatranium 2025 is an enterprise-grade PowerShell automation tool that streamlines Windows 10/11 optimization by:

* Removing redundant pre-installed applications
* Disabling telemetry and unnecessary background services
* Silently installing leading web browsers

Designed for both IT professionals and advanced home users, it offers preset cleanup levels and a fully granular custom mode, with English and German UI support.

---

## 🚀 Key Features

* **Multi-Level Debloating**

  * **Minimum**: Disables telemetry & data collection services only
  * **Medium**: Removes standard bloatware (Xbox suite, OneDrive, Mixed Reality Portal, etc.)
  * **High**: Includes Medium + aggressive app removal (Weather, Paint, Maps, etc.)
  * **Maximum**: Full cleanup + silent installation of Chrome, Firefox, Opera GX, Opera
* **Custom Mode**: Step-by-step interactive prompts to select individual cleanup tasks
* **Localization**: English and German menu prompts and notifications
* **Security & Validation**: Verifies administrator privileges and confirms critical actions
* **Robust Error Handling**: Clear messages and safe fallbacks for uninterrupted execution

---

## 🛠️ Architecture & Modules

1. **Configuration**

   * Centralized translation tables for multi-language support
   * Versioning, author, and license metadata in script header
2. **Helper Functions**

   * `Write-Log`: Consistent colorized logging
   * `Check-Admin`: Ensures elevated execution
   * `Confirm-Action` & `Read-YesNo`: Standardized user prompts
   * `Remove-App` & `Disable-ServiceSafely`: Encapsulated system modifications
   * `Install-Browser`: Unified download & silent installation logic
3. **Debloat Modules**

   * **Telemetry**: Disables `DiagTrack`, `dmwappushservice`, `lfsvc`
   * **App Removal**: Xbox, OneDrive, Mixed Reality, Solitaire, Skype, YourPhone, and more
   * **Aggressive Cleanup**: Removes additional Windows built-in apps
   * **Service Tuning**: Disables Windows Search compression
   * **Browser Suite**: Installs Chrome, Firefox, Opera GX, Opera silently
4. **Preset Levels & Custom Mode**

   * Predefined functions invoking combinations of modules
   * Custom mode for per-component selection
5. **Main Execution Flow**

   * Clear console, set ExecutionPolicy
   * Language selection, menu presentation, choice validation
   * Final confirmation and execution switch-case
   * Result summary & exit handling

---

## 📥 Installation & Quickstart

1. **Launch PowerShell as Administrator**:

   * Click Start, search for "PowerShell", right-click and select **"Run as administrator"**.
2. **Execute Remote Script**:

   * Copy and paste the following command into the elevated PowerShell window, then press Enter:

     ```powershell
     & ([scriptblock]::Create((irm "https://raw.githubusercontent.com/Emre1001/Debloatranium/refs/heads/main/Debloatranium.ps1")))
     ```
3. **Follow the prompts** to select language, debloat level, and confirm actions.

---

## 🔍 Usage Matrix

| Level   | Telemetry | Common Apps | Aggressive Apps | Services | Browsers |
| ------- | :-------: | :---------: | :-------------: | :------: | :------: |
| Minimum |     ✓     |      -      |        -        |     -    |     -    |
| Medium  |     ✓     |      ✓      |        -        |     -    |     -    |
| High    |     ✓     |      ✓      |        ✓        |     -    |     -    |
| Maximum |     ✓     |      ✓      |        ✓        |     ✓    |     ✓    |
| Custom  |  ✓/× user |   ✓/× user  |     ✓/× user    | ✓/× user | ✓/× user |

---

## 🔧 Extensibility

* **Add New Modules**: Create additional `Debloat-<Module>` functions and include them in custom mode
* **Translate UI**: Extend `$Global:Lang` for more languages
* **Logging**: Integrate `Start-Transcript` or write logs to file
* **CI/CD**: Automate testing and releases via GitHub Actions
* **GUI Frontend**: Wrap with WPF/WinForms or Electron for end-users

---

## 🛡️ Best Practices

* **Backup**: Create a system restore point or full backup before execution
* **Review Code**: Audit script content when obtaining remotely
* **Test**: Validate in a virtual or staging environment prior to production
* **Update**: Regularly fetch latest script from repository for improvements and fixes

---

## 📜 License

This project is licensed under the **MIT License**. See [LICENSE](LICENSE) for details.

---

*© 2025 Emre Asik. All rights reserved.*
