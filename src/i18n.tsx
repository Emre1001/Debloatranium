import { createContext, useContext, useState } from "react";
import type { ReactNode } from "react";

export type Lang = "en" | "de" | "tr";
export const LANGS: { code: Lang; label: string }[] = [
  { code: "en", label: "English US" },
  { code: "de", label: "Deutsch" },
  { code: "tr", label: "Türkçe" },
];

type Dict = Record<string, Record<Lang, string>>;

const dict: Dict = {
  // common
  next: { en: "Next", de: "Weiter", tr: "İleri" },
  back: { en: "Back", de: "Zurück", tr: "Geri" },
  finish: { en: "Finish", de: "Fertig", tr: "Bitir" },
  close: { en: "Close", de: "Schließen", tr: "Kapat" },
  recommended: { en: "Recommended", de: "Empfohlen", tr: "Önerilen" },
  always_label: { en: "Always", de: "Immer", tr: "Her zaman" },
  run_admin: { en: "Restart as Admin", de: "Als Admin neu starten", tr: "Yönetici olarak başlat" },
  admin_warn: {
    en: "Run as Administrator so every tweak can apply.",
    de: "Als Administrator starten, damit alle Tweaks greifen.",
    tr: "Tüm ayarların uygulanması için yönetici olarak çalıştır.",
  },

  // welcome
  welcome_title: { en: "Ultimate System Cleanup", de: "Ultimative System-Optimierung", tr: "Nihai Sistem Temizliği" },
  lang_label: { en: "Language", de: "Sprache", tr: "Dil" },

  // hardware
  hw_title: { en: "Hardware Configuration", de: "Hardware-Konfiguration", tr: "Donanım Yapılandırması" },
  hw_sub: {
    en: "Toggle services for your specific components.",
    de: "Dienste für deine Komponenten ein-/ausschalten.",
    tr: "Bileşenlerine göre hizmetleri aç/kapat.",
  },

  // mode
  mode_title: { en: "Optimization Mode", de: "Optimierungs-Modus", tr: "Optimizasyon Modu" },
  mode_sub: { en: "Choose your level of control.", de: "Wähle dein Kontrolllevel.", tr: "Kontrol seviyeni seç." },
  mode_modus: { en: "Modus", de: "Modus", tr: "Mod" },
  mode_modus_d: {
    en: "Optimized profiles with smooth level control.",
    de: "Optimierte Profile mit Stufen-Regler.",
    tr: "Kademe denetimli optimize profiller.",
  },
  mode_custom: { en: "Custom", de: "Eigen", tr: "Özel" },
  mode_custom_d: {
    en: "Total control over every single mini-setting.",
    de: "Volle Kontrolle über jede Einstellung.",
    tr: "Her mini ayar üzerinde tam kontrol.",
  },

  // modus slider
  modus_title: { en: "Construction Level", de: "Ausbaustufe", tr: "Yapı Seviyesi" },
  modus_sub: { en: "Slide to your desired level.", de: "Schiebe zur gewünschten Stufe.", tr: "İstediğin seviyeye kaydır." },
  modus_custom: { en: "Custom", de: "Eigen", tr: "Özel" },
  modus_minimal: { en: "Minimal", de: "Minimal", tr: "Minimal" },
  modus_balanced: { en: "Balanced", de: "Ausgewogen", tr: "Dengeli" },
  modus_aggressive: { en: "Aggressive", de: "Aggressiv", tr: "Agresif" },
  modus_zero: { en: "Zero", de: "Zero", tr: "Sıfır" },
  modus_d_custom: { en: "Hand-pick exactly what you want.", de: "Wähle genau, was du willst.", tr: "Tam istediğini seç." },
  modus_d_minimal: {
    en: "Safe essentials: dark mode, file extensions, left taskbar.",
    de: "Sichere Basics: Dark Mode, Dateiendungen, linke Taskleiste.",
    tr: "Güvenli temeller: koyu tema, dosya uzantıları, sol görev çubuğu.",
  },
  modus_d_balanced: {
    en: "Cleaner desktop: hide widgets, task view, Bing in search.",
    de: "Aufgeräumter Desktop: Widgets, Taskansicht & Bing aus.",
    tr: "Temiz masaüstü: widget, görev görünümü ve Bing kapalı.",
  },
  modus_d_aggressive: {
    en: "Privacy focus: kill telemetry, Copilot and search box.",
    de: "Privatsphäre: Telemetrie, Copilot & Suchfeld aus.",
    tr: "Gizlilik: telemetri, Copilot ve arama kutusu kapalı.",
  },
  modus_d_zero: {
    en: "Total purge: everything above + remove bloat apps.",
    de: "Komplett: alles oben + Bloat-Apps entfernen.",
    tr: "Tam temizlik: yukarıdakiler + şişkin uygulamaları kaldır.",
  },

  // tweaks (custom)
  tweaks_title: { en: "Manual Tweaks", de: "Manuelle Tweaks", tr: "Manuel Ayarlar" },
  tweaks_sub: { en: "Toggle every setting by hand.", de: "Jede Einstellung selbst schalten.", tr: "Her ayarı elle aç/kapat." },
  cat_hardware: { en: "Hardware", de: "Hardware", tr: "Donanım" },
  cat_appearance: { en: "Appearance", de: "Darstellung", tr: "Görünüm" },
  cat_taskbar: { en: "Taskbar & Explorer", de: "Taskleiste & Explorer", tr: "Görev Çubuğu" },
  cat_privacy: { en: "Privacy & AI", de: "Privatsphäre & KI", tr: "Gizlilik ve YZ" },
  cat_debloat: { en: "Remove Apps", de: "Apps entfernen", tr: "Uygulamaları Kaldır" },
  removed: { en: "Removed", de: "Entfernt", tr: "Kaldırıldı" },

  // apps
  apps_title: { en: "App Setup", de: "App-Einrichtung", tr: "Uygulama Kurulumu" },
  apps_sub: { en: "Install the software you actually use.", de: "Installiere die Software, die du nutzt.", tr: "Gerçekten kullandığın yazılımları kur." },
  apps_pick: { en: "Quick pick a purpose:", de: "Schnellwahl nach Zweck:", tr: "Amaca göre hızlı seç:" },
  purpose_gaming: { en: "Gaming", de: "Gaming", tr: "Oyun" },
  purpose_browsers: { en: "Browsers", de: "Browser", tr: "Tarayıcı" },
  purpose_creator: { en: "Creator", de: "Creator", tr: "İçerik" },
  purpose_developer: { en: "Developer", de: "Entwickler", tr: "Geliştirici" },
  purpose_communication: { en: "Communication", de: "Kommunikation", tr: "İletişim" },
  purpose_utilities: { en: "Utilities", de: "Werkzeuge", tr: "Araçlar" },
  search_apps: { en: "Search apps…", de: "Apps suchen…", tr: "Uygulama ara…" },
  no_results: { en: "No apps found", de: "Keine Apps gefunden", tr: "Uygulama bulunamadı" },
  edge_title: { en: "Remove Microsoft Edge", de: "Microsoft Edge entfernen", tr: "Microsoft Edge'i Kaldır" },
  edge_d: {
    en: "Experimental — uninstalls Edge. Windows Update may restore it.",
    de: "Experimentell — deinstalliert Edge. Windows Update kann es zurückbringen.",
    tr: "Deneysel — Edge'i kaldırır. Windows Update geri yükleyebilir.",
  },
  edge_badge: { en: "Risky", de: "Riskant", tr: "Riskli" },
  restart_pc: { en: "Restart PC", de: "PC neu starten", tr: "PC'yi yeniden başlat" },
  restart_pc_confirm: { en: "Click again to reboot", de: "Nochmal klicken — Neustart", tr: "Tekrar tıkla — yeniden başlat" },
  cat_performance: { en: "Performance", de: "Leistung", tr: "Performans" },
  boost_title: { en: "System Boost", de: "System-Boost", tr: "Sistem Hızlandırma" },
  power_plan: { en: "High Performance Power Plan", de: "Höchstleistungs-Energieplan", tr: "Yüksek Performans Güç Planı" },
  power_plan_d: { en: "Switch Windows to the High Performance power plan.", de: "Windows auf Höchstleistung umstellen.", tr: "Windows'u yüksek performansa al." },
  clean_temp: { en: "Clean Temp Files", de: "Temp-Dateien löschen", tr: "Geçici Dosyaları Temizle" },
  clean_temp_d: { en: "Delete temporary junk files to free space.", de: "Temporäre Müll-Dateien löschen.", tr: "Geçici çöp dosyalarını sil." },
  gpu_driver: { en: "Install latest {v} driver", de: "Neuesten {v}-Treiber installieren", tr: "En son {v} sürücüsünü kur" },
  gpu_driver_d: { en: "Auto-detected GPU — installs the official driver app.", de: "GPU erkannt — installiert die offizielle Treiber-App.", tr: "GPU algılandı — resmi sürücü uygulamasını kurar." },
  gpu_none: { en: "No dedicated GPU detected", de: "Keine dedizierte GPU erkannt", tr: "Özel GPU algılanmadı" },
  deep_title: { en: "Deep Optimization", de: "Tiefen-Optimierung", tr: "Derin Optimizasyon" },

  // review
  review_title: { en: "Review & Construct", de: "Prüfen & Konstruieren", tr: "Gözden Geçir & Kur" },
  review_sub: { en: "Final check before we build your system.", de: "Letzter Check vor dem Umbau.", tr: "Sistemini kurmadan önce son kontrol." },
  review_restore: { en: "System Restore Point", de: "Systemwiederherstellungspunkt", tr: "Sistem Geri Yükleme Noktası" },
  review_restore_d: {
    en: "Create a safety snapshot before any changes.",
    de: "Sicherheits-Snapshot vor allen Änderungen anlegen.",
    tr: "Değişikliklerden önce güvenlik anlık görüntüsü oluştur.",
  },
  review_tweaks: { en: "System tweaks", de: "System-Tweaks", tr: "Sistem ayarları" },
  review_apps: { en: "App installs", de: "App-Installationen", tr: "Uygulama kurulumları" },
  construct: { en: "Construct", de: "Konstruieren", tr: "Kur" },

  // loading
  loading_title: { en: "Constructing your system", de: "System wird konstruiert", tr: "Sistemin kuruluyor" },
  loading_wait: { en: "This can take a few minutes. Keep the window open.", de: "Das kann ein paar Minuten dauern. Fenster offen lassen.", tr: "Bu birkaç dakika sürebilir. Pencereyi açık tut." },
  loading_restore: { en: "Creating restore point", de: "Wiederherstellungspunkt wird erstellt", tr: "Geri yükleme noktası oluşturuluyor" },
  loading_apply: { en: "Applying", de: "Anwenden", tr: "Uygulanıyor" },
  loading_install: { en: "Installing", de: "Installiere", tr: "Kuruluyor" },

  // done
  done_title: { en: "Construction Complete", de: "Konstruktion abgeschlossen", tr: "Kurulum Tamamlandı" },
  done_sub: { en: "Your system has been optimized.", de: "Dein System wurde optimiert.", tr: "Sistemin optimize edildi." },
  steps_done: { en: "steps completed", de: "Schritte erledigt", tr: "adım tamamlandı" },
  steps_failed: { en: "failed", de: "fehlgeschlagen", tr: "başarısız" },
  restart_explorer: { en: "Restart Explorer", de: "Explorer neu starten", tr: "Explorer'ı yeniden başlat" },
};

interface I18n {
  lang: Lang;
  setLang: (l: Lang) => void;
  t: (k: string) => string;
}
const Ctx = createContext<I18n>(null!);

export function I18nProvider({ children }: { children: ReactNode }) {
  const [lang, setLang] = useState<Lang>("en");
  const t = (k: string) => dict[k]?.[lang] ?? k;
  return <Ctx.Provider value={{ lang, setLang, t }}>{children}</Ctx.Provider>;
}

export const useI18n = () => useContext(Ctx);
