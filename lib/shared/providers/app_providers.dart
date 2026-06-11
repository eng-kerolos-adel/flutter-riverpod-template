import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

part 'app_providers.g.dart';

// ─── Shared Preferences ───────────────────────────────────────────

@riverpod
Future<SharedPreferences> sharedPreferences(SharedPreferencesRef ref) {
  return SharedPreferences.getInstance();
}

// ─── Theme Mode ───────────────────────────────────────────────────

@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() {
    _loadThemeMode();
    return ThemeMode.system;
  }

  Future<void> _loadThemeMode() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final stored = prefs.getString(AppConstants.themeKey);
    if (stored != null) {
      state = ThemeMode.values.firstWhere(
        (e) => e.name == stored,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(AppConstants.themeKey, mode.name);
  }

  void toggleTheme() {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setThemeMode(next);
  }
}

@riverpod
ThemeMode themeMode(ThemeModeRef ref) {
  return ref.watch(themeModeNotifierProvider);
}

// ─── Connectivity ─────────────────────────────────────────────────

@riverpod
class ConnectivityNotifier extends _$ConnectivityNotifier {
  @override
  bool build() {
    // TODO: initialize connectivity_plus listener
    return true;
  }
}

@riverpod
bool isConnected(IsConnectedRef ref) {
  return ref.watch(connectivityNotifierProvider);
}
