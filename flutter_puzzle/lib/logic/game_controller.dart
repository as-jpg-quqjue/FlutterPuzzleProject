import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/difficulty.dart';
import '../models/game_result.dart';
import 'puzzle_board.dart';

/// Estados posibles de una partida.
enum GameStatus {
  /// Tablero listo; el cronómetro arranca con el primer movimiento.
  ready,

  /// Partida en curso, cronómetro corriendo.
  playing,

  /// Partida pausada (por el jugador o porque la app pasó a segundo plano).
  paused,

  /// Todas las piezas en su lugar.
  won,

  /// Se acabó el tiempo o el jugador se rindió.
  lost,
}

/// Lógica de una partida: tablero, movimientos, cronómetro, límite de
/// tiempo, pausa, rendición y resultado.
///
/// No depende de ningún widget: la pantalla escucha sus cambios
/// (es un [ChangeNotifier]) y solo se encarga de dibujar.
class GameController extends ChangeNotifier {
  GameController({
    required this.difficulty,
    this.timeLimitEnabled = true,
    Duration? timeLimitOverride,
    PuzzleBoard? initialBoard,
    Random? random,
    this.tickInterval = const Duration(milliseconds: 200),
  })  : _timeLimitOverride = timeLimitOverride,
        _random = random ?? Random(),
        _board = initialBoard ??
            PuzzleBoard.shuffled(difficulty.size, random: random);

  final Difficulty difficulty;

  /// Si es `false`, no hay límite de tiempo y solo se pierde al rendirse.
  final bool timeLimitEnabled;

  /// Cada cuánto se revisa el reloj (para refrescar la UI y el límite).
  final Duration tickInterval;

  final Duration? _timeLimitOverride;
  final Random _random;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;

  PuzzleBoard _board;
  int _moves = 0;
  GameStatus _status = GameStatus.ready;
  GameResult? _result;

  PuzzleBoard get board => _board;
  int get moves => _moves;
  GameStatus get status => _status;

  /// Resultado de la partida; solo existe cuando terminó.
  GameResult? get result => _result;

  Duration get elapsed => _stopwatch.elapsed;

  /// Tiempo máximo de la partida, o `null` si no hay límite.
  Duration? get timeLimit =>
      timeLimitEnabled ? (_timeLimitOverride ?? difficulty.timeLimit) : null;

  /// Tiempo restante, o `null` si no hay límite.
  Duration? get remaining {
    final limit = timeLimit;
    if (limit == null) return null;
    final left = limit - elapsed;
    return left.isNegative ? Duration.zero : left;
  }

  bool get isFinished =>
      _status == GameStatus.won || _status == GameStatus.lost;

  /// `true` si hay una partida empezada que se perdería al salir.
  bool get isInProgress =>
      _status == GameStatus.playing || _status == GameStatus.paused;

  bool get canPlay =>
      _status == GameStatus.ready || _status == GameStatus.playing;

  /// Intenta mover la pieza de la posición [index].
  /// Devuelve `true` si el movimiento fue válido.
  bool tapTile(int index) {
    if (!canPlay) return false;
    final next = _board.move(index);
    if (next == null) return false;

    if (_status == GameStatus.ready) _startClock();

    _board = next;
    _moves++;

    if (_board.isSolved) {
      _finish(won: true);
    } else {
      notifyListeners();
    }
    return true;
  }

  /// Desliza una pieza con el teclado o con un gesto.
  bool slide(MoveDirection direction) {
    final index = _board.tileIndexForDirection(direction);
    return index != null && tapTile(index);
  }

  void pause() {
    if (_status != GameStatus.playing) return;
    _stopwatch.stop();
    _stopTicker();
    _status = GameStatus.paused;
    notifyListeners();
  }

  void resume() {
    if (_status != GameStatus.paused) return;
    _status = GameStatus.playing;
    _stopwatch.start();
    _startTicker();
    notifyListeners();
  }

  /// El jugador abandona la partida: cuenta como derrota.
  void surrender() {
    if (isFinished) return;
    _finish(won: false, reason: LossReason.surrendered);
  }

  /// Nueva partida con un tablero nuevo de la misma dificultad.
  void restart() {
    _stopTicker();
    _stopwatch
      ..stop()
      ..reset();
    _board = PuzzleBoard.shuffled(difficulty.size, random: _random);
    _moves = 0;
    _result = null;
    _status = GameStatus.ready;
    notifyListeners();
  }

  /// Revisa el reloj: si se pasó del límite, la partida se pierde.
  /// Lo llama el temporizador interno; es público para poder probarlo.
  @visibleForTesting
  void checkClock() {
    if (_status != GameStatus.playing) return;
    final limit = timeLimit;
    if (limit != null && elapsed >= limit) {
      _finish(won: false, reason: LossReason.timeUp);
    } else {
      notifyListeners();
    }
  }

  void _startClock() {
    _status = GameStatus.playing;
    _stopwatch.start();
    _startTicker();
  }

  void _startTicker() {
    _stopTicker();
    _ticker = Timer.periodic(tickInterval, (_) => checkClock());
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _finish({required bool won, LossReason? reason}) {
    _stopwatch.stop();
    _stopTicker();
    _status = won ? GameStatus.won : GameStatus.lost;
    _result = GameResult(
      difficulty: difficulty,
      won: won,
      moves: _moves,
      duration: elapsed,
      date: DateTime.now(),
      lossReason: won ? null : reason,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTicker();
    _stopwatch.stop();
    super.dispose();
  }
}
