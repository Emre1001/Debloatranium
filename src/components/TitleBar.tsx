import { Minus, X, Radiation } from "lucide-react";
import { getCurrentWindow } from "@tauri-apps/api/window";

const isTauri = typeof window !== "undefined" && "__TAURI_INTERNALS__" in window;
const win = isTauri ? getCurrentWindow() : null;

export default function TitleBar() {
  return (
    <div
      data-tauri-drag-region
      className="flex h-12 shrink-0 items-center justify-between pl-5 pr-2"
    >
      <div data-tauri-drag-region className="pointer-events-none flex items-center gap-2.5">
        <Radiation size={20} className="text-[#22e06b]" />
        <span className="text-sm font-bold uppercase tracking-[0.2em] text-[#2bed6f]">
          Debloatranium
        </span>
      </div>

      <div className="flex items-center">
        <button
          onClick={() => win?.minimize()}
          className="grid h-9 w-11 place-items-center rounded-lg text-white/55 transition-colors hover:bg-white/10 hover:text-white"
        >
          <Minus size={17} />
        </button>
        <button
          onClick={() => win?.close()}
          className="grid h-9 w-11 place-items-center rounded-lg text-white/55 transition-colors hover:bg-[#ff4d6d] hover:text-white"
        >
          <X size={17} />
        </button>
      </div>
    </div>
  );
}
