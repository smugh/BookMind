# 📦 Book&Mind - Release Distribution Directory

Folder ini berisi berkas instalasi aplikasi **Book&Mind** yang siap rilis dan diunduh langsung untuk pengujian maupun pemasangan di perangkat Android.

---

## 📱 Berkas Rilis Saat Ini

| Informasi | Keterangan |
| :--- | :--- |
| **Nama Berkas** | [`BookMind-v.1.0.3.apk`](./BookMind-v.1.0.3.apk) |
| **Versi Aplikasi** | `v1.0.3` (Build `4`) |
| **Tanggal Build** | 29 September 2026 |
| **Target OS** | Android 5.0 (API level 21) ke atas |
| **Arsitektur** | Universal (`arm64-v8a`, `armeabi-v7a`, `x86_64`) |

---

## 🚀 Panduan Instalasi

### 1. Melalui Perangkat Android Langsung:
1. Unduh berkas [`BookMind-v.1.0.3.apk`](./BookMind-v.1.0.3.apk) ke memori ponsel.
2. Buka berkas APK melalui File Manager atau browser.
3. Izinkan *"Install unknown apps"* (Pasang aplikasi yang tidak dikenal) pada pengaturan keamanan ponsel jika diminta.
4. Klik **Install** dan buka aplikasi Book&Mind.

### 2. Melalui ADB (Android Debug Bridge):
Jalankan perintah berikut di terminal:
```bash
adb install -r release/BookMind-v.1.0.3.apk
```

---

## ✨ Fitur & Pembaruan Versi 1.0.3
- **Menu Edit Informasi Buku**: Menu baru pada detail buku untuk mengubah judul, penulis, dan genre buku yang langsung tersimpan di database lokal.
- **Statistik Genre Favorit Dinamis**: Section "Genre Favorit" pada profil membaca kini mengkalkulasi waktu dan buku secara akurat berdasarkan genre buku yang dibaca.
- **Tombol Record & Pop-up Mulai Sesi**: Tombol catat sesi membaca di reader didesain lebih menonjol (pulsing red pill) dan pop-up dialog otomatis muncul saat mulai membaca buku.
- **Kutipan / Quotes Editable**: Form catatan refleksi kini memiliki kolom quotes yang dapat diisi dan diedit secara bebas.
- **Pembersihan Antarmuka**: Menghilangkan label teks yang tidak diperlukan pada formulir catatan refleksi.

---

## 📜 Riwayat Versi Sebelumnya (v1.0.2)
- **Layar Cover HD & Motivasi Membaca**: Visual artwork cover editorial definisi tinggi (HD) 1 halaman penuh tanpa tombol aktif lain kecuali tombol geser panah (*arrow slider*) untuk masuk, dilengkapi rotasi kalimat motivasi membaca harian.
- **Ikon Aplikasi Resmi & Favicon**: Seluruh icon Android dan favicon web menggunakan logo resmi Book&Mind berbentuk buku terbuka bernuansa terracotta & cream.
- **Pengalaman Catatan Tanpa Hambatan (Add Notes)**: Tombol *Add notes* tersedia langsung pada navbar atas di samping menu *Bookmark*.
- **Manajemen Profil & Kustomisasi Email**: Informasi pengguna yang dapat diperbarui secara interaktif.
- **Statistik Baca Bersih (Zero-State)**: Tampilan statistik membaca awal yang bersih tanpa dummy data.
- **100% Offline & Bebas Iklan**: Seluruh buku, progres baca, dan catatan tersimpan aman di database SQLite lokal.
- **Dukungan Bilingual**: Tersedia dalam Bahasa Indonesia 🇮🇩 dan English 🇬🇧.
- **Informasi Creator**: Identitas persembahan karya oleh `smugh-tech`.
