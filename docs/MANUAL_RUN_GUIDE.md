# 🚀 Panduan Menjalankan FinSight (Full Stack)

Panduan ini akan membantu Anda menjalankan aplikasi FinSight secara manual, yang terdiri dari **Backend (Laravel)** dan **Frontend (Flutter)** agar dapat berjalan bersamaan.

---

## 📋 Prasyarat (Prerequisites)

Pastikan Anda telah menginstal tools berikut:

1.  **XAMPP** atau **Laragon** (Untuk Database MySQL & PHP).
2.  **Composer** (Untuk dependensi PHP/Laravel).
3.  **Flutter SDK** (Untuk aplikasi Mobile/Web).
4.  **Terminal/Command Prompt** (Git Bash atau PowerShell).

---

## 🛠️ Langkah 1: Persiapan Database

1.  Jalankan **Apache** dan **MySQL** di XAMPP/Laragon Anda.
2.  Buka aplikasi pengelolaan database (seperti phpMyAdmin atau HeidiSQL).
3.  Buat database baru dengan nama: `finsight`
    - Jika menggunakan terminal MySQL:
      ```sql
      CREATE DATABASE finsight;
      ```

---

## 🔙 Langkah 2: Menjalankan Backend (Laravel)

Buka terminal baru, lalu ikuti langkah berikut:

1.  **Masuk ke folder backend:**

    ```bash
    cd C:\laragon\www\FinSight\backend
    ```

2.  **Install Dependensi (Jika belum):**

    ```bash
    composer install
    ```

3.  **Setup Environment:**

    - Pastikan file `.env` sudah ada. Jika belum, copy dari `.env.example`:
      ```bash
      cp .env.example .env
      ```
    - Edit file `.env` dan pastikan konfigurasi database benar:
      ```env
      DB_CONNECTION=mysql
      DB_HOST=127.0.0.1
      DB_PORT=3306
      DB_DATABASE=finsight
      DB_USERNAME=root
      DB_PASSWORD=
      ```

4.  **Generate Key & Migrasi Database:**

    ```bash
    php artisan key:generate
    php artisan migrate:fresh --seed
    ```

    _(Perintah `--seed` akan otomatis mengisi data User Admin, Kategori, dan Produk awal)_

5.  **Jalankan Server Laravel:**
    ```bash
    php artisan serve --host=0.0.0.0 --port=8000
    ```
    - **PENTING**: Jangan tutup terminal ini! Biarkan berjalan agar API tetap hidup.
    - Server akan berjalan di: `http://localhost:8000`

---

## 📱 Langkah 3: Menjalankan Frontend (Flutter)

Buka **Terminal Baru** (terminal backend jangan ditutup), lalu:

1.  **Masuk ke folder root project:**

    ```bash
    cd C:\laragon\www\FinSight
    ```

2.  **Get Packages:**

    ```bash
    flutter pub get
    ```

3.  **Jalankan Aplikasi:**
    - **Untuk Chrome (Web):**
      ```bash
      flutter run -d chrome
      ```
    - **Untuk Windows (Desktop):**
      ```bash
      flutter run -d windows
      ```
    - **Untuk Android Emulator:**
      - _Catatan_: Pastikan `ApiService` di `lib/core/services/api_service.dart` menggunakan IP `10.0.2.2` bukan `127.0.0.1`.
      ```bash
      flutter run
      ```

---

## 🔑 Akun Login Demo

Gunakan akun berikut untuk masuk ke aplikasi:

- **Email**: `admin@finsight.com`
- **Password**: `password`

---

## ❓ Troubleshooting

**Masalah**: "Connection refused" atau "Failed to load data".

- **Solusi**:
  1.  Pastikan Server Laravel (Langkah 2) masih berjalan.
  2.  Pastikan MySQL (XAMPP/Laragon) berjalan.
  3.  Cek URL di `lib/core/services/api_service.dart`. Jika di Android Emulator, gunakan `10.0.2.2:8000`. Jika di Chrome/Windows, gunakan `127.0.0.1:8000`.

**Masalah**: Data transaksi/produk masih kosong setelah login.

- **Solusi**: Jalankan ulang seeding database:
  ```bash
  cd backend
  php artisan migrate:fresh --seed
  ```
