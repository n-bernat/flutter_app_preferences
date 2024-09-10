# flutter_app_preferences

[![Package](https://img.shields.io/pub/v/flutter_app_preferences.svg)](https://pub.dev/packages/flutter_app_preferences) [![Publisher](https://img.shields.io/pub/publisher/flutter_app_preferences.svg)](https://pub.dev/packages/flutter_app_preferences/publisher) [![MIT License](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT) [![LeanCode Style](https://img.shields.io/badge/style-leancode__lint-black)](https://pub.dartlang.org/packages/leancode_lint)

`flutter_app_preferences` manages shared preferences in a type-safe way and allows you to receive notifications when one of them changes. Each `Preference<T>` extends `ValueNotifier<T>` to maximize compatibility with existing solutions and provide seamless experience when using in Flutter.

|                                                                                                                          Status                                                                                                                           |               Comments               |
| :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: | :----------------------------------: |
| [![flutter_app_preferences - Tests (stable)](https://github.com/n-bernat/flutter_app_preferences/actions/workflows/flutter_tests_stable.yaml/badge.svg)](https://github.com/n-bernat/flutter_app_preferences/actions/workflows/flutter_tests_stable.yaml) |    Current stable Flutter version    |
|    [![flutter_app_preferences - Tests (beta)](https://github.com/n-bernat/flutter_app_preferences/actions/workflows/flutter_tests_beta.yaml/badge.svg)](https://github.com/n-bernat/flutter_app_preferences/actions/workflows/flutter_tests_beta.yaml)    |     Current beta Flutter version     |
|    [![flutter_app_preferences - Tests (3.24.0)](https://github.com/n-bernat/flutter_app_preferences/actions/workflows/flutter_tests_min.yaml/badge.svg)](https://github.com/n-bernat/flutter_app_preferences/actions/workflows/flutter_tests_min.yaml)    | The oldest supported Flutter version |

## Getting started

1. Add this package to your dependencies.

```yaml
dependencies:
  flutter_app_preferences: latest_version
```

2. Get the dependencies.

```sh
flutter pub get
```

## Usage

1. Create a class with your preferences:

```dart
import 'package:flutter_app_preferences/flutter_app_preferences.dart';

// A class that holds the preferences.
class AppPreferences extends BaseAppPreferences {
  // An example that stores a boolean value.
  final highContrast = Preference('high-contrast', true);

  // An example that stores an enum.
  final fontSize = Preference(
    'font-size',
    FontSize.medium,
    values: FontSize.values,
  );

  // An example that stores a custom object.
  final currentUser = Preference(
    'current-user',
    User.initialUser,
    fromJson: User.fromJson,
    toJson: (user) => user.toJson(),
  );

  // Provide a list of all the app preferences to ensure that the `AppPreferences` instance can notify its listeners.
  @override
  List<Preference<Object?>> get props => [
        highContrast,
        fontSize,
        currentUser,
      ];
}
```

```dart
// Sample enum.
enum FontSize {
  small,
  medium,
  large,
}
```

```dart
// Sample custom object.
class User {
  const User({required this.name});

  factory User.fromJson(Map<String, Object?> json) =>
      User(name: json['name']! as String);

  Map<String, Object?> toJson() => {'name': name};

  static const initialUser = User(name: '');

  final String name;
}
```

2. Initialize an instance of `AppPreferences`:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = AppPreferences();
  await prefs.initialize();

  runApp(const MaterialApp());
}

```

3. Provide and use it everywhere in your app:

- using `provider`

```dart
// Provide
runApp(
  ChangeNotifierProvider.value(
    value: prefs,
    child: const MaterialApp(),
  ),
);
```

```dart
// Read all
final prefs = context.watch<AppPreferences>();

// Read single
final fontSize = context.select<AppPreferences, FontSize>(
  (prefs) => prefs.fontSize.value,
);
```

- using a global instance

```dart
// Declare
class AppPreferences extends BaseAppPreferences {
  static final i = AppPreferences();
}

// Initialize
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppPreferences.i.initialize();

  runApp(const MaterialApp());
}
```

```dart
// Write
AppPreferences.i.highContrast.value = true;

// Read
print(AppPreferences.i.highContrast.value);

// Read and react to changes
return ListenableBuilder(
  listenable: AppPreferences.i.highContrast,
  builder: (context, _) => Text(
    'High contrast? ${AppPreferences.i.highContrast.value}',
  ),
);
```

## Additional information

- `BaseAppPreferences` extends `ChangeNotifier` and notifies its listeners when any `Preference` changes.
- `Preference<T>` extends `ValueNotifier<T>` and notifies its listeners when its value changes.
- You have to call `initialize` on app preferences before accessing any `Preference`.
- Preferences are backed by `SharedPreferencesWithCache` which means that if you currently use `SharedPreferences.getInstance()` in your project and you want to migrate to this package you have to specify your keys with `flutter.` prefixes and, in case of Android, migrate them manually. For more information [see the official documentation](https://pub.dev/packages/shared_preferences#migration-and-prefixes).
- This package requires at least Flutter 3.24 to work.
- If there are any issues feel free to go to [GitHub Issues](https://github.com/n-bernat/flutter_flutter_app_preferences/issues) and report a bug.

## Maintainers

- [Nikodem Bernat](https://nikodembernat.com)
