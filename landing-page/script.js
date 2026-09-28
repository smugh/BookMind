/**
 * Book&Mind - Interactive Scripts
 * Handles bilingual (ID / EN) switching, dynamic screenshot swapping,
 * frameless User Guideline stepper, and Download APK notice.
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
      navScreenshots: 'Screenshots',
      navGuideline: '📖 User Guideline',
      navDownloadApk: 'Unduh APK',

      // Hero
      heroTagline: 'READ &bull; REFLECT &bull; GROW',
      heroTitle: 'Baca Lebih Dalam.<br><span>Ingat Lebih Lama.</span>',
      heroDesc: 'Personal reading knowledge system offline untuk Android.',
      heroBtnScreenshots: 'Screenshots',
      heroBtnGuideline: 'User Guideline',
      heroPillOffline: '100% Offline',
      heroPillFormats: 'PDF &amp; EPUB',
      heroPillSqlite: 'SQLite Local',

      // Features
      feat1Title: 'Highlight',
      feat1Desc: 'Terkumpul di satu hub',
      feat2Title: 'Refleksi',
      feat2Desc: 'Catatan &amp; multi-tag',
      feat3Title: 'Pencarian',
      feat3Desc: 'SQLite FTS instan',
      feat4Title: 'Deep Link',
      feat4Desc: 'Lompat ke halaman asal',

      // Screenshots Showcase
      screensTag: 'ANTARMUKA APLIKASI',
      screensTitle: 'Screenshots',
      screensSub: 'Antarmuka minimalis bernuansa buku fisik yang dirancang untuk fokus membaca tanpa distraksi.',

      card1Tag: '01 &bull; PEMBACA',
      card1Title: 'Reader &amp; Highlight',
      card1Desc: 'Anotasi multi-warna &amp; navigasi progres membaca',

      card2Tag: '02 &bull; KATALOG',
      card2Title: 'Perpustakaan',
      card2Desc: 'Koleksi offline &amp; filter status baca terorganisir',

      card3Tag: '03 &bull; INSIGHT',
      card3Title: 'Knowledge Hub',
      card3Desc: 'Sentralisasi kutipan, refleksi, &amp; pencarian cepat',

      card4Tag: '04 &bull; ANALISIS',
      card4Title: 'Statistik Membaca',
      card4Desc: 'Metrik halaman dibaca &amp; grafik kebiasaan membaca',

      card5Tag: '05 &bull; DOKUMEN',
      card5Title: 'Detail Buku',
      card5Desc: 'Sinopsis, cover otomatis, &amp; metadata file buku',

      card6Tag: '06 &bull; ONBOARDING',
      card6Title: 'Onboarding',
      card6Desc: 'Pengenalan filosofi baca mendalam &amp; alur aplikasi',

      // User Guideline Section Header
      guideSectionTag: 'PANDUAN APLIKASI',
      guideSectionTitle: 'User Guideline',
      guideTab1: 'Import Buku',
      guideTab2: 'Highlight Teks',
      guideTab3: 'Refleksi &amp; Tag',
      guideTab4: 'Knowledge Hub',

      // Footer
      footerNote: 'Offline-First Android App &bull; Drift SQLite',

      // Toast Notice
      toastApkSoon: '📦 Link unduh APK akan segera tersedia!',

      // Guide navigation buttons
      guidePrevText: '&larr; Sebelumnya',
      guideNextText: 'Langkah Berikutnya &rarr;',
      guideRestartText: 'Kembali ke Awal &#8634;'
    },
    en: {
      // Navbar
      navFeatures: 'Features',
      navScreenshots: 'Screenshots',
      navGuideline: '📖 User Guideline',
      navDownloadApk: 'Download APK',

      // Hero
      heroTagline: 'READ &bull; REFLECT &bull; GROW',
      heroTitle: 'Read Deeper.<br><span>Remember Longer.</span>',
      heroDesc: 'Offline personal reading knowledge system for Android.',
      heroBtnScreenshots: 'Screenshots',
      heroBtnGuideline: 'User Guideline',
      heroPillOffline: '100% Offline',
      heroPillFormats: 'PDF &amp; EPUB',
      heroPillSqlite: 'SQLite Local',

      // Features
      feat1Title: 'Highlight',
      feat1Desc: 'Collected in one hub',
      feat2Title: 'Reflect',
      feat2Desc: 'Notes &amp; multi-tags',
      feat3Title: 'Search',
      feat3Desc: 'Instant SQLite FTS',
      feat4Title: 'Deep Link',
      feat4Desc: 'Jump to original page',

      // Screenshots Showcase
      screensTag: 'APP INTERFACE',
      screensTitle: 'Screenshots',
      screensSub: 'A physical book-inspired minimalist interface designed for distraction-free, focused reading.',

      card1Tag: '01 &bull; READER',
      card1Title: 'Reader &amp; Highlight',
      card1Desc: 'Multi-color annotations &amp; reading progress slider',

      card2Tag: '02 &bull; CATALOG',
      card2Title: 'Library',
      card2Desc: 'Offline book collection &amp; organized reading status filters',

      card3Tag: '03 &bull; INSIGHT',
      card3Title: 'Knowledge Hub',
      card3Desc: 'Centralized quotes, personal reflections, &amp; quick search',

      card4Tag: '04 &bull; ANALYTICS',
      card4Title: 'Reading Stats',
      card4Desc: 'Daily page metrics &amp; long-term reading habit trends',

      card5Tag: '05 &bull; DOCUMENT',
      card5Title: 'Book Details',
      card5Desc: 'Synopsis, auto-extracted cover, &amp; document metadata',

      card6Tag: '06 &bull; ONBOARDING',
      card6Title: 'Onboarding',
      card6Desc: 'Deep reading philosophy &amp; quick app walkthrough',

      // User Guideline Section Header
      guideSectionTag: 'APP WALKTHROUGH',
      guideSectionTitle: 'User Guideline',
      guideTab1: 'Import Books',
      guideTab2: 'Highlight Text',
      guideTab3: 'Reflect &amp; Tag',
      guideTab4: 'Knowledge Hub',

      // Footer
      footerNote: 'Offline-First Android App &bull; Drift SQLite',

      // Toast Notice
      toastApkSoon: '📦 The APK download link will be available soon!',

      // Guide navigation buttons
      guidePrevText: '&larr; Previous',
      guideNextText: 'Next Step &rarr;',
      guideRestartText: 'Back to Start &#8634;'
    }
  };

  // Localized User Guideline Steps Data
  const stepsData = {
    id: {
      '1': {
        tag: 'LANGKAH 01 DARI 04',
        title: 'Import PDF & EPUB',
        lead: 'Tambahkan dokumen buku langsung dari penyimpanan perangkat. Metadata judul, pengarang, dan sampul buku otomatis terekstrak ke katalog lokal.',
        bullets: [
          'Dukungan file format .PDF & .EPUB',
          'Ekstraksi cover & metadata otomatis',
          '100% offline, data tetap aman di perangkat'
        ],
        badge: '📚 Koleksi & Resume Halaman',
        img: 'assets/home_library.png'
      },
      '2': {
        tag: 'LANGKAH 02 DARI 04',
        title: 'Membaca & Highlight',
        lead: 'Buka buku seketika pada posisi halaman terakhir kamu membaca. Seleksi teks penting dan beri penanda warna tematik yang nyaman di mata.',
        bullets: [
          'Persistensi posisi membaca otomatis',
          'Pilihan warna Yellow, Green, dan Blue',
          'Tampilan bersih tanpa gangguan iklan'
        ],
        badge: '🖍️ Highlight Nyaman di Mata',
        img: 'assets/reader_highlight.png'
      },
      '3': {
        tag: 'LANGKAH 03 DARI 04',
        title: 'Tulis Refleksi & Tag',
        lead: 'Jangan biarkan kutipan berhenti sebagai teks pasif. Tuangkan pemikiran orisinalmu (*My Reflection*) dan sematkan tag topik lintas buku.',
        bullets: [
          'Tulis catatan refleksi & ide aksi nyata',
          'Multi-tagging untuk menghubungkan topik',
          'Tersimpan seketika di SQLite lokal'
        ],
        badge: '💡 Refleksi & Multi-Tagging',
        img: 'assets/notes_modal.png'
      },
      '4': {
        tag: 'LANGKAH 04 DARI 04',
        title: 'Knowledge Hub & Deep Link',
        lead: 'Sentral seluruh insight dari semua buku yang pernah kamu baca. Temukan gagasan seketika dan lompat langsung ke nomor halaman asal.',
        bullets: [
          'Pencarian teks instan via SQLite FTS',
          'Filter berdasarkan judul buku & label tag',
          '1-Klik Deep Link langsung ke halaman sumber'
        ],
        badge: '🔗 1-Klik Kembali ke Hal. 84',
        img: 'assets/knowledge_hub.png'
      }
    },
    en: {
      '1': {
        tag: 'STEP 01 OF 04',
        title: 'Import PDF & EPUB',
        lead: 'Add book files directly from your device storage. Title, author, and cover are automatically extracted into your local catalog.',
        bullets: [
          'Full support for .PDF & .EPUB files',
          'Automatic cover & metadata extraction',
          '100% offline, your files remain strictly local'
        ],
        badge: '📚 Catalog & Page Resume',
        img: 'assets/en/home_library.png'
      },
      '2': {
        tag: 'STEP 02 OF 04',
        title: 'Read & Highlight',
        lead: 'Jump straight into your last-read page. Select key phrases and highlight them with warm, eye-friendly paper tones.',
        bullets: [
          'Automatic reading position persistence',
          'Warm Yellow, Sage Green, and Soft Blue palettes',
          'Pure, distraction-free reading experience'
        ],
        badge: '🖍️ Eye-Friendly Highlights',
        img: 'assets/en/reader_highlight.png'
      },
      '3': {
        tag: 'STEP 03 OF 04',
        title: 'Reflect & Tag Topics',
        lead: 'Never let quotes remain passive words. Capture your original thoughts (*My Reflection*) and link them across books using topic tags.',
        bullets: [
          'Draft personal reflections & action items',
          'Multi-tagging to connect related themes',
          'Saved instantly in local SQLite storage'
        ],
        badge: '💡 Reflections & Multi-Tagging',
        img: 'assets/en/notes_modal.png'
      },
      '4': {
        tag: 'STEP 04 OF 04',
        title: 'Knowledge Hub & Deep Link',
        lead: 'The central hub for all wisdom across every book you have read. Find thoughts instantly and leap directly back to the original page.',
        bullets: [
          'Instant text search powered by SQLite FTS',
          'Filter by book title & topic tags',
          '1-Click Deep Link back to the exact page'
        ],
        badge: '🔗 1-Click Jump to Page 84',
        img: 'assets/en/knowledge_hub.png'
      }
    }
  };

  // Localized Screenshots Image Maps
  const screenshotImages = {
    id: {
      heroImg: 'assets/reader_highlight.png',
      screenImg1: 'assets/reader_highlight.png',
      screenImg2: 'assets/home_library.png',
      screenImg3: 'assets/knowledge_hub.png',
      screenImg4: 'assets/reading_stats.png',
      screenImg5: 'assets/book_detail.png',
      screenImg6: 'assets/onboarding.png'
    },
    en: {
      heroImg: 'assets/en/reader_highlight.png',
      screenImg1: 'assets/en/reader_highlight.png',
      screenImg2: 'assets/en/home_library.png',
      screenImg3: 'assets/en/knowledge_hub.png',
      screenImg4: 'assets/en/reading_stats.png',
      screenImg5: 'assets/en/book_detail.png',
      screenImg6: 'assets/en/onboarding.png'
    }
  };

  // DOM Elements
  const langIdBtn = document.getElementById('langIdBtn');
  const langEnBtn = document.getElementById('langEnBtn');
  const downloadApkBtn = document.getElementById('downloadApkBtn');
  const toastNotice = document.getElementById('toastNotice');

  let currentStep = 1;
  const totalSteps = 4;

  const stepTabs = document.querySelectorAll('.g-step-tab');
  const guideTag = document.getElementById('guideTag');
  const guideTitle = document.getElementById('guideTitle');
  const guideLead = document.getElementById('guideLead');
  const guideBullets = document.getElementById('guideBullets');
  const guideBadge = document.getElementById('guideBadge');
  const guideImg = document.getElementById('guideImg');
  const guidePrev = document.getElementById('guidePrev');
  const guideNext = document.getElementById('guideNext');

  // Switch Language Implementation
  function setLanguage(lang) {
    currentLang = lang;
    localStorage.setItem('bookmind_lang', lang);
    document.documentElement.lang = lang;

    // Toggle active state on buttons
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

    // Swap Screenshot Images
    const imgMap = screenshotImages[lang];
    if (imgMap) {
      Object.keys(imgMap).forEach(imgId => {
        const imgEl = document.getElementById(imgId);
        if (imgEl && imgEl.src !== imgMap[imgId]) {
          imgEl.src = imgMap[imgId];
        }
      });
    }

    // Re-render current User Guideline step with new language
    renderStep(currentStep);
  }

  // Language Button Listeners
  if (langIdBtn) {
    langIdBtn.addEventListener('click', () => setLanguage('id'));
  }
  if (langEnBtn) {
    langEnBtn.addEventListener('click', () => setLanguage('en'));
  }

  // Render User Guideline Step
  function renderStep(step) {
    currentStep = parseInt(step);
    const langSteps = stepsData[currentLang] || stepsData.id;
    const data = langSteps[currentStep];
    const dict = i18n[currentLang] || i18n.id;
    if (!data) return;

    // Update active tab in stepper bar
    stepTabs.forEach(tab => {
      const tabStep = parseInt(tab.getAttribute('data-step'));
      tab.classList.toggle('active', tabStep === currentStep);
    });

    // Update left column text
    if (guideTag) guideTag.textContent = data.tag;
    if (guideTitle) guideTitle.textContent = data.title;
    if (guideLead) guideLead.textContent = data.lead;
    if (guideBadge) guideBadge.textContent = data.badge;

    if (guideBullets) {
      guideBullets.innerHTML = data.bullets
        .map(b => `<li class="guide-bullet-item"><span class="guide-bullet-icon">✓</span><span>${b}</span></li>`)
        .join('');
    }

    // Update right mockup image smoothly
    if (guideImg) {
      guideImg.style.opacity = '0';
      setTimeout(() => {
        guideImg.src = data.img;
        guideImg.style.opacity = '1';
      }, 120);
    }

    // Update button states and localized labels
    if (guidePrev) {
      guidePrev.innerHTML = dict.guidePrevText;
      guidePrev.disabled = currentStep === 1;
      guidePrev.style.opacity = currentStep === 1 ? '0.45' : '1';
      guidePrev.style.cursor = currentStep === 1 ? 'default' : 'pointer';
    }
    if (guideNext) {
      guideNext.innerHTML = currentStep === totalSteps ? dict.guideRestartText : dict.guideNextText;
    }
  }

  stepTabs.forEach(tab => {
    tab.addEventListener('click', () => {
      renderStep(tab.getAttribute('data-step'));
    });
  });

  if (guidePrev) {
    guidePrev.addEventListener('click', () => {
      if (currentStep > 1) renderStep(currentStep - 1);
    });
  }

  if (guideNext) {
    guideNext.addEventListener('click', () => {
      if (currentStep < totalSteps) {
        renderStep(currentStep + 1);
      } else {
        renderStep(1);
      }
    });
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
      const msg = i18n[currentLang]?.toastApkSoon || '📦 File APK akan segera tersedia untuk diunduh!';
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
