# Panduan Menjalankan FinSight

## 📱 Menjalankan di Android

### Opsi 1: Menggunakan Emulator Android

1. **Buka Android Studio**

   - Buka AVD Manager (Tools > AVD Manager)
   - Pilih atau buat emulator baru
   - Klik tombol Play untuk menjalankan emulator

2. **Jalankan Aplikasi**

   ```bash
   cd C:\laragon\www\FinSight
   flutter run
   ```

3. **Aplikasi akan otomatis terinstall di emulator**

### Opsi 2: Menggunakan Perangkat Fisik

1. **Aktifkan USB Debugging di HP Android**

   - Buka Settings > About Phone
   - Tap "Build Number" 7 kali untuk aktifkan Developer Options
   - Kembali ke Settings > Developer Options
   - Aktifkan "USB Debugging"

2. **Hubungkan HP ke Komputer**

   - Gunakan kabel USB
   - Izinkan USB Debugging saat muncul popup

3. **Cek Perangkat Terdeteksi**

   ```bash
   flutter devices
   ```

4. **Jalankan Aplikasi**
   ```bash
   flutter run
   ```

---

## 💻 Menjalankan di Windows

### Prasyarat

Windows 10/11 dengan Developer Mode aktif

### Langkah-langkah:

1. **Aktifkan Developer Mode**

   - Tekan `Win + I` untuk buka Settings
   - Pilih "Privacy & Security" > "For developers"
   - Aktifkan "Developer Mode"

   **ATAU jalankan command:**

   ```bash
   start ms-settings:developers
   ```

2. **Jalankan Aplikasi**

   ```bash
   cd C:\laragon\www\FinSight
   flutter run -d windows
   ```

3. **Build Release (Optional)**
   ```bash
   flutter build windows
   ```
   File executable ada di: `build\windows\runner\Release\finsight.exe`

---

## 🌐 Menjalankan di Web (Chrome)

```bash
cd C:\laragon\www\FinSight
flutter run -d chrome
```

**Build untuk production:**

```bash
flutter build web
```

Output ada di folder `build/web/`

---

## 🍎 Menjalankan di iOS/macOS

**Catatan:** Memerlukan macOS dan Xcode

```bash
# iOS
flutter run -d ios

# macOS
flutter run -d macos
```

---

## 🔧 Troubleshooting

### Error: "Building with plugins requires symlink support"

**Solusi:** Aktifkan Developer Mode di Windows

```bash
start ms-settings:developers
```

### Error: "No devices found"

**Solusi:**

1. Pastikan emulator sudah running
2. Atau HP sudah terhubung dengan USB Debugging aktif
3. Jalankan `flutter doctor` untuk cek masalah

### Error: "Gradle build failed"

**Solusi:**

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Error: "CocoaPods not installed" (iOS)

**Solusi:**

```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
flutter run
```

---

## 🚀 Hot Reload & Hot Restart

Saat aplikasi running:

- **Hot Reload**: Tekan `r` di terminal (untuk update UI tanpa restart)
- **Hot Restart**: Tekan `R` di terminal (restart app dengan state baru)
- **Quit**: Tekan `q` di terminal

---

## 📦 Build untuk Production

### Android APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (untuk Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### Windows

```bash
flutter build windows --release
```

Output: `build/windows/runner/Release/`

### Web

```bash
flutter build web --release
```

Output: `build/web/`

---

## 🎯 Tips Performance

1. **Selalu gunakan `const` constructor** untuk widget yang tidak berubah
2. **Gunakan `flutter run --profile`** untuk test performance
3. **Gunakan `flutter run --release`** untuk test performa production

---

## 📊 Monitoring & Debugging

### Flutter DevTools

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

### Logs

```bash
flutter logs
```

### Analyze Code

```bash
flutter analyze
```

### Format Code

```bash
flutter format lib/
```

---

## ✅ Checklist Sebelum Deploy

- [ ] Jalankan `flutter analyze` - tidak ada error
- [ ] Jalankan `flutter test` - semua test pass
- [ ] Test di berbagai device/emulator
- [ ] Update version di `pubspec.yaml`
- [ ] Update CHANGELOG.md
- [ ] Build release version
- [ ] Test release build

---

**Happy Coding! 🚀**
