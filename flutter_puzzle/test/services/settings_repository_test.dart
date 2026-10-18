import 'package:flutter/material.dart';
import 'package:flutter_puzzle/models/difficulty.dart';
import 'package:flutter_puzzle/models/tile_style.dart';
import 'package:flutter_puzzle/services/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('sin preferencias guardadas usa los valores por defecto', () async {
    final settings = await SettingsRepository().loadGameSettings();
    expect(settings.difficulty, Difficulty.medium);
    expect(settings.tileStyle, TileStyle.classic);
    expect(settings.animationsEnabled, isTrue);
    expect(settings.timeLimitEnabled, isTrue);
    expect(await SettingsRepository().loadThemeMode(), ThemeMode.system);
  });

  test('guarda y lee cada preferencia', () async {
    final repo = SettingsRepository();
    await repo.saveDifficulty(Difficulty.hard);
    await repo.saveTileStyle(TileStyle.retro);
    await repo.saveAnimationsEnabled(false);
    await repo.saveTimeLimitEnabled(false);
    await repo.saveThemeMode(ThemeMode.dark);

    final settings = await SettingsRepository().loadGameSettings();
    expect(settings.difficulty, Difficulty.hard);
    expect(settings.tileStyle, TileStyle.retro);
    expect(settings.animationsEnabled, isFalse);
    expect(settings.timeLimitEnabled, isFalse);
    expect(await SettingsRepository().loadThemeMode(), ThemeMode.dark);
  });

  test('un valor guardado desconocido vuelve al valor por defecto', () async {
    SharedPreferences.setMockInitialValues({
      'selected_difficulty': 'imposible',
      'selected_tile_style': 'neon',
    });
    final settings = await SettingsRepository().loadGameSettings();
    expect(settings.difficulty, Difficulty.medium);
    expect(settings.tileStyle, TileStyle.classic);
  });
}
