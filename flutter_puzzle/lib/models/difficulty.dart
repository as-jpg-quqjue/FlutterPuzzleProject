/// Niveles de dificultad del juego.
///
/// Cada nivel define el tamaño de la cuadrícula y el tiempo máximo
/// para resolverla cuando el límite de tiempo está activado.
enum Difficulty {
  easy(size: 3, label: 'Fácil', timeLimit: Duration(minutes: 3)),
  medium(size: 4, label: 'Medio', timeLimit: Duration(minutes: 12)),
  hard(size: 5, label: 'Difícil', timeLimit: Duration(minutes: 25));

  const Difficulty({
    required this.size,
    required this.label,
    required this.timeLimit,
  });

  /// Cantidad de filas (y de columnas) del tablero.
  final int size;

  /// Nombre que se muestra al usuario.
  final String label;

  /// Tiempo máximo de la partida cuando el límite de tiempo está activo.
  final Duration timeLimit;

  /// Número de piezas (sin contar el espacio vacío).
  int get tileCount => size * size - 1;

  /// Texto corto del tamaño, por ejemplo "4x4".
  String get gridLabel => '${size}x$size';

  /// Devuelve la dificultad correspondiente a un tamaño de cuadrícula.
  static Difficulty fromSize(int size) {
    return Difficulty.values.firstWhere(
      (difficulty) => difficulty.size == size,
      orElse: () => Difficulty.medium,
    );
  }
}
