/* Debloatranium website */
(() => {
  "use strict";

  const $ = (s, r = document) => r.querySelector(s);
  const $$ = (s, r = document) => Array.from(r.querySelectorAll(s));
  const clamp = (v, a = 0, b = 1) => Math.min(b, Math.max(a, v));
  const REDUCED = matchMedia("(prefers-reduced-motion: reduce)").matches;
  const store = {
    get: (k) => { try { return localStorage.getItem(k); } catch { return null; } },
    set: (k, v) => { try { localStorage.setItem(k, v); } catch {} },
    sget: (k) => { try { return sessionStorage.getItem(k); } catch { return null; } },
    sset: (k, v) => { try { sessionStorage.setItem(k, v); } catch {} },
  };

  const TWEAKS = window.DR_TWEAKS || [];
  const APPS = window.DR_APPS || [];
  const LANGS = ["en", "de", "tr"];
  const LI = { en: 0, de: 1, tr: 2 };

  /* ---------------------------------------------------------------- text */
  // English is read from the HTML. German and Turkish live here.
  const DICT = {
    nav_how: { de: "So funktioniert's", tr: "Nasıl çalışır" },
    nav_levels: { de: "Was sich ändert", tr: "Neler değişir" },
    nav_apps: { de: "Apps", tr: "Uygulamalar" },
    nav_faq: { de: "FAQ", tr: "SSS" },
    nav_dl: { de: "Download", tr: "İndir" },
    h1: {
      de: "Werbung, Telemetrie und Copilot raus aus Windows.",
      tr: "Reklamları, telemetriyi ve Copilot'u Windows'tan çıkarın.",
    },
    hero_p: {
      de: "Debloatranium ist ein kostenloses Open-Source-Tool für Windows 10 und 11. Du legst fest, wie weit es gehen soll und welche Programme installiert werden, den Rest erledigt das Tool. Vor der ersten Änderung setzt es einen Wiederherstellungspunkt.",
      tr: "Debloatranium, Windows 10 ve 11 için ücretsiz ve açık kaynaklı bir araçtır. Ne kadar ileri gideceğine ve hangi programların kurulacağına sen karar verirsin, gerisini araç halleder. İlk değişiklikten önce bir geri yükleme noktası oluşturur.",
    },
    btn_dl: { de: "Für Windows herunterladen", tr: "Windows için indir" },
    btn_src: { de: "Quellcode auf GitHub", tr: "GitHub'da kaynak kodu" },
    meta_v: { de: "Version", tr: "Sürüm" },
    meta_exe: { de: "Portable .exe,", tr: "Taşınabilir .exe," },
    meta_none: { de: "Keine Installation", tr: "Kurulum gerektirmez" },

    how_h: { de: "So funktioniert's", tr: "Nasıl çalışır" },
    how_p: { de: "Die App ist ein kurzer Assistent. Das hier sind die echten Bildschirme.", tr: "Uygulama kısa bir sihirbazdır. Bunlar gerçek ekranlar." },
    s1_h: { de: "Sprache wählen", tr: "Dil seç" },
    s1_p: { de: "Englisch, Deutsch oder Türkisch. Lässt sich später jederzeit ändern.", tr: "İngilizce, Almanca veya Türkçe. Daha sonra istediğin zaman değiştirebilirsin." },
    s2_h: { de: "Hardware prüfen", tr: "Donanımı kontrol et" },
    s2_p: {
      de: "Schalte WLAN-, Bluetooth- oder Druckerdienste ab, wenn dein PC sie nicht braucht. Alles bleibt an, solange du es nicht ausschaltest.",
      tr: "Bilgisayarın kullanmıyorsa WiFi, Bluetooth veya yazıcı hizmetlerini kapat. Sen kapatmadıkça her şey açık kalır.",
    },
    s3_h: { de: "Voreinstellung oder eigene Auswahl", tr: "Hazır ayar veya özel" },
    s3_p: {
      de: "Die Voreinstellungen sind der schnelle Weg. Unter „Eigen“ siehst du jede einzelne Einstellung und entscheidest selbst.",
      tr: "Hazır ayarlar hızlı yoldur. Özel seçeneğinde her ayarı tek tek görür ve kendin karar verirsin.",
    },
    s4_h: { de: "Stufe wählen", tr: "Seviye seç" },
    s4_p: {
      de: "Vier Stufen, von Minimal bis Zero. Jede baut auf der vorherigen auf. Zero deinstalliert zusätzlich vorinstallierte Apps wie Clipchamp, Solitär und die Xbox-App.",
      tr: "Minimal'den Sıfır'a dört seviye. Her biri bir öncekinin üzerine ekler. Sıfır ayrıca Clipchamp, Solitaire ve Xbox uygulaması gibi önceden yüklü uygulamaları kaldırır.",
    },
    s5_h: { de: "Apps und Extras", tr: "Uygulamalar ve ekstralar" },
    s5_p: {
      de: "Wähle Programme, die über winget, den Paketmanager von Microsoft, installiert werden. Hier findest du auch den GPU-Treiber, den Energieplan, Aufräum-Optionen und die optionale Edge-Entfernung.",
      tr: "Microsoft'un paket yöneticisi winget ile kurulacak programları seç. Ekran kartı sürücüsü, güç planı, temizlik seçenekleri ve isteğe bağlı Edge kaldırma da burada.",
    },
    s6_h: { de: "Prüfen und starten", tr: "Gözden geçir ve başlat" },
    s6_p: {
      de: "Zuerst bekommst du eine Zusammenfassung. Danach zeigt ein Fortschrittsbildschirm jeden Schritt, und am Ende kannst du den PC direkt aus der App neu starten.",
      tr: "Önce bir özet görürsün. Ardından bir ilerleme ekranı her adımı gösterir, sonunda bilgisayarını doğrudan uygulamadan yeniden başlatabilirsin.",
    },

    lv_h: { de: "Was jede Stufe ändert", tr: "Her seviye neyi değiştirir" },
    lv_p: {
      de: "Diese Liste stammt direkt aus dem Quellcode der App. Jede Stufe enthält alles aus den Stufen davor.",
      tr: "Bu liste doğrudan uygulamanın kaynak kodundan geliyor. Her seviye, önceki seviyelerdeki her şeyi içerir.",
    },
    lv_1: { de: "Minimal", tr: "Minimal" },
    lv_2: { de: "Ausgewogen", tr: "Dengeli" },
    lv_3: { de: "Aggressiv", tr: "Agresif" },
    lv_4: { de: "Zero", tr: "Sıfır" },
    lvd_1: { en: "Safe essentials: dark mode, file extensions, left taskbar.", de: "Sichere Basics: Dark Mode, Dateiendungen, linke Taskleiste.", tr: "Güvenli temeller: koyu tema, dosya uzantıları, sol görev çubuğu." },
    lvd_2: { en: "Cleaner desktop: hide widgets, task view, Bing in search.", de: "Aufgeräumter Desktop: Widgets, Taskansicht und Bing aus.", tr: "Temiz masaüstü: widget, görev görünümü ve Bing kapalı." },
    lvd_3: { en: "Privacy focus: telemetry, Copilot and the search box off.", de: "Privatsphäre: Telemetrie, Copilot und Suchfeld aus.", tr: "Gizlilik: telemetri, Copilot ve arama kutusu kapalı." },
    lvd_4: { en: "Everything above, plus preinstalled apps removed.", de: "Alles oben, plus vorinstallierte Apps entfernt.", tr: "Yukarıdakilerin hepsi, artı önceden yüklü uygulamalar kaldırılır." },
    count: { en: "of {t} changes", de: "von {t} Änderungen", tr: "/ {t} değişiklik" },
    cat_appearance: { en: "Appearance", de: "Darstellung", tr: "Görünüm" },
    cat_taskbar: { en: "Taskbar & Explorer", de: "Taskleiste & Explorer", tr: "Görev çubuğu ve Explorer" },
    cat_privacy: { en: "Privacy & AI", de: "Privatsphäre & KI", tr: "Gizlilik ve YZ" },
    cat_performance: { en: "Performance", de: "Leistung", tr: "Performans" },
    cat_debloat: { en: "Removed apps", de: "Entfernte Apps", tr: "Kaldırılan uygulamalar" },
    lv_note: {
      de: "Entfernte Apps lassen sich in Debloatranium nicht wiederherstellen. Die meisten kannst du aber aus dem Microsoft Store neu installieren.",
      tr: "Kaldırılan uygulamalar Debloatranium içinden geri getirilemez. Çoğunu Microsoft Store'dan yeniden yükleyebilirsin.",
    },

    ap_h: { de: "Installierbare Apps", tr: "Kurulabilen uygulamalar" },
    ap_p: {
      de: "51 Programme in sieben Gruppen. Du wählst sie in der App aus, danach werden sie nacheinander installiert. WinRAR ist immer dabei.",
      tr: "Yedi grupta 51 program. Uygulamada seçersin, ardından sırayla kurulurlar. WinRAR her zaman dahildir.",
    },
    p_gaming: { en: "Gaming", de: "Gaming", tr: "Oyun" },
    p_browsers: { en: "Browsers", de: "Browser", tr: "Tarayıcılar" },
    p_creator: { en: "Creator", de: "Creator", tr: "İçerik üretimi" },
    p_developer: { en: "Developer", de: "Entwickler", tr: "Geliştirici" },
    p_gamedev: { en: "Game dev", de: "Spieleentwicklung", tr: "Oyun geliştirme" },
    p_communication: { en: "Communication", de: "Kommunikation", tr: "İletişim" },
    p_utilities: { en: "Utilities", de: "Werkzeuge", tr: "Araçlar" },
    always: { en: "always", de: "immer", tr: "her zaman" },

    fq_h: { de: "Fragen", tr: "Sorular" },
    q1: { de: "Kann ich die Änderungen rückgängig machen?", tr: "Değişiklikleri geri alabilir miyim?" },
    a1: {
      de: "Bei allen Einstellungen ja: Schaltest du eine aus, gilt wieder der Windows-Standard. Ausnahme sind entfernte Apps. Vor der ersten Änderung wird ein Systemwiederherstellungspunkt erstellt, damit lässt sich auch das ganze System zurücksetzen.",
      tr: "Tüm ayarlar için evet: birini kapattığında Windows varsayılanı geri gelir. Kaldırılan uygulamalar bunun istisnasıdır. İlk değişiklikten önce bir sistem geri yükleme noktası oluşturulur, böylece tüm sistemi de geri alabilirsin.",
    },
    q2: { de: "Brauche ich Administratorrechte?", tr: "Yönetici hakları gerekiyor mu?" },
    a2: {
      de: "Für die meisten Änderungen ja. Startest du die App ohne, zeigt sie einen Button, um sich als Administrator neu zu starten.",
      tr: "Çoğu değişiklik için evet. Uygulamayı yönetici olmadan başlatırsan, yönetici olarak yeniden başlatmak için bir düğme gösterir.",
    },
    q3: { de: "Muss ich etwas installieren?", tr: "Kurulum gerekiyor mu?" },
    a3: {
      de: "Nein. Es ist eine einzelne .exe mit ca. 8 MB. Sie nutzt WebView2, das in Windows 10 (ab Version 1803) und Windows 11 enthalten ist.",
      tr: "Hayır. Yaklaşık 8 MB'lık tek bir .exe dosyası. Windows 10 (1803 ve sonrası) ve Windows 11'de bulunan WebView2'yi kullanır.",
    },
    q4: { de: "Was ist mit Microsoft Edge?", tr: "Microsoft Edge ne olacak?" },
    a4: {
      de: "Die Edge-Entfernung ist optional und in der App als riskant markiert. Sie funktioniert, aber Windows Update kann Edge wieder installieren.",
      tr: "Edge'i kaldırmak isteğe bağlıdır ve uygulamada riskli olarak işaretlidir. Çalışır, ancak Windows Update Edge'i yeniden kurabilir.",
    },
    q5: { de: "Sammelt Debloatranium Daten?", tr: "Debloatranium veri topluyor mu?" },
    a5: { de: "Nein. Kein Konto, keine Analyse, keine Werbung. Der komplette Quellcode liegt auf GitHub.", tr: "Hayır. Hesap yok, analiz yok, reklam yok. Kaynak kodunun tamamı GitHub'da." },
    q6: { de: "Welche Windows-Versionen werden unterstützt?", tr: "Hangi Windows sürümleri destekleniyor?" },
    a6: {
      de: "Windows 10 ab Version 1803 und Windows 11. Einige Einstellungen, etwa die linksbündige Taskleiste, wirken nur unter Windows 11.",
      tr: "1803 ve sonrası Windows 10 ile Windows 11. Sola hizalı görev çubuğu gibi bazı ayarlar yalnızca Windows 11'de etkilidir.",
    },

    dl_h: { de: "Download", tr: "İndir" },
    dl_p: { de: "Kostenlos und Open Source unter der MIT-Lizenz.", tr: "MIT lisansı altında ücretsiz ve açık kaynak." },
    dl_btn: { de: "Debloatranium.exe herunterladen", tr: "Debloatranium.exe'yi indir" },
    f_ver: { de: "Version", tr: "Sürüm" },
    f_date: { de: "Veröffentlicht", tr: "Yayın tarihi" },
    f_size: { de: "Größe", tr: "Boyut" },
    f_size_v: { de: "ca. 8 MB", tr: "yaklaşık 8 MB" },
    f_req: { de: "Voraussetzung", tr: "Gereksinim" },
    f_req_v: { de: "Windows 10 (ab 1803) oder Windows 11", tr: "Windows 10 (1803+) veya Windows 11" },
    l_rel: { de: "Alle Releases", tr: "Tüm sürümler" },
    l_src: { de: "Quellcode", tr: "Kaynak kodu" },
    l_bug: { de: "Fehler melden", tr: "Hata bildir" },
    l_don: { de: "Projekt unterstützen", tr: "Projeyi destekle" },
    foot: { de: "Debloatranium von Emre1001. MIT-Lizenz.", tr: "Debloatranium, Emre1001 tarafından. MIT lisansı." },
    top: { de: "Nach oben", tr: "Başa dön" },
  };

  let lang = "en";
  const t = (k) => (DICT[k] && (DICT[k][lang] ?? DICT[k].en)) ?? k;
  const textEls = $$("[data-i]");
  textEls.forEach((el) => {
    const k = el.dataset.i;
    DICT[k] = DICT[k] || {};
    if (DICT[k].en == null) DICT[k].en = el.innerHTML.trim();
  });
  const hooks = [];

  function setLang(next, animate) {
    const apply = () => {
      lang = next;
      document.documentElement.lang = lang;
      textEls.forEach((el) => {
        const v = t(el.dataset.i);
        if (el.innerHTML !== v) el.innerHTML = v;
      });
      $$(".lang button").forEach((b) => b.classList.toggle("is-on", b.dataset.lang === lang));
      hooks.forEach((fn) => fn());
    };
    if (!animate || REDUCED) return apply();
    document.body.classList.add("is-swapping");
    setTimeout(() => {
      apply();
      requestAnimationFrame(() => document.body.classList.remove("is-swapping"));
    }, 200);
  }
  $$(".lang button").forEach((b) =>
    b.addEventListener("click", () => {
      if (b.dataset.lang === lang) return;
      store.set("dr-lang", b.dataset.lang);
      setLang(b.dataset.lang, true);
    })
  );

  /* ---------------------------------------------------------------- screenshots */
  const shot = (name) => `assets/shots/${lang}-${name}.webp`;
  const frameSets = $$(".window__frames").map((box) => {
    const names = box.dataset.frames.split(" ");
    box.innerHTML = names.map((n, i) => `<img data-name="${n}" alt="" ${i ? 'loading="lazy"' : ""} decoding="async" />`).join("");
    const imgs = $$("img", box);
    let cur = -1;
    return {
      names,
      show(name) {
        const i = names.indexOf(name);
        if (i === cur || i < 0) return;
        // the old frame stays fully visible underneath until the new one has faded in
        imgs.forEach((im) => im.classList.remove("is-prev"));
        if (cur >= 0) {
          const old = imgs[cur];
          old.classList.remove("is-on");
          old.classList.add("is-prev");
          clearTimeout(old._t);
          old._t = setTimeout(() => old.classList.remove("is-prev"), 750);
        }
        imgs[i].classList.add("is-on");
        imgs[i].alt = name;
        cur = i;
      },
      reload() {
        imgs.forEach((img) => {
          const src = shot(img.dataset.name);
          if (img.getAttribute("src") === src) return;
          // swap only once the new language's image is ready, so nothing flashes
          const pre = new Image();
          pre.onload = () => (img.src = src);
          pre.src = src;
          if (!img.getAttribute("src")) img.src = src;
        });
      },
    };
  });
  hooks.push(() => frameSets.forEach((f) => f.reload()));
  hooks.push(() => $$(".step").forEach((s) => (s.querySelector(".step__img").src = shot(s.dataset.frames.split(" ")[0]))));

  /* hero: plays through the wizard like a short clip */
  const hero = frameSets[0];
  const reel = $(".reel");
  const HOLD = 3200;
  let reelIdx = 0, reelStart = performance.now(), reelVisible = true;
  if (reel && hero) {
    reel.innerHTML = hero.names.map((n, i) => `<button type="button" role="tab" aria-label="${n}" data-i-idx="${i}"><i></i></button>`).join("");
    const bars = $$("button", reel);
    const go = (i) => {
      reelIdx = (i + hero.names.length) % hero.names.length;
      reelStart = performance.now();
      hero.show(hero.names[reelIdx]);
      bars.forEach((b, j) => {
        b.classList.toggle("is-done", j < reelIdx);
        b.setAttribute("aria-selected", j === reelIdx);
        b.querySelector("i").style.transform = j < reelIdx ? "" : "scaleX(0)";
      });
    };
    bars.forEach((b, i) => b.addEventListener("click", () => go(i)));
    go(0);
    new IntersectionObserver(([e]) => (reelVisible = e.isIntersecting)).observe($(".stage"));
    const tick = (now) => {
      if (!reelVisible || document.hidden || REDUCED) {
        reelStart = now - Math.min(now - reelStart, HOLD * 0.5);
      } else {
        const p = (now - reelStart) / HOLD;
        bars[reelIdx].querySelector("i").style.transform = `scaleX(${clamp(p)})`;
        if (p >= 1) go(reelIdx + 1);
      }
      requestAnimationFrame(tick);
    };
    requestAnimationFrame(tick);
  }

  /* ---------------------------------------------------------------- how it works */
  const steps = $$(".step");
  const howFrames = frameSets[1];
  function updateSteps() {
    if (!steps.length || innerWidth <= 900) return;
    const mid = innerHeight / 2;
    let active = 0;
    steps.forEach((s, i) => { if (s.getBoundingClientRect().top < mid) active = i; });
    steps.forEach((s, i) => {
      const r = s.getBoundingClientRect();
      const q = clamp((mid - r.top) / r.height);
      s.classList.toggle("is-on", i === active);
      s.querySelector(".step__bar i").style.transform = `scaleY(${i < active ? 1 : i === active ? q : 0})`;
      if (i === active) {
        const names = s.dataset.frames.split(" ");
        howFrames.show(names[Math.min(names.length - 1, Math.floor(q * names.length * 1.15))]);
      }
    });
  }

  /* ---------------------------------------------------------------- levels */
  const CATS = ["appearance", "taskbar", "privacy", "performance", "debloat"];
  const catsEl = $(".cats");
  const seg = $(".seg");
  let level = 2;
  function buildLevels() {
    if (!catsEl) return;
    catsEl.innerHTML = CATS.map((c) => {
      const items = TWEAKS.filter((tw) => tw[1] === c);
      return `<div class="cat cat--${c}"><h3>${t("cat_" + c)}</h3><ul>${items
        .map((tw) => `<li data-lv="${tw[2]}">${tw[3 + LI[lang]]}</li>`)
        .join("")}</ul></div>`;
    }).join("");
    renderLevel(true);
  }
  let countAnim = 0;
  function renderLevel(instant) {
    const on = TWEAKS.filter((tw) => tw[2] <= level).length;
    const countEl = $(".js-count");
    const from = +countEl.textContent || 0;
    cancelAnimationFrame(countAnim);
    if (instant || REDUCED) countEl.textContent = on;
    else {
      const t0 = performance.now();
      const step = (now) => {
        const p = clamp((now - t0) / 500);
        countEl.textContent = Math.round(from + (on - from) * (1 - Math.pow(1 - p, 3)));
        if (p < 1) countAnim = requestAnimationFrame(step);
      };
      countAnim = requestAnimationFrame(step);
    }
    $(".js-count-label").textContent = t("count").replace("{t}", TWEAKS.length);
    $(".js-desc").textContent = t("lvd_" + level);
    $(".js-note").classList.toggle("is-on", level === 4);
    $$(".cat").forEach((cat) => {
      let k = 0;
      $$("li", cat).forEach((li) => {
        const want = +li.dataset.lv <= level;
        if (want === li.classList.contains("is-on")) return;
        const d = instant ? 0 : k++ * 35;
        setTimeout(() => li.classList.toggle("is-on", want), d);
      });
    });
    $$("button", seg).forEach((b) => {
      const sel = +b.dataset.lv === level;
      b.classList.toggle("is-on", sel);
      b.setAttribute("aria-checked", sel);
      b.tabIndex = sel ? 0 : -1;
    });
    movePill();
  }
  function movePill() {
    const b = $("button.is-on", seg), pill = $(".seg__pill", seg);
    if (!b || !pill) return;
    pill.style.width = b.offsetWidth + "px";
    pill.style.transform = `translate(${b.offsetLeft}px, ${b.offsetTop - 4}px)`;
  }
  if (seg) {
    $$("button", seg).forEach((b) => b.addEventListener("click", () => { level = +b.dataset.lv; renderLevel(false); }));
    seg.addEventListener("keydown", (e) => {
      const d = { ArrowRight: 1, ArrowDown: 1, ArrowLeft: -1, ArrowUp: -1 }[e.key];
      if (!d) return;
      e.preventDefault();
      level = clamp(level + d, 1, 4);
      renderLevel(false);
      $("button.is-on", seg).focus();
    });
  }
  hooks.push(buildLevels);

  /* ---------------------------------------------------------------- apps */
  const PURPOSES = ["gaming", "browsers", "creator", "developer", "gamedev", "communication", "utilities"];
  function buildApps() {
    const box = $(".groups");
    if (!box) return;
    box.innerHTML = PURPOSES.map((p) => {
      const list = APPS.filter((a) => a[2] === p);
      return `<div class="group reveal is-in"><h3>${t("p_" + p)}<span>${list.length}</span></h3><ul>${list
        .map((a) => `<li title="${a[3 + LI[lang]].replace(/"/g, "&quot;")}"><span>${a[1]}</span>${a[6] ? `<em>${t("always")}</em>` : ""}</li>`)
        .join("")}</ul></div>`;
    }).join("");
  }
  hooks.push(buildApps);

  /* ---------------------------------------------------------------- faq */
  $$(".qa details").forEach((d) => {
    const sum = $("summary", d), body = $(".qa__a", d);
    sum.addEventListener("click", (e) => {
      if (REDUCED || !body.animate) return;
      e.preventDefault();
      if (d.dataset.busy) return;
      d.dataset.busy = "1";
      if (!d.open) {
        d.open = true;
        const h = body.scrollHeight;
        body.animate([{ height: "0px", opacity: 0 }, { height: h + "px", opacity: 1 }], { duration: 380, easing: "cubic-bezier(.22,1,.36,1)" }).onfinish = () => delete d.dataset.busy;
      } else {
        const h = body.scrollHeight;
        body.animate([{ height: h + "px", opacity: 1 }, { height: "0px", opacity: 0 }], { duration: 280, easing: "ease-in" }).onfinish = () => {
          d.open = false;
          delete d.dataset.busy;
        };
      }
    });
  });

  /* ---------------------------------------------------------------- reveal on scroll */
  const io = new IntersectionObserver(
    (es) => es.forEach((e) => { if (e.isIntersecting) { e.target.classList.add("is-in"); io.unobserve(e.target); } }),
    { threshold: 0.15 }
  );
  $$(".section-head, .seg, .cats, .groups, .qa, .get__card").forEach((el) => { el.classList.add("reveal"); io.observe(el); });

  /* ---------------------------------------------------------------- release info */
  let release = null;
  function applyRelease() {
    if (!release) return;
    if (release.tag) $$(".js-ver").forEach((el) => (el.textContent = release.tag.replace(/^v/i, "")));
    if (release.exe) $$(".js-dl").forEach((a) => (a.href = release.exe));
    if (release.date) {
      const d = new Date(release.date);
      $(".js-date").textContent = d.toLocaleDateString(lang, { year: "numeric", month: "long", day: "numeric" });
    }
    if (release.size) $$(".js-size").forEach((el) => (el.textContent = (release.size / 1048576).toLocaleString(lang, { maximumFractionDigits: 1 }) + " MB"));
  }
  hooks.push(applyRelease);
  (async () => {
    const cached = store.sget("dr-release");
    if (cached) {
      try { release = JSON.parse(cached); return applyRelease(); } catch {}
    }
    try {
      const r = await fetch("https://api.github.com/repos/Emre1001/Debloatranium/releases/latest");
      if (!r.ok) return;
      const j = await r.json();
      const exe = (j.assets || []).find((a) => /\.exe$/i.test(a.name));
      release = { tag: j.tag_name, date: j.published_at, exe: exe && exe.browser_download_url, size: exe && exe.size };
      store.sset("dr-release", JSON.stringify(release));
      applyRelease();
    } catch {}
  })();

  /* ---------------------------------------------------------------- scroll */
  const nav = $(".nav");
  const navLinks = $$(".nav__links a");
  const tiltEl = $(".js-tilt");
  let ticking = false;
  function onScroll() {
    ticking = false;
    const y = scrollY;
    nav.classList.toggle("is-scrolled", y > 8);
    // the hero window starts tipped back and stands up as you scroll
    if (tiltEl && !REDUCED) {
      const p = clamp(y / (innerHeight * 0.6));
      tiltEl.style.transform = `rotateX(${(1 - p) * 11}deg) scale(${0.955 + p * 0.045})`;
    }
    updateSteps();
    let cur = null;
    navLinks.forEach((a) => {
      const s = $(a.getAttribute("href"));
      const r = s && s.getBoundingClientRect();
      if (r && r.top < innerHeight * 0.35 && r.bottom > innerHeight * 0.35) cur = a;
    });
    navLinks.forEach((a) => a.classList.toggle("is-on", a === cur));
  }
  addEventListener("scroll", () => { if (!ticking) { ticking = true; requestAnimationFrame(onScroll); } }, { passive: true });
  addEventListener("resize", () => { movePill(); onScroll(); });
  document.fonts && document.fonts.ready.then(movePill);

  /* ---------------------------------------------------------------- start */
  const saved = store.get("dr-lang");
  const guess = (navigator.language || "en").slice(0, 2).toLowerCase();
  setLang(LANGS.includes(saved) ? saved : LANGS.includes(guess) ? guess : "en", false);
  onScroll();
})();
