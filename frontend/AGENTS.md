# AGENTS.md - Feel Chat Frontend

> **Important:** When running Flutter commands, first enter the development environment using `nix-shell -p  flutter --run 'flutter analyze# This is a Example'`

A Flutter chat application using BLoC for state management, HTTP for API calls, and Flutter Secure Storage. Targets Android, iOS, Web, macOS, Linux, and Windows.

## Development Environment

Uses Nix for a reproducible environment with Flutter pre-installed.

```bash
nix-shell -p flutter
```

## Build Commands

```bash
# Dependencies
flutter pub get

# Run the app
flutter run

# Build for specific platforms
flutter build apk          # Android
flutter build web          # Web
flutter build ios          # iOS
flutter build macos        # macOS
flutter build linux        # Linux
flutter build windows      # Windows

# Run on specific device
flutter run -d <device-id>
flutter devices            # List available devices
```

## Lint & Analysis

```bash
flutter analyze            # Run static analysis
flutter analyze --fix     # Fix auto-fixable issues
```

The project uses `flutter_lints` (see `analysis_options.yaml`).

## Testing

```bash
# Run all tests
flutter test

# Run a specific test file
flutter test test/widget_test.dart

# Run tests matching a name pattern
flutter test --name "Counter increments"

# Run tests in a specific directory
flutter test test/unit/

# Run with coverage
flutter test --coverage
```

## Code Style Guidelines

### Naming Conventions

- **Files**: snake_case (`login_screen.dart`, `user_service.dart`)
- **Classes**: PascalCase (`LoginScreen`, `UserService`)
- **Methods/Variables**: camelCase (`userService`, `handleLogin()`)

### Imports

- Use package imports: `import 'package:frontend/data/services/user_service.dart';`
- Order: dart: → package: → relative
- Use aliases: `import 'package:http/http.dart' as http;`

### Formatting

- 2-space indentation
- Trailing commas for readability
- Use `const` constructors when possible
- Use `late` for lazy initialization

### Types

- Enable strict typing
- Prefer explicit types over `var` for public APIs
- Use `final` by default, `var` only when reassignment needed

### Error Handling

- Use try-catch for async operations
- Display user-friendly error messages via SnackBar
- Handle null safety with `?` and `??` operators
- Check `mounted` before calling setState in async callbacks

### Widgets

- Use `const` constructors for stateless widgets
- Extract reusable widgets to `lib/views/widgets/`
- Follow Material Design guidelines

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── configurations/routes/       # Route definitions
├── data/services/              # API services
├── utils/validators/           # Validation logic
└── views/
    ├── screens/                # Screen widgets
    └── widgets/                # Reusable widgets
test/
└── widget_test.dart
```

## Key Dependencies

- `flutter_bloc: ^9.2.0` - State management
- `http: ^1.6.0` - HTTP client
- `flutter_secure_storage: ^10.0.0` - Secure storage

## Common Patterns

### API Service Method

```dart
Future<bool> someAction({
  required String sessionId,
  required String userId,
}) async {
  final response = await _client.post(
    Uri.parse('$baseUrl/endpoint'),
    headers: {'Content-Type': 'application/json', 'session-id': sessionId},
    body: jsonEncode({'user_id': userId}),
  );
  return response.statusCode == 200;
}
```

### Screen with Form

```dart
class SomeScreen extends StatefulWidget {
  const SomeScreen({super.key});

  @override
  State<SomeScreen> createState() => _SomeScreenState();
}

class _SomeScreenState extends State<SomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleAction() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // ... async work
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: /* ... */,
      ),
    );
  }
}
```

## Before Submitting Changes

1. Run `flutter analyze` - fix any warnings/errors
2. Run `flutter test` - ensure tests pass
3. Verify build works: `flutter build apk --debug`
