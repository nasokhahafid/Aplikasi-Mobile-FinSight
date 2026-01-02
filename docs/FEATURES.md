# Penjelasan Fitur FinSight

## 1. Halaman Login (`login_screen.dart`)

### Fitur:

- Form login dengan email dan password
- Logo FinSight dengan branding profesional
- Animasi loading saat proses login
- Navigasi otomatis ke Dashboard setelah login

### UI/UX:

- Background gradient Deep Navy Blue
- Card putih untuk form dengan shadow
- Icon wallet sebagai logo
- Responsive design

---

## 2. Dashboard (`dashboard_screen.dart`)

### Fitur:

- **Summary Cards**: Menampilkan ringkasan penjualan hari ini, jumlah transaksi, dan total produk
- **Menu Grid**: 6 menu utama dengan icon dan warna berbeda
  - Kasir (Hijau)
  - Produk (Biru)
  - Stok (Kuning)
  - Laporan (Ungu)
  - Staff (Teal)
  - Pengaturan (Abu-abu)

### Data Real-time:

- Total penjualan hari ini dihitung dari transaksi
- Jumlah transaksi hari ini
- Total produk dari database

---

## 3. Kasir / POS (`kasir_screen.dart`)

### Fitur Utama:

1. **Product Grid**

   - Menampilkan produk dalam grid 2 kolom
   - Gambar produk (icon placeholder)
   - Nama, harga, dan stok
   - Indikator stok menipis (merah jika < 10)

2. **Search & Filter**

   - Search bar untuk mencari produk
   - Filter kategori: Semua, Makanan, Minuman, Snack
   - Filter chip dengan highlight

3. **Shopping Cart**

   - Badge counter di icon cart
   - Bottom sheet untuk menampilkan keranjang
   - Tambah/kurang quantity
   - Total harga real-time
   - Hapus item jika quantity = 0

4. **Checkout & Payment**
   - Dialog pemilihan metode pembayaran
   - Pilihan: Tunai, QRIS, E-Wallet
   - Konfirmasi pembayaran
   - Auto update stok setelah transaksi
   - Notifikasi sukses

### Flow:

```
Pilih Produk → Tambah ke Cart → Review Cart → Pilih Metode Bayar → Konfirmasi → Selesai
```

---

## 4. Produk (`produk_screen.dart`)

### Fitur:

- Grid view semua produk
- Search produk by nama
- Tap produk untuk lihat detail
- FAB untuk tambah produk baru (demo)

### Product Card:

- Icon produk
- Nama produk
- Harga (format Rupiah)
- Stok dengan warna indikator

---

## 5. Stok (`stok_screen.dart`)

### Fitur:

- List view semua produk dengan stok
- **Indikator Stok Menipis**:
  - Merah jika stok < 10
  - Hijau jika stok >= 10
  - Label "Stok Menipis!"
- Tap untuk edit stok
- Dialog edit dengan input number
- Update stok real-time

### Use Case:

- Monitoring stok barang
- Cepat identifikasi produk yang perlu restock
- Update stok setelah pembelian supplier

---

## 6. Laporan (`laporan_screen.dart`)

### Fitur:

1. **Ringkasan Penjualan**

   - Penjualan hari ini
   - Total transaksi

2. **Grafik Penjualan**

   - Line chart 7 hari terakhir
   - Menggunakan fl_chart
   - Smooth curve dengan gradient area
   - Interactive (dummy data)

3. **Riwayat Transaksi**
   - List semua transaksi
   - ID transaksi
   - Tanggal & waktu
   - Total amount
   - Metode pembayaran
   - Format tanggal Indonesia

### Data Visualization:

- Chart dengan warna brand (Emerald Green)
- Card-based layout
- Easy to read format

---

## 7. Staff (`staff_screen.dart`)

### Fitur:

- List staff dengan avatar
- Badge role (Admin/Kasir)
- Warna berbeda per role
- Email staff
- FAB untuk tambah staff (demo)

### Staff Data:

- Admin Utama (Admin)
- Kasir 1 (Kasir)
- Kasir 2 (Kasir)

---

## 8. Pengaturan (`pengaturan_screen.dart`)

### Fitur:

1. **Profil Toko**

   - Logo toko
   - Nama toko: "Toko FinSight"
   - Alamat
   - Button edit profil

2. **Preferensi**

   - Toggle mode gelap (demo)
   - Pilihan bahasa
   - Pengaturan printer

3. **Tentang**

   - Info aplikasi FinSight
   - Versi aplikasi
   - Bantuan

4. **Logout**
   - Konfirmasi dialog
   - Kembali ke login screen
   - Clear navigation stack

---

## Shared Widgets

### 1. `SummaryCard`

- Reusable card untuk dashboard
- Icon dengan background color
- Title & value
- Customizable color

### 2. `ProductCard`

- Card untuk menampilkan produk
- Image placeholder
- Nama, harga, stok
- OnTap callback

### 3. `CustomButton`

- Full-width button
- Loading state
- Optional icon
- Customizable colors

### 4. `CustomSearchBar`

- TextField dengan icon search
- OnChanged callback
- Consistent styling

---

## State Management (Provider)

### `DummyService` (ChangeNotifier)

**Properties:**

- `List<Product> products` - Daftar produk
- `List<TransactionModel> transactions` - Daftar transaksi

**Methods:**

- `addTransaction(TransactionModel)` - Tambah transaksi baru
- `updateStock(productId, newStock)` - Update stok produk
- `totalRevenueToday` - Getter untuk total penjualan hari ini

**Notifikasi:**

- `notifyListeners()` dipanggil setiap ada perubahan data
- UI auto-update via `Consumer` atau `Provider.of`

---

## Utilities

### `CurrencyFormatter`

- Format angka ke Rupiah: `Rp 25.000`
- Locale: Indonesia (id_ID)
- No decimal untuk Rupiah

### `AppColors`

- Centralized color palette
- Consistent branding
- Easy to maintain

### `AppTheme`

- Material 3 theme
- Google Fonts (Inter)
- Consistent spacing & styling

---

## Best Practices yang Diterapkan

1. ✅ **Clean Architecture** - Pemisahan concerns (features, core, shared)
2. ✅ **Reusable Widgets** - DRY principle
3. ✅ **State Management** - Provider pattern
4. ✅ **Consistent Styling** - Theme & color constants
5. ✅ **Responsive Design** - Adaptable layouts
6. ✅ **User Feedback** - SnackBar, dialogs, loading states
7. ✅ **Navigation** - Proper routing & back stack
8. ✅ **Code Organization** - Feature-based structure

---

## Tips Development

### Menambah Produk Baru:

```dart
service.products.add(Product(
  id: 'p9',
  name: 'Produk Baru',
  category: 'Makanan',
  price: 15000,
  stock: 50,
));
service.notifyListeners();
```

### Menambah Transaksi:

```dart
final transaction = TransactionModel(
  id: 'TRX-${DateTime.now().millisecondsSinceEpoch}',
  date: DateTime.now(),
  items: cartItems,
  totalAmount: total,
  paymentMethod: 'Tunai',
);
service.addTransaction(transaction);
```

### Custom Theme Color:

Edit `lib/core/constants/app_colors.dart` untuk mengubah warna brand.

---

**FinSight** - Built with ❤️ using Flutter
