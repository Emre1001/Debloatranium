import { useEffect, useRef, useState } from "react";
import { motion, AnimatePresence, useMotionValue, useTransform, animate } from "framer-motion";
import { Radiation } from "lucide-react";
import { useI18n } from "../i18n";

const STOPS = ["modus_minimal", "modus_balanced", "modus_aggressive", "modus_zero"];
const DESCS = ["modus_d_minimal", "modus_d_balanced", "modus_d_aggressive", "modus_d_zero"];
const TH = 24; // thumb diameter

// level 1..4  <->  index 0..3
export default function ModusSlider({ level, onChange }: { level: number; onChange: (l: number) => void }) {
  const { t } = useI18n();
  const trackRef = useRef<HTMLDivElement>(null);
  const [w, setW] = useState(0);
  const x = useMotionValue(0);
  const idx = Math.min(3, Math.max(0, level - 1));
  const [live, setLive] = useState(idx);

  const usable = Math.max(0, w - TH);
  const stepW = usable / 3;

  useEffect(() => {
    const measure = () => setW(trackRef.current?.offsetWidth ?? 0);
    measure();
    window.addEventListener("resize", measure);
    return () => window.removeEventListener("resize", measure);
  }, []);

  // slide thumb when level/width changes externally
  useEffect(() => {
    if (usable <= 0) return;
    const controls = animate(x, idx * stepW, { type: "spring", stiffness: 420, damping: 36 });
    setLive(idx);
    return () => controls.stop();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [usable, idx]);

  const fillW = useTransform(x, (v) => v + TH / 2);
  const danger = live >= 2;

  function commit(i: number) {
    const c = Math.min(3, Math.max(0, i));
    if (stepW > 0) animate(x, c * stepW, { type: "spring", stiffness: 420, damping: 36 });
    setLive(c);
    if (c + 1 !== level) onChange(c + 1);
  }

  return (
    <div>
      <div className="mb-6 flex items-center gap-3">
        <motion.div
          animate={{ rotate: live === 3 ? 360 : 0, scale: 1 + live * 0.06 }}
          transition={live === 3 ? { duration: 6, repeat: Infinity, ease: "linear" } : { type: "spring", stiffness: 300, damping: 16 }}
        >
          <Radiation size={30} className={danger ? "text-[#d4ff3d]" : "text-[#22e06b]"} />
        </motion.div>
        <AnimatePresence mode="wait">
          <motion.h3
            key={live}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
            transition={{ duration: 0.2 }}
            className="grad-text text-3xl font-black tracking-tight"
          >
            {t(STOPS[live])}
          </motion.h3>
        </AnimatePresence>
      </div>

      <div ref={trackRef} className="relative h-2.5 w-full rounded-full bg-white/10">
        <motion.div className="grad-fill absolute inset-y-0 left-0 rounded-full" style={{ width: fillW }} />
        {STOPS.map((_, i) => (
          <button
            key={i}
            onClick={() => commit(i)}
            aria-label={`stop ${i}`}
            className="absolute top-1/2 z-10 h-3 w-3 -translate-x-1/2 -translate-y-1/2 rounded-full bg-white/25 transition-colors hover:bg-white/50"
            style={{ left: `${TH / 2 + i * stepW}px` }}
          />
        ))}
        <motion.div
          drag="x"
          dragConstraints={{ left: 0, right: usable }}
          dragElastic={0}
          dragMomentum={false}
          onDrag={() => stepW > 0 && setLive(Math.min(3, Math.max(0, Math.round(x.get() / stepW))))}
          onDragEnd={() => stepW > 0 && commit(Math.round(x.get() / stepW))}
          style={{ x }}
          whileDrag={{ scale: 1.25 }}
          whileHover={{ scale: 1.12 }}
          className="absolute top-1/2 z-20 h-6 w-6 -translate-y-1/2 cursor-grab rounded-full active:cursor-grabbing"
        >
          <span className="grad-fill-br glow-green block h-6 w-6 rounded-full border-[3px] border-[#07120c]" />
        </motion.div>
      </div>

      <div className="mt-4 flex justify-between" style={{ paddingLeft: TH / 2, paddingRight: TH / 2 }}>
        {STOPS.map((n, i) => (
          <button
            key={n}
            onClick={() => commit(i)}
            className={`text-[11px] font-semibold transition-colors ${i === live ? "text-white" : "text-white/35 hover:text-white/60"}`}
          >
            {t(n)}
          </button>
        ))}
      </div>

      <AnimatePresence mode="wait">
        <motion.p
          key={live}
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 0.2 }}
          className="mt-6 text-sm leading-relaxed text-white/55"
        >
          {t(DESCS[live])}
        </motion.p>
      </AnimatePresence>
    </div>
  );
}
