import { motion } from "framer-motion";
import { Check } from "lucide-react";
import Toggle from "./Toggle";
import { useI18n } from "../i18n";
import type { TweakMeta } from "../data/tweaks";

export default function TweakCard({
  meta,
  selected,
  applied,
  onToggle,
  i = 0,
}: {
  meta: TweakMeta;
  selected: boolean;
  applied: boolean;
  onToggle: () => void;
  i?: number;
}) {
  const { t, lang } = useI18n();
  const Icon = meta.icon;
  const removed = !!meta.oneWay && applied;
  const pending = meta.oneWay ? selected && !applied : selected !== applied;

  return (
    <motion.div
      layout
      initial={{ opacity: 0, y: 12 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: i * 0.03, type: "spring", stiffness: 320, damping: 26 }}
      className={`glass-soft glass-hover relative flex items-center gap-4 rounded-2xl p-4 ${
        pending ? "border-[#22e06b]/50" : ""
      }`}
    >
      <div
        className={`grid h-11 w-11 shrink-0 place-items-center rounded-xl transition-colors ${
          selected ? "grad-chip text-white" : "bg-white/[0.06] text-white/55"
        }`}
      >
        <Icon size={20} />
      </div>

      <div className="min-w-0 flex-1">
        <div className="flex items-center gap-2">
          <p className="truncate text-[15px] font-medium">{meta.title[lang]}</p>
          {pending && <span className="h-1.5 w-1.5 shrink-0 rounded-full bg-[#2bed6f] shadow-[0_0_8px_#2bed6f]" />}
        </div>
        <p className="mt-0.5 text-[12.5px] leading-snug text-white/45">{meta.desc[lang]}</p>
      </div>

      {removed ? (
        <span className="flex shrink-0 items-center gap-1 rounded-full bg-emerald-400/15 px-3 py-1 text-xs font-medium text-emerald-300">
          <Check size={13} />
          {t("removed")}
        </span>
      ) : (
        <Toggle on={selected} onClick={onToggle} disabled={removed} />
      )}
    </motion.div>
  );
}
