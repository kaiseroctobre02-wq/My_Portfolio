import 'package:flutter/foundation.dart';

/// Global app state that stores the student profile name.
///
/// Any widget can read [name] or call [setName]. When [setName]
/// runs, `notifyListeners()` rebuilds every subscribed widget
/// (including the Home Dashboard) immediately.
class ProfileProvider extends ChangeNotifier {
  String _name = '';

  String get name => _name;

  /// The first letter of the name, used for the circle avatar.
  String get initial {
    final trimmed = _name.trim();
    return trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();
  }

  void setName(String value) {
    _name = value.trim();
    notifyListeners();
  }
}