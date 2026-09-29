# 📦 Book&Mind - Release Distribution Directory

Folder ini berisi berkas instalasi aplikasi **Book&Mind** yang siap rilis dan diunduh langsung untuk pengujian maupun pemasangan di perangkat Android.

---

## 📱 Berkas Rilis Saat Ini

| Informasi | Keterangan |
| :--- | :--- |
| **Nama Berkas** | [`BookMind-v.1.0.2.apk`](./BookMind-v.1.0.2.apk) |
| **Versi Aplikasi** | `v1.0.2` (Build `3`) |
| **Tanggal Build** | 29 September 2026 |
| **Ukuran Berkas** | ~35.9 MB |
| **Target OS** | Android 5.0 (API level 21) ke atas |
| **Arsitektur** | Universal (`arm64-v8a`, `armeabi-v7a`, `x86_64`) |
| **SHA-256 Checksum** | `4ebff10f573e5277987c3859acf8d91f50b07aa0127c8767eb65f89527d22db4` |

---

## 🚀 Panduan Instalasi

### 1. Melalui Perangkat Android Langsung:
1. Unduh berkas [`BookMind-v.1.0.2.apk`](./BookMind-v.1.0.2.apk) ke memori ponsel.
2. Buka berkas APK melalui File Manager atau browser.
3. Izinkan *"Install unknown apps"* (Pasang aplikasi yang tidak dikenal) pada pengaturan keamanan ponsel jika diminta.
4. Klik **Install** dan buka aplikasi Book&Mind.

### 2. Melalui ADB (Android Debug Bridge):
Jalankan perintah berikut di terminal:
```bash
adb install -r release/BookMind-v.1.0.2.apk
```

---

## ✨ Fitur & Pembaruan Versi 1.0.2
- **Layar Cover HD & Motivasi Membaca**: Visual artwork cover editorial definisi tinggi (HD) 1 halaman penuh tanpa tombol aktif lain kecuali tombol geser panah (*arrow slider*) untuk masuk, dilengkapi rotasi kalimat motivasi membaca harian.
- **Ikon Aplikasi Resmi & Favicon**: Seluruh icon Android (hdpi, mdpi, xhdpi, xxhdpi, xxxhdpi) dan favicon web menggunakan logo resmi Book&Mind berbentuk buku terbuka bernuansa terracotta & cream.
- **Pengalaman Catatan Tanpa Hambatan (Add Notes)**: Tombol *Add notes* tersedia langsung pada navbar atas di samping menu *Bookmark*, memungkinkan pencatatan refleksi per halaman tanpa perlu memblok teks atau terganggu floating action menu.
- **Manajemen Profil & Kustomisasi Email**: Informasi default pengguna `"No name"` dan `"Noname@email.com"` yang dapat diperbarui secara interaktif melalui modal dialog profil.
- **Statistik Baca Bersih (Zero-State)**: Tampilan statistik membaca awal yang bersih dan akurat tanpa dummy data—semua metrik, grafik, dan riwayat sesi terisi dinamis sesuai aktivitas riil.
- **100% Offline & Bebas Iklan**: Tanpa ketergantungan server cloud, login, maupun analitik pihak ketiga. Seluruh buku, progres baca, dan catatan tersimpan aman di database SQLite lokal.
- **Pengaturan Tampilan & Ekspor Catatan**: Kustomisasi foto profil dan foto cover depan dengan tombol reset ke default bawaan, serta ekspor catatan ke format Markdown (.md) dan Plain Text (.txt).
- **Dukungan Bilingual**: Tersedia dalam Bahasa Indonesia 🇮🇩 dan English 🇬🇧.
- **Informasi Creator**: Identitas persembahan karya oleh `smugh-tech`.
