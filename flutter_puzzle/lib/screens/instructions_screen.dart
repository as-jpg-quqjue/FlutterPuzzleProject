import 'package:flutter/material.dart';

/// Pantalla de Instrucciones / Tutorial del juego.
class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Instrucciones'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Text(
                      'Este puzzle consiste en una imagen divida en varios cuadritos, quitando una pieza de la imagen y colocando las demas en una matriz, la cual es randomizada. Tu objetivo es volver a ensamblar la imagen dentro del tiempo limite. Si se acaba el tiempo antes de completar el puzzle, pierdes. Puedes mover las piezas presionando la que quieres mover al espacio en blanco. Existen las dificultades 3x3, 4x4 y 5x5.',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 20, // Tamaño de fuente más grande
                        height: 1.6,  // Espaciado cómodo entre líneas
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Volver al Menú Principal'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}