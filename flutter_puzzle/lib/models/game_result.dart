import 'difficulty.dart';

/// Motivo por el que se perdió una partida.
enum LossReason {
  timeUp('Se acabó el tiempo'),
  surrendered('Te rendiste');

  const LossReason(this.message);

  /// Texto que se le muestra al jugador.
  final String message;
}

/// Resumen de una partida terminada (ganada o perdida).
class GameResult {
  const GameResult({
    required this.difficulty,
    required this.won,
    required this.moves,
    required this.duration,
    required this.date,
    this.lossReason,
  });

  final Difficulty difficulty;
  final bool won;
  final int moves;
  final Duration duration;
  final DateTime date;

  /// Solo tiene valor cuando [won] es `false`.
  final LossReason? lossReason;
}
