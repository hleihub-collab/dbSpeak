# dbSpeak

**dbSpeak** is a Flutter application that allows users to query databases using voice and natural language. It translates conversational questions into optimized SQL queries, provides AI-driven explanations of query logic, simulates query execution with realistic latency, and displays formatted results in interactive data tables.

---

## Features

- **Voice & Speech Input**: Pulsating animated microphone with speech-to-text dictation simulation.
- **Natural Language to SQL**: Converts natural language prompts (e.g., *"Top 5 customers by lifetime spend"*, *"Show products with low stock"*) into structured SQL.
- **Multi-Dialect Support**: Configurable database dialects including PostgreSQL, MySQL, SQLite, and Supabase.
- **AI Query Explanation**: Expandable plain-English explanation for every generated query.
- **Interactive Data Table**: Scrollable results view displaying row count, query latency (in ms), and CSV export simulation.
- **Schema Explorer**: Interactive bottom sheet displaying available database tables, row counts, and column metadata (primary keys, data types).
- **Connection Switcher**: Switch between databases (Production, Analytics, Local cache) with a single tap.
- **Material 3 Design**: Supports both Dark Mode and Light Mode with fluid transitions.

---

## Project Structure

```
lib/
├── main.dart                      # Application entry point & theme management
├── models/
│   └── db_models.dart             # DbConnection, TableSchema, ColumnInfo, QueryRecord
├── services/
│   └── mock_db_service.dart       # NLP SQL synthesis engine & database simulator
├── screens/
│   └── home_screen.dart           # Primary dashboard & query interface
└── widgets/
    ├── connection_modal.dart      # Database connection selector dialog
    ├── query_result_table.dart    # Tabular result viewer with metrics
    ├── schema_viewer_sheet.dart   # Interactive schema explorer sheet
    ├── sql_view_card.dart         # Syntax-styled SQL viewer with copy action
    └── voice_mic_button.dart      # Animated pulsating microphone widget
```

---

## Getting Started

### Prerequisites

- Flutter SDK (installed at `C:\src\flutter`)
- Google Chrome or Edge (for web preview) or Android Studio

### Running the App

To run on Chrome:
```powershell
flutter run -d chrome
```

To run on Edge:
```powershell
flutter run -d edge
```

To run on Windows desktop (requires Visual Studio C++ workload):
```powershell
flutter run -d windows
```

### Running Tests

```powershell
flutter test
```

### Static Analysis

```powershell
flutter analyze
```
