import {
  Gamepad2,
  Joystick,
  MessageCircle,
  Globe,
  Shield,
  Flame,
  Compass,
  Video,
  Image,
  Music,
  Box,
  Brush,
  Camera,
  Code2,
  GitBranch,
  Wrench,
  Hexagon,
  Terminal,
  SquareTerminal,
  MessageSquare,
  Send,
  Archive,
  FileText,
  Search,
  Download,
  Play,
  Music2,
  FileArchive,
  Gauge,
  Boxes,
  Users,
  Cpu,
  Thermometer,
  HardDrive,
  PieChart,
  ShieldCheck,
  Sparkles,
  Rocket,
} from "lucide-react";
import type { LucideIcon } from "lucide-react";
import type { Lang } from "../i18n";

export type Purpose = "gaming" | "browsers" | "creator" | "developer" | "gamedev" | "communication" | "utilities";
export const PURPOSES: Purpose[] = ["gaming", "browsers", "creator", "developer", "gamedev", "communication", "utilities"];

export interface AppItem {
  id: string;
  winget: string;
  name: string;
  purpose: Purpose;
  always?: boolean;
  icon: LucideIcon;
  desc: Record<Lang, string>;
}

const d = (en: string, de: string, tr: string): Record<Lang, string> => ({ en, de, tr });

export const APPS: AppItem[] = [
  // 🎮 gaming
  { id: "steam", winget: "Valve.Steam", name: "Steam", purpose: "gaming", icon: Gamepad2, desc: d("Game store & launcher", "Spiele-Store & Launcher", "Oyun mağazası") },
  { id: "epic", winget: "EpicGames.EpicGamesLauncher", name: "Epic Games", purpose: "gaming", icon: Joystick, desc: d("Epic Games launcher", "Epic-Games-Launcher", "Epic Games başlatıcı") },
  { id: "gog", winget: "GOG.Galaxy", name: "GOG Galaxy", purpose: "gaming", icon: Gamepad2, desc: d("DRM-free launcher", "DRM-freier Launcher", "DRM'siz başlatıcı") },
  { id: "ubisoft", winget: "Ubisoft.Connect", name: "Ubisoft Connect", purpose: "gaming", icon: Gamepad2, desc: d("Ubisoft launcher", "Ubisoft-Launcher", "Ubisoft başlatıcı") },
  { id: "ea", winget: "ElectronicArts.EADesktop", name: "EA App", purpose: "gaming", icon: Gamepad2, desc: d("EA games launcher", "EA-Games-Launcher", "EA başlatıcı") },

  // 🌐 browsers
  { id: "firefox", winget: "Mozilla.Firefox", name: "Firefox", purpose: "browsers", icon: Flame, desc: d("Open-source browser", "Open-Source-Browser", "Açık kaynak tarayıcı") },
  { id: "chrome", winget: "Google.Chrome", name: "Chrome", purpose: "browsers", icon: Globe, desc: d("Google's web browser", "Googles Webbrowser", "Google web tarayıcı") },
  { id: "tor", winget: "TorProject.TorBrowser", name: "Tor Browser", purpose: "browsers", icon: Shield, desc: d("Anonymous browsing", "Anonymes Surfen", "Anonim tarama") },
  { id: "brave", winget: "Brave.Brave", name: "Brave", purpose: "browsers", icon: Globe, desc: d("Private, ad-blocking browser", "Privater Browser mit Adblock", "Reklamsız gizli tarayıcı") },
  { id: "opera", winget: "Opera.Opera", name: "Opera", purpose: "browsers", icon: Globe, desc: d("Feature-rich browser", "Funktionsreicher Browser", "Zengin özellikli tarayıcı") },
  { id: "vivaldi", winget: "Vivaldi.Vivaldi", name: "Vivaldi", purpose: "browsers", icon: Compass, desc: d("Highly customizable browser", "Anpassbarer Browser", "Özelleştirilebilir tarayıcı") },

  // 🎬 creator
  { id: "obs", winget: "OBSProject.OBSStudio", name: "OBS Studio", purpose: "creator", icon: Video, desc: d("Streaming & recording", "Streaming & Aufnahme", "Yayın & kayıt") },
  { id: "gimp", winget: "GIMP.GIMP", name: "GIMP", purpose: "creator", icon: Image, desc: d("Image editor", "Bildbearbeitung", "Görüntü düzenleyici") },
  { id: "krita", winget: "KDE.Krita", name: "Krita", purpose: "creator", icon: Brush, desc: d("Digital painting", "Digitales Malen", "Dijital boyama") },
  { id: "audacity", winget: "Audacity.Audacity", name: "Audacity", purpose: "creator", icon: Music, desc: d("Audio editor", "Audio-Editor", "Ses düzenleyici") },
  { id: "blender", winget: "BlenderFoundation.Blender", name: "Blender", purpose: "creator", icon: Box, desc: d("3D creation suite", "3D-Software", "3D yazılımı") },
  { id: "sharex", winget: "ShareX.ShareX", name: "ShareX", purpose: "creator", icon: Camera, desc: d("Screenshots & capture", "Screenshots & Aufnahme", "Ekran görüntüsü") },

  // 💻 developer
  { id: "vscode", winget: "Microsoft.VisualStudioCode", name: "VS Code", purpose: "developer", icon: Code2, desc: d("Code editor", "Code-Editor", "Kod düzenleyici") },
  { id: "git", winget: "Git.Git", name: "Git", purpose: "developer", icon: GitBranch, desc: d("Version control", "Versionskontrolle", "Sürüm kontrolü") },
  { id: "nodejs", winget: "OpenJS.NodeJS", name: "Node.js", purpose: "developer", icon: Hexagon, desc: d("JavaScript runtime", "JavaScript-Runtime", "JavaScript çalışma zamanı") },
  { id: "python", winget: "Python.Python.3.12", name: "Python", purpose: "developer", icon: Terminal, desc: d("Python 3.12", "Python 3.12", "Python 3.12") },
  { id: "terminal", winget: "Microsoft.WindowsTerminal", name: "Windows Terminal", purpose: "developer", icon: SquareTerminal, desc: d("Modern terminal", "Modernes Terminal", "Modern terminal") },
  { id: "powertoys", winget: "Microsoft.PowerToys", name: "PowerToys", purpose: "developer", icon: Wrench, desc: d("Windows power utilities", "Windows-Power-Tools", "Windows güç araçları") },
  { id: "claude", winget: "Anthropic.Claude", name: "Claude", purpose: "developer", icon: Sparkles, desc: d("Anthropic AI desktop app", "Anthropic-KI-Desktop-App", "Anthropic YZ masaüstü uygulaması") },
  { id: "claudecode", winget: "Anthropic.ClaudeCode", name: "Claude Code", purpose: "developer", icon: Terminal, desc: d("Agentic coding in your terminal", "Agentisches Coden im Terminal", "Terminalde ajan tabanlı kodlama") },
  { id: "antigravity", winget: "Google.Antigravity", name: "Antigravity", purpose: "developer", icon: Rocket, desc: d("Google's agentic AI IDE", "Googles agentische KI-IDE", "Google'ın ajan tabanlı YZ IDE'si") },
  { id: "vscommunity", winget: "Microsoft.VisualStudio.2022.Community", name: "Visual Studio", purpose: "developer", icon: Code2, desc: d("Full IDE (C#, C++, game dev)", "Voll-IDE (C#, C++, Game Dev)", "Tam IDE (C#, C++, oyun)") },

  // 🕹️ game dev
  { id: "godot", winget: "GodotEngine.GodotEngine", name: "Godot Engine", purpose: "gamedev", icon: Joystick, desc: d("Open-source game engine", "Open-Source-Spiel-Engine", "Açık kaynak oyun motoru") },
  { id: "unityhub", winget: "Unity.UnityHub", name: "Unity Hub", purpose: "gamedev", icon: Boxes, desc: d("Manage Unity engine versions", "Unity-Engine-Versionen verwalten", "Unity sürümlerini yönet") },
  { id: "blenderdev", winget: "BlenderFoundation.Blender", name: "Blender", purpose: "gamedev", icon: Box, desc: d("3D modeling for games", "3D-Modellierung für Spiele", "Oyunlar için 3D modelleme") },

  // 💬 communication
  { id: "discord", winget: "Discord.Discord", name: "Discord", purpose: "communication", icon: MessageCircle, desc: d("Voice & chat", "Voice & Chat", "Sesli & sohbet") },
  { id: "zoom", winget: "Zoom.Zoom", name: "Zoom", purpose: "communication", icon: Video, desc: d("Video meetings", "Videokonferenzen", "Görüntülü toplantı") },
  { id: "slack", winget: "SlackTechnologies.Slack", name: "Slack", purpose: "communication", icon: MessageSquare, desc: d("Team chat", "Team-Chat", "Ekip sohbeti") },
  { id: "telegram", winget: "Telegram.TelegramDesktop", name: "Telegram", purpose: "communication", icon: Send, desc: d("Messaging app", "Messaging-App", "Mesajlaşma") },

  // 🛠️ utilities
  { id: "sevenzip", winget: "7zip.7zip", name: "7-Zip", purpose: "utilities", icon: Archive, desc: d("Free archive tool", "Gratis Archiv-Tool", "Ücretsiz arşiv aracı") },
  { id: "notepadpp", winget: "Notepad++.Notepad++", name: "Notepad++", purpose: "utilities", icon: FileText, desc: d("Text & code editor", "Text- & Code-Editor", "Metin düzenleyici") },
  { id: "everything", winget: "voidtools.Everything", name: "Everything", purpose: "utilities", icon: Search, desc: d("Instant file search", "Sofortige Dateisuche", "Anında dosya arama") },
  { id: "qbittorrent", winget: "qBittorrent.qBittorrent", name: "qBittorrent", purpose: "utilities", icon: Download, desc: d("Torrent client", "Torrent-Client", "Torrent istemcisi") },
  { id: "vlc", winget: "VideoLAN.VLC", name: "VLC", purpose: "utilities", icon: Play, desc: d("Plays any media", "Spielt jede Mediendatei", "Her medyayı oynatır") },
  { id: "spotify", winget: "Spotify.Spotify", name: "Spotify", purpose: "utilities", icon: Music2, desc: d("Music streaming", "Musik-Streaming", "Müzik akışı") },

  { id: "afterburner", winget: "Guru3D.Afterburner", name: "MSI Afterburner", purpose: "gaming", icon: Gauge, desc: d("GPU overclock & monitor", "GPU übertakten & überwachen", "GPU hız aşırtma & izleme") },
  { id: "docker", winget: "Docker.DockerDesktop", name: "Docker Desktop", purpose: "developer", icon: Boxes, desc: d("Containers for development", "Container für Entwicklung", "Geliştirme için konteyner") },
  { id: "signal", winget: "OpenWhisperSystems.Signal", name: "Signal", purpose: "communication", icon: MessageSquare, desc: d("Private messenger", "Privater Messenger", "Gizli mesajlaşma") },
  { id: "teams", winget: "Microsoft.Teams", name: "Microsoft Teams", purpose: "communication", icon: Users, desc: d("Work chat & calls", "Arbeits-Chat & Anrufe", "İş sohbeti & arama") },
  { id: "cpuz", winget: "CPUID.CPU-Z", name: "CPU-Z", purpose: "utilities", icon: Cpu, desc: d("Hardware info tool", "Hardware-Info-Tool", "Donanım bilgi aracı") },
  { id: "hwmonitor", winget: "CPUID.HWMonitor", name: "HWMonitor", purpose: "utilities", icon: Thermometer, desc: d("Temps & voltages", "Temperaturen & Spannungen", "Sıcaklık & voltaj") },
  { id: "crystaldisk", winget: "CrystalDewWorld.CrystalDiskInfo", name: "CrystalDiskInfo", purpose: "utilities", icon: HardDrive, desc: d("Disk health (S.M.A.R.T.)", "Festplatten-Gesundheit", "Disk sağlığı (S.M.A.R.T.)") },
  { id: "wiztree", winget: "AntibodySoftware.WizTree", name: "WizTree", purpose: "utilities", icon: PieChart, desc: d("Find what fills your disk", "Findet Speicherfresser", "Diski ne dolduruyor bul") },
  { id: "sumatra", winget: "SumatraPDF.SumatraPDF", name: "SumatraPDF", purpose: "utilities", icon: FileText, desc: d("Fast, light PDF reader", "Schneller, leichter PDF-Reader", "Hızlı, hafif PDF okuyucu") },
  { id: "libreoffice", winget: "TheDocumentFoundation.LibreOffice", name: "LibreOffice", purpose: "utilities", icon: FileText, desc: d("Free office suite", "Gratis Office-Suite", "Ücretsiz ofis paketi") },
  { id: "malwarebytes", winget: "Malwarebytes.Malwarebytes", name: "Malwarebytes", purpose: "utilities", icon: ShieldCheck, desc: d("Anti-malware scanner", "Anti-Malware-Scanner", "Kötü amaçlı yazılım tarayıcı") },

  // ☢️ always installed
  { id: "winrar", winget: "RARLab.WinRAR", name: "WinRAR", purpose: "utilities", always: true, icon: FileArchive, desc: d("The legendary archiver — installed every time.", "Der legendäre Archivierer — immer dabei.", "Efsanevi arşivleyici — her zaman kurulur.") },
];

export const ALWAYS_APPS = APPS.filter((a) => a.always);
export const purposeApps = (p: Purpose) => APPS.filter((a) => a.purpose === p && !a.always);
