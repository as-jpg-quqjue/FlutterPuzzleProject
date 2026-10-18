import 'package:flutter/material.dart';

import '../models/difficulty.dart';
import '../models/high_score.dart';
import '../services/score_repository.dart';
import '../widgets/high_score_card.dart';
import '../services/score_repository.dart';

/// Pantalla de Marcadores / High Scores (Sección 3.3).
///
/// Muestra las mejores marcas por dificultad (Fácil, Medio, Difícil),
/// permite borrar todos los marcadores con confirmación previa y regresar al
/// menú principal.
class HighScoresScreen extends StatefulWidget {
  const HighScoresScreen({
    super.key,
    this.scoreRepository,
  });

  /// Repositorio de récords; si no se pasa, se usa el de shared_preferences..
  final ScoreRepository? scoreRepository;

  @override
  State<HighScoresScreen> createState() => _HighScoresScreenState();
}

class _HighScoresScreenState extends State<HighScoresScreen> {
  late final ScoreRepository _scores;
  late Future<Map<Difficulty, HighScore?>> _scoresFuture;

  @override
  void initState() {
    super.initState();
    _scores = widget.scoreRepository ?? ScoreRepository();
    _reloadScores();
  }

  void _reloadScores() {
    setState(() {
      _scoresFuture = _scores.loadAll();
    });
  }

  Future<void> _confirmAndClearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar marcadores?'),
        content: const Text(
          'Se eliminarán todos los récords de todas las dificultades.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Borrar todo'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _scores.clearAll();
      _reloadScores();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Marcadores borrados correctamente.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marcadores / High Scores'),
        actions: [
          IconButton(
            tooltip: 'Borrar marcadores',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: _confirmAndClearAll,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<Map<Difficulty, HighScore?>>(
                future: _scoresFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error al cargar los marcadores.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }

                  final scores = snapshot.data ?? {};
                  final hasAnyScore =
                      scores.values.any((score) => score != null);

                  if (!hasAnyScore) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.emoji_events_outlined,
                              size: 64,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '¡No hay récords guardados!',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Completa una partida para registrar tu mejor tiempo y menor número de movimientos.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    children: Difficulty.values.map((difficulty) {
                      return HighScoreCard(
                        difficulty: difficulty,
                        highScore: scores[difficulty],
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Volver al Menú Principal'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}