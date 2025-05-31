# Visits Tracker Flutter Application

## Overview

The Visits Tracker is a mobile application for managing customer visits. It enables users to view, add, update, and delete visit records, featuring robust data caching and advanced filtering. The app is built with a focus on a smooth user experience through a clean architecture and reactive state management.

---

## Screenshots

*(Replace the placeholder URLs with the raw links to your screenshots on GitHub or wherever they are hosted. Ensure they are publicly accessible.)*

| Home Page | Add Visit Page | Visit Detail Page | Edit Visit Page |
| :--------------------: | :------------------: | :------------------------: | :-----------------: |
| ![Screenshot 1](https://raw.github.com/jessNzembi/visits_tracker/main/screenshots/home.png) | ![Screenshot 2](https://raw.github.com/jessNzembi/visits_tracker/main/screenshots/add_visit.png) | ![Screenshot 3](https://raw.github.com/jessNzembi/visits_tracker/main/screenshots/visit_detail.png) | ![Screenshot 4](https://raw.github.com/jessNzembi/visits_tracker/main/screenshots/edit_visit.png) |

---

## Key Architectural Choices

The application prioritizes maintainability, scalability, and testability through these architectural decisions:

1.  **Bloc (Business Logic Component) for State Management:** Provides clear separation of UI and business logic, ensuring predictable state changes and testability.
2.  **Repository Pattern (via Services):** Abstracts data sources, allowing the BLoC to interact with a clean API for data operations without knowing the underlying data source (API or local DB).
3.  **Local Database (SQLite via `sqflite`):** Used for data caching to enable faster read operations and reduce network dependency.
4.  **`dartz` for Functional Error Handling:** Offers a robust and explicit way to manage success and failure paths in asynchronous operations using `Either<Failure, T>`.
5.  **`GetX` for Dependency Injection and Routing:** Simplifies service location and navigation, complementing Bloc for overall application structure.
6.  **`sqflite_common_ffi` for Cross-Platform Database Initialization:** Ensures consistent SQLite database functionality across mobile and desktop platforms, and for testing environments.

---

## Setup Instructions

To run this Flutter application, follow these steps:

### Prerequisites

* [Flutter SDK](https://flutter.dev/docs/get-started/install) installed and configured.
* A code editor (e.g., VS Code).
* A Supabase project with your data.

### 1. Clone the Repository

```bash
git clone <your-repository-url>
cd visits_tracker
```

### 2. Install Dependencies

```bash
flutter pub get
```

---

### 3. Configure API Keys and Base URL

API keys and the base URL are injected at build time using `--dart-define` for security.

- **Provide at Runtime**:  
  The app expects these values to be provided as string environment variables during the `flutter run` or `flutter build` command.

---

### 4. Run the Application

You must provide the `BASE_URL` and `API_KEY` when running the application.

### For Development:

```bash
flutter run \
  --dart-define=BASE_URL=<your-url> \
  --dart-define=API_KEY=<YOUR_API_KEY>
```

### For Release Builds:

```bash
flutter build apk \ # or ios, web, windows, etc.
  --dart-define=BASE_URL=<your-url> \
  --dart-define=API_KEY=<YOUR_API_KEY>
```

> **Note:** Replace `<your-url>` and `<YOUR_API_KEY>` with your actual Supabase project ID and anon key.

---


## Notes on Implementation


### Filtering and Statistics Logic

The Home page uses a **layered approach** for filtering and statistics:

- **Data Sources**:
  - `allVisits`: Complete dataset
  - `filteredVisitsBySearch`: Filtered only by search query
  - `finalDisplayedVisits`: Final list shown after applying search and status filters

- **Statistics Behavior**:
  - **No search query**: Stats (e.g., "All", "Completed" counts) reflect `allVisits`
  - **With search query**: Stats reflect `filteredVisitsBySearch` and remain unchanged by status filters

---

### State Persistence on Navigation

Using Bloc:
- The HomePage's filter state (selected status, search query) and displayed data persist across navigations.
- Returning to the Home page restores the last emitted `VisitsBloc` state, ensuring the UI reflects previously applied filters and search queries.

---

### Error Handling

- API and DB operations use `Either<Failure, T>` from `dartz` for explicit error handling.
- `VisitsBloc` processes these, emitting `VisitsError` states for UI display.

---

## Assumptions, Trade-offs, and Limitations

- **API Structure**: Assumes RESTful API (e.g., Supabase PostgREST) with predefined endpoints.
- **Customers and Activities**: No functionality to detect updates on the customers or activities records.
- **Authentication**: No user authentication; all API calls use a single API key.
- **Testing**: Architecture supports testability, but full test coverage needs to be written.
- **UI/UX**: Basic and functional. Further UI polish, animations, and accessibility are recommended.
- **Memory Management**: For large datasets, implement pagination to optimize performance and memory usage.