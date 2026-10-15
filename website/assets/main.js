/* ==========================================================================
   Debloatranium — website behaviour. No dependencies.
   ========================================================================== */
(() => {
  "use strict";

  const $ = (s, r = document) => r.querySelector(s);
  const $$ = (s, r = document) => Array.from(r.querySelectorAll(s));
  const clamp = (v, a = 0, b = 1) => Math.min(b, Math.max(a, v));
  const lerp = (a, b, t) => a + (b - a) * t;
  const easeOut = (t) => 1 - Math.pow(1 - t, 4);
  const pad = (n, l = 2) => String(n).padStart(l, "0");
  const REDUCED = matchMedia("(prefers-reduced-motion: reduce)").matches;
  const store = {
    get(k) { try { return localStorage.getItem(k); } catch { return null; } },
    set(k, v) { try { localStorage.setItem(k, v); } catch {} },
    sget(k) { try { return sessionStorage.getItem(k); } catch { return null; } },
    sset(k, v) { try { sessionStorage.setItem(k, v); } catch {} },
  };

  const TWEAKS = window.DR_TWEAKS || [];
  const APPS = window.DR_APPS || [];
  const LANGS = ["en", "de", "tr"];
  const LI = { en: 0, de: 1, tr: 2 };

  /* ------------------------------------------------------------------ i18n */
  // English lives in the HTML; captured on boot. Here: de + tr, plus keys only used from JS.
  const DICT = {
    nav_levels: { de: "Stufen", tr: "Seviyeler" },
    nav_process: { de: "Ablauf", tr: "Süreç" },
    nav_spec: { de: "Datenblatt", tr: "Özellikler" },
    nav_apps: { de: "Apps", tr: "Uygulamalar" },
    nav_dl: { de: "Download", tr: "İndir" },
    hero_tag: { de: "Windows-Optimierer · Kostenlos &amp; Open Source", tr: "Windows optimize aracı · Ücretsiz &amp; açık kaynak" },
    h1_a: { de: "Windows,", tr: "Windows," },
    h1_b: { de: "ohne", tr: "eksi" },
    h1_c: { de: "Ballast.", tr: "şişkinlik." },
    hero_lead: {
      de: "Debloatranium entfernt Telemetrie, Werbung, Copilot und vorinstallierten Müll aus Windows&nbsp;10 &amp; 11 und installiert danach die Software, die du wirklich nutzt. Ein Assistent. Ein Regler. Ein Klick.",
      tr: "Debloatranium; telemetriyi, reklamları, Copilot'u ve önceden yüklü gereksiz uygulamaları Windows&nbsp;10 ve 11'den temizler, ardından gerçekten kullandığın yazılımları kurar. Tek sihirbaz. Tek kaydırıcı. Tek tık.",
    },
    cta_dl: { de: "Für Windows herunterladen", tr: "Windows için indir" },
    cta_gh: { de: "Quellcode auf GitHub", tr: "GitHub'da kaynak kod" },
    el_half: { de: "Halbwertszeit von Bloat", tr: "Şişkinliğin yarı ömrü" },
    el_cap: { de: "Abb. 0 — Element-Kachel, Originalgröße: 8&nbsp;MB", tr: "Şekil 0 — Element kartı, gerçek boyut: 8&nbsp;MB" },
    st_size: { de: "Größe", tr: "Boyut" },
    st_ram: { de: "Arbeitsspeicher", tr: "Bellek" },
    st_tweaks: { de: "Tweaks", tr: "Ayar" },
    st_apps: { de: "Apps", tr: "Uygulama" },
    st_price: { de: "Preis", tr: "Fiyat" },
    st_label: { de: "Das Problem", tr: "Sorun" },
    statement: {
      de: "Windows kommt mit Copilot, Bing im Startmenü, Werbung auf dem Sperrbildschirm, Telemetrie im Hintergrund und einem Dutzend Apps, die niemand bestellt hat. <em>Debloatranium holt dir deinen PC zurück. Mit einem Regler.</em>",
      tr: "Windows; Copilot, Başlat menüsünde Bing, kilit ekranında reklamlar, arka planda çalışan telemetri ve kimsenin istemediği bir düzine uygulamayla gelir. <em>Debloatranium bilgisayarını sana geri verir. Tek kaydırmayla.</em>",
    },
    lv_label: { de: "Ausbaustufen", tr: "Yapı seviyeleri" },
    lv_title: { de: "Wähle, wie tief es&nbsp;geht.", tr: "Ne kadar derine ineceğini&nbsp;seç." },
    lv_lead: {
      de: "Vier Stufen. Jede enthält alles davor. Zieh den Regler und sieh im Manifest darunter, was sich auf deinem Rechner ändert — genau das, nicht mehr.",
      tr: "Dört seviye. Her biri öncekilerin tamamını içerir. Kaydırıcıyı sürükle, aşağıdaki listede bilgisayarında tam olarak neyin değişeceğini gör.",
    },
    cat_privacy: { en: "Privacy &amp; AI", de: "Privatsphäre &amp; KI", tr: "Gizlilik &amp; YZ" },
    cat_performance: { en: "Performance", de: "Leistung", tr: "Performans" },
    cat_taskbar: { en: "Taskbar &amp; Explorer", de: "Taskleiste &amp; Explorer", tr: "Görev çubuğu" },
    cat_debloat: { en: "Remove apps", de: "Apps entfernen", tr: "Uygulama kaldırma" },
    lv_1: { en: "Minimal", de: "Minimal", tr: "Minimal" },
    lv_2: { en: "Balanced", de: "Ausgewogen", tr: "Dengeli" },
    lv_3: { en: "Aggressive", de: "Aggressiv", tr: "Agresif" },
    lv_4: { en: "Zero", de: "Zero", tr: "Sıfır" },
    lvd_1: { en: "Safe essentials: dark mode, file extensions, left taskbar.", de: "Sichere Basics: Dark Mode, Dateiendungen, linke Taskleiste.", tr: "Güvenli temeller: koyu tema, dosya uzantıları, sol görev çubuğu." },
    lvd_2: { en: "Cleaner desktop: hide widgets, task view, Bing in search.", de: "Aufgeräumter Desktop: Widgets, Taskansicht &amp; Bing aus.", tr: "Temiz masaüstü: widget, görev görünümü ve Bing kapalı." },
    lvd_3: { en: "Privacy focus: kill telemetry, Copilot and the search box.", de: "Privatsphäre: Telemetrie, Copilot &amp; Suchfeld aus.", tr: "Gizlilik: telemetri, Copilot ve arama kutusu kapalı." },
    lvd_4: { en: "Total purge: everything above, plus bloat apps removed.", de: "Komplett: alles oben, plus Bloat-Apps entfernt.", tr: "Tam temizlik: yukarıdakiler + şişkin uygulamalar kaldırılır." },
    lv_hint: { de: "Ziehen, Stufe anklicken oder ← → Tasten", tr: "Sürükle, seviyeye tıkla ya da ← → tuşları" },
    mf_tweak: { de: "Tweak", tr: "Ayar" },
    mf_cat: { de: "Kategorie", tr: "Kategori" },
    mf_from: { de: "Ab", tr: "Sev." },
    mf_state: { de: "Status", tr: "Durum" },
    mf_note: {
      de: "Stufe 04 entfernt vorinstallierte Apps. Das ist nicht umkehrbar — vorher wird ein Wiederherstellungspunkt erstellt.",
      tr: "Seviye 04 yerleşik uygulamaları kaldırır. Bu geri alınamaz — önce bir geri yükleme noktası oluşturulur.",
    },
    pr_label: { de: "Ablauf", tr: "Süreç" },
    pr_title: { de: "Sechs Screens. Kein Rätselraten.", tr: "Altı ekran. Tahmin yok." },
    s1_t: { de: "Sprache wählen", tr: "Dil seç" },
    s1_d: { de: "English, Deutsch oder Türkçe. Jederzeit live umschaltbar — jede Beschriftung zieht mit.", tr: "English, Deutsch ya da Türkçe. İstediğin an canlı değiştir — tüm etiketler anında güncellenir." },
    s2_t: { de: "Hardware erkennen", tr: "Donanımı algıla" },
    s2_d: { de: "Deine Grafikkarte wird automatisch erkannt — NVIDIA, AMD oder Intel — und die offizielle Treiber-App vorgemerkt. WLAN-, Bluetooth- oder Druckerdienste, die du nicht brauchst, schaltest du ab.", tr: "Ekran kartın otomatik algılanır — NVIDIA, AMD ya da Intel — ve resmi sürücü uygulaması sıraya alınır. Kullanmadığın WiFi, Bluetooth veya yazıcı hizmetlerini kapat." },
    s3_t: { de: "Modus oder Eigen", tr: "Mod ya da Özel" },
    s3_d: { de: "Nimm eine kuratierte Stufe oder wechsle zu Eigen und schalte jeden einzelnen Tweak selbst.", tr: "Hazır bir seviye seç ya da Özel'e geç ve her ayarı tek tek kendin belirle." },
    s4_t: { de: "Stufe einstellen", tr: "Seviyeyi kaydır" },
    s4_d: { de: "Minimal, Ausgewogen, Aggressiv oder Zero. Der Regler oben ist dasselbe Bedienelement wie in der App.", tr: "Minimal, Dengeli, Agresif ya da Sıfır. Yukarıdaki kaydırıcı, uygulamadakiyle aynı kontroldür." },
    s5_t: { de: "Apps auswählen", tr: "Uygulamaları seç" },
    s5_d: { de: "Über 50 Pakete in sieben Kategorien, still über winget installiert. WinRAR ist jedes Mal dabei.", tr: "Yedi kategoride 50'den fazla paket, winget ile sessizce kurulur. WinRAR her seferinde gelir." },
    s6_t: { de: "Konstruieren", tr: "Kur" },
    s6_d: { de: "Zuerst ein Wiederherstellungspunkt. Dann Live-Fortschritt im Vollbild. Am Ende startet ein Klick den PC neu.", tr: "Önce bir geri yükleme noktası. Sonra tam ekran canlı ilerleme. Bitince tek tıkla bilgisayar yeniden başlar." },
    sp_label: { de: "Datenblatt", tr: "Teknik sayfa" },
    sp_title: { de: "Was drin ist. Klartext.", tr: "İçinde ne var. Açıkça." },
    sp_note: { de: "Keine Werbeadjektive. Das ist die Liste dessen, was Debloatranium an deinem System anfasst.", tr: "Pazarlama sıfatı yok. Bu, Debloatranium'un sisteminde dokunduğu her şeyin listesi." },
    fig_1: { de: "Registry- &amp; Dienst-Tweaks", tr: "kayıt defteri &amp; hizmet ayarı" },
    fig_2: { de: "Tiefen-Aktionen", tr: "derin tek seferlik işlem" },
    fig_3: { de: "GPU-Hersteller erkannt", tr: "GPU üreticisi algılanır" },
    f1_t: { de: "Privatsphäre &amp; Telemetrie", tr: "Gizlilik &amp; telemetri" },
    f1_d: { de: "Telemetrie, der DiagTrack-Dienst, Werbe-ID, personalisierte Werbung, Aktivitätsverlauf, Standort, Fehlerberichte, Eingabe- &amp; Freihanddaten, CEIP, Cortana, Copilot und Bing in der Startsuche.", tr: "Telemetri, DiagTrack hizmeti, reklam kimliği, kişiselleştirilmiş reklamlar, etkinlik geçmişi, konum, hata raporlama, yazma &amp; mürekkep verileri, CEIP, Cortana, Copilot ve Başlat aramasındaki Bing." },
    f2_t: { de: "Leistung", tr: "Performans" },
    f2_d: { de: "Höchstleistungs-Energieplan, Spielmodus, hardwarebeschleunigte GPU-Planung, kein Power-Throttling, keine Hintergrund-Apps, keine Startverzögerung, Optik auf Leistung, Temp-Dateien bereinigen.", tr: "Yüksek performans güç planı, Oyun Modu, donanım hızlandırmalı GPU zamanlama, güç kısma yok, arka plan uygulaması yok, başlangıç gecikmesi yok, performans görselleri, geçici dosya temizliği." },
    f3_t: { de: "Debloat", tr: "Temizlik" },
    f3_d: { de: "Entfernt Copilot, Solitär, News, Clipchamp, Xbox, Karten, Wetter, Smartphone-Link, Hilfe anfordern, Feedback-Hub, Schnellhilfe, To Do und Teams (privat). Optional wird Microsoft Edge deinstalliert (experimentell).", tr: "Copilot, Solitaire, Haberler, Clipchamp, Xbox, Haritalar, Hava Durumu, Telefonum, Yardım Al, Geri Bildirim Merkezi, Hızlı Yardım, To Do ve kişisel Teams kaldırılır. İsteğe bağlı olarak Microsoft Edge de kaldırılır (deneysel)." },
    f4_t: { de: "Tiefen-Optimierung", tr: "Derin optimizasyon" },
    f4_d: { de: "SysMain und Suchindizierung deaktivieren, Ruhezustand abschalten und so mehrere GB freigeben, DNS-Cache leeren, OneDrive vollständig entfernen.", tr: "SysMain ve arama dizinini kapat, hazırda bekletmeyi kapatarak birkaç GB aç, DNS önbelleğini temizle, OneDrive'ı tamamen kaldır." },
    f5_t: { de: "Treiber", tr: "Sürücüler" },
    f5_d: { de: "Erkennt NVIDIA-, AMD- oder Intel-Grafik und installiert die offizielle Treiber-App des Herstellers über winget.", tr: "NVIDIA, AMD ya da Intel grafiği algılar ve üreticinin resmi sürücü uygulamasını winget ile kurar." },
    f6_t: { de: "Sicherheit", tr: "Güvenlik" },
    f6_d: { de: "Legt vor jeder Änderung einen Systemwiederherstellungspunkt an. Jeder Registry-Schalter ist umkehrbar — aus heißt Windows-Standard. Startet sich bei Bedarf selbst als Administrator neu.", tr: "Herhangi bir değişiklikten önce sistem geri yükleme noktası oluşturur. Her kayıt defteri ayarı geri alınabilir — kapalı, Windows varsayılanı demektir. Gerekirse kendini yönetici olarak yeniden başlatır." },
    f7_t: { de: "Technik", tr: "Yapı" },
    f7_d: { de: "Tauri v2 mit Rust-Backend auf der WebView2-Runtime, die Windows schon mitbringt. Eine portable .exe, kein Installer, kein .NET, rund 40 MB RAM.", tr: "Windows ile gelen WebView2 üzerinde Rust tabanlı Tauri v2. Tek taşınabilir .exe, kurulum yok, .NET yok, yaklaşık 40 MB RAM." },
    f8_t: { de: "Lizenz", tr: "Lisans" },
    f8_d: { de: "MIT. Kein Konto, keine Werbung, keine eigene Telemetrie. Jede Zeile liegt auf GitHub.", tr: "MIT. Hesap yok, reklam yok, kendi telemetrisi yok. Her satırı GitHub'da." },
    ap_label: { de: "Packliste", tr: "Paket listesi" },
    ap_title: { de: "Nimm deine Apps&nbsp;mit.", tr: "Uygulamalarını&nbsp;getir." },
    ap_lead: { de: "Jedes Paket hier ist in der App. Hak ein paar an — der winget-Befehl baut sich selbst, genau so, wie Debloatranium ihn ausführt.", tr: "Buradaki her paket uygulamada var. Birkaçını işaretle — winget komutu, Debloatranium'un çalıştırdığı şekliyle kendini oluşturur." },
    ap_search: { en: "Search apps", de: "Apps suchen", tr: "Uygulama ara" },
    ap_none: { de: "Keine Apps gefunden.", tr: "Uygulama bulunamadı." },
    ap_copy: { de: "Kopieren", tr: "Kopyala" },
    ap_copied: { en: "Copied", de: "Kopiert", tr: "Kopyalandı" },
    ap_all: { en: "All", de: "Alle", tr: "Tümü" },
    ap_always: { en: "Always", de: "Immer", tr: "Her zaman" },
    p_gaming: { en: "Gaming", de: "Gaming", tr: "Oyun" },
    p_browsers: { en: "Browsers", de: "Browser", tr: "Tarayıcı" },
    p_creator: { en: "Creator", de: "Creator", tr: "İçerik" },
    p_developer: { en: "Developer", de: "Entwickler", tr: "Geliştirici" },
    p_gamedev: { en: "Game Dev", de: "Spiele-Dev", tr: "Oyun Geliştirme" },
    p_communication: { en: "Communication", de: "Kommunikation", tr: "İletişim" },
    p_utilities: { en: "Utilities", de: "Werkzeuge", tr: "Araçlar" },
    cn_label: { de: "Konstruieren", tr: "Kurulum" },
    cn_title: { de: "Dann baut es. Du schaust zu.", tr: "Sonra kurar. Sen izlersin." },
    cn_bar: { de: "System wird konstruiert", tr: "Sistemin kuruluyor" },
    cn_done: { de: "Konstruktion abgeschlossen.", tr: "Kurulum tamamlandı." },
    cn_restart: { de: "PC neu starten", tr: "PC'yi yeniden başlat" },
    cn_confirm: { en: "Click again to reboot", de: "Nochmal klicken — Neustart", tr: "Tekrar tıkla — yeniden başlat" },
    cn_replay: { de: "Nochmal ausführen", tr: "Tekrar çalıştır" },
    cn_disc: { de: "Simulation. Auf deinem Computer läuft nichts.", tr: "Simülasyon. Bilgisayarında hiçbir şey çalışmıyor." },
    cn_idle: { en: "idle", de: "bereit", tr: "hazır" },
    cn_run: { en: "running", de: "läuft", tr: "çalışıyor" },
    cn_ok: { en: "done", de: "fertig", tr: "bitti" },
    lg_restore: { en: "Creating restore point", de: "Wiederherstellungspunkt wird erstellt", tr: "Geri yükleme noktası oluşturuluyor" },
    lg_apply: { en: "Applying", de: "Anwenden", tr: "Uygulanıyor" },
    lg_install: { en: "Installing", de: "Installiere", tr: "Kuruluyor" },
    lg_temp: { en: "Clean Temp Files", de: "Temp-Dateien löschen", tr: "Geçici dosyaları temizle" },
    lg_diag: { en: "Kill Telemetry Service", de: "Telemetrie-Dienst killen", tr: "Telemetri hizmetini kapat" },
    lg_power: { en: "High Performance Power Plan", de: "Höchstleistungs-Energieplan", tr: "Yüksek performans güç planı" },
    lg_explorer: { en: "Restart Explorer", de: "Explorer neu starten", tr: "Explorer'ı yeniden başlat" },
    fq_title: { de: "Berechtigte Fragen.", tr: "Haklı sorular." },
    q1: { de: "Ist das sicher?", tr: "Güvenli mi?" },
    a1: { de: "Registry-Tweaks sind umkehrbar — schaltest du einen ab, gilt wieder der Windows-Standard. Vor allem anderen wird ein Systemwiederherstellungspunkt erstellt. Prüf, was du aktivierst; jede Änderung liegt bei dir.", tr: "Kayıt defteri ayarları geri alınabilir — birini kapattığında Windows varsayılanı geri gelir. Her şeyden önce bir sistem geri yükleme noktası oluşturulur. Neyi açtığını gözden geçir; her değişiklik senin kontrolünde." },
    q2: { de: "Was lässt sich nicht rückgängig machen?", tr: "Ne geri alınamaz?" },
    a2: { de: "Das Entfernen vorinstallierter Apps (Stufe Zero) und die Edge-Deinstallation sind endgültig. Die Edge-Entfernung ist experimentell — Windows Update kann Edge zurückbringen.", tr: "Yerleşik uygulamaların kaldırılması (Sıfır seviyesi) ve Edge'in kaldırılması geri alınamaz. Edge kaldırma deneyseldir — Windows Update onu geri getirebilir." },
    q3: { de: "Brauche ich Administratorrechte?", tr: "Yönetici hakları gerekli mi?" },
    a3: { de: "Für Telemetrie, Dienste und Treiber ja. Startest du normal, bietet Debloatranium einen Neustart als Administrator mit einem Klick an.", tr: "Telemetri, hizmetler ve sürücüler için evet. Normal başlatırsan Debloatranium tek tıkla yönetici olarak yeniden başlatmayı önerir." },
    q4: { de: "Muss es installiert werden?", tr: "Kurulum gerekiyor mu?" },
    a4: { de: "Nein. Es ist eine einzelne portable .exe mit rund 8 MB. Sie nutzt WebView2, das in Windows 10 (ab 1803) und Windows 11 bereits enthalten ist.", tr: "Hayır. Yaklaşık 8 MB'lık tek bir taşınabilir .exe. Windows 10 (1803+) ve Windows 11'de zaten bulunan WebView2'yi kullanır." },
    q5: { de: "Welche Windows-Versionen?", tr: "Hangi Windows sürümleri?" },
    a5: { de: "Windows 10 (ab 1803) und Windows 11. Einige Tweaks, etwa die linksbündige Taskleiste, wirken nur unter Windows 11.", tr: "Windows 10 (1803 ve sonrası) ve Windows 11. Sola hizalı görev çubuğu gibi bazı ayarlar yalnızca Windows 11'de geçerlidir." },
    q6: { de: "Ist es wirklich kostenlos?", tr: "Gerçekten ücretsiz mi?" },
    a6: { de: "Ja. MIT-lizenziert, kein Konto, keine Werbung, keine eigene Telemetrie. Wenn dein PC dadurch schneller wurde, freut sich das Projekt über eine Spende.", tr: "Evet. MIT lisanslı, hesap yok, reklam yok, kendi telemetrisi yok. Bilgisayarını hızlandırdıysa bağış memnuniyetle karşılanır." },
    dl_label: { de: "Download", tr: "İndir" },
    dl_a: { de: "Schieb auf", tr: "Sıfıra" },
    dl_b: { de: "Zero.", tr: "kaydır." },
    dl_btn: { de: "Debloatranium herunterladen", tr: "Debloatranium'u indir" },
    rq_os: { de: "System", tr: "Sistem" },
    rq_size: { de: "Größe", tr: "Boyut" },
    rq_run: { de: "Starten als", tr: "Çalıştır" },
    rq_price: { de: "Preis", tr: "Fiyat" },
    rq_free: { de: "Kostenlos, MIT", tr: "Ücretsiz, MIT" },
    ft_donate: { de: "Spenden", tr: "Bağış" },
    ft_top: { de: "Nach oben", tr: "Başa dön" },
    tk_rm: { en: "Removed", de: "Entfernt", tr: "Kaldırıldı" },
    tk_off: { en: "Off", de: "Aus", tr: "Kapalı" },
  };

  let lang = "en";
  const t = (k) => (DICT[k] && (DICT[k][lang] ?? DICT[k].en)) ?? k;
  const i18nEls = $$("[data-i]");
  i18nEls.forEach((el) => {
    const k = el.dataset.i;
    DICT[k] = DICT[k] || {};
    if (DICT[k].en == null) DICT[k].en = el.innerHTML.trim();
  });
  const langHooks = [];
  const onLang = (fn) => langHooks.push(fn);

  function applyLang(next, animate) {
    const run = () => {
      lang = next;
      document.documentElement.lang = lang;
      i18nEls.forEach((el) => {
        const v = t(el.dataset.i);
        if (el.innerHTML !== v) el.innerHTML = v;
      });
      $$("[data-i-ph]").forEach((el) => (el.placeholder = t(el.dataset.iPh)));
      $$(".lang button").forEach((b) => b.classList.toggle("is-on", b.dataset.lang === lang));
      const ind = $(".lang__ind");
      if (ind) ind.style.transform = `translateX(${LI[lang] * 36}px)`;
      langHooks.forEach((fn) => fn());
    };
    if (!animate || REDUCED) return run();
    document.body.classList.add("is-swapping");
    setTimeout(() => {
      run();
      requestAnimationFrame(() => document.body.classList.remove("is-swapping"));
    }, 260);
  }
  $$(".lang button").forEach((b) =>
    b.addEventListener("click", () => {
      if (b.dataset.lang === lang) return;
      store.set("dr-lang", b.dataset.lang);
      applyLang(b.dataset.lang, true);
    })
  );

  /* ------------------------------------------------------------------ text splitting */
  function splitMask(el) {
    // headline words slide up from a mask
    const words = el.innerHTML.split(/ +/);
    el.innerHTML = words
      .map((w, i) => `<span class="wm"><span style="transition-delay:${i * 55}ms">${w}</span></span>`)
      .join(" ");
  }
  function splitWords(el) {
    const out = [];
    el.childNodes.forEach((n) => {
      const isEm = n.nodeType === 1 && n.tagName === "EM";
      const txt = n.textContent;
      txt.split(/(\s+)/).forEach((w) => {
        if (!w) return;
        if (/^\s+$/.test(w)) out.push(" ");
        else out.push(`<span class="w${isEm ? " is-em" : ""}">${w.replace(/&/g, "&amp;").replace(/</g, "&lt;")}</span>`);
      });
    });
    el.innerHTML = out.join("");
  }
  const decorate = () => {
    $$(".reveal-lines").forEach(splitMask);
    $$(".js-words").forEach(splitWords);
    statementWords = $$(".statement__text .w");
  };
  let statementWords = [];
  onLang(decorate);

  /* ------------------------------------------------------------------ reveal on view */
  const io = new IntersectionObserver(
    (entries) =>
      entries.forEach((e) => {
        if (!e.isIntersecting) return;
        e.target.classList.add("is-in");
        e.target.dispatchEvent(new CustomEvent("inview"));
        io.unobserve(e.target);
      }),
    { threshold: 0.18, rootMargin: "0px 0px -6% 0px" }
  );
  const watch = (el) => el && io.observe(el);

  /* ------------------------------------------------------------------ count-up */
  function countUp(el, to, dur = 1400) {
    if (REDUCED) return void (el.textContent = to);
    const from = 0;
    const t0 = performance.now();
    const step = (now) => {
      const p = clamp((now - t0) / dur);
      el.textContent = Math.round(lerp(from, to, easeOut(p)));
      if (p < 1) requestAnimationFrame(step);
    };
    requestAnimationFrame(step);
  }

  /* ------------------------------------------------------------------ intro */
  const intro = $(".intro");
  function startIntro(done) {
    const seen = store.sget("dr-intro");
    if (REDUCED || !intro) {
      intro && intro.classList.add("is-gone");
      return done();
    }
    const num = $("#introNum");
    const bar = $(".intro__bar i");
    const log = $("#introLog");
    const lines = ["parse manifest", "load 46 tweaks", "index 51 packages", "detect gpu vendor", "arm fader", "ready"];
    const dur = seen ? 500 : 1500;
    const t0 = performance.now();
    const tick = (now) => {
      const p = clamp((now - t0) / dur);
      const e = p < 0.5 ? 4 * p * p * p : 1 - Math.pow(-2 * p + 2, 3) / 2;
      num.textContent = pad(Math.round(e * 100), 3);
      bar.style.transform = `scaleX(${e})`;
      log.textContent = lines[Math.min(lines.length - 1, Math.floor(e * lines.length))];
      if (p < 1) return requestAnimationFrame(tick);
      store.sset("dr-intro", "1");
      setTimeout(() => {
        intro.classList.add("is-out");
        document.body.classList.remove("is-loading");
        setTimeout(done, 380);
        setTimeout(() => intro.classList.add("is-gone"), 1200);
      }, 140);
    };
    requestAnimationFrame(tick);
  }

  /* ------------------------------------------------------------------ nav */
  const nav = $(".nav");
  const navLinks = $$(".nav__links a");
  const progressBar = $(".progress i");
  let lastY = scrollY;

  /* ------------------------------------------------------------------ hero */
  const hero = $(".hero");
  const card = $(".element__card");
  const tilt = { x: 0, y: 0, tx: 0, ty: 0 };
  const isFine = matchMedia("(pointer: fine)").matches;

  if (hero && isFine && !REDUCED) {
    const cx = $("#cx"), cy = $("#cy");
    hero.addEventListener("pointermove", (e) => {
      const r = hero.getBoundingClientRect();
      tilt.tx = (e.clientX - r.left) / r.width - 0.5;
      tilt.ty = (e.clientY - r.top) / r.height - 0.5;
      cx.textContent = pad(Math.round(e.clientX), 4);
      cy.textContent = pad(Math.round(e.clientY - r.top), 4);
    });
    hero.addEventListener("pointerleave", () => { tilt.tx = 0; tilt.ty = 0; });
  }

  // electrons
  const electrons = $$(".element__orbit .e");
  const orbitRot = [0, 60, 120].map((d) => (d * Math.PI) / 180);
  function drawElectrons(time) {
    electrons.forEach((e, i) => {
      const a = time / (1600 + i * 450) + i * 2.1;
      const x = 96 * Math.cos(a), y = 34 * Math.sin(a);
      const r = orbitRot[i];
      e.setAttribute("cx", (100 + x * Math.cos(r) - y * Math.sin(r)).toFixed(2));
      e.setAttribute("cy", (100 + x * Math.sin(r) + y * Math.cos(r)).toFixed(2));
    });
  }

  // geiger LED
  const led = $(".element__led");
  (function click() {
    if (!led || REDUCED) return;
    led.classList.add("is-click");
    setTimeout(() => led.classList.remove("is-click"), 45);
    setTimeout(click, -Math.log(1 - Math.random()) * 520 + 30);
  })();

  // decaying bloat words
  const BLOAT = ["Copilot", "Bing in Start", "Cortana", "DiagTrack", "Telemetry", "Widgets", "Clipchamp", "Solitaire", "Xbox Game Bar", "OneDrive", "Advertising ID", "Lock-screen ads", "Microsoft News", "Teams (personal)", "CEIP", "Activity history", "Start suggestions", "Error reporting", "Location tracking", "Feedback Hub", "Tailored ads", "Background apps", "Power throttling", "Hibernation"];
  const decayLayer = $(".hero__decay");
  const GLYPH = "▓▒░#%&/\\|<>=+*01";
  function heroBlocks() {
    const hr = hero.getBoundingClientRect();
    return $$(".hero__title .line > span, .hero__lead, .hero__cta, .element, .hero__stats, .hero__meta, .nav")
      .map((el) => {
        const r = el.getBoundingClientRect();
        return { l: r.left - hr.left - 24, t: r.top - hr.top - 16, r: r.right - hr.left + 24, b: r.bottom - hr.top + 16 };
      });
  }
  function spawnDecay() {
    if (!decayLayer || document.hidden) return setTimeout(spawnDecay, 1200);
    const hr = hero.getBoundingClientRect();
    if (hr.bottom < 0) return setTimeout(spawnDecay, 1200);
    const blocks = heroBlocks();
    const word = BLOAT[Math.floor(Math.random() * BLOAT.length)];
    const w = word.length * 7.4 + 20, h = 16;
    let x, y, ok = false;
    for (let k = 0; k < 30 && !ok; k++) {
      x = 16 + Math.random() * (hr.width - w - 32);
      y = 70 + Math.random() * (hr.height - 120);
      ok = !blocks.some((b) => x < b.r && x + w > b.l && y < b.b && y + h > b.t);
    }
    if (!ok) return setTimeout(spawnDecay, 600);
    const el = document.createElement("span");
    el.className = "decay";
    el.style.left = x + "px";
    el.style.top = y + "px";
    decayLayer.appendChild(el);
    let i = 0;
    const type = setInterval(() => {
      el.textContent = word.slice(0, ++i);
      if (i >= word.length) {
        clearInterval(type);
        setTimeout(() => {
          el.classList.add("is-dying");
          let n = 0;
          const scr = setInterval(() => {
            n++;
            el.textContent = word
              .split("")
              .map((c, j) => (j < (n / 10) * word.length || c === " " ? (Math.random() < 0.5 ? GLYPH[Math.floor(Math.random() * GLYPH.length)] : "·") : c))
              .join("");
            if (n > 12) {
              clearInterval(scr);
              el.style.opacity = "0";
              setTimeout(() => el.remove(), 700);
            }
          }, 55);
        }, 1400 + Math.random() * 2400);
      }
    }, 38);
    setTimeout(spawnDecay, 700 + Math.random() * 900);
  }

  /* ------------------------------------------------------------------ ticker */
  const ticker = $(".ticker__track");
  const TICK = [
    ["rm", "Copilot"], ["off", "Telemetry"], ["off", "Bing in Start"], ["rm", "Clipchamp"], ["off", "Advertising ID"],
    ["off", "Lock-screen ads"], ["rm", "Solitaire"], ["off", "Cortana"], ["rm", "Xbox app"], ["off", "Activity history"],
    ["rm", "Microsoft News"], ["off", "Widgets"], ["off", "Error reporting"], ["rm", "Teams (personal)"], ["off", "Game Bar"],
    ["off", "Background apps"], ["rm", "OneDrive"], ["off", "Power throttling"], ["rm", "Feedback Hub"], ["off", "Tailored ads"],
  ];
  let tickX = 0, tickHalf = 0;
  function buildTicker() {
    if (!ticker) return;
    const html = TICK.map(([k, n]) => `<span><b>${t(k === "rm" ? "tk_rm" : "tk_off")}</b><i lang="en">${n}</i></span>`).join("");
    ticker.innerHTML = html + html;
    tickHalf = ticker.scrollWidth / 2;
  }
  onLang(buildTicker);

  /* ------------------------------------------------------------------ levels */
  const LV_TOTAL = TWEAKS.length;
  const CAT_CODE = { appearance: "UI", taskbar: "TASK", privacy: "PRIV", performance: "PERF", debloat: "APPX" };
  const mBody = $(".manifest__body");
  const fader = $(".fader");
  const rail = $(".fader__rail");
  const capEl = $(".fader__cap");
  const fillEl = $(".fader__fill");
  let level = 2, levelShown = 0;
  const cap = { p: 1 / 3, v: 0, target: 1 / 3, drag: false };
  let userTouchedFader = false;
  let rows = [];

  function buildManifest() {
    if (!mBody) return;
    mBody.innerHTML = TWEAKS.map(
      (tw, i) =>
        `<div class="mrow${tw[1] === "debloat" ? " is-del" : ""}" data-lv="${tw[2]}">` +
        `<span class="mrow__i">${pad(i + 1, 3)}</span>` +
        `<span class="mrow__n">${tw[3 + LI[lang]]}</span>` +
        `<span class="mrow__c">${CAT_CODE[tw[1]] || tw[1]}</span>` +
        `<span class="mrow__l">L${tw[2]}</span>` +
        `<span class="mrow__s"><b>—</b></span></div>`
    ).join("");
    rows = $$(".mrow", mBody);
    levelShown = 0;
    renderLevel(true);
  }
  // duplicate header for the two-column layout
  (function headCols() {
    const head = $(".manifest__head");
    if (!head) return;
    const wrap = document.createElement("div");
    wrap.className = "manifest__heads";
    head.parentNode.insertBefore(wrap, head);
    wrap.appendChild(head);
    const clone = head.cloneNode(true);
    clone.classList.add("manifest__head--2");
    clone.querySelectorAll("[data-i]").forEach((el) => i18nEls.push(el));
    wrap.appendChild(clone);
  })();

  const lvCountEl = $(".js-lv-count");
  let lvCountTween = null;
  function renderLevel(instant) {
    const active = TWEAKS.filter((tw) => tw[2] <= level).length;
    // readout number
    if (lvCountEl) {
      const from = +lvCountEl.textContent || 0;
      cancelAnimationFrame(lvCountTween);
      if (instant || REDUCED) lvCountEl.textContent = active;
      else {
        const t0 = performance.now();
        const step = (now) => {
          const p = clamp((now - t0) / 650);
          lvCountEl.textContent = Math.round(lerp(from, active, easeOut(p)));
          if (p < 1) lvCountTween = requestAnimationFrame(step);
        };
        lvCountTween = requestAnimationFrame(step);
      }
    }
    $(".js-lv-idx").textContent = pad(level);
    $(".js-lv-name").textContent = t("lv_" + level);
    $(".js-lv-desc").innerHTML = t("lvd_" + level);
    ["privacy", "performance", "taskbar", "debloat"].forEach((c) => {
      const all = TWEAKS.filter((tw) => tw[1] === c);
      const on = all.filter((tw) => tw[2] <= level).length;
      const b = $(`.js-bar[data-cat="${c}"]`);
      const n = $(`.js-bar-n[data-cat="${c}"]`);
      if (b) b.style.transform = `scaleX(${all.length ? on / all.length : 0})`;
      if (n) n.textContent = on;
    });
    $$(".fader__labels button").forEach((b) => {
      const l = +b.dataset.lv;
      b.classList.toggle("is-on", l === level);
      b.classList.toggle("is-past", l < level);
    });
    fader && fader.setAttribute("aria-valuenow", level);
    fader && fader.setAttribute("aria-valuetext", t("lv_" + level));
    // manifest wave: rows changing state animate in order from the boundary
    const goingUp = level > levelShown;
    const changing = rows.filter((r) => (+r.dataset.lv <= level) !== r.classList.contains("is-on"));
    if (!goingUp) changing.reverse();
    changing.forEach((r, k) => {
      const on = +r.dataset.lv <= level;
      const delay = instant ? 0 : k * 16;
      r.style.transitionDelay = delay + "ms";
      r.querySelector(".mrow__s").style.transitionDelay = delay + "ms";
      setTimeout(() => {
        r.classList.toggle("is-on", on);
        r.querySelector(".mrow__s b").textContent = on ? (r.classList.contains("is-del") ? "DEL" : "ON") : "—";
        if (!instant) {
          r.classList.remove("is-flash");
          void r.offsetWidth;
          r.classList.add("is-flash");
        }
      }, delay);
    });
    $(".js-zero-note") && $(".js-zero-note").classList.toggle("is-on", level === 4);
    levelShown = level;
  }
  function setLevel(l, fromDrag) {
    l = clamp(Math.round(l), 1, 4);
    if (!fromDrag) cap.target = (l - 1) / 3;
    if (l === level) return;
    level = l;
    renderLevel(false);
  }
  onLang(() => { buildManifest(); });

  if (fader && rail) {
    // ticks
    const ticks = $(".fader__ticks");
    let th = "";
    for (let i = 0; i <= 48; i++) {
      const maj = i % 16 === 0;
      th += `<i class="${maj ? "maj" : ""}" style="left:${(i / 48) * 100}%"></i><i class="lo ${maj ? "maj" : ""}" style="left:${(i / 48) * 100}%"></i>`;
    }
    ticks.innerHTML = th;

    const fracAt = (x) => {
      const r = rail.getBoundingClientRect();
      return clamp((x - r.left) / r.width);
    };
    rail.addEventListener("pointerdown", (e) => {
      userTouchedFader = true;
      cap.drag = true;
      fader.classList.add("is-drag");
      rail.setPointerCapture(e.pointerId);
      cap.target = fracAt(e.clientX);
      setLevel(cap.target * 3 + 1, true);
      e.preventDefault();
    });
    rail.addEventListener("pointermove", (e) => {
      if (!cap.drag) return;
      cap.target = fracAt(e.clientX);
      setLevel(cap.target * 3 + 1, true);
    });
    const end = () => {
      if (!cap.drag) return;
      cap.drag = false;
      fader.classList.remove("is-drag");
      cap.target = (level - 1) / 3;
    };
    rail.addEventListener("pointerup", end);
    rail.addEventListener("pointercancel", end);
    $$(".fader__labels button").forEach((b) =>
      b.addEventListener("click", () => { userTouchedFader = true; setLevel(+b.dataset.lv); })
    );
    fader.addEventListener("keydown", (e) => {
      const map = { ArrowRight: 1, ArrowUp: 1, ArrowLeft: -1, ArrowDown: -1 };
      if (map[e.key]) { userTouchedFader = true; setLevel(level + map[e.key]); e.preventDefault(); }
      if (e.key === "Home") { setLevel(1); e.preventDefault(); }
      if (e.key === "End") { setLevel(4); e.preventDefault(); }
    });
    // first time in view: a short sweep so it's obvious this thing moves
    const console_ = $(".console");
    console_.addEventListener("inview", () => {
      if (REDUCED) return;
      const seq = [[500, 3], [1200, 4], [2300, 2]];
      seq.forEach(([d, l]) => setTimeout(() => !userTouchedFader && setLevel(l), d));
    });
    watch(console_);
  }
  function stepFader() {
    if (!capEl) return;
    if (cap.drag) {
      cap.p = lerp(cap.p, cap.target, 0.5);
      cap.v = 0;
    } else {
      cap.v += (cap.target - cap.p) * 0.14;
      cap.v *= 0.7;
      cap.p += cap.v;
    }
    const w = rail.clientWidth;
    capEl.style.transform = `translateX(${(cap.p * w).toFixed(2)}px)`;
    fillEl.style.transform = `scaleX(${clamp(cap.p).toFixed(4)})`;
  }

  /* ------------------------------------------------------------------ process (pinned horizontal) */
  const proc = $(".process");
  const track = $(".process__track");
  const steps = $$(".step");
  const procRail = $(".process__rail i");
  const procCur = $(".js-pr-cur");
  let procMax = 0, procActive = -1;
  const pinMode = () => innerWidth > 900 && !REDUCED;

  function layoutProcess() {
    if (!proc || !track) return;
    proc.classList.toggle("no-pin", !pinMode());
    if (!pinMode()) {
      proc.style.height = "";
      track.style.transform = "";
      return;
    }
    const pin = $(".process__pin");
    procMax = Math.max(0, track.scrollWidth - innerWidth);
    proc.style.height = pin.offsetHeight + procMax + "px";
  }
  const stepTimers = new Map();
  function activateStep(i) {
    if (i === procActive) return;
    if (procActive >= 0) {
      steps[procActive].classList.remove("is-active");
      (stepTimers.get(procActive) || []).forEach(clearTimeout);
      (stepTimers.get(procActive + "i") || []).forEach(clearInterval);
    }
    procActive = i;
    const s = steps[i];
    if (!s) return;
    s.classList.add("is-active");
    if (procCur) procCur.textContent = pad(i + 1);
    const T = [], I = [];
    stepTimers.set(i, T);
    stepTimers.set(i + "i", I);
    const later = (fn, d) => T.push(setTimeout(fn, d));
    if (s.querySelector(".screen--lang")) {
      const pills = $$(".pills span", s);
      let k = 0;
      const show = () => pills.forEach((p, j) => p.classList.toggle("is-on", j === k % 3));
      show();
      I.push(setInterval(() => { k++; show(); }, 1100));
    }
    if (s.querySelector(".screen--hw")) {
      const tg = $$(".tg", s);
      tg.forEach((x) => x.classList.add("on"));
      later(() => tg[1].classList.remove("on"), 1300);
      later(() => tg[2].classList.remove("on"), 1800);
    }
    if (s.querySelector(".screen--mode")) {
      const ch = $$(".choice", s);
      ch[0].classList.remove("is-on"); ch[1].classList.add("is-on");
      later(() => { ch[1].classList.remove("is-on"); ch[0].classList.add("is-on"); }, 900);
    }
    if (s.querySelector(".screen--apps")) {
      const q = $(".search__q", s);
      const items = $$(".mini-apps span", s);
      q.textContent = "";
      items.forEach((x) => x.classList.remove("is-dim"));
      "ste".split("").forEach((c, j) =>
        later(() => {
          q.textContent += c;
          const v = q.textContent.toLowerCase();
          items.forEach((x) => x.classList.toggle("is-dim", !x.textContent.toLowerCase().includes(v)));
        }, 500 + j * 180)
      );
      later(() => { q.textContent = ""; items.forEach((x) => x.classList.remove("is-dim")); }, 2400);
    }
    if (s.querySelector(".screen--build")) {
      const pct = $(".js-mini-pct", s), bar = $(".build-bar i", s), logs = $$(".build-log span", s);
      logs.forEach((l) => l.classList.remove("is-on"));
      const t0 = performance.now();
      const run = (now) => {
        const p = clamp((now - t0) / 2600);
        pct.textContent = Math.round(easeOut(p) * 100);
        bar.style.transform = `scaleX(${easeOut(p)})`;
        logs.forEach((l, j) => l.classList.toggle("is-on", p > j / logs.length));
        if (p < 1 && s.classList.contains("is-active")) requestAnimationFrame(run);
      };
      requestAnimationFrame(run);
    }
  }
  function updateProcess() {
    if (!proc) return;
    if (!pinMode()) return;
    const r = proc.getBoundingClientRect();
    const span = proc.offsetHeight - innerHeight;
    const p = span > 0 ? clamp(-r.top / span) : 0;
    track.style.transform = `translate3d(${(-p * procMax).toFixed(1)}px,0,0)`;
    if (procRail) procRail.style.transform = `scaleX(${p})`;
    if (r.top < innerHeight && r.bottom > 0) {
      const mid = innerWidth / 2;
      let best = 0, bd = Infinity;
      steps.forEach((s, i) => {
        const sr = s.getBoundingClientRect();
        const d = Math.abs(sr.left + sr.width / 2 - mid);
        if (d < bd) { bd = d; best = i; }
      });
      activateStep(best);
    }
  }
  const stepIO = new IntersectionObserver(
    (es) => es.forEach((e) => { if (e.isIntersecting && !pinMode()) activateStep(steps.indexOf(e.target)); }),
    { threshold: 0.6 }
  );
  steps.forEach((s) => stepIO.observe(s));

  /* ------------------------------------------------------------------ spec wipe + sheet */
  const wipe = $(".spec__wipe");
  function updateWipe() {
    if (!wipe || REDUCED) return;
    const r = wipe.getBoundingClientRect();
    const p = clamp(1 - r.top / innerHeight);
    const max = Math.min(64, innerWidth * 0.05);
    wipe.style.setProperty("--wipe", ((1 - easeOut(p)) * max).toFixed(1) + "px");
    wipe.style.setProperty("--wipe-r", ((1 - p) * 28).toFixed(1) + "px");
  }
  $$(".sheet__row").forEach(watch);

  /* ------------------------------------------------------------------ apps */
  const PURPOSES = ["gaming", "browsers", "creator", "developer", "gamedev", "communication", "utilities"];
  const tabsEl = $(".tabs");
  const listEl = $(".pack__list");
  const emptyEl = $(".pack__empty");
  const findEl = $(".js-find");
  const codeEl = $(".cmd__code");
  const selected = new Set(["Valve.Steam", "Mozilla.Firefox", "Discord.Discord"]);
  const ALWAYS = APPS.filter((a) => a[6]).map((a) => a[0]);
  let tab = "all";

  const uniqueApps = () => {
    const seen = new Set();
    return APPS.filter((a) => (seen.has(a[0]) ? false : (seen.add(a[0]), true)));
  };
  function buildTabs() {
    if (!tabsEl) return;
    const keys = ["all", ...PURPOSES];
    tabsEl.innerHTML =
      keys
        .map((k) => {
          const n = k === "all" ? uniqueApps().length : APPS.filter((a) => a[2] === k).length;
          return `<button role="tab" data-tab="${k}" class="${k === tab ? "is-on" : ""}" aria-selected="${k === tab}">${t(k === "all" ? "ap_all" : "p_" + k)}<sup>${n}</sup></button>`;
        })
        .join("") + `<i class="tabs__ind"></i>`;
    $$("button", tabsEl).forEach((b) =>
      b.addEventListener("click", () => {
        tab = b.dataset.tab;
        $$("button", tabsEl).forEach((x) => { x.classList.toggle("is-on", x === b); x.setAttribute("aria-selected", x === b); });
        moveTabInd();
        renderApps();
      })
    );
    requestAnimationFrame(moveTabInd);
  }
  function moveTabInd() {
    const b = $("button.is-on", tabsEl), ind = $(".tabs__ind", tabsEl);
    if (!b || !ind) return;
    ind.style.width = b.offsetWidth + "px";
    ind.style.transform = `translate(${b.offsetLeft}px, ${b.offsetTop}px)`;
  }
  function renderApps() {
    if (!listEl) return;
    const q = (findEl.value || "").trim().toLowerCase();
    const src = tab === "all" ? uniqueApps() : APPS.filter((a) => a[2] === tab);
    const items = src.filter((a) => !q || (a[1] + " " + a[0] + " " + a[3 + LI[lang]]).toLowerCase().includes(q));
    listEl.innerHTML = items
      .map((a, i) => {
        const always = !!a[6];
        const on = always || selected.has(a[0]);
        return (
          `<button type="button" role="listitem" class="app${on ? " is-on" : ""}${always ? " is-always" : ""}" data-id="${a[0]}" data-always="${t("ap_always")}" style="--i:${i}" aria-pressed="${on}"${always ? ' aria-disabled="true"' : ""}>` +
          `<span class="app__box"></span><span class="app__name">${a[1]}</span><span class="app__id">${a[0]}</span>` +
          `<span class="app__desc">${a[3 + LI[lang]]}</span></button>`
        );
      })
      .join("");
    emptyEl.hidden = items.length > 0;
  }
  listEl &&
    listEl.addEventListener("click", (e) => {
      const b = e.target.closest(".app");
      if (!b || b.classList.contains("is-always")) return;
      const id = b.dataset.id;
      selected.has(id) ? selected.delete(id) : selected.add(id);
      $$(`.app[data-id="${CSS.escape(id)}"]`, listEl).forEach((x) => {
        x.classList.toggle("is-on", selected.has(id));
        x.setAttribute("aria-pressed", selected.has(id));
      });
      renderCmd(selected.has(id) ? id : null);
    });
  findEl &&
    findEl.addEventListener("input", () => {
      renderApps();
    });
  addEventListener("keydown", (e) => {
    if (e.key === "/" && document.activeElement !== findEl && !/input|textarea/i.test(document.activeElement.tagName)) {
      const r = $("#apps").getBoundingClientRect();
      if (r.top < innerHeight && r.bottom > 0) { e.preventDefault(); findEl.focus(); }
    }
  });
  const FLAGS = "--silent --accept-package-agreements --accept-source-agreements";
  const cmdLines = () => [...ALWAYS, ...Array.from(selected).filter((id) => !ALWAYS.includes(id))];
  function renderCmd(added) {
    if (!codeEl) return;
    codeEl.innerHTML = cmdLines()
      .map((id) => `<span class="ln"${id === added ? "" : ' style="animation:none"'}>winget install --id ${id} -e <span class="fl">${FLAGS}</span></span>`)
      .join("");
    if (added) codeEl.scrollTop = codeEl.scrollHeight;
  }
  const copyBtn = $(".cmd__copy");
  copyBtn &&
    copyBtn.addEventListener("click", async () => {
      const txt = cmdLines().map((id) => `winget install --id ${id} -e ${FLAGS}`).join("\n");
      try {
        await navigator.clipboard.writeText(txt);
      } catch {
        const ta = document.createElement("textarea");
        ta.value = txt;
        document.body.appendChild(ta);
        ta.select();
        try { document.execCommand("copy"); } catch {}
        ta.remove();
      }
      copyBtn.textContent = t("ap_copied");
      copyBtn.classList.add("is-done");
      setTimeout(() => { copyBtn.textContent = t("ap_copy"); copyBtn.classList.remove("is-done"); }, 1600);
    });
  onLang(() => { buildTabs(); renderApps(); renderCmd(); });

  /* ------------------------------------------------------------------ construct */
  const term = $(".term");
  const logEl = $(".term__log");
  const pctEl = $(".js-pct");
  const blocksEl = $(".term__blocks");
  const curEl = $(".js-cur");
  const stateEl = $(".js-term-state");
  const restartBtn = $(".js-restart");
  let runId = 0;
  const BLOCKS = 36;

  blocksEl && (blocksEl.innerHTML = "<i></i>".repeat(BLOCKS));
  const cells = blocksEl ? Array.from(blocksEl.children) : [];
  function drawBlocks(p) {
    const n = Math.round(p * BLOCKS);
    cells.forEach((c, i) => c.classList.toggle("on", i < n));
  }
  function buildQueue() {
    const q = [{ l: t("lg_restore"), d: 1300 }];
    const pick = TWEAKS.filter((tw) => tw[2] <= 3);
    pick.slice(0, 12).forEach((tw) => q.push({ l: `${t("lg_apply")} ${tw[3 + LI[lang]]}`, d: 160 + Math.random() * 260 }));
    q.push({ l: t("lg_diag"), d: 600 });
    q.push({ l: t("lg_power"), d: 420 });
    q.push({ l: t("lg_temp"), d: 900 });
    cmdLines().forEach((id) => {
      const a = APPS.find((x) => x[0] === id);
      q.push({ l: `${t("lg_install")} ${a ? a[1] : id}`, d: 900 + Math.random() * 700 });
    });
    q.push({ l: t("lg_explorer"), d: 500 });
    return q;
  }
  function runConstruct() {
    if (!term) return;
    const id = ++runId;
    term.classList.remove("is-done", "is-reboot");
    restartBtn.classList.remove("is-confirm");
    restartBtn.querySelector("span").textContent = t("cn_restart");
    logEl.innerHTML = "";
    stateEl.textContent = t("cn_run");
    stateEl.classList.add("is-run");
    const queue = buildQueue();
    const total = queue.reduce((s, x) => s + x.d, 0);
    let elapsed = 0, i = 0;
    const t0 = performance.now();
    const stamp = (ms) => `[${pad(Math.floor(ms / 60000))}:${pad(Math.floor(ms / 1000) % 60)}.${pad(Math.floor(ms / 10) % 100)}]`;
    const next = () => {
      if (id !== runId) return;
      if (i >= queue.length) {
        pctEl.textContent = 100;
        drawBlocks(1);
        curEl.textContent = "—";
        stateEl.textContent = t("cn_ok");
        stateEl.classList.remove("is-run");
        setTimeout(() => id === runId && term.classList.add("is-done"), 500);
        return;
      }
      const it = queue[i];
      const li = document.createElement("li");
      li.className = "is-wait";
      li.innerHTML = `<span class="t">${stamp(performance.now() - t0)}</span><span class="s">·</span><span>${it.l}</span>`;
      logEl.appendChild(li);
      while (logEl.children.length > 16) logEl.firstChild.remove();
      curEl.textContent = it.l;
      const s0 = elapsed;
      const st = performance.now();
      const anim = (now) => {
        if (id !== runId) return;
        const p = clamp((now - st) / it.d);
        const g = (s0 + it.d * p) / total;
        pctEl.textContent = Math.floor(g * 100);
        drawBlocks(g);
        if (p < 1) return requestAnimationFrame(anim);
        li.classList.remove("is-wait");
        li.querySelector(".s").textContent = "✓";
        elapsed += it.d;
        i++;
        next();
      };
      requestAnimationFrame(anim);
    };
    next();
  }
  if (term) {
    drawBlocks(0);
    stateEl.textContent = t("cn_idle");
    term.addEventListener("inview", () => setTimeout(runConstruct, 300));
    io.observe(term);
    $(".js-replay").addEventListener("click", runConstruct);
    restartBtn.addEventListener("click", () => {
      if (!restartBtn.classList.contains("is-confirm")) {
        restartBtn.classList.add("is-confirm");
        restartBtn.querySelector("span").textContent = t("cn_confirm");
        return;
      }
      term.classList.add("is-reboot");
      setTimeout(runConstruct, 1800);
    });
    onLang(() => {
      if (!stateEl.classList.contains("is-run")) stateEl.textContent = t(term.classList.contains("is-done") ? "cn_ok" : "cn_idle");
    });
  }

  /* ------------------------------------------------------------------ faq */
  $$(".acc details").forEach((d) => {
    const sum = $("summary", d), body = $(".acc__a", d);
    sum.addEventListener("click", (e) => {
      if (REDUCED) return;
      e.preventDefault();
      if (d.dataset.busy) return;
      d.dataset.busy = "1";
      if (!d.open) {
        d.open = true;
        const h = body.scrollHeight;
        body.animate([{ height: "0px", opacity: 0 }, { height: h + "px", opacity: 1 }], { duration: 520, easing: "cubic-bezier(.19,1,.22,1)" }).onfinish = () => delete d.dataset.busy;
      } else {
        const h = body.scrollHeight;
        body.animate([{ height: h + "px", opacity: 1 }, { height: "0px", opacity: 0 }], { duration: 380, easing: "cubic-bezier(.76,0,.24,1)" }).onfinish = () => {
          d.open = false;
          delete d.dataset.busy;
        };
      }
    });
  });

  /* ------------------------------------------------------------------ final + footer */
  watch($(".final"));
  const footWord = $(".foot__word");
  function fitFoot() {
    if (!footWord) return;
    footWord.style.fontSize = "100px";
    const w = footWord.offsetWidth;
    const target = footWord.parentElement.clientWidth * 0.97;
    footWord.style.fontSize = (100 * target) / w + "px";
  }
  function updateFoot() {
    if (!footWord || REDUCED) return;
    const r = footWord.getBoundingClientRect();
    const p = clamp((innerHeight - r.top) / (r.height + 80));
    footWord.style.setProperty("--fy", ((1 - easeOut(p)) * 45).toFixed(1) + "%");
  }

  /* ------------------------------------------------------------------ download burst */
  $$(".js-burst").forEach((b) =>
    b.addEventListener("click", (e) => {
      if (REDUCED) return;
      const x = e.clientX || b.getBoundingClientRect().left + 20, y = e.clientY || b.getBoundingClientRect().top + 20;
      const parts = [];
      for (let i = 0; i < 18; i++) {
        const s = document.createElement("i");
        s.className = "shard";
        document.body.appendChild(s);
        const a = Math.random() * Math.PI * 2, v = 3 + Math.random() * 7;
        parts.push({ s, x, y, vx: Math.cos(a) * v, vy: Math.sin(a) * v - 4, r: Math.random() * 360, life: 1 });
      }
      const tick = () => {
        let alive = false;
        parts.forEach((p) => {
          if (p.life <= 0) return;
          p.vy += 0.38; p.x += p.vx; p.y += p.vy; p.vx *= 0.98; p.r += p.vx * 4; p.life -= 0.022;
          p.s.style.transform = `translate(${p.x}px,${p.y}px) rotate(${p.r}deg)`;
          p.s.style.opacity = p.life;
          if (p.life > 0) alive = true; else p.s.remove();
        });
        if (alive) requestAnimationFrame(tick);
      };
      requestAnimationFrame(tick);
    })
  );

  /* ------------------------------------------------------------------ live release info */
  (async function release() {
    const apply = (d) => {
      if (d.tag) $$(".js-ver").forEach((el) => (el.textContent = d.tag));
      if (d.exe) $$(".js-dl").forEach((a) => (a.href = d.exe));
      if (d.stars >= 10) $$(".js-stars").forEach((el) => (el.textContent = "★ " + d.stars));
    };
    const cached = store.sget("dr-rel");
    if (cached) { try { return apply(JSON.parse(cached)); } catch {} }
    const d = {};
    try {
      const [rel, repo] = await Promise.all([
        fetch("https://api.github.com/repos/Emre1001/Debloatranium/releases/latest").then((r) => (r.ok ? r.json() : null)),
        fetch("https://api.github.com/repos/Emre1001/Debloatranium").then((r) => (r.ok ? r.json() : null)),
      ]);
      if (rel) {
        d.tag = rel.tag_name;
        const exe = (rel.assets || []).find((a) => /\.exe$/i.test(a.name));
        if (exe) d.exe = exe.browser_download_url;
      }
      if (repo) d.stars = repo.stargazers_count;
      store.sset("dr-rel", JSON.stringify(d));
      apply(d);
    } catch {}
  })();

  /* ------------------------------------------------------------------ main loop */
  let vel = 0;
  function frame(now) {
    const y = scrollY;
    const dy = y - lastY;
    vel = lerp(vel, dy, 0.2);

    // nav
    if (nav) {
      nav.classList.toggle("is-solid", y > 40);
      if (Math.abs(dy) > 2) nav.classList.toggle("is-hidden", dy > 0 && y > 400);
    }
    const docH = document.documentElement.scrollHeight - innerHeight;
    if (progressBar) progressBar.style.transform = `scaleX(${docH > 0 ? y / docH : 0})`;

    // hero
    if (card && !REDUCED) {
      tilt.x = lerp(tilt.x, tilt.tx, 0.08);
      tilt.y = lerp(tilt.y, tilt.ty, 0.08);
      card.style.transform = `rotateY(${(tilt.x * 16).toFixed(2)}deg) rotateX(${(-tilt.y * 12).toFixed(2)}deg)`;
      if (y < innerHeight) drawElectrons(now);
    }

    // ticker
    if (ticker && tickHalf && !REDUCED) {
      const dir = vel < -0.5 ? -1 : 1;
      tickX -= (0.6 + Math.min(18, Math.abs(vel) * 0.5)) * dir;
      if (tickX <= -tickHalf) tickX += tickHalf;
      if (tickX > 0) tickX -= tickHalf;
      ticker.style.transform = `translate3d(${tickX.toFixed(1)}px,0,0)`;
    }

    // statement words lit by scroll position
    if (statementWords.length && !REDUCED) {
      const el = statementWords[0].parentElement;
      const r = el.getBoundingClientRect();
      const p = clamp((innerHeight * 0.82 - r.top) / (r.height + innerHeight * 0.32));
      const n = Math.floor(p * statementWords.length * 1.04);
      statementWords.forEach((w, i) => w.classList.toggle("is-lit", i < n));
    }

    stepFader();
    if (Math.abs(dy) > 0 || now < 3000) {
      updateProcess();
      updateWipe();
      updateFoot();
      // active nav link
      let cur = null;
      navLinks.forEach((a) => {
        const s = $(a.getAttribute("href"));
        if (s) {
          const r = s.getBoundingClientRect();
          if (r.top < innerHeight * 0.4 && r.bottom > innerHeight * 0.4) cur = a;
        }
      });
      navLinks.forEach((a) => a.classList.toggle("is-active", a === cur));
    }
    lastY = y;
    requestAnimationFrame(frame);
  }

  /* ------------------------------------------------------------------ boot */
  const initial = store.get("dr-lang") || (navigator.language || "en").slice(0, 2).toLowerCase();
  applyLang(LANGS.includes(initial) ? initial : "en", false);
  renderCmd();

  const onResize = () => {
    layoutProcess();
    fitFoot();
    moveTabInd();
    tickHalf = ticker ? ticker.scrollWidth / 2 : 0;
    updateProcess();
  };
  addEventListener("resize", onResize);
  addEventListener("load", onResize);
  document.fonts && document.fonts.ready.then(onResize);
  onLang(() => requestAnimationFrame(onResize));
  onResize();
  requestAnimationFrame(frame);

  startIntro(() => {
    document.body.classList.add("is-ready");
    $$(".hero .js-count").forEach((el, i) => setTimeout(() => countUp(el, +el.dataset.to, 1300), 250 + i * 70));
    $$(".h2.reveal-lines, .head").forEach(watch);
    setTimeout(spawnDecay, 1400);
    setTimeout(spawnDecay, 2100);
    setTimeout(spawnDecay, 2900);
  });
  $$(".spec .js-count").forEach((el) => {
    el.addEventListener("inview", () => countUp(el, +el.dataset.to, 1200));
    watch(el);
  });
})();
