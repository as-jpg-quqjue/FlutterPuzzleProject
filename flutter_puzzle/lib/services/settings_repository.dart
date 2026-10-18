import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/difficulty.dart';
import '../models/tile_style.dart';

/// Preferencias que usa la pantalla de juego.
class GameSettings {
  const GameSettings({
    this.difficulty = Difficulty.medium,
    this.tileStyle = TileStyle.classic,
    this.animationsEnabled = true,
    this.timeLimitEnabled = true,
  });

  /// Dificultad con la que arranca el botón "Jugar".
  final Difficulty difficulty;
  final TileStyle tileStyle;
  final bool animationsEnabled;

  /// Si es `false` no hay límite de tiempo y solo se pierde al rendirse.
  final bool timeLimitEnabled;
}

/// Guarda y lee las preferencias del usuario en el dispositivo
/// (dificultad, estilo de fichas, tema, animaciones y límite de tiempo).
class SettingsRepository {
  SettingsRepository({SharedPreferences? preferences})
      : _preferences = preferences;

  static const String _tileStyleKey = 'selected_tile_style';
  static const String _themeModeKey = 'selected_theme_mode';
  static const String _difficultyKey = 'selected_difficulty';
  static const String _animationsKey = 'animations_enabled';
  static const String _timeLimitKey = 'time_limit_enabled';

  SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async =>
      _preferences ??= await SharedPreferences.getInstance();

  /// Todas las preferencias de juego de una vez.
  Future<GameSettings> loadGameSettings() async {
    return GameSettings(
      difficulty: await loadDifficulty(),
      tileStyle: await loadTileStyle(),
      animationsEnabled: await loadAnimationsEnabled(),
      timeLimitEnabled: await loadTimeLimitEnabled(),
    );
  }

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

  Future<Difficulty> loadDifficulty() async {
    final prefs = await _prefs;
    final name = prefs.getString(_difficultyKey);
    return Difficulty.values.firstWhere(
      (difficulty) => difficulty.name == name,
      orElse: () => Difficulty.medium,
    );
  }

  Future<void> saveDifficulty(Difficulty difficulty) async {
    final prefs = await _prefs;
    await prefs.setString(_difficultyKey, difficulty.name);
  }

  Future<bool> loadAnimationsEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_animationsKey) ?? true;
  }

  Future<void> saveAnimationsEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_animationsKey, enabled);
  }

  Future<bool> loadTimeLimitEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_timeLimitKey) ?? true;
  }

  Future<void> saveTimeLimitEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_timeLimitKey, enabled);
  }
}
