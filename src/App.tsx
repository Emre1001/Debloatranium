import { useEffect, useMemo, useState } from "react";
import type { ReactNode } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Radiation, Check, Sparkles, Gem, ShieldAlert, RotateCcw, History, Search, Trash2, Power, Gauge, Cpu } from "lucide-react";
import { getCurrentWindow } from "@tauri-apps/api/window";
import Background from "./components/Background";
import TitleBar from "./components/TitleBar";
import ModusSlider from "./components/ModusSlider";
import TweakCard from "./components/TweakCard";
import Dropdown from "./components/Dropdown";
import { I18nProvider, useI18n, LANGS } from "./i18n";
import { TWEAKS } from "./data/tweaks";
import type { Cat } from "./data/tweaks";
import { APPS, PURPOSES, ALWAYS_APPS, purposeApps } from "./data/apps";
import type { Purpose, AppItem } from "./data/apps";
import { ACTIONS } from "./data/actions";
import { api } from "./lib/api";
import type { SystemInfo } from "./lib/api";

const isTauri = typeof window !== "undefined" && "__TAURI_INTERNALS__" in window;
const win = isTauri ? getCurrentWindow() : null;

type StepKey = "welcome" | "hardware" | "mode" | "modus" | "tweaks" | "apps" | "review";
type Mode = "modus" | "custom";
type Phase = "wizard" | "loading" | "done";

function presetFor(map: Record<string, boolean>, l: number) {
  const next = { ...map };
  for (const tw of TWEAKS) {
    if (tw.cat === "hardware") continue;
    const inP = tw.level <= l;
    next[tw.id] = tw.oneWay ? inP || !!map[tw.id] : inP;
  }
  return next;
}

function Header({ title, sub }: { title: string; sub: string }) {
  return (
    <motion.div initial={{ opacity: 0, y: -6 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.3 }} className="mb-7">
      <h2 className="text-4xl font-black tracking-tight">{title}</h2>
      <p className="mt-2 text-sm text-white/45">{sub}</p>
    </motion.div>
  );
}

function AppCard({ app, selected, onToggle, i }: { app: AppItem; selected: boolean; onToggle: () => void; i: number }) {
  const { t, lang } = useI18n();
  const Icon = app.icon;
  const forced = !!app.always;
  return (
    <motion.button
      layout
      initial={{ opacity: 0, y: 12 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: i * 0.02, type: "spring", stiffness: 320, damping: 26 }}
      onClick={forced ? undefined : onToggle}
      disabled={forced}
      whileHover={forced ? undefined : { scale: 1.015 }}
      className={`glass-soft glass-hover flex items-center gap-3.5 rounded-2xl p-3.5 text-left ${selected ? "border-[#22e06b]/50" : ""} ${forced ? "cursor-default" : ""}`}
    >
      <div className={`grid h-10 w-10 shrink-0 place-items-center rounded-xl ${selected ? "grad-chip text-white" : "bg-white/[0.06] text-white/55"}`}>
        <Icon size={18} />
      </div>
      <div className="min-w-0 flex-1">
        <p className="truncate text-sm font-semibold">{app.name}</p>
        <p className="truncate text-[11.5px] text-white/45">{app.desc[lang]}</p>
      </div>
      {forced ? (
        <span className="rounded-full bg-[#22e06b]/15 px-2.5 py-1 text-[10px] font-bold uppercase tracking-wide text-[#2bed6f]">{t("always_label")}</span>
      ) : (
        <span className={`grid h-5 w-5 shrink-0 place-items-center rounded-md border ${selected ? "grad-fill border-transparent" : "border-white/15"}`}>
          {selected && <Check size={13} className="text-black" />}
        </span>
      )}
    </motion.button>
  );
}

const GPU: Record<string, { label: string; winget: string }> = {
  nvidia: { label: "NVIDIA", winget: "Nvidia.GeForceExperience" },
  amd: { label: "AMD", winget: "AMD.RadeonSoftware" },
  intel: { label: "Intel", winget: "Intel.IntelDriverAndSupportAssistant" },
};

function BoostCard({ icon: Icon, title, desc, on, onToggle, disabled }: { icon: typeof Gauge; title: string; desc: string; on: boolean; onToggle: () => void; disabled?: boolean }) {
  const active = on && !disabled;
  return (
    <motion.button
      layout
      whileHover={disabled ? undefined : { scale: 1.015 }}
      onClick={disabled ? undefined : onToggle}
      disabled={disabled}
      className={`glass-soft flex items-center gap-3.5 rounded-2xl p-3.5 text-left ${active ? "border-[#22e06b]/50" : ""} ${disabled ? "cursor-not-allowed opacity-50" : ""}`}
    >
      <div className={`grid h-10 w-10 shrink-0 place-items-center rounded-xl ${active ? "grad-chip text-white" : "bg-white/[0.06] text-white/55"}`}>
        <Icon size={18} />
      </div>
      <div className="min-w-0 flex-1">
        <p className="truncate text-sm font-semibold">{title}</p>
        <p className="truncate text-[11.5px] text-white/45">{desc}</p>
      </div>
      <span className={`grid h-5 w-5 shrink-0 place-items-center rounded-md border ${active ? "grad-fill border-transparent" : "border-white/15"}`}>
        {active && <Check size={13} className="text-black" />}
      </span>
    </motion.button>
  );
}

function ModeCard({ active, onClick, icon: Icon, title, desc }: { active: boolean; onClick: () => void; icon: typeof Sparkles; title: string; desc: string }) {
  return (
    <motion.button
      onClick={onClick}
      whileHover={{ scale: 1.02 }}
      whileTap={{ scale: 0.99 }}
      className={`glass-soft glass-hover flex-1 rounded-3xl p-6 text-left ${active ? "border-[#22e06b]/60 glow-green" : ""}`}
    >
      <Icon size={26} className={active ? "text-[#22e06b]" : "text-white/60"} />
      <h3 className="mt-5 text-xl font-bold">{title}</h3>
      <p className="mt-1.5 text-sm text-white/45">{desc}</p>
    </motion.button>
  );
}

function AppInner() {
  const { t, lang, setLang } = useI18n();
  const [phase, setPhase] = useState<Phase>("wizard");
  const [stepIdx, setStepIdx] = useState(0);
  const [mode, setMode] = useState<Mode>("modus");
  const [level, setLevel] = useState(1);
  const [info, setInfo] = useState<SystemInfo | null>(null);
  const [applied, setApplied] = useState<Record<string, boolean>>({});
  const [selected, setSelected] = useState<Record<string, boolean>>({});
  const [appsSel, setAppsSel] = useState<Set<string>>(new Set(ALWAYS_APPS.map((a) => a.id)));
  const [edge, setEdge] = useState(false);
  const [restore, setRestore] = useState(true);
  const [search, setSearch] = useState("");
  const [arm, setArm] = useState(false);
  const [gpu, setGpu] = useState("unknown");
  const [powerPlan, setPowerPlan] = useState(true);
  const [cleanTemp, setCleanTemp] = useState(false);
  const [gpuDriver, setGpuDriver] = useState(true);
  const [deep, setDeep] = useState<Set<string>>(new Set(ACTIONS.filter((a) => a.def).map((a) => a.id)));
  const [prog, setProg] = useState({ done: 0, total: 0, label: "", errors: 0 });

  const flow: StepKey[] = useMemo(
    () => ["welcome", "hardware", "mode", mode === "custom" ? "tweaks" : "modus", "apps", "review"],
    [mode],
  );
  const stepKey = flow[stepIdx];

  async function load() {
    const [st, inf] = await Promise.all([api.getStates(), api.systemInfo()]);
    const map: Record<string, boolean> = {};
    st.forEach((s) => (map[s.id] = s.enabled));
    setApplied(map);
    setSelected(mode === "modus" ? presetFor(map, level) : { ...map });
    setInfo(inf);
  }
  useEffect(() => {
    load();
    api.detectGpu().then(setGpu).catch(() => {});
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  function pickMode(m: Mode) {
    setMode(m);
    setSelected(m === "modus" ? presetFor(applied, level) : { ...applied });
  }
  function setModus(l: number) {
    setLevel(l);
    setSelected(presetFor(applied, l));
  }
  function toggle(id: string) {
    setSelected((p) => ({ ...p, [id]: !p[id] }));
  }
  function toggleApp(id: string) {
    setAppsSel((p) => {
      const n = new Set(p);
      n.has(id) ? n.delete(id) : n.add(id);
      return n;
    });
  }
  function toggleDeep(id: string) {
    setDeep((p) => {
      const n = new Set(p);
      n.has(id) ? n.delete(id) : n.add(id);
      return n;
    });
  }
  function togglePurpose(p: Purpose) {
    const ids = purposeApps(p).map((a) => a.id);
    setAppsSel((prev) => {
      const n = new Set(prev);
      const allOn = ids.every((i) => n.has(i));
      ids.forEach((i) => (allOn ? n.delete(i) : n.add(i)));
      return n;
    });
  }

  const tweakChanges = useMemo(
    () =>
      TWEAKS.filter((tw) => {
        const sel = !!selected[tw.id];
        const app = !!applied[tw.id];
        return tw.oneWay ? sel && !app : sel !== app;
      }),
    [selected, applied],
  );

  const filteredApps = useMemo(() => {
    const q = search.trim().toLowerCase();
    if (!q) return APPS;
    return APPS.filter((a) => a.name.toLowerCase().includes(q) || a.desc[lang].toLowerCase().includes(q));
  }, [search, lang]);

  function buildQueue() {
    const q: { label: string; run: () => Promise<unknown> }[] = [];
    if (restore) q.push({ label: t("loading_restore"), run: () => api.createRestorePoint() });
    for (const tw of tweakChanges) {
      const sel = !!selected[tw.id];
      q.push({ label: `${t("loading_apply")}: ${tw.title[lang]}`, run: () => api.setTweak(tw.id, sel) });
    }
    if (edge) q.push({ label: t("edge_title"), run: () => api.removeEdge() });
    if (powerPlan) q.push({ label: t("power_plan"), run: () => api.setPowerPlan(true) });
    if (cleanTemp) q.push({ label: t("clean_temp"), run: () => api.cleanTemp() });
    if (gpuDriver && gpu !== "unknown" && GPU[gpu]) q.push({ label: `${t("loading_install")} ${GPU[gpu].label}`, run: () => api.installApp(GPU[gpu].winget) });
    for (const a of ACTIONS) {
      if (deep.has(a.id)) q.push({ label: a.title[lang], run: () => api.applyAction(a.id) });
    }
    for (const a of APPS) {
      if (appsSel.has(a.id)) q.push({ label: `${t("loading_install")} ${a.name}`, run: () => api.installApp(a.winget) });
    }
    return q;
  }

  async function construct() {
    const q = buildQueue();
    setProg({ done: 0, total: q.length, label: q[0]?.label ?? "", errors: 0 });
    setPhase("loading");
    await win?.setFullscreen(true).catch(() => {});
    let errors = 0;
    for (let i = 0; i < q.length; i++) {
      setProg((p) => ({ ...p, label: q[i].label, done: i }));
      try {
        await q[i].run();
      } catch {
        errors++;
      }
    }
    setProg((p) => ({ ...p, done: q.length, errors }));
    await load().catch(() => {});
    await win?.setFullscreen(false).catch(() => {});
    setPhase("done");
  }

  const next = () => (stepKey === "review" ? construct() : setStepIdx((i) => Math.min(i + 1, flow.length - 1)));
  const back = () => setStepIdx((i) => Math.max(i - 1, 0));

  function renderTweakCats(cats: Cat[]) {
    let n = 0;
    return (
      <div className="space-y-7">
        {cats.map((cat) => (
          <div key={cat}>
            <h4 className="mb-3 ml-1 text-[11px] font-semibold uppercase tracking-[0.14em] text-white/40">{t(`cat_${cat}`)}</h4>
            <div className="grid grid-cols-1 gap-3 md:grid-cols-2">
              {TWEAKS.filter((tw) => tw.cat === cat).map((tw) => (
                <TweakCard key={tw.id} meta={tw} i={n++} selected={!!selected[tw.id]} applied={!!applied[tw.id]} onToggle={() => toggle(tw.id)} />
              ))}
            </div>
          </div>
        ))}
      </div>
    );
  }

  function StepBody() {
    switch (stepKey) {
      case "welcome":
        return (
          <div className="flex h-full flex-col items-center justify-center px-10 text-center">
            <motion.div
              initial={{ scale: 0, rotate: -90 }}
              animate={{ scale: 1, rotate: 0 }}
              transition={{ type: "spring", stiffness: 200, damping: 14 }}
              className="pulse-ring mb-9 grid h-24 w-24 place-items-center rounded-full border-2 border-[#22e06b]/60"
            >
              <Radiation size={46} className="text-[#22e06b]" />
            </motion.div>
            <motion.h1 initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.15 }} className="text-5xl font-black tracking-tight">
              {t("welcome_title")}
            </motion.h1>
            <motion.div initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.25 }} className="mt-11 w-64">
              <Dropdown value={lang} onChange={(v) => setLang(v as typeof lang)} options={LANGS.map((l) => ({ value: l.code, label: l.label }))} />
            </motion.div>
            <motion.button
              initial={{ opacity: 0, y: 12 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.35 }}
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.97 }}
              onClick={next}
              className="grad-fill glow-green mt-6 rounded-xl px-9 py-3 text-sm font-bold text-black"
            >
              {t("next")} →
            </motion.button>
          </div>
        );
      case "hardware":
        return (
          <>
            <Header title={t("hw_title")} sub={t("hw_sub")} />
            <div className="grid grid-cols-1 gap-3 md:grid-cols-2">
              {TWEAKS.filter((tw) => tw.cat === "hardware").map((tw, i) => (
                <TweakCard key={tw.id} meta={tw} i={i} selected={!!selected[tw.id]} applied={!!applied[tw.id]} onToggle={() => toggle(tw.id)} />
              ))}
            </div>
          </>
        );
      case "mode":
        return (
          <>
            <Header title={t("mode_title")} sub={t("mode_sub")} />
            <div className="flex gap-4">
              <ModeCard active={mode === "modus"} onClick={() => pickMode("modus")} icon={Sparkles} title={t("mode_modus")} desc={t("mode_modus_d")} />
              <ModeCard active={mode === "custom"} onClick={() => pickMode("custom")} icon={Gem} title={t("mode_custom")} desc={t("mode_custom_d")} />
            </div>
          </>
        );
      case "modus":
        return (
          <>
            <Header title={t("modus_title")} sub={t("modus_sub")} />
            <div className="glass rounded-3xl p-8">
              <ModusSlider level={level} onChange={setModus} />
            </div>
          </>
        );
      case "tweaks":
        return (
          <>
            <Header title={t("tweaks_title")} sub={t("tweaks_sub")} />
            {renderTweakCats(["performance", "appearance", "taskbar", "privacy", "debloat"])}
          </>
        );
      case "apps":
        return (
          <>
            <Header title={t("apps_title")} sub={t("apps_sub")} />
            <div className="relative mb-5">
              <Search size={16} className="pointer-events-none absolute left-3.5 top-1/2 -translate-y-1/2 text-white/40" />
              <input
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder={t("search_apps")}
                className="glass-soft w-full rounded-xl py-2.5 pl-10 pr-4 text-sm text-white outline-none placeholder:text-white/35 focus:border-[#22e06b]/40"
              />
            </div>
            {!search && (
              <div className="mb-5 flex flex-wrap gap-2">
                {PURPOSES.map((p) => {
                  const ids = purposeApps(p).map((a) => a.id);
                  const allOn = ids.length > 0 && ids.every((i) => appsSel.has(i));
                  return (
                    <button
                      key={p}
                      onClick={() => togglePurpose(p)}
                      className={`rounded-full px-4 py-2 text-xs font-semibold transition-colors ${allOn ? "grad-fill text-black" : "glass-soft text-white/70 hover:text-white"}`}
                    >
                      {t(`purpose_${p}`)}
                    </button>
                  );
                })}
              </div>
            )}

            {!search && (
              <button
                onClick={() => setEdge((v) => !v)}
                className={`mb-4 flex w-full items-center gap-3.5 rounded-2xl border p-3.5 text-left transition-colors ${edge ? "border-[#ff4d6d]/50 bg-[#ff4d6d]/[0.08]" : "border-white/10 bg-white/[0.035] hover:bg-white/[0.06]"}`}
              >
                <div className={`grid h-10 w-10 shrink-0 place-items-center rounded-xl ${edge ? "bg-[#ff4d6d]/20 text-[#ff708a]" : "bg-white/[0.06] text-white/55"}`}>
                  <Trash2 size={18} />
                </div>
                <div className="min-w-0 flex-1">
                  <div className="flex items-center gap-2">
                    <p className="text-sm font-semibold">{t("edge_title")}</p>
                    <span className="rounded-full bg-[#ff4d6d]/15 px-2 py-0.5 text-[10px] font-bold uppercase tracking-wide text-[#ff708a]">{t("edge_badge")}</span>
                  </div>
                  <p className="mt-0.5 text-[11.5px] text-white/45">{t("edge_d")}</p>
                </div>
                <span className={`grid h-5 w-5 shrink-0 place-items-center rounded-md border ${edge ? "border-transparent bg-[#ff4d6d]" : "border-white/15"}`}>
                  {edge && <Check size={13} className="text-black" />}
                </span>
              </button>
            )}

            {!search && (
              <div className="mb-5">
                <p className="mb-3 ml-1 text-[11px] font-semibold uppercase tracking-[0.14em] text-white/40">{t("boost_title")}</p>
                <div className="grid grid-cols-1 gap-3 md:grid-cols-2">
                  <BoostCard icon={Gauge} title={t("power_plan")} desc={t("power_plan_d")} on={powerPlan} onToggle={() => setPowerPlan((v) => !v)} />
                  <BoostCard icon={Trash2} title={t("clean_temp")} desc={t("clean_temp_d")} on={cleanTemp} onToggle={() => setCleanTemp((v) => !v)} />
                  <BoostCard
                    icon={Cpu}
                    title={gpu !== "unknown" && GPU[gpu] ? t("gpu_driver").replace("{v}", GPU[gpu].label) : t("gpu_none")}
                    desc={t("gpu_driver_d")}
                    on={gpuDriver}
                    onToggle={() => setGpuDriver((v) => !v)}
                    disabled={gpu === "unknown"}
                  />
                </div>
              </div>
            )}

            {!search && (
              <div className="mb-5">
                <p className="mb-3 ml-1 text-[11px] font-semibold uppercase tracking-[0.14em] text-white/40">{t("deep_title")}</p>
                <div className="grid grid-cols-1 gap-3 md:grid-cols-2">
                  {ACTIONS.map((a) => (
                    <BoostCard key={a.id} icon={a.icon} title={a.title[lang]} desc={a.desc[lang]} on={deep.has(a.id)} onToggle={() => toggleDeep(a.id)} />
                  ))}
                </div>
              </div>
            )}

            {filteredApps.length === 0 ? (
              <p className="py-10 text-center text-sm text-white/35">{t("no_results")}</p>
            ) : (
              <div className="grid grid-cols-1 gap-3 md:grid-cols-2">
                {filteredApps.map((a, i) => (
                  <AppCard key={a.id} app={a} i={i} selected={appsSel.has(a.id)} onToggle={() => toggleApp(a.id)} />
                ))}
              </div>
            )}
          </>
        );
      case "review":
        return (
          <>
            <Header title={t("review_title")} sub={t("review_sub")} />
            <div className="space-y-3">
              <button
                onClick={() => setRestore((v) => !v)}
                className={`glass-soft flex w-full items-center gap-4 rounded-2xl p-4 text-left ${restore ? "border-[#22e06b]/50" : ""}`}
              >
                <div className={`grid h-11 w-11 shrink-0 place-items-center rounded-xl ${restore ? "grad-chip text-white" : "bg-white/[0.06] text-white/55"}`}>
                  <History size={20} />
                </div>
                <div className="flex-1">
                  <div className="flex items-center gap-2">
                    <p className="text-[15px] font-semibold">{t("review_restore")}</p>
                    <span className="rounded-full bg-[#22e06b]/15 px-2 py-0.5 text-[10px] font-bold uppercase tracking-wide text-[#2bed6f]">{t("recommended")}</span>
                  </div>
                  <p className="mt-0.5 text-[12.5px] text-white/45">{t("review_restore_d")}</p>
                </div>
                <span className={`grid h-6 w-6 shrink-0 place-items-center rounded-md border ${restore ? "grad-fill border-transparent" : "border-white/15"}`}>
                  {restore && <Check size={14} className="text-black" />}
                </span>
              </button>

              <div className="grid grid-cols-2 gap-3">
                <div className="glass-soft rounded-2xl p-4">
                  <p className="text-3xl font-black text-[#2bed6f]">{tweakChanges.length + (edge ? 1 : 0)}</p>
                  <p className="mt-1 text-xs text-white/45">{t("review_tweaks")}</p>
                </div>
                <div className="glass-soft rounded-2xl p-4">
                  <p className="text-3xl font-black text-[#2bed6f]">{appsSel.size}</p>
                  <p className="mt-1 text-xs text-white/45">{t("review_apps")}</p>
                </div>
              </div>

              {info && !info.elevated && (
                <button
                  onClick={() => api.relaunchAsAdmin()}
                  className="flex w-full items-center gap-2 rounded-2xl border border-amber-400/20 bg-amber-400/[0.07] p-3.5 text-sm text-amber-200/90 transition-colors hover:bg-amber-400/15"
                >
                  <ShieldAlert size={17} className="shrink-0" />
                  <span className="flex-1 text-left">{t("admin_warn")}</span>
                  <span className="shrink-0 text-xs font-semibold">{t("run_admin")} →</span>
                </button>
              )}
            </div>
          </>
        );
      default:
        return null;
    }
  }

  if (phase === "loading") {
    const pct = prog.total ? Math.round((prog.done / prog.total) * 100) : 0;
    return (
      <Shell>
        <div className="flex h-full flex-col items-center justify-center px-12 text-center">
          <motion.div animate={{ rotate: 360 }} transition={{ duration: 5, repeat: Infinity, ease: "linear" }} className="mb-9 grid h-28 w-28 place-items-center rounded-full border-2 border-[#22e06b]/50 glow-green">
            <Radiation size={56} className="text-[#22e06b]" />
          </motion.div>
          <h1 className="text-3xl font-black tracking-tight">{t("loading_title")}</h1>
          <p className="mt-2 text-sm text-white/40">{t("loading_wait")}</p>
          <div className="mt-9 w-full max-w-md">
            <div className="mb-2 flex items-center justify-between text-xs">
              <span className="truncate pr-3 text-white/70">{prog.label}</span>
              <span className="shrink-0 font-semibold text-[#2bed6f]">{prog.done}/{prog.total}</span>
            </div>
            <div className="h-2 w-full overflow-hidden rounded-full bg-white/10">
              <motion.div className="grad-fill h-full rounded-full" animate={{ width: `${pct}%` }} transition={{ duration: 0.3 }} />
            </div>
          </div>
        </div>
      </Shell>
    );
  }

  if (phase === "done") {
    return (
      <Shell>
        <div className="flex h-full flex-col items-center justify-center px-12 text-center">
          <motion.div initial={{ scale: 0 }} animate={{ scale: 1 }} transition={{ type: "spring", stiffness: 300, damping: 16 }} className="grad-fill glow-green mb-8 grid h-24 w-24 place-items-center rounded-full">
            <Check size={52} className="text-black" />
          </motion.div>
          <h1 className="text-4xl font-black tracking-tight">{t("done_title")}</h1>
          <p className="mt-2 text-sm text-white/45">{t("done_sub")}</p>
          <p className="mt-5 text-sm text-white/60">
            <b className="text-[#2bed6f]">{prog.total - prog.errors}</b> {t("steps_done")}
            {prog.errors > 0 && <> · <b className="text-[#ff4d6d]">{prog.errors}</b> {t("steps_failed")}</>}
          </p>
          <div className="mt-9 flex flex-wrap items-center justify-center gap-3">
            <button onClick={() => api.restartExplorer()} className="glass-soft flex items-center gap-2 rounded-xl px-4 py-2.5 text-sm font-medium text-white/80 transition-colors hover:bg-white/10">
              <RotateCcw size={15} /> {t("restart_explorer")}
            </button>
            <button onClick={() => (win ? win.close() : window.location.reload())} className="glass-soft flex items-center gap-2 rounded-xl px-5 py-2.5 text-sm font-semibold text-white/80 transition-colors hover:bg-white/10">
              {t("finish")}
            </button>
            <motion.button
              onClick={() => (arm ? api.restartPc() : (setArm(true), setTimeout(() => setArm(false), 4000)))}
              animate={arm ? { scale: [1, 1.04, 1] } : { scale: 1 }}
              transition={arm ? { duration: 1, repeat: Infinity } : {}}
              className={`flex items-center gap-2 rounded-xl px-5 py-2.5 text-sm font-bold transition-colors ${arm ? "bg-[#ff4d6d] text-white" : "grad-fill glow-green text-black"}`}
            >
              <Power size={15} /> {arm ? t("restart_pc_confirm") : t("restart_pc")}
            </motion.button>
          </div>
        </div>
      </Shell>
    );
  }

  return (
    <Shell>
      <TitleBar />
      <div className="relative flex-1 overflow-y-auto px-10 py-6">
        <AnimatePresence mode="wait">
          <motion.div
            key={stepKey}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
            transition={{ duration: 0.2 }}
            className={stepKey === "welcome" ? "h-full" : ""}
          >
            <StepBody />
          </motion.div>
        </AnimatePresence>
      </div>

      {stepKey !== "welcome" && (
        <div className="flex shrink-0 items-center justify-between px-10 py-5">
          <motion.button whileHover={{ scale: 1.04 }} whileTap={{ scale: 0.97 }} onClick={back} className="glass-soft rounded-xl px-5 py-2.5 text-sm font-semibold text-white/75 transition-colors hover:text-white">
            ← {t("back")}
          </motion.button>
          <motion.button
            whileHover={{ scale: 1.04 }}
            whileTap={{ scale: 0.97 }}
            onClick={next}
            className="grad-fill glow-green flex items-center gap-2 rounded-xl px-7 py-2.5 text-sm font-bold text-black"
          >
            {stepKey === "review" ? (
              <>
                <Radiation size={16} /> {t("construct")}
              </>
            ) : (
              <>{t("next")} →</>
            )}
          </motion.button>
        </div>
      )}
    </Shell>
  );
}

function Shell({ children }: { children: ReactNode }) {
  return (
    <div
      className="relative flex h-screen w-screen flex-col overflow-hidden rounded-[14px]"
      style={{ background: "linear-gradient(160deg, rgba(9,13,11,0.93), rgba(6,9,7,0.96))" }}
    >
      <Background />
      <div className="relative z-10 flex h-full flex-col">{children}</div>
    </div>
  );
}

export default function App() {
  return (
    <I18nProvider>
      <AppInner />
    </I18nProvider>
  );
}
