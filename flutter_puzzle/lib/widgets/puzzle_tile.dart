import 'package:flutter/material.dart';

import '../models/tile_style.dart';

/// Una pieza del rompecabezas.
///
/// Solo dibuja: recibe el número, el estilo y qué hacer al tocarla.
class PuzzleTile extends StatelessWidget {
  const PuzzleTile({
    super.key,
    required this.value,
    required this.tileCount,
    required this.extent,
    required this.style,
    required this.inPlace,
    required this.onTap,
  });

  /// Número de la pieza (1..n²-1).
  final int value;

  /// Total de piezas del tablero (para repartir los colores).
  final int tileCount;

  /// Lado de la pieza en píxeles.
  final double extent;

  final TileStyle style;

  /// `true` si la pieza ya está en su posición final.
  final bool inPlace;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final look = _TileLook.resolve(style, scheme, value, tileCount);
    final radius = BorderRadius.circular(look.radius * extent);

    return Semantics(
      button: onTap != null,
      label: 'Pieza $value${inPlace ? ', en su lugar' : ''}',
      child: Material(
        color: look.background,
        elevation: look.elevation,
        shadowColor: scheme.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: inPlace ? look.inPlaceBorder : look.border,
            width: inPlace ? look.borderWidth + 1.5 : look.borderWidth,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Center(
            child: Text(
              '$value',
              style: TextStyle(
                fontSize: extent * 0.38,
                fontWeight: look.fontWeight,
                fontFamily: look.fontFamily,
                color: look.foreground,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Colores y formas de cada estilo de pieza.
class _TileLook {
  const _TileLook({
    required this.background,
    required this.foreground,
    required this.border,
    required this.inPlaceBorder,
    this.borderWidth = 0,
    this.radius = 0.16,
    this.elevation = 2,
    this.fontWeight = FontWeight.w700,
    this.fontFamily,
  });

  final Color background;
  final Color foreground;
  final Color border;
  final Color inPlaceBorder;
  final double borderWidth;

  /// Radio de las esquinas como fracción del lado de la pieza.
  final double radius;
  final double elevation;
  final FontWeight fontWeight;
  final String? fontFamily;

  static _TileLook resolve(
    TileStyle style,
    ColorScheme scheme,
    int value,
    int tileCount,
  ) {
    switch (style) {
      case TileStyle.classic:
        return _TileLook(
          background: scheme.primaryContainer,
          foreground: scheme.onPrimaryContainer,
          border: Colors.transparent,
          inPlaceBorder: scheme.primary,
        );
      case TileStyle.colorful:
        final hue = 360.0 * (value - 1) / tileCount;
        return _TileLook(
          background: HSLColor.fromAHSL(1, hue, 0.65, 0.52).toColor(),
          foreground: Colors.white,
          border: Colors.transparent,
          inPlaceBorder: Colors.white,
          radius: 0.22,
          elevation: 3,
          fontWeight: FontWeight.w800,
        );
      case TileStyle.retro:
        return const _TileLook(
          background: Color(0xFFE2B77C),
          foreground: Color(0xFF4E2A0E),
          border: Color(0xFF8B5A2B),
          inPlaceBorder: Color(0xFF2E7D32),
          borderWidth: 2.5,
          radius: 0.05,
          elevation: 4,
          fontFamily: 'monospace',
        );
      case TileStyle.minimal:
        return _TileLook(
          background: scheme.surface,
          foreground: scheme.onSurface,
          border: scheme.outlineVariant,
          inPlaceBorder: scheme.primary,
          borderWidth: 1,
          radius: 0.1,
          elevation: 0,
          fontWeight: FontWeight.w300,
        );
    }
  }
}
