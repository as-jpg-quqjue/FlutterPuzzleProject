import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/difficulty.dart';
import '../models/game_result.dart';
import '../models/high_score.dart';

/// Qué récords se rompieron al guardar una partida ganada.
class RecordUpdate {
  const RecordUpdate({
    required this.highScore,
    required this.isNewBestTime,
    required this.isNewFewestMoves,
  });

  /// Marcas guardadas después de registrar la partida.
  final HighScore highScore;
  final bool isNewBestTime;
  final bool isNewFewestMoves;

  bool get isNewRecord => isNewBestTime || isNewFewestMoves;
}

/// Guarda y lee los High Scores en el almacenamiento local del
/// dispositivo (shared_preferences). Hay una entrada por dificultad.
class ScoreRepository {
  ScoreRepository({SharedPreferences? preferences}) : _preferences = preferences;

  static const String _keyPrefix = 'high_score_';

  SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async =>
      _preferences ??= await SharedPreferences.getInstance();

  static String _keyFor(Difficulty difficulty) =>
      '$_keyPrefix${difficulty.name}';

  /// Marcas de una dificultad, o `null` si todavía no hay ninguna.
  Future<HighScore?> load(Difficulty difficulty) async {
    final raw = (await _prefs).getString(_keyFor(difficulty));
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) return null;
      return HighScore.fromJson(difficulty, json);
    } on FormatException {
      return null;
    }
  }

  /// Marcas de todas las dificultades.
  Future<Map<Difficulty, HighScore?>> loadAll() async {
    return {
      for (final difficulty in Difficulty.values)
        difficulty: await load(difficulty),
    };
  }

  /// Registra una partida ganada.
  Future<RecordUpdate?> submit(GameResult result) async {
    if (!result.won) return null;

    final current = await load(result.difficulty);
    if (current == null) {
      final first = HighScore.fromResult(result);
      await _save(first);
      return RecordUpdate(
        highScore: first,
        isNewBestTime: true,
        isNewFewestMoves: true,
      );
    }

    final isNewBestTime = result.duration < current.bestTime;
    final isNewFewestMoves = result.moves < current.fewestMoves;
    final updated = current.copyWith(
      bestTime: isNewBestTime ? result.duration : null,
      bestTimeDate: isNewBestTime ? result.date : null,
      fewestMoves: isNewFewestMoves ? result.moves : null,
      fewestMovesDate: isNewFewestMoves ? result.date : null,
      gamesWon: current.gamesWon + 1,
    );
    await _save(updated);
    return RecordUpdate(
      highScore: updated,
      isNewBestTime: isNewBestTime,
      isNewFewestMoves: isNewFewestMoves,
    );
  }

  /// Borra los marcadores de todas las dificultades.
  Future<void> clearAll() async {
    final prefs = await _prefs;
    for (final difficulty in Difficulty.values) {
      await prefs.remove(_keyFor(difficulty));
    }
  }

  Future<void> _save(HighScore score) async {
    await (await _prefs).setString(
      _keyFor(score.difficulty),
      jsonEncode(score.toJson()),
    );
  }
}