import 'package:flutter/material.dart';

import '../models/game_result.dart';
import '../services/score_repository.dart';
import '../utils/time_format.dart';

/// Pantalla superpuesta de fin de partida (victoria o derrota).
class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({
    super.key,
    required this.result,
    required this.onRestart,
    required this.onExit,
    this.recordUpdate,
    this.animate = true,
  });

  final GameResult result;

  /// Información de récords; `null` mientras se guarda o si se perdió.
  final RecordUpdate? recordUpdate;

  final VoidCallback onRestart;
  final VoidCallback onExit;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final won = result.won;
    final record = won ? recordUpdate : null;

    final card = Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              won ? Icons.emoji_events_rounded : Icons.sentiment_dissatisfied,
              size: 64,
              color: won ? Colors.amber.shade600 : scheme.error,
            ),
            const SizedBox(height: 8),
            Text(
              won ? '¡Ganaste!' : 'Perdiste',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            if (!won && result.lossReason != null) ...[
              const SizedBox(height: 4),
              Text(
                result.lossReason!.message,
                style: theme.textTheme.bodyLarge,
              ),
            ],
            if (record != null && record.isNewRecord) ...[
              const SizedBox(height: 12),
              _NewRecordBadge(update: record),
            ],
            const SizedBox(height: 20),
            _SummaryRow(
              icon: Icons.timer_outlined,
              label: 'Tiempo total',
              value: formatDuration(result.duration),
            ),
            _SummaryRow(
              icon: Icons.swap_horiz_rounded,
              label: 'Movimientos',
              value: '${result.moves}',
            ),
            _SummaryRow(
              icon: Icons.grid_view_rounded,
              label: 'Dificultad',
              value:
                  '${result.difficulty.label} (${result.difficulty.gridLabel})',
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onRestart,
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Reiniciar'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onExit,
                icon: const Icon(Icons.home_outlined),
                label: const Text('Menú principal'),
              ),
            ),
          ],
        ),
      ),
    );

    return Positioned.fill(
      child: ColoredBox(
        color: scheme.scrim.withValues(alpha: 0.55),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: animate
                  ? TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1),
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutBack,
                      builder: (context, scale, child) => Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: ((scale - 0.8) / 0.2).clamp(0.0, 1.0),
                          child: child,
                        ),
                      ),
                      child: card,
                    )
                  : card,
            ),
          ),
        ),
      ),
    );
  }
}

class _NewRecordBadge extends StatelessWidget {
  const _NewRecordBadge({required this.update});

  final RecordUpdate update;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final details = [
      if (update.isNewBestTime) 'mejor tiempo',
      if (update.isNewFewestMoves) 'menos movimientos',
    ].join(' y ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Column(
        children: [
          Text(
            '¡Nuevo récord!',
            style: TextStyle(
              color: scheme.onTertiaryContainer,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          Text(
            details[0].toUpperCase() + details.substring(1),
            style: TextStyle(color: scheme.onTertiaryContainer),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Text(label, style: theme.textTheme.bodyLarge),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
