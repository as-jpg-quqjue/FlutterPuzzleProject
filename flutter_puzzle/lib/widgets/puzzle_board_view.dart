import 'dart:math';

import 'package:flutter/material.dart';

import '../logic/puzzle_board.dart';
import '../models/tile_style.dart';
import 'puzzle_tile.dart';

/// Dibuja el tablero completo y anima el deslizamiento de las piezas.
///
/// Ocupa el cuadrado más grande que quepa en el espacio disponible,
/// así se adapta a móvil, tablet y escritorio.
class PuzzleBoardView extends StatelessWidget {
  const PuzzleBoardView({
    super.key,
    required this.board,
    required this.style,
    required this.onTileTap,
    this.enabled = true,
    this.animate = true,
    this.maxSide = 640,
  });

  final PuzzleBoard board;
  final TileStyle style;

  /// Se llama con la posición de la pieza tocada.
  final ValueChanged<int> onTileTap;

  /// Si es `false`, las piezas no responden al toque.
  final bool enabled;

  /// Animar el movimiento de las piezas.
  final bool animate;

  /// Tamaño máximo del tablero en pantallas grandes.
  final double maxSide;

  static const Duration slideDuration = Duration(milliseconds: 160);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final side = min(
          maxSide,
          min(constraints.maxWidth, constraints.maxHeight),
        );
        final n = board.size;
        final gap = side * 0.02;
        final tileExtent = (side - gap * (n + 1)) / n;

        return Center(
          child: Container(
            width: side,
            height: side,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(side * 0.04),
            ),
            child: Stack(
              children: [
                for (var value = 1; value < n * n; value++)
                  _buildTile(value, tileExtent, gap),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTile(int value, double tileExtent, double gap) {
    final index = board.indexOfTile(value);
    final row = board.rowOf(index);
    final col = board.colOf(index);

    return AnimatedPositioned(
      // La key hace que cada pieza conserve su identidad y se anime
      // de su posición anterior a la nueva.
      key: ValueKey<int>(value),
      duration: animate ? slideDuration : Duration.zero,
      curve: Curves.easeOutCubic,
      left: gap + col * (tileExtent + gap),
      top: gap + row * (tileExtent + gap),
      width: tileExtent,
      height: tileExtent,
      child: PuzzleTile(
        value: value,
        tileCount: board.size * board.size - 1,
        extent: tileExtent,
        style: style,
        inPlace: board.isTileInPlace(index),
        onTap: enabled ? () => onTileTap(index) : null,
      ),
    );
  }
}
