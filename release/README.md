# 📦 BookMind - Release Distribution Directory

Folder ini berisi berkas instalasi aplikasi **BookMind** yang siap rilis dan diunduh langsung untuk pengujian maupun pemasangan di perangkat Android.

---

## 📱 Berkas Rilis Saat Ini

| Informasi | Keterangan |
| :--- | :--- |
| **Nama Berkas** | [`BookMind-v1.0.0.apk`](./BookMind-v1.0.0.apk) |
| **Versi Aplikasi** | `v1.0.0` (Build `1`) |
| **Tanggal Build** | 28 September 2026 |
| **Ukuran Berkas** | ~33.7 MB |
| **Target OS** | Android 5.0 (API level 21) ke atas |
| **Arsitektur** | Universal (`arm64-v8a`, `armeabi-v7a`, `x86_64`) |
| **SHA-256 Checksum** | `188acc1d3441f7195d201a0b1c7ccd4d8e99396a2f86b0174e5942a15ec5cf85` |

---

## 🚀 Panduan Instalasi

### 1. Melalui Perangkat Android Langsung:
1. Unduh berkas [`BookMind-v1.0.0.apk`](./BookMind-v1.0.0.apk) ke memori ponsel.
2. Buka berkas APK melalui File Manager atau browser.
3. Izinkan *"Install unknown apps"* (Pasang aplikasi yang tidak dikenal) pada pengaturan keamanan ponsel jika diminta.
4. Klik **Install** dan buka aplikasi BookMind.

### 2. Melalui ADB (Android Debug Bridge):
Jalankan perintah berikut di terminal:
```bash
adb install -r release/BookMind-v1.0.0.apk
```

---

## ✨ Fitur Utama Versi 1.0.0
- **100% Offline & Private**: Menggunakan penyimpanan database SQLite lokal terenkripsi (Drift ORM) tanpa ketergantungan server luar.
- **Zero-Layout-Shift Ebook Reader**: Pembacaan PDF & EPUB yang nyaman dengan highlight teks natural (`TextStyle.backgroundColor`) tanpa mengubah margin atau perataan baris teks buku.
- **Interactive Sticky Notes & Reflection**: Catatan dan refleksi tersimpan rapi dan dapat dibuka kembali kapan saja via modal sheet interaktif.
- **Reading Stats & Habit Tracker**: Kalender bacaan harian, streak membaca, dan jam baca paling aktif.
- **Knowledge Hub**: Pengarsipan kutipan (*quotes*), refleksi pribadi, dan pencarian cepat berdasarkan tag/kategori.
