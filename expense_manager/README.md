# Expense Manager

A personal expense tracking app built with Flutter. Track your income and expenses, set budgets, view analytics, and manage your finances with a clean Material 3 interface.

## Features

- **Dashboard** - Overview of balance, recent transactions, and budget progress
- **Transaction Management** - Add, view, and filter income/expense transactions with categories
- **Budget Tracking** - Set monthly budgets per category and monitor spending
- **Analytics** - Visual charts (pie and bar) for spending breakdown and trends
- **Dark Mode** - Toggle between light and dark themes
- **Local Storage** - All data stored locally using SQLite

## Screens

| Dashboard | Transactions | Analytics | Budget | Settings |
|-----------|-------------|-----------|--------|----------|
| Balance overview, recent activity, budget bars | Full list with filters by category and type | Pie charts, bar charts, monthly trends | Set and track monthly budgets | Theme toggle, data management |

## Tech Stack

- **Flutter** with Material 3 design
- **Provider** for state management
- **sqflite** for local SQLite database
- **fl_chart** for data visualization
- **intl** for date/currency formatting

## Getting Started

### Prerequisites

- Flutter SDK >= 3.11.1
- Dart SDK >= 3.11.1

### Installation

```bash
# Clone the repository
git clone https://github.com/Vayug12/expense-traker.git

# Navigate to the project
cd expense-traker/expense_manager

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Build

```bash
# Android
flutter build apk

# iOS
flutter build ios

# Web
flutter build web

# Windows
flutter build windows
```

## Project Structure

```
expense_manager/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── database/
│   │   └── database_helper.dart  # SQLite database helper
│   ├── models/
│   │   ├── transaction.dart      # Transaction model
│   │   └── budget.dart           # Budget model
│   ├── providers/
│   │   ├── transaction_provider.dart
│   │   ├── budget_provider.dart
│   │   ├── analytics_provider.dart
│   │   └── theme_provider.dart
│   └── screens/
│       ├── dashboard_screen.dart
│       ├── add_transaction_screen.dart
│       ├── transaction_list_screen.dart
│       ├── analytics_screen.dart
│       ├── budget_screen.dart
│       └── settings_screen.dart
├── android/
├── ios/
├── web/
├── windows/
├── linux/
├── macos/
└── pubspec.yaml
```

## License

This project is open source and available under the [MIT License](LICENSE).
