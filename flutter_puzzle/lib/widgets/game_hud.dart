import 'package:flutter/material.dart';

import '../utils/time_format.dart';

/// Barra de información de la partida: movimientos, tiempo y,
/// si hay límite, el tiempo restante.
class GameHud extends StatelessWidget {
  const GameHud({
    super.key,
    required this.moves,
    required this.elapsed,
    this.remaining,
    this.axis = Axis.horizontal,
  });

  final int moves;
  final Duration elapsed;

  /// Tiempo restante; `null` cuando no hay límite de tiempo.
  final Duration? remaining;

  /// Horizontal en móvil, vertical al lado del tablero en pantallas anchas.
  final Axis axis;

  /// A partir de aquí el tiempo restante se pinta como alerta.
  static const Duration warningThreshold = Duration(seconds: 30);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final left = remaining;
    final isRunningOut = left != null && left <= warningThreshold;

    final items = <Widget>[
      _HudItem(
        icon: Icons.swap_horiz_rounded,
        label: 'Movimientos',
        value: '$moves',
      ),
      _HudItem(
        icon: Icons.timer_outlined,
        label: 'Tiempo',
        value: formatDuration(elapsed),
      ),
      if (left != null)
        _HudItem(
          icon: Icons.hourglass_bottom_rounded,
          label: 'Restante',
          value: formatDuration(left),
          color: isRunningOut ? scheme.error : null,
        ),
    ];

    if (axis == Axis.vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in items)
            Padding(padding: const EdgeInsets.only(bottom: 12), child: item),
        ],
      );
    }
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: items[i]),
        ],
      ],
    );
  }
}

class _HudItem extends StatelessWidget {
  const _HudItem({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = color ?? theme.colorScheme.onSurface;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, color: foreground, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // scaleDown evita que el número se corte en pantallas angostas.
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 1,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
