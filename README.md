# Flutter Clean Architecture Example

A Flutter project implementing Clean Architecture with comprehensive tooling and feature generation.

## 🏗️ Project Structure

```
lib/
├── core/                   # Core functionality
│   ├── bloc/              # Base BLoC classes
│   ├── database/          # Database service
│   ├── di/                # Dependency injection
│   ├── error/            # Error handling
│   ├── network/          # Network service
│   ├── router/           # Navigation
│   ├── theme/            # App theme
│   └── utils/            # Utilities
├── features/             # Feature modules
│   ├── feature_name/     # Feature template
│   │   ├── data/        # Data layer
│   │   ├── domain/      # Domain layer
│   │   └── presentation/ # Presentation layer
└── app.dart             # App entry point

tools/
├── scripts/             # Development scripts
│   ├── build.dart       # Build script
│   ├── create_feature.dart # Feature generator
│   ├── rename_project.dart # Project renaming
│   ├── run.dart        # Run script
│   └── test.dart       # Test runner
└── templates/          # Feature templates
```

## 🚀 Getting Started

1. Clone the repository:
```bash
git clone https://github.com/yourusername/flutter_clean_architecture.git
```

2. Get dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
dart tools/scripts/run.dart
```

## 📜 Available Scripts

All scripts are written in Dart for cross-platform compatibility. Run them using the Dart CLI:

### Feature Generation
Create a new feature with all necessary files:
```bash
dart tools/scripts/create_feature.dart feature_name
```

After creating a feature, run the following command to generate JSON serialization code:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate:
- JSON serialization code for models
- Mock classes for tests
- Other generated code

### Building
Build the app for release:
```bash
dart tools/scripts/build.dart [platform]
```
Platforms: apk, ios, web, windows, macos, linux

### Running
Run the app in debug mode:
```bash
dart tools/scripts/run.dart
```

### Testing
Run tests with coverage:
```bash
dart tools/scripts/test.dart
```

### Renaming Project
Rename the project and update all necessary files:
```bash
dart tools/scripts/rename_project.dart new_project_name
```

## 🏛️ Architecture

This project follows Clean Architecture principles with three main layers:

### Data Layer
- Remote Data Source: API communication
- Local Data Source: Local storage
- Repository Implementation: Data management

### Domain Layer
- Entities: Business objects
- Repositories: Abstract data contracts
- Use Cases: Business logic

### Presentation Layer
- BLoC: State management
- Pages: UI screens
- Widgets: Reusable components

## 🛠️ Development Tools

### Feature Generation
The `create_feature.dart` script generates:
- Complete feature structure
- Data sources (Remote/Local)
- Repository implementation
- Use cases
- BLoC with events and states
- UI templates
- Test files

### Testing
- Unit tests
- Widget tests
- Integration tests
- Coverage reporting

## 📚 Documentation

### Quick References
- [Development Scripts Guide](docs/SCRIPTS.md) - Detailed information about available development scripts
- [Architecture Overview](docs/ARCHITECTURE.md) - In-depth explanation of the project architecture
- [Contributing Guide](docs/CONTRIBUTING.md) - Guidelines for contributing to the project
- [Style Guide](docs/STYLE_GUIDE.md) - Coding conventions and best practices

### Comprehensive Documentation
- [Documentation Index](documentation/00-documentation-index.md) - Start here for complete documentation
- [Getting Started Guide](documentation/01-getting-started.md) - Complete setup and installation guide
- [Architecture Patterns](documentation/ARCHITECTURE_PATTERNS.md) - Detailed architectural decisions and patterns
- [Development Guide](documentation/03-feature-development.md) - Complete feature development workflow
- [Testing Guide](documentation/05-testing.md) - Comprehensive testing strategy
- [Security Guidelines](documentation/10-security-guide.md) - Security best practices
- [Troubleshooting](documentation/13-troubleshooting.md) - Common issues and solutions

View the complete documentation in the [documentation](documentation/) directory.

## 🔧 Dependencies

- flutter_bloc: State management
- get_it: Dependency injection
- dio: HTTP client
- go_router: Navigation
- sembast: Local database
- equatable: Value equality

## 🧪 Testing

Run tests with coverage:
```bash
dart tools/scripts/test.dart
```

View coverage report:
```bash
open coverage/html/index.html
```

## 📱 Supported Platforms

- Android
- iOS
- Web
- Windows
- macOS
- Linux

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
