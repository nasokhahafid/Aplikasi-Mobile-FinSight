# Struktur Folder FinSight

```
FinSight/
│
├── lib/
│   ├── main.dart                                    # Entry point aplikasi
│   ├── app.dart                                     # FinSightApp widget
│   │
│   ├── core/                                        # Core functionality
│   │   ├── constants/
│   │   │   └── app_colors.dart                     # Color palette
│   │   ├── theme/
│   │   │   └── app_theme.dart                      # Material 3 theme
│   │   ├── utils/
│   │   │   └── currency_formatter.dart             # Format Rupiah
│   │   ├── models/
│   │   │   ├── product_model.dart                  # Product data model
│   │   │   └── transaction_model.dart              # Transaction model
│   │   └── services/
│   │       └── dummy_service.dart                  # State management
│   │
│   ├── features/                                    # Feature modules
│   │   ├── auth/
│   │   │   └── screens/
│   │   │       └── login_screen.dart               # Login page
│   │   ├── dashboard/
│   │   │   └── screens/
│   │   │       └── dashboard_screen.dart           # Main dashboard
│   │   ├── kasir/
│   │   │   └── screens/
│   │   │       └── kasir_screen.dart               # POS/Cashier
│   │   ├── produk/
│   │   │   └── screens/
│   │   │       └── produk_screen.dart              # Product management
│   │   ├── stok/
│   │   │   └── screens/
│   │   │       └── stok_screen.dart                # Stock management
│   │   ├── laporan/
│   │   │   └── screens/
│   │   │       └── laporan_screen.dart             # Reports & analytics
│   │   ├── staff/
│   │   │   └── screens/
│   │   │       └── staff_screen.dart               # Staff management
│   │   └── pengaturan/
│   │       └── screens/
│   │           └── pengaturan_screen.dart          # Settings
│   │
│   └── shared/                                      # Shared components
│       └── widgets/
│           ├── summary_card.dart                    # Dashboard card
│           ├── product_card.dart                    # Product display card
│           ├── custom_button.dart                   # Reusable button
│           └── custom_search_bar.dart               # Search input
│
├── test/
│   └── widget_test.dart                             # Widget tests
│
├── android/                                         # Android config
├── ios/                                             # iOS config
├── windows/                                         # Windows config
├── web/                                             # Web config
│
├── pubspec.yaml                                     # Dependencies
├── README.md                                        # Project overview
├── FEATURES.md                                      # Feature documentation
├── RUNNING_GUIDE.md                                 # How to run
├── SUMMARY.md                                       # Project summary
└── QUICKSTART.md                                    # Quick start guide
```

## 📊 Statistik

- **Total Dart Files**: 21
- **Total Screens**: 8
- **Total Widgets**: 4
- **Total Models**: 2
- **Total Services**: 1
- **Total Documentation**: 5

## 🎯 Arsitektur

### Clean Architecture Pattern

```
Presentation Layer (UI)
    ↓
Business Logic Layer (Services)
    ↓
Data Layer (Models)
```

### Feature-Based Structure

Setiap feature memiliki folder sendiri dengan:

- `screens/` - UI screens
- (Future: `widgets/`, `controllers/`, `models/`)

### Shared Resources

Komponen yang digunakan di banyak tempat:

- `shared/widgets/` - Reusable UI components
- `core/` - App-wide utilities & configs

## 🔄 Data Flow

```
User Action
    ↓
Widget (UI)
    ↓
DummyService (Provider)
    ↓
notifyListeners()
    ↓
Widget Rebuild
    ↓
UI Update
```

## 🎨 Design Tokens

### Spacing

- xs: 4px
- sm: 8px
- md: 12px
- lg: 16px
- xl: 24px

### Border Radius

- Default: 12px
- Large: 16px
- Circle: 20px

### Elevation

- Card: 2
- Button: 0
- AppBar: 0

---

**FinSight** - Organized, Scalable, Production-Ready
