import { motion } from "framer-motion";
import { LayoutDashboard, SlidersHorizontal, Trash2, Info, ShieldCheck, ShieldAlert } from "lucide-react";
import { useI18n } from "../i18n";
import type { SystemInfo } from "../lib/api";

export type View = "dashboard" | "tweaks" | "debloat" | "about";

const ITEMS: { id: View; icon: typeof LayoutDashboard; key: string }[] = [
  { id: "dashboard", icon: LayoutDashboard, key: "nav_dashboard" },
  { id: "tweaks", icon: SlidersHorizontal, key: "nav_tweaks" },
  { id: "debloat", icon: Trash2, key: "nav_debloat" },
  { id: "about", icon: Info, key: "nav_about" },
];

export default function Sidebar({
  view,
  setView,
  info,
  onAdmin,
}: {
  view: View;
  setView: (v: View) => void;
  info: SystemInfo | null;
  onAdmin: () => void;
}) {
  const { t } = useI18n();
  return (
    <aside className="flex w-[212px] shrink-0 flex-col gap-1 border-r border-white/[0.06] p-3">
      {ITEMS.map((it) => {
        const active = view === it.id;
        const Icon = it.icon;
        return (
          <button
            key={it.id}
            onClick={() => setView(it.id)}
            className={`relative flex items-center gap-3 rounded-xl px-3.5 py-2.5 text-sm transition-colors ${
              active ? "text-white" : "text-white/55 hover:text-white/90"
            }`}
          >
            {active && (
              <motion.div
                layoutId="navpill"
                transition={{ type: "spring", stiffness: 400, damping: 32 }}
                className="absolute inset-0 rounded-xl border border-white/10 bg-white/[0.07]"
              />
            )}
            <Icon size={18} className="relative z-10" />
            <span className="relative z-10 font-medium">{t(it.key)}</span>
          </button>
        );
      })}

      <div className="mt-auto">
        {info && (
          <button
            onClick={info.elevated ? undefined : onAdmin}
            disabled={info.elevated}
            className={`flex w-full items-center gap-2 rounded-xl px-3 py-2.5 text-xs font-medium transition-colors ${
              info.elevated
                ? "bg-emerald-400/10 text-emerald-300"
                : "bg-amber-400/10 text-amber-300 hover:bg-amber-400/20"
            }`}
          >
            {info.elevated ? <ShieldCheck size={15} /> : <ShieldAlert size={15} />}
            <span className="truncate">{info.elevated ? t("admin_on") : t("run_admin")}</span>
          </button>
        )}
      </div>
    </aside>
  );
}
