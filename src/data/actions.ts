import { Snowflake, Database, Search, Activity, Network, Cloud } from "lucide-react";
import type { LucideIcon } from "lucide-react";
import type { Lang } from "../i18n";

export interface ActionItem {
  id: string;
  icon: LucideIcon;
  def: boolean; // default selected
  title: Record<Lang, string>;
  desc: Record<Lang, string>;
}

const d = (en: string, de: string, tr: string): Record<Lang, string> => ({ en, de, tr });

// One-shot "deep optimization" actions (mostly admin). Run via apply_action.
export const ACTIONS: ActionItem[] = [
  {
    id: "disable_diagtrack",
    icon: Activity,
    def: true,
    title: d("Kill Telemetry Service", "Telemetrie-Dienst killen", "Telemetri Hizmetini Kapat"),
    desc: d("Stop & disable the DiagTrack tracking service.", "DiagTrack-Tracking-Dienst stoppen & deaktivieren.", "DiagTrack izleme hizmetini durdur & devre dışı bırak."),
  },
  {
    id: "disable_sysmain",
    icon: Database,
    def: false,
    title: d("Disable SysMain", "SysMain deaktivieren", "SysMain'i Kapat"),
    desc: d("Stop Superfetch — helps on SSDs & low RAM.", "Superfetch stoppen — gut für SSD & wenig RAM.", "Superfetch'i durdur — SSD & az RAM için iyi."),
  },
  {
    id: "disable_search_index",
    icon: Search,
    def: false,
    title: d("Disable Search Indexing", "Suchindex deaktivieren", "Arama Dizinini Kapat"),
    desc: d("Stop the indexer for less disk & CPU load.", "Indexer für weniger Last stoppen.", "Daha az yük için dizinleyiciyi durdur."),
  },
  {
    id: "disable_hibernation",
    icon: Snowflake,
    def: false,
    title: d("Disable Hibernation", "Ruhezustand deaktivieren", "Hazırda Beklemeyi Kapat"),
    desc: d("Remove hiberfil.sys — frees several GB.", "hiberfil.sys entfernen — spart mehrere GB.", "hiberfil.sys'i kaldır — birkaç GB açar."),
  },
  {
    id: "flush_dns",
    icon: Network,
    def: false,
    title: d("Flush DNS Cache", "DNS-Cache leeren", "DNS Önbelleğini Temizle"),
    desc: d("Clear the DNS resolver cache.", "DNS-Resolver-Cache leeren.", "DNS çözümleyici önbelleğini temizle."),
  },
  {
    id: "disable_onedrive",
    icon: Cloud,
    def: false,
    title: d("Remove OneDrive", "OneDrive entfernen", "OneDrive'ı Kaldır"),
    desc: d("Uninstall Microsoft OneDrive completely.", "Microsoft OneDrive komplett deinstallieren.", "Microsoft OneDrive'ı tamamen kaldır."),
  },
];
