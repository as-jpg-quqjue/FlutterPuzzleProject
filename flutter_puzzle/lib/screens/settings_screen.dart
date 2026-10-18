import 'package:flutter/material.dart';

import '../main.dart'; // Importa themeNotifier
import '../models/difficulty.dart';
import '../models/tile_style.dart';
import '../services/settings_repository.dart';
import '../widgets/puzzle_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.settingsRepository,
  });

  final SettingsRepository? settingsRepository;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsRepository _settingsRepo;
  Difficulty _selectedDifficulty = Difficulty.medium;
  TileStyle _selectedStyle = TileStyle.classic;
  ThemeMode _selectedThemeMode = ThemeMode.system;
  bool _animationsEnabled = true;
  bool _timeLimitEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _settingsRepo = widget.settingsRepository ?? SettingsRepository();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _settingsRepo.loadGameSettings();
    final theme = await _settingsRepo.loadThemeMode();
    if (mounted) {
      setState(() {
        _selectedDifficulty = settings.difficulty;
        _selectedStyle = settings.tileStyle;
        _animationsEnabled = settings.animationsEnabled;
        _timeLimitEnabled = settings.timeLimitEnabled;
        _selectedThemeMode = theme;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateDifficulty(Difficulty difficulty) async {
    setState(() => _selectedDifficulty = difficulty);
    await _settingsRepo.saveDifficulty(difficulty);
  }

  Future<void> _updateAnimations(bool enabled) async {
    setState(() => _animationsEnabled = enabled);
    await _settingsRepo.saveAnimationsEnabled(enabled);
  }

  Future<void> _updateTimeLimit(bool enabled) async {
    setState(() => _timeLimitEnabled = enabled);
    await _settingsRepo.saveTimeLimitEnabled(enabled);
  }

  Future<void> _updateStyle(TileStyle style) async {
    setState(() => _selectedStyle = style);
    await _settingsRepo.saveTileStyle(style);
  }

  Future<void> _updateThemeMode(ThemeMode mode) async {
    setState(() => _selectedThemeMode = mode);
    themeNotifier.value = mode; // Actualiza el tema visual al instante
    await _settingsRepo.saveThemeMode(mode);
  }

  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Modo del Sistema';
      case ThemeMode.light:
        return 'Modo Claro';
      case ThemeMode.dark:
        return 'Modo Oscuro';
    }
  }

  String _difficultyDetail(Difficulty difficulty) {
    return '${difficulty.gridLabel} · ${difficulty.tileCount} piezas · '
        'límite de ${difficulty.timeLimit.inMinutes} min';
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        // --- SECCIÓN DIFICULTAD ---
                        _sectionTitle(context, 'Dificultad'),
                        const SizedBox(height: 6),
                        Text(
                          'Es la que usa el botón "Jugar" del menú.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: Difficulty.values.map((difficulty) {
                              return RadioListTile<Difficulty>(
                                value: difficulty,
                                groupValue: _selectedDifficulty,
                                title: Text(difficulty.label),
                                subtitle: Text(_difficultyDetail(difficulty)),
                                onChanged: (val) {
                                  if (val != null) _updateDifficulty(val);
                                },
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // --- SECCIÓN PARTIDA ---
                        _sectionTitle(context, 'Partida'),
                        const SizedBox(height: 12),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              SwitchListTile(
                                value: _timeLimitEnabled,
                                title: const Text('Límite de tiempo'),
                                subtitle: const Text(
                                  'Si se acaba el tiempo, pierdes la partida.',
                                ),
                                onChanged: _updateTimeLimit,
                              ),
                              const Divider(height: 1),
                              SwitchListTile(
                                value: _animationsEnabled,
                                title: const Text('Animaciones'),
                                subtitle: const Text(
                                  'Deslizamiento de las piezas y pantalla de fin de partida.',
                                ),
                                onChanged: _updateAnimations,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // --- SECCIÓN TEMA VISUAL ---
                        _sectionTitle(context, 'Tema General de la App'),
                        const SizedBox(height: 12),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: ThemeMode.values.map((mode) {
                              return RadioListTile<ThemeMode>(
                                value: mode,
                                groupValue: _selectedThemeMode,
                                title: Text(_getThemeLabel(mode)),
                                onChanged: (val) {
                                  if (val != null) _updateThemeMode(val);
                                },
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // --- SECCIÓN ESTILO DE FICHAS ---
                        _sectionTitle(context, 'Estilo Visual de las Fichas'),
                        const SizedBox(height: 6),
                        Text(
                          'Personaliza el aspecto de las piezas en el tablero.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Vista Previa
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Text(
                                  'Vista Previa: ${_selectedStyle.label}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 70,
                                      height: 70,
                                      child: PuzzleTile(
                                        value: 1,
                                        tileCount: 8,
                                        extent: 70,
                                        style: _selectedStyle,
                                        inPlace: true,
                                        onTap: null,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      width: 70,
                                      height: 70,
                                      child: PuzzleTile(
                                        value: 2,
                                        tileCount: 8,
                                        extent: 70,
                                        style: _selectedStyle,
                                        inPlace: false,
                                        onTap: null,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        ...TileStyle.values.map((style) {
                          final isSelected = style == _selectedStyle;
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: RadioListTile<TileStyle>(
                              value: style,
                              groupValue: _selectedStyle,
                              title: Text(
                                style.label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onChanged: (val) {
                                if (val != null) _updateStyle(val);
                              },
                            ),
                          );
                        }),
                      ],
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
