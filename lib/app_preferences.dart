import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferencesWithCache? _prefs;

/// A class that holds the app preferences.
abstract class BaseAppPreferences extends ChangeNotifier {
  /// Initializes the app preferences.
  @mustCallSuper
  Future<void> initialize() async {
    _prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );

    for (final prop in props) {
      prop.addListener(prop.notifyListeners);
    }
  }

  @override
  @mustCallSuper
  void dispose() {
    for (final prop in props) {
      prop.dispose();
    }

    super.dispose();
  }

  /// A list of all the app preferences.
  List<Preference<Object?>> get props;
}

/// A class that holds the app preferences.
class Preference<T> extends ValueNotifier<T> {
  /// Creates a new instance of [Preference].
  Preference(
    String key,
    T initialValue, {
    List<T>? values,
    T Function(Map<String, Object?>)? fromJson,
    Map<String, Object?> Function(T)? toJson,
  }) : super(initialValue) {
    _key = 'settings.$key';

    if (_prefs == null) {
      throw StateError(
        'You have to call AppPreferences.initialize() before accessing any value.',
      );
    }

    if (initialValue is Enum) {
      if (values == null) {
        throw ArgumentError(
          'You have to provide a list of values for an enum type.',
        );
      }

      _value = _prefs?.getString(_key) != null
          ? values.firstWhere(
              (v) => (v as Enum).name == _prefs?.getString(_key),
              orElse: () => initialValue,
            )
          : initialValue;
    } else {
      // TODO: Add a check for non-primitive types.
      if (initialValue is List && initialValue is! List<String>) {
        if (fromJson == null || toJson == null) {
          throw ArgumentError(
            'You have to provide a fromJson and toJson function for a list of custom objects.',
          );
        }

        _toJson = toJson;
      }

      final nullable = switch (T) {
        // Primitives
        (const (String)) => _prefs?.getString(_key),
        (const (bool)) => _prefs?.getBool(_key),
        (const (int)) => _prefs?.getInt(_key),
        (const (double)) => _prefs?.getDouble(_key),
        // List of primitives
        (const (List<String>)) => _prefs?.getStringList(_key),
        (const (List<bool>)) =>
          _prefs?.getStringList(_key)?.map(bool.parse).toList(),
        (const (List<int>)) =>
          _prefs?.getStringList(_key)?.map(int.parse).toList(),
        (const (List<double>)) =>
          _prefs?.getStringList(_key)?.map(double.parse).toList(),
        // Custom objects
        (const (List)) => _prefs
            ?.getStringList(_key)
            ?.map((v) => fromJson!(jsonDecode(v) as Map<String, dynamic>))
            .toList(),
        _ => (_prefs?.containsKey(_key) ?? false)
            ? fromJson!(_prefs!.getString(_key)! as Map<String, dynamic>)
            : null,
      } as T?;

      _value = nullable ?? initialValue;
    }
  }

  late String _key;
  late T _value;
  late Map<String, Object?> Function(T) _toJson;

  /// Gets the value of the preference.
  T get() => value;

  @override
  T get value => _value;

  /// Sets the value of the preference.
  void set(T newValue) => value = newValue;

  @override
  set value(T newValue) {
    if (_value == newValue) {
      return;
    }

    if (newValue is Enum) {
      _prefs?.setString(_key, (newValue as Enum).name);
      _value = newValue;
      return notifyListeners();
    }

    final _ = switch (T) {
      // Primitives
      (const (String)) => _prefs?.setString(_key, newValue as String),
      (const (bool)) => _prefs?.setBool(_key, newValue as bool),
      (const (int)) => _prefs?.setInt(_key, newValue as int),
      (const (double)) => _prefs?.setDouble(_key, newValue as double),
      // List of primitives
      (const (List<String>)) => _prefs?.setStringList(
          _key,
          newValue as List<String>,
        ),
      (const (List<bool>)) => _prefs?.setStringList(
          _key,
          (newValue as List<bool>).map((v) => v.toString()).toList(),
        ),
      (const (List<int>)) => _prefs?.setStringList(
          _key,
          (newValue as List<int>).map((v) => v.toString()).toList(),
        ),
      (const (List<double>)) => _prefs?.setStringList(
          _key,
          (newValue as List<double>).map((v) => v.toString()).toList(),
        ),
      // Custom objects
      (const (List)) => _prefs?.setStringList(
          _key,
          (newValue as List<T>).map((v) => jsonEncode(_toJson(v))).toList(),
        ),
      _ => _prefs?.setString(_key, jsonEncode(_toJson(newValue))),
    };

    _value = newValue;
    notifyListeners();
  }
}
