import 'difficulty.dart';
import 'game_result.dart';

/// Mejores marcas guardadas para una dificultad.
///
/// El mejor tiempo y la menor cantidad de movimientos se guardan por
/// separado (pueden venir de partidas distintas), cada uno con su fecha.
class HighScore {
  const HighScore({
    required this.difficulty,
    required this.bestTime,
    required this.bestTimeDate,
    required this.fewestMoves,
    required this.fewestMovesDate,
    this.gamesWon = 1,
  });

  /// Marca inicial a partir de la primera partida ganada.
  factory HighScore.fromResult(GameResult result) {
    return HighScore(
      difficulty: result.difficulty,
      bestTime: result.duration,
      bestTimeDate: result.date,
      fewestMoves: result.moves,
      fewestMovesDate: result.date,
    );
  }

  /// Lee una marca guardada. Lanza [FormatException] si los datos
  /// no tienen el formato esperado.
  factory HighScore.fromJson(Difficulty difficulty, Map<String, dynamic> json) {
    final bestTimeMs = json['bestTimeMs'];
    final fewestMoves = json['fewestMoves'];
    final bestTimeDate = DateTime.tryParse('${json['bestTimeDate']}');
    final fewestMovesDate = DateTime.tryParse('${json['fewestMovesDate']}');
    final gamesWon = json['gamesWon'];
    if (bestTimeMs is! int ||
        fewestMoves is! int ||
        bestTimeDate == null ||
        fewestMovesDate == null) {
      throw const FormatException('Marca guardada con formato inválido');
    }
    return HighScore(
      difficulty: difficulty,
      bestTime: Duration(milliseconds: bestTimeMs),
      bestTimeDate: bestTimeDate,
      fewestMoves: fewestMoves,
      fewestMovesDate: fewestMovesDate,
      gamesWon: gamesWon is int ? gamesWon : 1,
    );
  }

  final Difficulty difficulty;
  final Duration bestTime;
  final DateTime bestTimeDate;
  final int fewestMoves;
  final DateTime fewestMovesDate;

  /// Partidas ganadas en esta dificultad.
  final int gamesWon;

  /// Fecha del récord más reciente.
  DateTime get lastRecordDate =>
      bestTimeDate.isAfter(fewestMovesDate) ? bestTimeDate : fewestMovesDate;

  Map<String, dynamic> toJson() => {
        'bestTimeMs': bestTime.inMilliseconds,
        'bestTimeDate': bestTimeDate.toIso8601String(),
        'fewestMoves': fewestMoves,
        'fewestMovesDate': fewestMovesDate.toIso8601String(),
        'gamesWon': gamesWon,
      };

  HighScore copyWith({
    Duration? bestTime,
    DateTime? bestTimeDate,
    int? fewestMoves,
    DateTime? fewestMovesDate,
    int? gamesWon,
  }) {
    return HighScore(
      difficulty: difficulty,
      bestTime: bestTime ?? this.bestTime,
      bestTimeDate: bestTimeDate ?? this.bestTimeDate,
      fewestMoves: fewestMoves ?? this.fewestMoves,
      fewestMovesDate: fewestMovesDate ?? this.fewestMovesDate,
      gamesWon: gamesWon ?? this.gamesWon,
    );
  }
}
