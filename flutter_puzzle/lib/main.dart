import 'package:flutter/material.dart';

import 'models/difficulty.dart';
import 'screens/game_screen.dart';
import 'screens/high_scores_screen.dart';
import 'screens/instructions_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'services/settings_repository.dart';
import 'widgets/menu_button.dart';

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
          title: '15-Puzzle Flutter',
          debugShowCheckedModeBanner: false,

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

/// Menú principal.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SettingsRepository _settingsRepo = SettingsRepository();

  // Preferencias guardadas: se muestran en el botón "Jugar" y se pasan al
  // juego. Se recargan al volver de Configuración.
  GameSettings _settings = const GameSettings();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _settingsRepo.loadGameSettings();
    if (!mounted) return;
    setState(() => _settings = settings);
  }

  /// Abre la pantalla de juego con las preferencias guardadas. Si no se
  /// indica [difficulty], usa la dificultad guardada en Configuración.
  Future<void> _startGame([Difficulty? difficulty]) async {
    final settings = await _settingsRepo.loadGameSettings();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => GameScreen(
          difficulty: difficulty ?? settings.difficulty,
          tileStyle: settings.tileStyle,
          animationsEnabled: settings.animationsEnabled,
          timeLimitEnabled: settings.timeLimitEnabled,
        ),
      ),
    );
  }

  /// Abre la configuración y, al volver, recarga las preferencias.
  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const SettingsScreen(),
      ),
    );
    await _loadSettings();
  }

  void _openHighScores() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const HighScoresScreen(),
      ),
    );
  }

  void _openInstructions() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const InstructionsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final animate = _settings.animationsEnabled;
    final difficulty = _settings.difficulty;

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
                // Bloque claro semitransparente para que el menú se lea
                // sobre la imagen de fondo.
                color: const Color.fromARGB(255, 233, 228, 228)
                    .withValues(alpha: 0.85),
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
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  MenuButton(
                    label: 'Jugar',
                    subtitle: '${difficulty.label} · ${difficulty.gridLabel}',
                    icon: Icons.play_arrow_rounded,
                    color: Colors.deepPurple,
                    height: 92,
                    animate: animate,
                    onPressed: () => _startGame(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Partida rápida',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.black87,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (final d in Difficulty.values) ...[
                        if (d != Difficulty.values.first) const SizedBox(width: 12),
                        Expanded(
                          child: MenuButton(
                            label: d.gridLabel,
                            subtitle: d.label,
                            height: 60,
                            index: 1,
                            animate: animate,
                            onPressed: () => _startGame(d),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                  MenuButton(
                    label: 'Marcadores',
                    icon: Icons.emoji_events_outlined,
                    index: 2,
                    animate: animate,
                    onPressed: _openHighScores,
                  ),
                  const SizedBox(height: 24),
                  MenuButton(
                    label: 'Configuración',
                    icon: Icons.settings_outlined,
                    index: 3,
                    animate: animate,
                    onPressed: _openSettings,
                  ),
                  const SizedBox(height: 24),
                  MenuButton(
                    label: 'Instrucciones',
                    icon: Icons.help_outline_rounded,
                    index: 4,
                    animate: animate,
                    onPressed: _openInstructions,
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
