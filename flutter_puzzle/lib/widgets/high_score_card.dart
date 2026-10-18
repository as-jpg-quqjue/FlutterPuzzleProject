import 'package:flutter/material.dart';

import '../models/difficulty.dart';
import '../models/high_score.dart';
import '../utils/time_format.dart';

/// Tarjeta que muestra las estadísticas del récord más alto para una dificultad.
class HighScoreCard extends StatelessWidget {
  const HighScoreCard({
    super.key,
    required this.difficulty,
    this.highScore,
  });

  final Difficulty difficulty;
  final HighScore? highScore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (highScore == null) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${difficulty.label} (${difficulty.gridLabel})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sin récords en esta dificultad.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    final score = highScore!;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${difficulty.label} (${difficulty.gridLabel})',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Chip(
                  avatar: const Icon(Icons.emoji_events, size: 18),
                  label: Text(
                    '${score.gamesWon} ${score.gamesWon == 1 ? 'victoria' : 'victorias'}',
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 24),
            _StatRow(
              icon: Icons.timer_outlined,
              title: 'Mejor Tiempo',
              value: formatDuration(score.bestTime),
              date: score.bestTimeDate,
            ),
            const SizedBox(height: 12),
            _StatRow(
              icon: Icons.touch_app_outlined,
              title: 'Menor Movimientos',
              value: '${score.fewestMoves} movs.',
              date: score.fewestMovesDate,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.date,
  });

  final IconData icon;
  final String title;
  final String value;
  final DateTime date;

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Text(
          _formatDate(date),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}