# 🚀 FinSight - Solusi Manajemen Keuangan & POS UMKM Modern

FinSight adalah aplikasi **Point of Sale (POS)** dan **Manajemen Keuangan** cerdas yang dirancang khusus untuk memberdayakan UMKM melalui digitalisasi. Dengan antarmuka yang sangat premium, modern, dan intuitif, FinSight memudahkan pemilik usaha dalam mengelola operasional bisnis dari satu genggaman.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Laravel](https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Status](https://img.shields.io/badge/Status-77%25_Fungsional-green?style=for-the-badge)

---

## ✨ Fitur Utama

### 1. 📊 Dashboard Analitik

- **Statistik Real-time**: Visualisasi total pendapatan, jumlah transaksi, dan total produk harian.
- **Menu Sirkular Modern**: Layout navigasi yang dinamis dan futuristik untuk akses cepat ke semua fitur.
- **Greeting Personal**: Interface yang ramah dengan sambutan berbasis waktu dan format tanggal lokal.

### 2. 🛒 Sistem Kasir (Point of Sale)

- **Katalog Interaktif**: Tampilan grid produk profesional dengan dukungan kategori dan pencarian instan.
- **Smart Shopping Cart**: Manajemen keranjang belanja yang responsif dengan kalkulasi total otomatis.
- **Hybrid Payment**: Mendukung metode pembayaran Tunai (Cash), QRIS, dan E-Wallet.
- **Sync Stok Otomatis**: Integrasi langsung antara transaksi dan pengurangan stok barang di database.

### 3. 📦 Inventaris & Stok Pintar

- **Manajemen Produk**: Tambah dan kelola produk dengan fitur upload gambar langsung dari galeri perangkat.
- **Indikator Stok Kritis**: Sistem peringatan visual (warna merah) untuk produk yang memiliki stok di bawah ambang batas (stok menipis).
- **Quick Stock Adjust**: Fitur edit stok cepat melalui dialog interaktif tanpa meninggalkan halaman utama.

### 4. 📈 Laporan & Riwayat

- **Graphic Insights**: Grafik performa penjualan 7 hari terakhir yang interaktif menggunakan `fl_chart`.
- **Riwayat Lengkap**: Pencatatan riwayat transaksi mendetail mulai dari jam, item terjual, hingga metode pembayaran.
- **Localization**: Dukungan penuh format Mata Uang Rupiah (IDR) dan Bahasa Indonesia.

---

## 🎨 Desain & Estetika (UI/UX)

FinSight dibangun dengan standar desain modern yang sangat premium:

- **Warna Utama**: Deep Navy Blue (#0F172A) & Emerald Green (#10B981).
- **Typography**: Menggunakan **Google Fonts - Inter** untuk keterbacaan tingkat tinggi.
- **Design System**: Implementasi penuh **Material 3** dengan sentuhan glassmorphism dan bayangan halus.
- **Micro-Interactions**: Animasi transisi halaman dan feedback tombol yang sangat halus (smooth).

---

## 🏗️ Tech Stack & Arsitektur

### **Frontend**

- **Framework**: `Flutter ^3.10.0`
- **State Management**: `Provider` (Reactive State)
- **Networking**: `http` (REST API Integration)
- **Charts**: `fl_chart`
- **Storage**: `shared_preferences` & `sqflite`
- **Hardware Integrasi**: `blue_thermal_printer`, `image_picker`, `mobile_scanner`

### **Backend**

- **Framework**: `Laravel` (Sebagai API Engine)
- **Database**: `MySQL`
- **Authentication**: `Sanctum/Token-based`

### **Struktur Folder**

```bash
lib/
├── core/               # Konfigurasi, Tema, Utils, & Service API
├── features/           # Modul fitur mandiri (Auth, POS, Laporan, dll)
│   ├── auth/           # Login & Session Management
│   ├── dashboard/      # Statistik & Navigasi Utama
│   ├── kasir/          # Mesin POS & Keranjang
│   ├── laporan/        # Chart & Riwayat Transaksi
│   └── produk/         # Manajemen Inventaris
└── shared/             # Widget global yang dapat digunakan kembali
```

---

## 🚀 Panduan Instalasi Cepat

### **Langkah 1: Setup Backend (Laravel)**

1.  Masuk ke direktori `backend/`.
2.  Copy `.env.example` ke `.env` dan atur koneksi database Anda.
3.  Jalankan perintah:
    ```bash
    composer install
    php artisan migrate --seed
    php artisan serve
    ```

### **Langkah 2: Setup Frontend (Flutter)**

1.  Pastikan Anda berada di root project FinSight.
2.  Pastikan Flutter SDK sudah terpasang dan terdeteksi.
3.  Jalankan perintah:
    ```bash
    flutter pub get
    flutter run
    ```
    _(Catatan: Rekomendasi menjalankan di Emulator Android atau Perangkat Windows)_

---

## 📅 Roadmap Pengembangan

- [x] Integrasi Real-time Dashboard & Stats.
- [x] Upload Gambar Produk ke Cloud/Server.
- [x] Sistem Kasir Terintegrasi Stok.
- [ ] ⏳ **Next**: Export Laporan ke Excel & PDF.
- [ ] ⏳ **Next**: Implementasi Cetak Struk via Bluetooth Printer.
- [ ] ⏳ **Next**: Notifikasi Push untuk Laporan Harian.


---

**FinSight** - _Cerdas Mengelola, Cepat Berkembang._
