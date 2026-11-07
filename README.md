# 💰 Expense Tracker

An offline-first, multi-currency personal expense tracking application built with **Flutter**, **Riverpod**, and **Hive**. Designed with Clean Architecture principles for maintainability, speed, and cross-platform flexibility (Android, iOS, Web, and Desktop).

![Expense Tracker Logo](expense-tracker-logo.png)

---

## ✨ Features

- **🌐 Multi-Currency Support**: Track expenses across 12 currencies (`INR`, `USD`, `EUR`, `GBP`, `JPY`, `CNY`, `AUD`, `CAD`, `CHF`, `AED`, `SAR`, `SGD`) with independent totals and month-over-month summaries.
- **💳 Payment Methods**: Categorize transactions by payment type — **Cash**, **UPI**, and **ATM/Card**.
- **🤖 Smart Emoji Categorization**: Automatic emoji/category mapping for 60+ keywords as you type titles (e.g., `Lunch` 🍔, `Uber` 🚕, `Coffee` ☕, `Rent` 🏠), with full manual picker override.
- **📊 Rich Analytics & Visualizations**:
  - Payment method breakdown (Interactive Pie Chart)
  - Top spending categories (Pie Chart)
  - Spending trends across 7-day daily, 8-week weekly, and 6-month bars (`fl_chart`)
- **🗓️ Weekly Swipe View**: Infinite scroll/swipe view to review expenses day-by-day (Monday to Sunday) with daily and weekly totals.
- **🔍 Advanced Filtering & Search**: Instant filter panel for currencies, payment methods, categories, location, date ranges, and keyword search.
- **⚡ Offline-First Persistence**: Superfast local storage powered by Hive key-value NoSQL database — no internet required and zero latency.
- **🎨 Material 3 & Dark Mode**: Modern Material 3 UI supporting automatic system light and dark themes.

---

## 🏗️ Project Architecture & Structure

This project follows **Clean Architecture** patterns, separating concerns across presentation, domain, and data layers:

```
expense-tracker/
├── lib/
│   ├── main.dart                        # App entry point, Hive initialization & Navigation shell
│   │
│   ├── core/                            # App-wide configurations and constants
│   │   ├── constants/
│   │   │   ├── currencies.dart          # Currency configurations & symbols (12 currencies)
│   │   │   └── emoji_mappings.dart      # Keyword-to-emoji dictionary (60+ keywords)
│   │   └── theme/
│   │       └── app_theme.dart           # Material 3 light & dark theme definitions
│   │
│   ├── data/                            # Data access, storage, and models
│   │   ├── models/
│   │   │   ├── expense_model.dart       # HiveObject model with HiveType annotations
│   │   │   └── expense_model.g.dart     # Auto-generated Hive adapters (build_runner)
│   │   ├── repositories/
│   │   │   └── expense_repository.dart  # Repository executing CRUD operations on Hive box
│   │   └── storage/
│   │       └── hive_storage.dart        # Hive database initialization & box manager
│   │
│   ├── domain/                          # Business logic & pure Dart entities
│   │   ├── entities/
│   │   │   └── expense.dart             # Immutable UI entity (pure Dart)
│   │   └── usecases/
│   │       ├── aggregate_expenses.dart  # Data aggregation logic for analytics & charts
│   │       └── filter_expenses.dart     # Multi-criteria filtering logic
│   │
│   └── presentation/                    # UI layer (Screens, Widgets & State Management)
│       ├── providers/
│       │   ├── expense_provider.dart    # StateNotifier provider for CRUD state
│       │   ├── filter_provider.dart     # Filter criteria & filtered computed providers
│       │   └── analytics_provider.dart  # Computed aggregation and stats providers
│       ├── screens/
│       │   ├── dashboard_screen.dart    # Dashboard with currency totals & today's expenses
│       │   ├── expense_list_screen.dart # Chronological expense history & filter/search actions
│       │   ├── analytics_screen.dart    # Pie and bar chart visualizations
│       │   ├── weekly_expenses_screen.dart # Week-by-week calendar swipe view
│       │   └── add_expense_screen.dart  # Add & Edit expense form
│       └── widgets/
│           ├── expense_card.dart        # Reusable dismissible expense card with swipe-to-delete
│           └── filter_panel.dart        # Draggable modal sheet for multi-parameter filtering
│
├── test/                                # Unit and widget test suites
├── pubspec.yaml                         # Project dependencies and asset manifests
└── analysis_options.yaml                # Linting configuration
```

---

## 🛠️ Tech Stack & Dependencies

| Category | Package / Tool | Purpose |
|---|---|---|
| **Framework** | [Flutter](https://flutter.dev) (SDK `^3.5.3`) | Cross-platform UI toolkit |
| **State Management** | [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) `^2.5.1` | Reactive and testable state management |
| **Local Database** | [hive](https://pub.dev/packages/hive) & [hive_flutter](https://pub.dev/packages/hive_flutter) | Fast, lightweight key-value offline storage |
| **Data Visualization** | [fl_chart](https://pub.dev/packages/fl_chart) `^0.69.0` | Pie and bar charts |
| **Date & Currency** | [intl](https://pub.dev/packages/intl) `^0.19.0` | Date and number formatting |
| **ID Generation** | [uuid](https://pub.dev/packages/uuid) `^4.5.1` | Unique ID generator for expense entities |
| **Code Generation** | [build_runner](https://pub.dev/packages/build_runner) & [hive_generator](https://pub.dev/packages/hive_generator) | Generates TypeAdapters for Hive models |
| **Icons** | [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons) | Automated launcher icon generation |

---

## 🚀 Getting Started & Setup

Follow these instructions to get a copy of the project up and running on your local machine.

### Prerequisites

Ensure you have the following installed on your machine:
- **[Flutter SDK](https://docs.flutter.dev/get-started/install)** (Version `>=3.5.3`)
- **Dart SDK** (included with Flutter)
- **IDE**: [VS Code](https://code.visualstudio.com/) (with Flutter and Dart extensions) or [Android Studio](https://developer.android.com/studio)
- An active emulator / simulator or physical device connected

Verify your setup by running:
```bash
flutter doctor
```

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/<your-username>/expense-tracker.git
   cd expense-tracker
   ```

2. **Install project dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run code generation (Required for Hive Adapters):**
   Hive requires generated adapter files (`expense_model.g.dart`) to serialize and deserialize data. Run:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
   > 💡 **Tip:** While actively developing models, you can run watcher mode:
   > ```bash
   > dart run build_runner watch --delete-conflicting-outputs
   > ```

4. **Launch the application:**
   ```bash
   flutter run
   ```

---

## 📦 Building for Production

### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Google Play Store)
flutter build appbundle --release
```

### iOS
```bash
flutter build ipa --release
```

### Web
```bash
flutter build web --release
```

### Desktop
```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

---

## 🧪 Testing & Code Quality

Run tests to ensure everything is operating properly:
```bash
# Run unit & widget tests
flutter test

# Run static analysis
flutter analyze
```

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
