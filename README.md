# Accounting App Flutter

A multi-platform accounting application built with Flutter using Clean Architecture in a monorepo structure.

## Architecture

This project follows Clean Architecture principles with clear separation of concerns:

- **apps/**: Composition roots for different platforms (mobile, desktop, web, admin)
- **packages/**: Shared packages organized by concern
  - **design_system/**: Shared UI components and styling
  - **app_shell/**: Application shell and navigation
  - **localization/**: Internationalization support
  - **shared/**: Common utilities and helpers
  - **core/**: Core domain abstractions and base classes
  - **platform_bridge/**: Platform-specific implementations
  - **networking/**: HTTP client and API communication
  - **storage/**: Local storage and database
  - **features/**: Feature-specific packages with Clean Architecture layers

## Feature Structure

Each feature package follows Clean Architecture:

```
packages/features/feature_name/
├─ lib/
│  ├─ domain/
│  │  ├─ entities/
│  │  ├─ value_objects/
│  │  ├─ repositories/
│  │  └─ rules/
│  ├─ application/
│  │  ├─ use_cases/
│  │  ├─ dtos/
│  │  └─ services/
│  ├─ data/
│  │  ├─ models/
│  │  ├─ datasources/
│  │  ├─ repositories_impl/
│  │  └─ mappers/
│  └─ presentation/
│     ├─ pages/
│     ├─ widgets/
│     ├─ state/
│     └─ routes/
```

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Melos (>=5.0.0)

### Installation

1. Install Melos:
```bash
dart pub global activate melos
```

2. Bootstrap the workspace:
```bash
melos bootstrap
```

### Running Apps

#### Mobile App
```bash
cd apps/mobile_app
flutter run
```

#### Desktop App
```bash
cd apps/desktop_app
flutter run -d windows
```

#### Web App
```bash
cd apps/web_app
flutter run -d chrome
```

## Development

### Running All Tests
```bash
melos run test
```

### Code Generation
```bash
melos run build_runner
```

### Formatting
```bash
melos run format
```

### Analyzing
```bash
melos run analyze
```

## Features

- Accounting
- Journal entries
- Customer management
- Supplier management
- Sales invoices
- Purchase invoices
- Payments
- Product management
- Inventory management
- Damages tracking
- Production management
- Stock counting
- Reports
- User management
- Settings
- Audit log

## License

MIT
