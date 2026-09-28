# 📦 Book&Mind - Release Distribution Directory

Folder ini berisi berkas instalasi aplikasi **Book&Mind** yang siap rilis dan diunduh langsung untuk pengujian maupun pemasangan di perangkat Android.

---

## 📱 Berkas Rilis Saat Ini

| Informasi | Keterangan |
| :--- | :--- |
| **Nama Berkas** | [`BookMind-v1.0.0.apk`](./BookMind-v1.0.0.apk) |
| **Versi Aplikasi** | `v1.0.0` (Build `1`) |
| **Tanggal Build** | 28 September 2026 |
| **Ukuran Berkas** | ~34.6 MB |
| **Target OS** | Android 5.0 (API level 21) ke atas |
| **Arsitektur** | Universal (`arm64-v8a`, `armeabi-v7a`, `x86_64`) |
| **SHA-256 Checksum** | `cda3dae4677c21bcb8b1042273cb9139cb259a900e245b5c94e1753721c4b081` |

---

## 🚀 Panduan Instalasi

### 1. Melalui Perangkat Android Langsung:
1. Unduh berkas [`BookMind-v1.0.0.apk`](./BookMind-v1.0.0.apk) ke memori ponsel.
2. Buka berkas APK melalui File Manager atau browser.
3. Izinkan *"Install unknown apps"* (Pasang aplikasi yang tidak dikenal) pada pengaturan keamanan ponsel jika diminta.
4. Klik **Install** dan buka aplikasi Book&Mind.

### 2. Melalui ADB (Android Debug Bridge):
Jalankan perintah berikut di terminal:
```bash
adb install -r release/BookMind-v1.0.0.apk
```

---

## ✨ Fitur Utama Versi 1.0.0
- **Layar Cover PRD & Motivasi Membaca**: Halaman cover depan bernuansa hangat dengan visual artwork resmi PRD, rotasi kalimat motivasi inspiratif harian untuk membangun kebiasaan membaca, serta interaksi buka cover menggunakan tombol geser panah (*arrow slider*) responsif.
- **100% Offline & Bebas Iklan**: Tanpa ketergantungan server cloud, login, maupun analitik pihak ketiga. Seluruh buku, progres baca, dan catatan tersimpan aman di database SQLite lokal.
- **Zero-Layout-Shift Ebook Reader**: Pembacaan PDF & EPUB yang nyaman dengan highlight teks natural tanpa mengganggu margin maupun struktur teks asli buku.
- **Interactive Sticky Notes & Reflection**: Catatan dan refleksi tersimpan rapi dan dapat dibuka kembali kapan saja via modal sheet interaktif.
- **Pengaturan Tampilan & Ekspor Catatan**: Kustomisasi foto profil dan foto cover depan dengan tombol reset ke default bawaan, serta ekspor catatan ke format Markdown (.md) dan Plain Text (.txt).
- **Dukungan Bilingual**: Tersedia dalam Bahasa Indonesia 🇮🇩 dan English 🇬🇧.
- **Informasi Creator**: Identitas persembahan karya oleh `smugh-tech`.
