☢️ Debloatranium

The ultimate Windows Debloater & Optimizer for every PC. > Powerful. Customizable. Multilingual.

🌍 About the Project

Debloatranium is an interactive PowerShell tool designed to accelerate and clean up your Windows experience. It removes bloatware, optimizes privacy, and tailors Windows exactly to your needs—whether for gaming, office work, or a minimal setup.

✨ Highlights

🗣️ Multilingual: Supports German 🇩🇪, English 🇺🇸, and Turkish 🇹🇷.

🌐 Browser Choice: Removes Edge (optional) and automatically installs Chrome, Firefox, or Tor.

🌙 Style: Automatically enables Dark Mode.

🛡️ Security: Built-in Registry Backup feature.

🎮 Gaming Ready: Special "Extreme" mode for maximum FPS.

🚀 Installation (Quick Start)

Start PowerShell as Administrator and run the following command. The script will load and start directly:

iwr -UseBasicParsing [https://raw.githubusercontent.com/Emre1001/Debloatranium/main/Debloatranium.ps1](https://raw.githubusercontent.com/Emre1001/Debloatranium/main/Debloatranium.ps1) | iex


Note: You will be guided through an interactive menu. No changes are made until you confirm them.

🎚️ Optimization Levels

Choose the level that fits your system:

Level

Name

Description

1️⃣

Minimum

Performance tweaks only (Telemetry reduced, GameMode on). No apps are deleted.

2️⃣

Light

Same as Minimum + disables unused services (Fax, Hibernation).

3️⃣

Medium

Same as Light + removes obvious bloatware (Weather, News, Solitaire).

4️⃣

High

Same as Medium + removes OneDrive, Cortana, Maps & Feedback Hub.

5️⃣

Extreme

⚠️ For Gaming/Pros only! Removes almost ALL system apps and the Microsoft Store. Only essentials remain.

6️⃣

Custom

Choose manually which categories you want to apply.

⚙️ Features in Detail

The script asks you step-by-step:

Language: Choose your preferred language.

Hardware Features: Keep or disable WiFi, Bluetooth, and Printer Spooler.

Browser: Decide the fate of Microsoft Edge.

Backup: Create a backup of your current settings directly on the Desktop.

Security: Double confirmation before execution.

⚠️ Disclaimer

USE AT YOUR OWN RISK.

This script makes deep changes to the Windows system configuration. Although it has been tested extensively and includes safety mechanisms (like the backup function), the developer cannot guarantee the functionality of your system after application.

The Extreme Mode deletes the Microsoft Store and many system components. This is intentional but may limit certain Windows functions.

It is strongly recommended to create a System Restore Point or use the integrated Registry Backup feature before using "Extreme" mode or making general changes.

Made with ❤️ by Emre1001
