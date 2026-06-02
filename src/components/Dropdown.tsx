import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { ChevronDown, Check } from "lucide-react";

export interface Opt {
  value: string;
  label: string;
}

export default function Dropdown({
  value,
  options,
  onChange,
}: {
  value: string;
  options: Opt[];
  onChange: (v: string) => void;
}) {
  const [open, setOpen] = useState(false);
  const cur = options.find((o) => o.value === value);

  return (
    <div className="relative w-full">
      <button
        onClick={() => setOpen((o) => !o)}
        className="glass-soft glass-hover flex w-full items-center justify-between rounded-xl px-4 py-3 text-sm font-semibold text-white"
      >
        {cur?.label ?? value}
        <motion.span animate={{ rotate: open ? 180 : 0 }} transition={{ duration: 0.2 }} className="text-white/50">
          <ChevronDown size={16} />
        </motion.span>
      </button>

      <AnimatePresence>
        {open && (
          <>
            <div className="fixed inset-0 z-30" onClick={() => setOpen(false)} />
            <motion.div
              initial={{ opacity: 0, y: -8, scale: 0.97 }}
              animate={{ opacity: 1, y: 0, scale: 1 }}
              exit={{ opacity: 0, y: -8, scale: 0.97 }}
              transition={{ duration: 0.16 }}
              className="glass absolute z-40 mt-2 w-full overflow-hidden rounded-xl p-1 shadow-2xl"
            >
              {options.map((o) => (
                <button
                  key={o.value}
                  onClick={() => {
                    onChange(o.value);
                    setOpen(false);
                  }}
                  className={`flex w-full items-center justify-between rounded-lg px-3 py-2 text-sm transition-colors ${
                    o.value === value ? "bg-white/[0.06] text-[#2bed6f]" : "text-white/80 hover:bg-white/5"
                  }`}
                >
                  {o.label}
                  {o.value === value && <Check size={14} />}
                </button>
              ))}
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </div>
  );
}
