/// Estilos de visualización de las piezas del tablero.
enum TileStyle {
  classic('Clásico'),
  colorful('Colorido'),
  retro('Retro'),
  minimal('Minimalista');

  const TileStyle(this.label);

  /// Nombre que se muestra en la configuración.
  final String label;
}
