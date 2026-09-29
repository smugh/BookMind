/**
 * BookMind - Interactive Scripts
 * Handles bilingual (ID / EN) switching, dynamic screenshot swapping,
 * and Download APK notifications.
 */

document.addEventListener('DOMContentLoaded', () => {
  // Current active language: check URL parameter, localStorage, or default to 'id'
  const urlParams = new URLSearchParams(window.location.search);
  let currentLang = urlParams.get('lang') || localStorage.getItem('bookmind_lang') || 'id';

  // Translation Dictionaries
  const i18n = {
    id: {
      // Navbar
      navFeatures: 'Fitur',
      navStats: 'Statistik',
      navStory: 'Alasan &amp; Nilai',
      navDownloadApk: 'Unduh APK',

      // Hero
      heroTagline: 'BOOKMIND BY SMUGH-TECH &bull; READ &bull; REFLECT &bull; GROW',
      heroTitle: 'Baca Lebih Dalam.<br><span>Ingat Lebih Lama.</span>',
      heroDesc: 'Personal reading knowledge system offline untuk Android. Ubah bacaan pasif menjadi aset pengetahuan yang bertumbuh.',
      heroPillOffline: '100% Offline',
      heroPillFormats: 'PDF &amp; EPUB',
      heroPillSqlite: 'SQLite Local',
      heroPillNoAccount: 'Tanpa Akun &amp; Login',

      // Features
      feat1Title: 'Highlight',
      feat1Desc: 'Terkumpul di satu hub',
      feat2Title: 'Refleksi',
      feat2Desc: 'Catatan &amp; multi-tag',
      feat3Title: 'Pencarian',
      feat3Desc: 'SQLite FTS instan',
      feat4Title: 'Deep Link',
      feat4Desc: 'Lompat ke halaman asal',

      // Reading Stats Section
      statsTag: 'STATISTIK MEMBACA &bull; BY SMUGH-TECH',
      statsTitle: 'Pantau Kebiasaan Membaca, Raih Konsistensi Nyata',
      statsSub: 'Dashboard personal visual yang merekam perjalanan literasi Anda secara presisi, terukur, dan 100% offline tanpa perantara cloud.',
      statsImgCaption: '📊 Statistik Baca: Waktu, streak, &amp; genre favorit',
      statsLead: 'MANFAAT UNTUK PEMBACA',
      statsHeadline: 'Mengapa Statistik Membaca Penting?',
      statsLeadDesc: 'Banyak orang ingin rutin membaca namun kehilangan jejak kemajuannya. BookMind mengubah aktivitas membaca harian menjadi data berharga yang memotivasi pertumbuhan diri Anda.',
      statBen1Title: 'Disiplin &amp; Reading Streak',
      statBen1Desc: 'Pelacak konsistensi harian dan rekor streak menjaga antusiasme membaca agar tidak mudah surut di tengah kesibukan.',
      statBen2Title: 'Analisis Waktu &amp; Jam Fokus',
      statBen2Desc: 'Ketahui akumulasi durasi baca harian hingga tahunan, serta temukan jam emas saat fokus membaca Anda berada di titik terbaik.',
      statBen3Title: 'Distribusi Genre Dinamis',
      statBen3Desc: 'Petakan topik buku favorit Anda secara proporsional untuk mengevaluasi diversitas wawasan dan eksplorasi literatur baru.',
      statBen4Title: '100% Privat Tanpa Tekanan',
      statBen4Desc: 'Semua data tersimpan aman di SQLite perangkat Anda. Tanpa algoritma kompetitif, pamer sosial, atau pantauan pihak luar.',

      // Story Section (Alasan Dibuatnya)
      storyTag: 'LATAR BELAKANG &bull; BY SMUGH-TECH',
      storyTitle: 'Mengapa BookMind Dibuat?',
      storySub: 'Ebook reader konvensional hanya fokus pada membaca pasif. BookMind dibangun untuk memastikan insight berharga dari setiap buku tidak hilang begitu saja.',

      problemTag: 'MASALAH YANG DIHADAPI',
      problemTitle: 'Pengetahuan Sering Hilang Begitu Buku Ditutup',
      problemDesc: 'Saat membaca buku, kita kerap menemukan ide atau kutipan luar biasa. Namun di reader biasa, highlight terkurung di dalam file buku, catatan sulit dicari ulang, dan insight tidak pernah terhubung lintas buku.',

      solutionTag: 'SOLUSI',
      solutionTitle: 'Personal Reading Knowledge System',
      solutionDesc: 'BookMind dibangun sebagai ruang baca personal: tangkap kutipan penting, tulis pemikiran orisinalmu (*My Reflection*), dan hubungkan topik lintas buku ke dalam satu sistem terpusat yang 100% offline.',

      storyImg1Caption: '📖 Seleksi teks &amp; beri penanda langsung di halaman',

      // Values Section (Value yang Ditawarkan)
      valuesTag: 'VALUE YANG DITAWARKAN',
      valuesTitle: 'Nilai Utama untuk Pembaca',

      val1Title: 'Refleksi Aktif &amp; Multi-Tagging',
      val1Desc: 'Kutipan tidak berhenti sebagai teks pasif. Tulis pemikiran orisinalmu (*My Reflection*) dan sematkan multi-tag topik lintas buku.',

      val2Title: 'Knowledge Hub &amp; Deep Link Instan',
      val2Desc: 'Sentralisasi ribuan catatan dari semua buku. Cari cepat dengan mesin SQLite FTS, dan 1-klik lompat langsung kembali ke nomor halaman asal.',

      val3Title: '100% Offline &amp; Kedaulatan Data',
      val3Desc: 'Tanpa login, tanpa akun, tanpa pelacakan cloud, dan bebas iklan. Buku dan seluruh catatan Anda tersimpan aman secara lokal di perangkat.',

      storyImg2Caption: '🧠 Knowledge Hub: Seluruh catatan &amp; FTS search',

      // Footer
      footerNote: 'Offline-First Android App &bull; Drift SQLite',
      footerCopy: '&copy; 2026 BookMind by Smugh-Tech. All rights reserved.',

      // Toast Notice
      toastApkDownloading: '📥 Mengunduh BookMind v.1.0.3 APK...'
    },
    en: {
      // Navbar
      navFeatures: 'Features',
      navStats: 'Reading Stats',
      navStory: 'Why &amp; Values',
      navDownloadApk: 'Download APK',

      // Hero
      heroTagline: 'BOOKMIND BY SMUGH-TECH &bull; READ &bull; REFLECT &bull; GROW',
      heroTitle: 'Read Deeper.<br><span>Remember Longer.</span>',
      heroDesc: 'Offline personal reading knowledge system for Android. Turn passive reading into a growing knowledge base.',
      heroPillOffline: '100% Offline',
      heroPillFormats: 'PDF &amp; EPUB',
      heroPillSqlite: 'SQLite Local',
      heroPillNoAccount: 'No Account Needed',

      // Features
      feat1Title: 'Highlight',
      feat1Desc: 'Collected in one hub',
      feat2Title: 'Reflect',
      feat2Desc: 'Notes &amp; multi-tags',
      feat3Title: 'Search',
      feat3Desc: 'Instant SQLite FTS',
      feat4Title: 'Deep Link',
      feat4Desc: 'Jump to original page',

      // Reading Stats Section
      statsTag: 'READING STATS &bull; BY SMUGH-TECH',
      statsTitle: 'Track Your Reading Habits, Build True Consistency',
      statsSub: 'A personal, visual dashboard capturing your literacy journey with precision, clarity, and 100% offline local privacy.',
      statsImgCaption: '📊 Reading Stats: Time, streaks, &amp; top genres',
      statsLead: 'BENEFITS FOR READERS',
      statsHeadline: 'Why Do Reading Stats Matter?',
      statsLeadDesc: 'Many intend to read consistently but lose track of their momentum. BookMind transforms daily reading into tangible data that inspires personal growth.',
      statBen1Title: 'Daily Discipline &amp; Reading Streaks',
      statBen1Desc: 'Visual streak tracker and consistency calendar help you maintain a sustainable reading rhythm amidst daily routines.',
      statBen2Title: 'Time Analytics &amp; Peak Focus Hours',
      statBen2Desc: 'Monitor total reading hours across days, weeks, and years, while uncovering your most productive reading hours.',
      statBen3Title: 'Dynamic Genre Distribution',
      statBen3Desc: 'Gain clear insight into your favorite book genres and reading diversity to balance your knowledge acquisition.',
      statBen4Title: '100% Private, Zero Social Pressure',
      statBen4Desc: 'All stats stay strictly inside your device SQLite. No public rankings, external trackers, or vanity competition.',

      // Story Section (Why it was built)
      storyTag: 'BACKGROUND &bull; BY SMUGH-TECH',
      storyTitle: 'Why Was BookMind Created?',
      storySub: 'Traditional ebook readers are designed for passive consumption, not long-term retention. BookMind solves that disconnect.',

      problemTag: 'THE PROBLEM',
      problemTitle: 'Great Insights Vanish When The Book Closes',
      problemDesc: 'While reading PDF or EPUB books, we often highlight profound ideas. But in traditional readers, highlights stay locked inside separate files, notes are hard to search, and insights from different books never connect.',

      solutionTag: 'SOLUTION',
      solutionTitle: 'A True Personal Reading Knowledge System',
      solutionDesc: 'Smugh-Tech built BookMind to help you capture quotes, write original reflections, and link cross-book topics into an offline knowledge vault that remains yours forever.',

      storyImg1Caption: '📖 Highlight text &amp; bookmark directly on the page',

      // Values Section (Core Values)
      valuesTag: 'CORE VALUES',
      valuesTitle: 'Built for Intentional, Deep Readers',

      val1Title: 'Active Reflection &amp; Multi-Tagging',
      val1Desc: 'Highlights never remain passive text. Add your own original thoughts (*My Reflection*) and tag themes across your entire library.',

      val2Title: 'Knowledge Hub &amp; Instant Deep Link',
      val2Desc: 'Lightning-fast full-text search powered by SQLite FTS. One click on any note jumps you straight back to the original page in the book.',

      val3Title: '100% Offline &amp; Complete Privacy',
      val3Desc: 'No sign-up, no cloud tracking, and zero ads. Your book files, highlights, and notes stay strictly on your local Android device.',

      storyImg2Caption: '🧠 Knowledge Hub: All notes &amp; fast FTS search',

      // Footer
      footerNote: 'Offline-First Android App &bull; Drift SQLite',
      footerCopy: '&copy; 2026 BookMind by Smugh-Tech. All rights reserved.',

      // Toast Notice
      toastApkDownloading: '📥 Downloading BookMind v.1.0.3 APK...'
    }
  };

  // Localized Screenshot Images
  const screenshotImages = {
    id: {
      heroImg: 'assets/reader_highlight.png',
      storyImg1: 'assets/reader_highlight.png',
      storyImg2: 'assets/knowledge_hub.png',
      statsImg: 'assets/reading_stats.png'
    },
    en: {
      heroImg: 'assets/en/reader_highlight.png',
      storyImg1: 'assets/en/reader_highlight.png',
      storyImg2: 'assets/en/knowledge_hub.png',
      statsImg: 'assets/en/reading_stats.png'
    }
  };

  // DOM Elements
  const langIdBtn = document.getElementById('langIdBtn');
  const langEnBtn = document.getElementById('langEnBtn');
  const downloadApkBtn = document.getElementById('downloadApkBtn');
  const toastNotice = document.getElementById('toastNotice');

  // Switch Language Implementation
  function setLanguage(lang) {
    currentLang = lang;
    localStorage.setItem('bookmind_lang', lang);
    document.documentElement.lang = lang;

    // Toggle active state on language buttons
    if (langIdBtn && langEnBtn) {
      langIdBtn.classList.toggle('active', lang === 'id');
      langEnBtn.classList.toggle('active', lang === 'en');
    }

    // Translate all elements with data-i18n attribute
    const dictionary = i18n[lang];
    if (dictionary) {
      document.querySelectorAll('[data-i18n]').forEach(el => {
        const key = el.getAttribute('data-i18n');
        if (dictionary[key]) {
          el.innerHTML = dictionary[key];
        }
      });
    }

    // Swap Screenshot Images dynamically
    const imgMap = screenshotImages[lang];
    if (imgMap) {
      Object.keys(imgMap).forEach(imgId => {
        const imgEl = document.getElementById(imgId);
        if (imgEl && imgEl.getAttribute('src') !== imgMap[imgId]) {
          imgEl.style.opacity = '0';
          setTimeout(() => {
            imgEl.src = imgMap[imgId];
            imgEl.style.opacity = '1';
          }, 120);
        }
      });
    }
  }

  // Language Button Listeners
  if (langIdBtn) {
    langIdBtn.addEventListener('click', () => setLanguage('id'));
  }
  if (langEnBtn) {
    langEnBtn.addEventListener('click', () => setLanguage('en'));
  }

  // Toast Notification for Download APK
  let toastTimer = null;
  function showToast(message) {
    if (!toastNotice) return;
    toastNotice.textContent = message;
    toastNotice.classList.add('show');

    if (toastTimer) clearTimeout(toastTimer);
    toastTimer = setTimeout(() => {
      toastNotice.classList.remove('show');
    }, 3500);
  }

  if (downloadApkBtn) {
    downloadApkBtn.addEventListener('click', () => {
      const msg = i18n[currentLang]?.toastApkDownloading || '📥 Mengunduh BookMind v.1.0.3 APK...';
      showToast(msg);
    });
  }

  // Smooth Scroll for anchor links
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function(e) {
      const href = this.getAttribute('href');
      if (href === '#' || !href) return;
      const target = document.querySelector(href);
      if (target) {
        e.preventDefault();
        window.scrollTo({
          top: target.offsetTop - 60,
          behavior: 'smooth'
        });
      }
    });
  });

  // Initialize with selected language
  setLanguage(currentLang);
});
