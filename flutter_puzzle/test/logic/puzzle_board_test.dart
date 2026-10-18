import 'dart:math';

import 'package:flutter_puzzle/logic/puzzle_board.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PuzzleBoard.isSolvable', () {
    test('el tablero ordenado siempre tiene solución', () {
      for (final size in [3, 4, 5]) {
        expect(
          PuzzleBoard.isSolvable(PuzzleBoard.solvedTiles(size), size),
          isTrue,
          reason: 'tamaño $size',
        );
      }
    });

    test('3x3 con dos piezas intercambiadas no tiene solución', () {
      expect(
        PuzzleBoard.isSolvable([2, 1, 3, 4, 5, 6, 7, 8, 0], 3),
        isFalse,
      );
    });

    test('4x4 con 14 y 15 intercambiadas (Sam Loyd) no tiene solución', () {
      final tiles = PuzzleBoard.solvedTiles(4);
      tiles[13] = 15;
      tiles[14] = 14;
      expect(PuzzleBoard.isSolvable(tiles, 4), isFalse);
    });

    test('4x4 cuenta la fila del espacio vacío', () {
      // Una sola pieza movida hacia abajo: sigue teniendo solución.
      final tiles = PuzzleBoard.solvedTiles(4);
      tiles[15] = 12;
      tiles[11] = 0;
      expect(PuzzleBoard.isSolvable(tiles, 4), isTrue);
    });

    test('cuenta bien las inversiones', () {
      expect(PuzzleBoard.countInversions([1, 2, 3, 0]), 0);
      expect(PuzzleBoard.countInversions([3, 2, 1, 0]), 3);
      expect(PuzzleBoard.countInversions([0, 2, 1, 3]), 1);
    });
  });

  group('PuzzleBoard.shuffled', () {
    test('siempre genera tableros resolubles y desordenados', () {
      for (final size in [3, 4, 5]) {
        for (var seed = 0; seed < 300; seed++) {
          final board = PuzzleBoard.shuffled(size, random: Random(seed));
          expect(board.tiles.length, size * size);
          expect(board.tiles.toSet().length, size * size);
          expect(
            PuzzleBoard.isSolvable(board.tiles, size),
            isTrue,
            reason: 'tamaño $size, semilla $seed\n$board',
          );
          expect(board.isSolved, isFalse);
        }
      }
    });
  });

  group('movimientos', () {
    // 1 2 3
    // 4 . 5
    // 7 8 6
    final board = PuzzleBoard.fromTiles(3, [1, 2, 3, 4, 0, 5, 7, 8, 6]);

    test('solo se mueven las piezas vecinas al espacio vacío', () {
      expect(board.canMove(1), isTrue); // 2 (arriba)
      expect(board.canMove(3), isTrue); // 4 (izquierda)
      expect(board.canMove(5), isTrue); // 5 (derecha)
      expect(board.canMove(7), isTrue); // 8 (abajo)
      expect(board.canMove(0), isFalse); // diagonal
      expect(board.canMove(4), isFalse); // el propio espacio
      expect(board.canMove(-1), isFalse);
      expect(board.canMove(9), isFalse);
    });

    test('mover intercambia la pieza con el espacio vacío', () {
      final next = board.move(5)!;
      expect(next.tiles, [1, 2, 3, 4, 5, 0, 7, 8, 6]);
      // El tablero original no cambia.
      expect(board.tiles, [1, 2, 3, 4, 0, 5, 7, 8, 6]);
    });

    test('un movimiento inválido devuelve null', () {
      expect(board.move(0), isNull);
    });

    test('deslizar en cada dirección mueve la pieza correcta', () {
      expect(board.slide(MoveDirection.up)!.tiles[4], 8);
      expect(board.slide(MoveDirection.down)!.tiles[4], 2);
      expect(board.slide(MoveDirection.left)!.tiles[4], 5);
      expect(board.slide(MoveDirection.right)!.tiles[4], 4);
    });

    test('no se puede deslizar hacia fuera del tablero', () {
      final solved = PuzzleBoard.solved(3); // espacio abajo a la derecha
      expect(solved.slide(MoveDirection.up), isNull);
      expect(solved.slide(MoveDirection.left), isNull);
      expect(solved.slide(MoveDirection.down), isNotNull);
      expect(solved.slide(MoveDirection.right), isNotNull);
    });

    test('detecta la victoria y las piezas en su lugar', () {
      final almost = PuzzleBoard.fromTiles(3, [1, 2, 3, 4, 5, 6, 7, 0, 8]);
      expect(almost.isSolved, isFalse);
      expect(almost.tilesInPlace, 7);
      final solved = almost.move(8)!;
      expect(solved.isSolved, isTrue);
      expect(solved.tilesInPlace, 8);
    });
  });

  test('fromTiles rechaza tableros inválidos', () {
    expect(() => PuzzleBoard.fromTiles(3, [1, 2, 3]), throwsArgumentError);
    expect(
      () => PuzzleBoard.fromTiles(3, [1, 1, 3, 4, 5, 6, 7, 8, 0]),
      throwsArgumentError,
    );
    expect(() => PuzzleBoard.fromTiles(1, [0]), throwsArgumentError);
  });
}
