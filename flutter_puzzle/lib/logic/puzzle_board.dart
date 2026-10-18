import 'dart:math';

/// Dirección en la que se desliza una pieza hacia el espacio vacío.
///
/// Por ejemplo, [MoveDirection.up] mueve hacia arriba la pieza que está
/// justo debajo del espacio vacío.
enum MoveDirection { up, down, left, right }

/// Estado inmutable del tablero del rompecabezas.
///
/// Las piezas se guardan en una lista plana recorrida de izquierda a derecha
/// y de arriba hacia abajo. El valor `0` representa el espacio vacío.
/// Cada movimiento devuelve un tablero nuevo, así la UI nunca modifica
/// el estado por accidente.
class PuzzleBoard {
  PuzzleBoard._(this.size, List<int> tiles)
      : tiles = List<int>.unmodifiable(tiles);

  /// Crea un tablero a partir de una lista de piezas, validando que sea
  /// una permutación de `0..size*size-1`.
  factory PuzzleBoard.fromTiles(int size, List<int> tiles) {
    if (size < 2) {
      throw ArgumentError.value(size, 'size', 'Debe ser al menos 2');
    }
    if (tiles.length != size * size) {
      throw ArgumentError(
        'Se esperaban ${size * size} piezas y llegaron ${tiles.length}',
      );
    }
    final sorted = [...tiles]..sort();
    for (var i = 0; i < sorted.length; i++) {
      if (sorted[i] != i) {
        throw ArgumentError(
          'Las piezas deben ser los números del 0 al ${size * size - 1} '
          'sin repetirse',
        );
      }
    }
    return PuzzleBoard._(size, tiles);
  }

  /// Tablero ordenado (estado de victoria).
  factory PuzzleBoard.solved(int size) =>
      PuzzleBoard._(size, solvedTiles(size));

  /// Tablero desordenado al azar que siempre tiene solución.
  ///
  /// Se mezclan las piezas y, si la permutación resultante no tiene
  /// solución según la paridad de inversiones, se intercambian dos piezas
  /// (que no sean el espacio vacío). Un intercambio cambia la paridad de
  /// las inversiones, por lo que el tablero pasa a ser resoluble.
  /// También se descarta el caso en que la mezcla quede ya ordenada.
  factory PuzzleBoard.shuffled(int size, {Random? random}) {
    if (size < 2) {
      throw ArgumentError.value(size, 'size', 'Debe ser al menos 2');
    }
    final rng = random ?? Random();
    final tiles = solvedTiles(size);
    do {
      tiles.shuffle(rng);
      if (!isSolvable(tiles, size)) {
        _swapFirstTwoTiles(tiles);
      }
    } while (_isSolvedList(tiles));
    return PuzzleBoard._(size, tiles);
  }

  /// Filas (y columnas) del tablero.
  final int size;

  /// Piezas en orden de lectura. `0` es el espacio vacío.
  final List<int> tiles;

  /// Lista ordenada: 1, 2, ..., n²-1 y el espacio vacío al final.
  static List<int> solvedTiles(int size) => [
        for (var i = 1; i < size * size; i++) i,
        0,
      ];

  /// Cuenta los pares de piezas que están en orden invertido
  /// (ignorando el espacio vacío).
  static int countInversions(List<int> tiles) {
    final numbers = tiles.where((tile) => tile != 0).toList();
    var inversions = 0;
    for (var i = 0; i < numbers.length; i++) {
      for (var j = i + 1; j < numbers.length; j++) {
        if (numbers[i] > numbers[j]) inversions++;
      }
    }
    return inversions;
  }

  /// Indica si una disposición de piezas se puede resolver.
  ///
  /// * Ancho impar (3x3, 5x5): tiene solución si el número de inversiones
  ///   es par.
  /// * Ancho par (4x4): tiene solución si la suma de las inversiones y la
  ///   fila del espacio vacío (contada desde abajo empezando en 1) es impar.
  static bool isSolvable(List<int> tiles, int size) {
    final inversions = countInversions(tiles);
    if (size.isOdd) return inversions.isEven;
    final emptyRowFromBottom = size - tiles.indexOf(0) ~/ size;
    return (inversions + emptyRowFromBottom).isOdd;
  }

  static bool _isSolvedList(List<int> tiles) {
    for (var i = 0; i < tiles.length - 1; i++) {
      if (tiles[i] != i + 1) return false;
    }
    return tiles.last == 0;
  }

  static void _swapFirstTwoTiles(List<int> tiles) {
    final first = tiles.indexWhere((tile) => tile != 0);
    final second = tiles.indexWhere((tile) => tile != 0, first + 1);
    final temp = tiles[first];
    tiles[first] = tiles[second];
    tiles[second] = temp;
  }

  /// Posición actual del espacio vacío.
  int get emptyIndex => tiles.indexOf(0);

  /// `true` cuando todas las piezas están en su lugar.
  bool get isSolved => _isSolvedList(tiles);

  /// Cantidad de piezas que ya están en su posición final.
  int get tilesInPlace {
    var count = 0;
    for (var i = 0; i < tiles.length; i++) {
      if (isTileInPlace(i)) count++;
    }
    return count;
  }

  int rowOf(int index) => index ~/ size;

  int colOf(int index) => index % size;

  /// Posición en la que se encuentra la pieza con ese número.
  int indexOfTile(int value) => tiles.indexOf(value);

  /// `true` si la pieza de esa posición ya está donde debe ir.
  bool isTileInPlace(int index) =>
      tiles[index] != 0 && tiles[index] == index + 1;

  /// Una pieza se puede mover si está justo al lado (no en diagonal)
  /// del espacio vacío.
  bool canMove(int index) {
    if (index < 0 || index >= tiles.length) return false;
    final empty = emptyIndex;
    if (index == empty) return false;
    final rowDistance = (rowOf(index) - rowOf(empty)).abs();
    final colDistance = (colOf(index) - colOf(empty)).abs();
    return rowDistance + colDistance == 1;
  }

  /// Mueve la pieza de [index] al espacio vacío.
  /// Devuelve `null` si el movimiento no es válido.
  PuzzleBoard? move(int index) {
    if (!canMove(index)) return null;
    final next = [...tiles];
    final empty = emptyIndex;
    next[empty] = next[index];
    next[index] = 0;
    return PuzzleBoard._(size, next);
  }

  /// Posición de la pieza que se movería al deslizar en [direction],
  /// o `null` si no hay pieza en ese lado del espacio vacío.
  int? tileIndexForDirection(MoveDirection direction) {
    final empty = emptyIndex;
    final row = rowOf(empty);
    final col = colOf(empty);
    switch (direction) {
      case MoveDirection.up:
        return row + 1 < size ? empty + size : null;
      case MoveDirection.down:
        return row > 0 ? empty - size : null;
      case MoveDirection.left:
        return col + 1 < size ? empty + 1 : null;
      case MoveDirection.right:
        return col > 0 ? empty - 1 : null;
    }
  }

  /// Desliza una pieza en la dirección indicada (teclado o gesto).
  PuzzleBoard? slide(MoveDirection direction) {
    final index = tileIndexForDirection(direction);
    return index == null ? null : move(index);
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    for (var row = 0; row < size; row++) {
      final values = tiles
          .sublist(row * size, (row + 1) * size)
          .map((tile) => tile == 0 ? ' .' : tile.toString().padLeft(2));
      buffer.writeln(values.join(' '));
    }
    return buffer.toString();
  }
}
