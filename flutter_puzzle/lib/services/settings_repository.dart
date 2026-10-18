import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/tile_style.dart';

/// Guarda y lee las preferencias del usuario (estilo de fichas y modo de tema).
class SettingsRepository {
  SettingsRepository({SharedPreferences? preferences})
      : _preferences = preferences;

  static const String _tileStyleKey = 'selected_tile_style';
  static const String _themeModeKey = 'selected_theme_mode';

  SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async =>
      _preferences ??= await SharedPreferences.getInstance();

  Future<TileStyle> loadTileStyle() async {
    final prefs = await _prefs;
    final name = prefs.getString(_tileStyleKey);
    if (name == null) return TileStyle.classic;

    return TileStyle.values.firstWhere(
      (style) => style.name == name,
      orElse: () => TileStyle.classic,
    );
  }

  Future<void> saveTileStyle(TileStyle style) async {
    final prefs = await _prefs;
    await prefs.setString(_tileStyleKey, style.name);
  }

  Future<ThemeMode> loadThemeMode() async {
    final prefs = await _prefs;
    final name = prefs.getString(_themeModeKey);
    if (name == null) return ThemeMode.system;

    return ThemeMode.values.firstWhere(
      (e) => e.name == name,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await _prefs;
    await prefs.setString(_themeModeKey, mode.name);
  }
}