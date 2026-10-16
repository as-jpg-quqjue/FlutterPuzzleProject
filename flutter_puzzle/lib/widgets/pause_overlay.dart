import 'package:flutter/material.dart';

/// Capa que tapa el tablero mientras la partida está en pausa,
/// para que no se pueda estudiar el tablero con el reloj detenido.
class PauseOverlay extends StatelessWidget {
  const PauseOverlay({
    super.key,
    required this.onResume,
    required this.onExit,
  });

  final VoidCallback onResume;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned.fill(
      child: ColoredBox(
        color: theme.colorScheme.surface,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.pause_circle_outline_rounded,
                size: 72,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text('Pausa', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 4),
              const Text('El cronómetro está detenido.'),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onResume,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Continuar'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onExit,
                child: const Text('Salir al menú'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
