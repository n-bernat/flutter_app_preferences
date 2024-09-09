import 'package:flutter_app_preferences/flutter_app_preferences.dart';

class AppPreferences extends BaseAppPreferences {
  /// Single instance of [AppPreferences].
  static final i = AppPreferences();

  final counter = Preference('counter', 0);

  @override
  List<Preference<Object?>> get props => [counter];
}
