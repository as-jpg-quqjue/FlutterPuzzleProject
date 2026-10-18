import 'package:flutter/material.dart';

import 'models/difficulty.dart';
import 'screens/game_screen.dart';
import 'screens/high_scores_screen.dart';
import 'screens/instructions_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'services/settings_repository.dart';

/// Notificador global del tema actual de la app.
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Carga el tema guardado antes de iniciar la app
  final savedTheme = await SettingsRepository().loadThemeMode();
  themeNotifier.value = savedTheme;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Reconstruye MaterialApp únicamente cuando cambia el modo de tema
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentThemeMode, _) {
        return MaterialApp(
          title: 'Juego de Rompecabezas 3x3',
          
          // 1. Configuración de Tema Claro
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          
          // 2. Configuración de Tema Oscuro
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          
          // 3. Establece el modo activo (system, light o dark)
          themeMode: currentThemeMode,
          
          home: const SplashScreen(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// Abre la pantalla de juego con la dificultad elegida.
  void _startGame(Difficulty difficulty) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => GameScreen(difficulty: difficulty),
      ),
    );
  }
  /// Abre la pantalla de configuración.
  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  /// Abre la pantalla de marcadores / high scores.
  void _openHighScores() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const HighScoresScreen(),
      ),
    );
  }

  /// Abre la pantalla de instrucciones.
  void _openInstructions() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const InstructionsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/menu_bg.png'),
            fit: BoxFit.cover, // Evita que la imagen se estire o deforme
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 580),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 233, 228, 228).withOpacity(0.85), // Bloque gris semi-oscuro similar al SplashScreen
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Título del menú principal
                  Text(
                    'Flutter Rompecabezas',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 80,
                    width: double.infinity,

                    child: ElevatedButton(
                      onPressed: () => _startGame(Difficulty.easy),
                      //SE DEFINE UNA VARIABLE EN MYHOMEPAGESTATE Y LA PUEDES CAMBIAR MEDIANTE SETSTATE
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ), //ASI SE CAMBIA EL COLOR
                      child: const Text(
                        'Iniciar 3x3',
                      ), //ASI SE DEFINE EL HIJO DEL OBJETO, SIEMPRE SE PONE AL FINAL
                    ),
                  ),
                  const SizedBox(height: 24), //Estos son espacios en blanco entre los botones para que no esten pegados
                  SizedBox(
                    height: 80,
                    width: double.infinity,

                    child: ElevatedButton(
                      onPressed: () => _startGame(Difficulty.medium),
                      //SE DEFINE UNA VARIABLE EN MYHOMEPAGESTATE Y LA PUEDES CAMBIAR MEDIANTE SETSTATE
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ), //ASI SE CAMBIA EL COLOR
                      child: const Text(
                        'Iniciar 4x4',
                      ), //ASI SE DEFINE EL HIJO DEL OBJETO, SIEMPRE SE PONE AL FINAL
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 80,
                    width: double.infinity,

                    child: ElevatedButton(
                      onPressed: () => _startGame(Difficulty.hard),
                      //SE DEFINE UNA VARIABLE EN MYHOMEPAGESTATE Y LA PUEDES CAMBIAR MEDIANTE SETSTATE
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ), //ASI SE CAMBIA EL COLOR
                      child: const Text(
                        'Iniciar 5x5',
                      ), //ASI SE DEFINE EL HIJO DEL OBJETO, SIEMPRE SE PONE AL FINAL
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 80,
                    width: double.infinity,

                    child: ElevatedButton(
                      onPressed: _openHighScores,
                      //SE DEFINE UNA VARIABLE EN MYHOMEPAGESTATE Y LA PUEDES CAMBIAR MEDIANTE SETSTATE
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ), //ASI SE CAMBIA EL COLOR
                      child: const Text(
                        'Scoreboard',
                      ), //ASI SE DEFINE EL HIJO DEL OBJETO, SIEMPRE SE PONE AL FINAL
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 80,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _openSettings, // <--- Cambiado para abrir SettingsScreen
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      child: const Text('Configuración'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 80,
                    width: double.infinity,

                    child: ElevatedButton(
                      onPressed: _openInstructions,
                      //SE DEFINE UNA VARIABLE EN MYHOMEPAGESTATE Y LA PUEDES CAMBIAR MEDIANTE SETSTATE
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ), //ASI SE CAMBIA EL COLOR
                      child: const Text(
                        'Instrucciones',
                      ), //ASI SE DEFINE EL HIJO DEL OBJETO, SIEMPRE SE PONE AL FINAL
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Matrix Grid Widget
class MatrixGrid extends StatelessWidget {
  final List<List<int>> matrix;

  const MatrixGrid({super.key, required this.matrix});

  @override
  Widget build(BuildContext context) {
    final rows = matrix.length;
    final cols = matrix[0].length;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: rows * cols,
      itemBuilder: (context, index) {
        final row = index ~/ cols;
        final col = index % cols;

        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${matrix[row][col]}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple.shade900,
            ),
          ),
        );
      },
    );
  }
}