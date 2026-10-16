import 'package:flutter_puzzle/logic/game_controller.dart';
import 'package:flutter_puzzle/logic/puzzle_board.dart';
import 'package:flutter_puzzle/models/difficulty.dart';
import 'package:flutter_puzzle/models/game_result.dart';
import 'package:flutter_test/flutter_test.dart';

/// 1 2 3
/// 4 5 6
/// . 7 8   -> dos movimientos para ganar.
PuzzleBoard twoMovesFromWin() =>
    PuzzleBoard.fromTiles(3, [1, 2, 3, 4, 5, 6, 0, 7, 8]);

GameController buildController({
  bool timeLimitEnabled = true,
  Duration? timeLimit,
}) {
  final controller = GameController(
    difficulty: Difficulty.easy,
    timeLimitEnabled: timeLimitEnabled,
    timeLimitOverride: timeLimit,
    initialBoard: twoMovesFromWin(),
  );
  addTearDown(controller.dispose);
  return controller;
}

void main() {
  test('empieza listo y el cronómetro arranca con el primer movimiento', () {
    final game = buildController();
    expect(game.status, GameStatus.ready);
    expect(game.moves, 0);
    expect(game.elapsed, Duration.zero);

    expect(game.tapTile(7), isTrue);
    expect(game.status, GameStatus.playing);
    expect(game.moves, 1);
  });

  test('un toque inválido no cuenta como movimiento', () {
    final game = buildController();
    expect(game.tapTile(0), isFalse);
    expect(game.moves, 0);
    expect(game.status, GameStatus.ready);
  });

  test('gana al ordenar todas las piezas', () {
    final game = buildController();
    game.tapTile(7);
    game.tapTile(8);
    expect(game.status, GameStatus.won);
    expect(game.result, isNotNull);
    expect(game.result!.won, isTrue);
    expect(game.result!.moves, 2);
    expect(game.result!.difficulty, Difficulty.easy);
    // Después de ganar ya no se puede mover.
    expect(game.tapTile(5), isFalse);
  });

  test('deslizar funciona igual que tocar', () {
    final game = buildController();
    expect(game.slide(MoveDirection.left), isTrue);
    expect(game.slide(MoveDirection.left), isTrue);
    expect(game.status, GameStatus.won);
  });

  test('pierde cuando se acaba el tiempo', () {
    final game = buildController(timeLimit: Duration.zero);
    game.tapTile(7);
    game.checkClock();
    expect(game.status, GameStatus.lost);
    expect(game.result!.won, isFalse);
    expect(game.result!.lossReason, LossReason.timeUp);
  });

  test('sin límite de tiempo no se pierde por tiempo', () {
    final game = buildController(timeLimitEnabled: false);
    expect(game.timeLimit, isNull);
    expect(game.remaining, isNull);
    game.tapTile(7);
    game.checkClock();
    expect(game.status, GameStatus.playing);
  });

  test('rendirse cuenta como derrota', () {
    final game = buildController();
    game.tapTile(7);
    game.surrender();
    expect(game.status, GameStatus.lost);
    expect(game.result!.lossReason, LossReason.surrendered);
  });

  test('en pausa no se puede mover y al continuar sí', () {
    final game = buildController();
    game.tapTile(7);
    game.pause();
    expect(game.status, GameStatus.paused);
    expect(game.tapTile(8), isFalse);
    expect(game.moves, 1);

    game.resume();
    expect(game.status, GameStatus.playing);
    expect(game.tapTile(8), isTrue);
    expect(game.status, GameStatus.won);
  });

  test('pausar antes de empezar no hace nada', () {
    final game = buildController();
    game.pause();
    expect(game.status, GameStatus.ready);
  });

  test('reiniciar deja una partida nueva', () {
    final game = buildController();
    game.tapTile(7);
    game.surrender();
    game.restart();
    expect(game.status, GameStatus.ready);
    expect(game.moves, 0);
    expect(game.result, isNull);
    expect(game.elapsed, Duration.zero);
    expect(game.board.isSolved, isFalse);
    expect(PuzzleBoard.isSolvable(game.board.tiles, 3), isTrue);
  });

  test('avisa a los oyentes en cada movimiento', () {
    final game = buildController();
    var notifications = 0;
    game.addListener(() => notifications++);
    game.tapTile(7);
    game.tapTile(8);
    expect(notifications, 2);
  });
}
