// Debloatranium core — registry/appx tweak engine + Windows helpers.
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use serde::Serialize;
use std::process::Command;
use winreg::enums::*;
use winreg::RegKey;

#[cfg(target_os = "windows")]
use std::os::windows::process::CommandExt;
#[cfg(target_os = "windows")]
const CREATE_NO_WINDOW: u32 = 0x0800_0000;

/// Run a PowerShell one-liner hidden, return trimmed stdout.
fn ps(script: &str) -> Result<String, String> {
    let mut cmd = Command::new("powershell");
    cmd.args([
        "-NoProfile",
        "-NonInteractive",
        "-WindowStyle",
        "Hidden",
        "-Command",
        script,
    ]);
    #[cfg(target_os = "windows")]
    cmd.creation_flags(CREATE_NO_WINDOW);
    let out = cmd.output().map_err(|e| e.to_string())?;
    if out.status.success() {
        Ok(String::from_utf8_lossy(&out.stdout).trim().to_string())
    } else {
        let err = String::from_utf8_lossy(&out.stderr).trim().to_string();
        Err(if err.is_empty() { "command failed".into() } else { err })
    }
}

// ---------------- registry tweaks ----------------
struct ValSpec {
    name: &'static str,
    on: u32,
    off: u32,
}
struct RegTweak {
    id: &'static str,
    hklm: bool,
    path: &'static str,
    vals: &'static [ValSpec],
}

fn reg_tweaks() -> &'static [RegTweak] {
    &[
        RegTweak {
            id: "dark_mode",
            hklm: false,
            path: r"Software\Microsoft\Windows\CurrentVersion\Themes\Personalize",
            vals: &[
                ValSpec { name: "AppsUseLightTheme", on: 0, off: 1 },
                ValSpec { name: "SystemUsesLightTheme", on: 0, off: 1 },
            ],
        },
        RegTweak {
            id: "taskbar_left",
            hklm: false,
            path: r"Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced",
            vals: &[ValSpec { name: "TaskbarAl", on: 0, off: 1 }],
        },
        RegTweak {
            id: "show_file_ext",
            hklm: false,
            path: r"Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced",
            vals: &[ValSpec { name: "HideFileExt", on: 0, off: 1 }],
        },
        RegTweak {
            id: "hide_widgets",
            hklm: false,
            path: r"Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced",
            vals: &[ValSpec { name: "TaskbarDa", on: 0, off: 1 }],
        },
        RegTweak {
            id: "hide_taskview",
            hklm: false,
            path: r"Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced",
            vals: &[ValSpec { name: "ShowTaskViewButton", on: 0, off: 1 }],
        },
        RegTweak {
            id: "end_task",
            hklm: false,
            path: r"Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings",
            vals: &[ValSpec { name: "TaskbarEndTask", on: 1, off: 0 }],
        },
        RegTweak {
            id: "hide_search",
            hklm: false,
            path: r"Software\Microsoft\Windows\CurrentVersion\Search",
            vals: &[ValSpec { name: "SearchboxTaskbarMode", on: 0, off: 2 }],
        },
        RegTweak {
            id: "disable_bing",
            hklm: false,
            path: r"Software\Policies\Microsoft\Windows\Explorer",
            vals: &[ValSpec { name: "DisableSearchBoxSuggestions", on: 1, off: 0 }],
        },
        RegTweak {
            id: "disable_copilot",
            hklm: false,
            path: r"Software\Policies\Microsoft\Windows\WindowsCopilot",
            vals: &[ValSpec { name: "TurnOffWindowsCopilot", on: 1, off: 0 }],
        },
        RegTweak {
            id: "disable_telemetry",
            hklm: true,
            path: r"SOFTWARE\Policies\Microsoft\Windows\DataCollection",
            vals: &[ValSpec { name: "AllowTelemetry", on: 0, off: 1 }],
        },
        // ---- performance ----
        RegTweak {
            id: "perf_visualfx",
            hklm: false,
            path: r"Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects",
            vals: &[ValSpec { name: "VisualFXSetting", on: 2, off: 0 }],
        },
        RegTweak {
            id: "perf_transparency",
            hklm: false,
            path: r"Software\Microsoft\Windows\CurrentVersion\Themes\Personalize",
            vals: &[ValSpec { name: "EnableTransparency", on: 0, off: 1 }],
        },
        RegTweak {
            id: "perf_taskbar_anim",
            hklm: false,
            path: r"Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced",
            vals: &[ValSpec { name: "TaskbarAnimations", on: 0, off: 1 }],
        },
        RegTweak {
            id: "perf_gamebar",
            hklm: false,
            path: r"System\GameConfigStore",
            vals: &[ValSpec { name: "GameDVR_Enabled", on: 0, off: 1 }],
        },
        RegTweak {
            id: "perf_bg_apps",
            hklm: false,
            path: r"Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications",
            vals: &[ValSpec { name: "GlobalUserDisabled", on: 1, off: 0 }],
        },
        // ---- extra privacy / telemetry ----
        RegTweak {
            id: "priv_adid",
            hklm: false,
            path: r"Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo",
            vals: &[ValSpec { name: "Enabled", on: 0, off: 1 }],
        },
        RegTweak {
            id: "priv_tailored",
            hklm: false,
            path: r"Software\Microsoft\Windows\CurrentVersion\Privacy",
            vals: &[ValSpec { name: "TailoredExperiencesWithDiagnosticDataEnabled", on: 0, off: 1 }],
        },
        RegTweak {
            id: "priv_start_track",
            hklm: false,
            path: r"Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced",
            vals: &[ValSpec { name: "Start_TrackProgs", on: 0, off: 1 }],
        },
        RegTweak {
            id: "priv_activity",
            hklm: true,
            path: r"SOFTWARE\Policies\Microsoft\Windows\System",
            vals: &[
                ValSpec { name: "EnableActivityFeed", on: 0, off: 1 },
                ValSpec { name: "PublishUserActivities", on: 0, off: 1 },
            ],
        },
        RegTweak {
            id: "priv_location",
            hklm: true,
            path: r"SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors",
            vals: &[ValSpec { name: "DisableLocation", on: 1, off: 0 }],
        },
        RegTweak {
            id: "priv_error",
            hklm: true,
            path: r"SOFTWARE\Microsoft\Windows\Windows Error Reporting",
            vals: &[ValSpec { name: "Disabled", on: 1, off: 0 }],
        },
        RegTweak {
            id: "priv_cortana",
            hklm: true,
            path: r"SOFTWARE\Policies\Microsoft\Windows\Windows Search",
            vals: &[ValSpec { name: "AllowCortana", on: 0, off: 1 }],
        },
        RegTweak {
            id: "priv_ceip",
            hklm: true,
            path: r"SOFTWARE\Policies\Microsoft\SQMClient\Windows",
            vals: &[ValSpec { name: "CEIPEnable", on: 0, off: 1 }],
        },
        // ---- deep performance ----
        RegTweak {
            id: "perf_startup_delay",
            hklm: false,
            path: r"Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize",
            vals: &[ValSpec { name: "StartupDelayInMSec", on: 0, off: 1 }],
        },
        RegTweak {
            id: "perf_gamemode",
            hklm: false,
            path: r"Software\Microsoft\GameBar",
            vals: &[
                ValSpec { name: "AllowAutoGameMode", on: 1, off: 0 },
                ValSpec { name: "AutoGameModeEnabled", on: 1, off: 0 },
            ],
        },
        RegTweak {
            id: "perf_hags",
            hklm: true,
            path: r"SYSTEM\CurrentControlSet\Control\GraphicsDrivers",
            vals: &[ValSpec { name: "HwSchMode", on: 2, off: 1 }],
        },
        RegTweak {
            id: "perf_lastaccess",
            hklm: true,
            path: r"SYSTEM\CurrentControlSet\Control\FileSystem",
            vals: &[ValSpec { name: "NtfsDisableLastAccessUpdate", on: 1, off: 0 }],
        },
        RegTweak {
            id: "perf_throttling",
            hklm: true,
            path: r"SYSTEM\CurrentControlSet\Control\Power\PowerThrottling",
            vals: &[ValSpec { name: "PowerThrottlingOff", on: 1, off: 0 }],
        },
        RegTweak {
            id: "perf_reserved_storage",
            hklm: true,
            path: r"SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager",
            vals: &[ValSpec { name: "ShippedWithReserves", on: 0, off: 1 }],
        },
        // ---- more privacy ----
        RegTweak {
            id: "priv_suggestions",
            hklm: false,
            path: r"Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager",
            vals: &[
                ValSpec { name: "SystemPaneSuggestionsEnabled", on: 0, off: 1 },
                ValSpec { name: "SilentInstalledAppsEnabled", on: 0, off: 1 },
                ValSpec { name: "SubscribedContent-338388Enabled", on: 0, off: 1 },
                ValSpec { name: "SubscribedContent-338389Enabled", on: 0, off: 1 },
            ],
        },
        RegTweak {
            id: "priv_lockscreen_ads",
            hklm: false,
            path: r"Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager",
            vals: &[
                ValSpec { name: "RotatingLockScreenOverlayEnabled", on: 0, off: 1 },
                ValSpec { name: "SubscribedContent-338387Enabled", on: 0, off: 1 },
            ],
        },
        RegTweak {
            id: "priv_inking",
            hklm: false,
            path: r"Software\Microsoft\InputPersonalization",
            vals: &[
                ValSpec { name: "RestrictImplicitTextCollection", on: 1, off: 0 },
                ValSpec { name: "RestrictImplicitInkCollection", on: 1, off: 0 },
            ],
        },
        RegTweak {
            id: "priv_feedback",
            hklm: false,
            path: r"Software\Microsoft\Siuf\Rules",
            vals: &[ValSpec { name: "NumberOfSIUFInPeriod", on: 0, off: 1 }],
        },
    ]
}

fn root_key(hklm: bool) -> RegKey {
    RegKey::predef(if hklm { HKEY_LOCAL_MACHINE } else { HKEY_CURRENT_USER })
}

fn reg_is_on(t: &RegTweak) -> bool {
    let key = match root_key(t.hklm).open_subkey(t.path) {
        Ok(k) => k,
        Err(_) => return false,
    };
    t.vals
        .iter()
        .all(|v| matches!(key.get_value::<u32, _>(v.name), Ok(cur) if cur == v.on))
}

fn reg_set(t: &RegTweak, enabled: bool) -> Result<(), String> {
    let (key, _) = root_key(t.hklm)
        .create_subkey(t.path)
        .map_err(|e| format!("{} ({})", e, if t.hklm { "needs admin" } else { "registry" }))?;
    for v in t.vals {
        let val = if enabled { v.on } else { v.off };
        key.set_value(v.name, &val).map_err(|e| e.to_string())?;
    }
    Ok(())
}

// ---------------- appx (per-user remove) ----------------
struct AppxTweak {
    id: &'static str,
    pattern: &'static str,
}
fn appx_tweaks() -> &'static [AppxTweak] {
    &[
        AppxTweak { id: "appx_copilot", pattern: "Microsoft.Copilot" },
        AppxTweak { id: "appx_solitaire", pattern: "Microsoft.MicrosoftSolitaireCollection" },
        AppxTweak { id: "appx_bingnews", pattern: "Microsoft.BingNews" },
        AppxTweak { id: "appx_clipchamp", pattern: "Clipchamp.Clipchamp" },
        AppxTweak { id: "appx_xbox", pattern: "Microsoft.GamingApp" },
        AppxTweak { id: "appx_maps", pattern: "Microsoft.WindowsMaps" },
        AppxTweak { id: "appx_weather", pattern: "Microsoft.BingWeather" },
        AppxTweak { id: "appx_yourphone", pattern: "Microsoft.YourPhone" },
        AppxTweak { id: "appx_gethelp", pattern: "Microsoft.GetHelp" },
        AppxTweak { id: "appx_feedback", pattern: "Microsoft.WindowsFeedbackHub" },
        AppxTweak { id: "appx_quickassist", pattern: "MicrosoftCorporationII.QuickAssist" },
        AppxTweak { id: "appx_todos", pattern: "Microsoft.Todos" },
        AppxTweak { id: "appx_teamsconsumer", pattern: "MicrosoftTeams" },
    ]
}

// ---------------- Windows services (hardware step) ----------------
struct Service {
    id: &'static str,
    names: &'static [&'static str],
}
fn services() -> &'static [Service] {
    &[
        Service { id: "svc_wifi", names: &["WlanSvc"] },
        Service { id: "svc_bluetooth", names: &["bthserv", "BTAGService"] },
        Service { id: "svc_printer", names: &["Spooler"] },
    ]
}
fn service_enabled(s: &Service) -> bool {
    let mode = ps(&format!(
        "(Get-CimInstance Win32_Service -Filter \"Name='{}'\" -ErrorAction SilentlyContinue).StartMode",
        s.names[0]
    ))
    .unwrap_or_default();
    // Auto / Manual / missing => considered active; only Disabled is "off"
    !mode.eq_ignore_ascii_case("Disabled")
}
fn set_service(s: &Service, enabled: bool) -> Result<(), String> {
    for name in s.names {
        let script = if enabled {
            format!("Set-Service -Name '{0}' -StartupType Automatic -ErrorAction Stop; Start-Service -Name '{0}' -ErrorAction SilentlyContinue", name)
        } else {
            format!("Stop-Service -Name '{0}' -Force -ErrorAction SilentlyContinue; Set-Service -Name '{0}' -StartupType Disabled -ErrorAction Stop", name)
        };
        ps(&script)?;
    }
    Ok(())
}

#[derive(Serialize)]
struct TweakState {
    id: String,
    enabled: bool,
}

#[tauri::command]
fn get_states() -> Vec<TweakState> {
    let mut out: Vec<TweakState> = reg_tweaks()
        .iter()
        .map(|t| TweakState { id: t.id.into(), enabled: reg_is_on(t) })
        .collect();

    let installed = ps("Get-AppxPackage | Select-Object -ExpandProperty Name")
        .unwrap_or_default()
        .to_lowercase();
    for a in appx_tweaks() {
        let removed = !installed.contains(&a.pattern.to_lowercase());
        out.push(TweakState { id: a.id.into(), enabled: removed });
    }
    for s in services() {
        out.push(TweakState { id: s.id.into(), enabled: service_enabled(s) });
    }
    out
}

#[tauri::command]
fn set_tweak(id: String, enabled: bool) -> Result<(), String> {
    if let Some(t) = reg_tweaks().iter().find(|t| t.id == id) {
        return reg_set(t, enabled);
    }
    if let Some(a) = appx_tweaks().iter().find(|a| a.id == id) {
        if !enabled {
            return Err("reinstall_not_supported".into());
        }
        ps(&format!(
            "Get-AppxPackage *{}* | Remove-AppxPackage -ErrorAction Stop",
            a.pattern
        ))?;
        return Ok(());
    }
    if let Some(s) = services().iter().find(|s| s.id == id) {
        return set_service(s, enabled);
    }
    Err(format!("unknown tweak: {id}"))
}

#[derive(Serialize)]
struct SystemInfo {
    os: String,
    build: String,
    ram_gb: f64,
    cpu: String,
    cores: u32,
    elevated: bool,
}

fn is_admin() -> bool {
    ps("[bool]([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)")
        .map(|s| s.eq_ignore_ascii_case("true"))
        .unwrap_or(false)
}

#[tauri::command]
fn system_info() -> SystemInfo {
    let json = ps(r#"$o=Get-CimInstance Win32_OperatingSystem; $c=Get-CimInstance Win32_Processor | Select-Object -First 1; [pscustomobject]@{os=$o.Caption;build=$o.BuildNumber;ram=[math]::Round($o.TotalVisibleMemorySize/1MB,1);cpu=$c.Name;cores=[int]$c.NumberOfLogicalProcessors} | ConvertTo-Json -Compress"#).unwrap_or_default();
    let v: serde_json::Value = serde_json::from_str(&json).unwrap_or(serde_json::Value::Null);
    let s = |k: &str| v.get(k).and_then(|x| x.as_str()).unwrap_or("").trim().to_string();
    SystemInfo {
        os: {
            let o = s("os");
            if o.is_empty() { "Windows".into() } else { o }
        },
        build: s("build"),
        ram_gb: v.get("ram").and_then(|x| x.as_f64()).unwrap_or(0.0),
        cpu: s("cpu"),
        cores: v.get("cores").and_then(|x| x.as_u64()).unwrap_or(0) as u32,
        elevated: is_admin(),
    }
}

#[tauri::command]
fn is_elevated() -> bool {
    is_admin()
}

#[tauri::command]
fn relaunch_as_admin() -> Result<(), String> {
    let exe = std::env::current_exe().map_err(|e| e.to_string())?;
    let exe = exe.to_string_lossy().replace('\'', "''");
    let mut cmd = Command::new("powershell");
    cmd.args([
        "-NoProfile",
        "-Command",
        &format!("Start-Process -FilePath '{exe}' -Verb RunAs"),
    ]);
    #[cfg(target_os = "windows")]
    cmd.creation_flags(CREATE_NO_WINDOW);
    cmd.spawn().map_err(|e| e.to_string())?;
    std::process::exit(0);
}

#[tauri::command]
fn restart_explorer() -> Result<(), String> {
    ps("Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue; Start-Sleep -Milliseconds 500; if(-not (Get-Process explorer -ErrorAction SilentlyContinue)){ Start-Process explorer }").map(|_| ())
}

#[tauri::command]
fn create_restore_point() -> Result<(), String> {
    // Enable System Protection, bypass the 24h throttle, then snapshot.
    ps(r#"
$drive = "$env:SystemDrive\"
try { Enable-ComputerRestore -Drive $drive -ErrorAction SilentlyContinue } catch {}
$k = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore"
New-Item -Path $k -Force | Out-Null
Set-ItemProperty -Path $k -Name "SystemRestorePointCreationFrequency" -Value 0 -Type DWord -Force
Checkpoint-Computer -Description "Debloatranium" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
"#).map(|_| ())
}

#[tauri::command]
fn install_app(winget_id: String) -> Result<String, String> {
    let id = winget_id.trim();
    if id.is_empty() {
        return Err("empty winget id".into());
    }
    let mut cmd = Command::new("winget");
    cmd.args([
        "install",
        "--id",
        id,
        "-e",
        "--silent",
        "--accept-package-agreements",
        "--accept-source-agreements",
        "--disable-interactivity",
    ]);
    #[cfg(target_os = "windows")]
    cmd.creation_flags(CREATE_NO_WINDOW);
    let out = cmd
        .output()
        .map_err(|e| format!("winget not available: {e}"))?;
    let txt = format!(
        "{}{}",
        String::from_utf8_lossy(&out.stdout),
        String::from_utf8_lossy(&out.stderr)
    );
    let low = txt.to_lowercase();
    if out.status.success()
        || low.contains("already installed")
        || low.contains("no available upgrade")
        || low.contains("found an existing")
    {
        Ok("ok".into())
    } else {
        let last = txt
            .lines()
            .map(str::trim)
            .filter(|l| !l.is_empty())
            .last()
            .unwrap_or("install failed");
        Err(last.to_string())
    }
}

#[tauri::command]
fn remove_edge() -> Result<String, String> {
    // Best-effort uninstall via Edge's own setup.exe. Windows Update may restore it.
    ps(r#"
$bases = @("${env:ProgramFiles(x86)}\Microsoft\Edge\Application", "$env:ProgramFiles\Microsoft\Edge\Application")
$setup = $null
foreach ($b in $bases) {
  if (Test-Path $b) {
    $s = Get-ChildItem $b -Recurse -Filter setup.exe -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($s) { $setup = $s.FullName; break }
  }
}
if (-not $setup) { throw "Edge setup.exe not found" }
Start-Process -FilePath $setup -ArgumentList '--uninstall','--system-level','--force-uninstall','--verbose-logging' -Wait -NoNewWindow
"removed"
"#)
}

#[tauri::command]
fn restart_pc() -> Result<(), String> {
    let mut cmd = Command::new("shutdown");
    cmd.args(["/r", "/t", "0"]);
    #[cfg(target_os = "windows")]
    cmd.creation_flags(CREATE_NO_WINDOW);
    cmd.spawn().map_err(|e| e.to_string())?;
    Ok(())
}

#[tauri::command]
fn set_power_plan(high: bool) -> Result<(), String> {
    // High Performance vs Balanced built-in scheme GUIDs.
    let guid = if high {
        "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
    } else {
        "381b4222-f694-41f0-9685-ff5bb260df2e"
    };
    let mut cmd = Command::new("powercfg");
    cmd.args(["/setactive", guid]);
    #[cfg(target_os = "windows")]
    cmd.creation_flags(CREATE_NO_WINDOW);
    let out = cmd.output().map_err(|e| e.to_string())?;
    if out.status.success() {
        Ok(())
    } else {
        Err(String::from_utf8_lossy(&out.stderr).trim().to_string())
    }
}

#[tauri::command]
fn detect_gpu() -> String {
    let n = ps("(Get-CimInstance Win32_VideoController | Select-Object -ExpandProperty Name) -join ' '")
        .unwrap_or_default()
        .to_lowercase();
    if n.contains("nvidia") {
        "nvidia".into()
    } else if n.contains("amd") || n.contains("radeon") {
        "amd".into()
    } else if n.contains("intel") {
        "intel".into()
    } else {
        "unknown".into()
    }
}

#[tauri::command]
fn clean_temp() -> Result<String, String> {
    ps(r#"Remove-Item -Path "$env:TEMP\*", "$env:SystemRoot\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue; "cleaned""#)
}

/// Deep one-shot optimizations (mostly admin). id maps to a specific action.
#[tauri::command]
fn apply_action(id: String) -> Result<String, String> {
    match id.as_str() {
        "disable_hibernation" => ps("powercfg /hibernate off; 'ok'"),
        "disable_sysmain" => ps(
            "Stop-Service -Name 'SysMain' -Force -ErrorAction SilentlyContinue; Set-Service -Name 'SysMain' -StartupType Disabled -ErrorAction Stop; 'ok'",
        ),
        "disable_search_index" => ps(
            "Stop-Service -Name 'WSearch' -Force -ErrorAction SilentlyContinue; Set-Service -Name 'WSearch' -StartupType Disabled -ErrorAction Stop; 'ok'",
        ),
        "disable_diagtrack" => ps(
            "Stop-Service -Name 'DiagTrack' -Force -ErrorAction SilentlyContinue; Set-Service -Name 'DiagTrack' -StartupType Disabled -ErrorAction Stop; 'ok'",
        ),
        "flush_dns" => ps("ipconfig /flushdns | Out-Null; 'ok'"),
        "disable_onedrive" => ps(
            r#"taskkill /f /im OneDrive.exe 2>$null | Out-Null; $s="$env:SystemRoot\System32\OneDriveSetup.exe"; if(-not (Test-Path $s)){ $s="$env:SystemRoot\SysWOW64\OneDriveSetup.exe" }; if(Test-Path $s){ Start-Process -FilePath $s -ArgumentList '/uninstall' -Wait -NoNewWindow }; "ok""#,
        ),
        _ => Err(format!("unknown action: {id}")),
    }
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .setup(|app| {
            #[cfg(target_os = "windows")]
            {
                use tauri::Manager;
                if let Some(win) = app.get_webview_window("main") {
                    let _ = window_vibrancy::apply_acrylic(&win, Some((8, 10, 20, 130)));
                }
            }
            Ok(())
        })
        .invoke_handler(tauri::generate_handler![
            get_states,
            set_tweak,
            system_info,
            is_elevated,
            relaunch_as_admin,
            restart_explorer,
            create_restore_point,
            install_app,
            remove_edge,
            restart_pc,
            set_power_plan,
            detect_gpu,
            clean_temp,
            apply_action
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
