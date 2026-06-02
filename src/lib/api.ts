import { invoke } from "@tauri-apps/api/core";

export interface TweakState {
  id: string;
  enabled: boolean;
}
export interface SystemInfo {
  os: string;
  build: string;
  ram_gb: number;
  cpu: string;
  cores: number;
  elevated: boolean;
}

const isTauri = typeof window !== "undefined" && "__TAURI_INTERNALS__" in window;

// Mock data so the UI renders in a plain browser preview (no Tauri backend).
const MOCK_STATES: TweakState[] = [
  { id: "dark_mode", enabled: true },
  { id: "show_file_ext", enabled: true },
  { id: "svc_wifi", enabled: true },
  { id: "svc_bluetooth", enabled: true },
  { id: "svc_printer", enabled: true },
];
const MOCK_INFO: SystemInfo = {
  os: "Windows 11 Pro",
  build: "26100",
  ram_gb: 32,
  cpu: "AMD Ryzen 7 7800X3D 8-Core Processor",
  cores: 16,
  elevated: false,
};
const wait = (ms: number) => new Promise((r) => setTimeout(r, ms));

export const api = {
  getStates: () =>
    isTauri ? invoke<TweakState[]>("get_states") : Promise.resolve(MOCK_STATES),
  setTweak: (id: string, enabled: boolean) =>
    isTauri ? invoke<void>("set_tweak", { id, enabled }) : wait(220).then(() => undefined),
  systemInfo: () =>
    isTauri ? invoke<SystemInfo>("system_info") : Promise.resolve(MOCK_INFO),
  isElevated: () =>
    isTauri ? invoke<boolean>("is_elevated") : Promise.resolve(false),
  relaunchAsAdmin: () =>
    isTauri ? invoke<void>("relaunch_as_admin") : Promise.resolve(),
  restartExplorer: () =>
    isTauri ? invoke<void>("restart_explorer") : Promise.resolve(),
  createRestorePoint: () =>
    isTauri ? invoke<void>("create_restore_point") : wait(900).then(() => undefined),
  installApp: (wingetId: string) =>
    isTauri ? invoke<string>("install_app", { wingetId }) : wait(700).then(() => "ok"),
  removeEdge: () =>
    isTauri ? invoke<string>("remove_edge") : wait(900).then(() => "removed"),
  restartPc: () =>
    isTauri ? invoke<void>("restart_pc") : Promise.resolve(),
  setPowerPlan: (high: boolean) =>
    isTauri ? invoke<void>("set_power_plan", { high }) : wait(300).then(() => undefined),
  detectGpu: () =>
    isTauri ? invoke<string>("detect_gpu") : Promise.resolve("nvidia"),
  cleanTemp: () =>
    isTauri ? invoke<string>("clean_temp") : wait(600).then(() => "cleaned"),
  applyAction: (id: string) =>
    isTauri ? invoke<string>("apply_action", { id }) : wait(500).then(() => "ok"),
};
