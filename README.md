# Debloatranium

Debloatranium is a comprehensive Windows debloating and optimization tool designed to remove bloatware and enhance system performance.

## Features

- **Multilingual Support**: Available in English, German, and Turkish
- **Multiple Debloat Levels**: Choose from Minimal, Medium, High, Maximum, or Custom options
- **System Optimization**: Improve performance by disabling unnecessary visual effects and animations
- **Taskbar Position Customization**: Position your taskbar to your preference (left or centered)
- **Browser Installation**: Option to install various browsers on fresh Windows installations
- **Simple User Interface**: Easy-to-use graphical interface to guide you through the process

## Usage

### Option 1: Run as PowerShell Script

1. Right-click on `Debloatranium.ps1` and select "Run with PowerShell"
2. If prompted about execution policy, you may need to run:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
   ```
3. Follow the on-screen instructions to select your preferences

### Option 2: Run as Executable (Recommended)

1. Download the latest `Debloatranium.exe` from the releases page
2. Right-click on the executable and select "Run as administrator"
3. Follow the on-screen instructions to select your preferences

## Building the Executable

If you want to build the executable yourself:

1. Ensure you have PowerShell 5.1 or newer
2. Run the `Build-Executable.ps1` script:
   ```powershell
   .\Build-Executable.ps1
   ```
3. The executable will be created in the `build` folder

## Warning

- The "Maximum" debloating option is extremely aggressive and may remove essential Windows components
- Always create a system restore point or backup before using this tool
- The tool requires administrative privileges to function properly

## Debloating Levels

- **Minimal**: Only optimizes system settings, no app removal
- **Medium**: Removes common bloatware (Paint 3D, Mixed Reality Portal, Xbox apps, etc.)
- **High**: Removes most non-essential apps while keeping core functionality
- **Maximum**: Removes almost all apps, may break functionality (use with caution)
- **Custom**: Choose specific apps to remove from a checklist

## License

This tool is provided as-is with no warranty. Use at your own risk.

## Acknowledgements

Debloatranium was created to provide a comprehensive solution for Windows system optimization and bloatware removal.
