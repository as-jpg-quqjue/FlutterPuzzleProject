import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../logic/game_controller.dart';
import '../logic/puzzle_board.dart';
import '../models/difficulty.dart';
import '../models/tile_style.dart';
import '../services/score_repository.dart';
import '../widgets/game_hud.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/pause_overlay.dart';
import '../widgets/puzzle_board_view.dart';

/// Pantalla de juego: tablero, contador de movimientos, cronómetro,
/// pausa, rendición y fin de partida.
///
/// Las opciones (dificultad, límite de tiempo, animaciones y estilo de
/// piezas) llegan por parámetro desde el menú o la configuración.
class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.difficulty,
    this.timeLimitEnabled = true,
    this.animationsEnabled = true,
    this.tileStyle = TileStyle.classic,
    this.scoreRepository,
    this.initialBoard,
  });

  final Difficulty difficulty;
  final bool timeLimitEnabled;
  final bool animationsEnabled;
  final TileStyle tileStyle;

  /// Repositorio de récords; si no se pasa, se usa el de shared_preferences.
  final ScoreRepository? scoreRepository;

  /// Tablero inicial fijo (solo para pruebas).
  @visibleForTesting
  final PuzzleBoard? initialBoard;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late final GameController _game;
  late final ScoreRepository _scores;
  final FocusNode _boardFocus = FocusNode(debugLabel: 'tablero');

  // Estado propio de la pantalla (no del juego): por eso se maneja con
  // setState. El estado del juego vive en GameController y se redibuja
  // con ListenableBuilder.
  RecordUpdate? _recordUpdate;
  bool _resultSaved = false;

  @override
  void initState() {
    super.initState();
    _game = GameController(
      difficulty: widget.difficulty,
      timeLimitEnabled: widget.timeLimitEnabled,
      initialBoard: widget.initialBoard,
    );
    _game.addListener(_onGameChanged);
    _scores = widget.scoreRepository ?? ScoreRepository();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _game.removeListener(_onGameChanged);
    _game.dispose();
    _boardFocus.dispose();
    super.dispose();
  }

  /// Si la app pasa a segundo plano (cambio de pestaña, llamada, etc.)
  /// se pausa la partida para no perder tiempo.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _game.pause();
  }

  void _onGameChanged() {
    if (_game.isFinished && !_resultSaved) {
      _resultSaved = true;
      _saveResult();
    }
  }

  Future<void> _saveResult() async {
    final result = _game.result;
    if (result == null || !result.won) return;
    RecordUpdate? update;
    try {
      update = await _scores.submit(result);
    } catch (error) {
      debugPrint('No se pudo guardar el récord: $error');
    }
    if (!mounted) return;
    setState(() => _recordUpdate = update);
  }

  void _restart() {
    setState(() {
      _recordUpdate = null;
      _resultSaved = false;
    });
    _game.restart();
    _boardFocus.requestFocus();
  }

  void _exitToMenu() => Navigator.of(context).pop();

  Future<bool> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final wasPlaying = _game.status == GameStatus.playing;
    _game.pause();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    if (confirmed != true && wasPlaying) _game.resume();
    return confirmed == true;
  }

  Future<void> _askExit() async {
    final exit = await _confirm(
      title: '¿Salir de la partida?',
      message: 'Se perderá el progreso de esta partida.',
      confirmLabel: 'Salir',
    );
    if (exit && mounted) _exitToMenu();
  }

  Future<void> _askSurrender() async {
    final surrender = await _confirm(
      title: '¿Rendirte?',
      message: 'La partida contará como perdida.',
      confirmLabel: 'Rendirme',
    );
    if (surrender) _game.surrender();
  }

  Future<void> _askRestart() async {
    if (!_game.isInProgress) {
      _restart();
      return;
    }
    final restart = await _confirm(
      title: '¿Reiniciar?',
      message: 'Se mezclará un tablero nuevo y se perderá esta partida.',
      confirmLabel: 'Reiniciar',
    );
    if (restart) _restart();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    MoveDirection? direction;
    if (key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.keyW) {
      direction = MoveDirection.up;
    } else if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.keyS) {
      direction = MoveDirection.down;
    } else if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.keyA) {
      direction = MoveDirection.left;
    } else if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.keyD) {
      direction = MoveDirection.right;
    } else if (key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.keyP) {
      _togglePause();
      return KeyEventResult.handled;
    }
    if (direction == null) return KeyEventResult.ignored;
    _game.slide(direction);
    return KeyEventResult.handled;
  }

  void _onSwipe(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;
    const minSpeed = 150.0;
    if (velocity.distance < minSpeed) return;
    final MoveDirection direction;
    if (velocity.dx.abs() > velocity.dy.abs()) {
      direction = velocity.dx > 0 ? MoveDirection.right : MoveDirection.left;
    } else {
      direction = velocity.dy > 0 ? MoveDirection.down : MoveDirection.up;
    }
    _game.slide(direction);
  }

  void _togglePause() {
    if (_game.status == GameStatus.playing) {
      _game.pause();
    } else if (_game.status == GameStatus.paused) {
      _game.resume();
      _boardFocus.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _game,
      builder: (context, _) {
        return PopScope(
          // Si hay una partida empezada, se pide confirmación antes de salir.
          canPop: !_game.isInProgress,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _askExit();
          },
          child: Scaffold(
            appBar: _buildAppBar(),
            body: SafeArea(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildContent(),
                  ),
                  if (_game.status == GameStatus.paused)
                    PauseOverlay(
                      onResume: _togglePause,
                      onExit: _askExit,
                    ),
                  if (_game.result != null)
                    GameOverOverlay(
                      result: _game.result!,
                      recordUpdate: _recordUpdate,
                      animate: widget.animationsEnabled,
                      onRestart: _restart,
                      onExit: _exitToMenu,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final status = _game.status;
    return AppBar(
      title: Text(
        '${widget.difficulty.label} · ${widget.difficulty.gridLabel}',
      ),
      actions: [
        if (status == GameStatus.playing || status == GameStatus.paused)
          IconButton(
            tooltip: status == GameStatus.paused ? 'Continuar' : 'Pausar',
            icon: Icon(
              status == GameStatus.paused
                  ? Icons.play_arrow_rounded
                  : Icons.pause_rounded,
            ),
            onPressed: _togglePause,
          ),
        IconButton(
          tooltip: 'Reiniciar',
          icon: const Icon(Icons.refresh_rounded),
          onPressed: _game.isFinished ? null : _askRestart,
        ),
        IconButton(
          tooltip: 'Rendirse',
          icon: const Icon(Icons.flag_outlined),
          onPressed: _game.isFinished ? null : _askSurrender,
        ),
      ],
    );
  }

  Widget _buildContent() {
    final hint = _buildHint();
    return LayoutBuilder(
      builder: (context, constraints) {
        // Pantallas anchas (escritorio, tablet horizontal): datos al lado.
        final isWide = constraints.maxWidth >= 720 &&
            constraints.maxWidth > constraints.maxHeight;

        if (isWide) {
          return Row(
            children: [
              Expanded(child: _buildBoard()),
              const SizedBox(width: 24),
              SizedBox(
                width: 240,
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHud(Axis.vertical),
                        if (hint != null) hint,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return Column(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: _buildHud(Axis.horizontal),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildBoard()),
            if (hint != null) ...[const SizedBox(height: 12), hint],
          ],
        );
      },
    );
  }

  Widget _buildHud(Axis axis) {
    return GameHud(
      moves: _game.moves,
      elapsed: _game.elapsed,
      remaining: _game.remaining,
      axis: axis,
    );
  }

  Widget? _buildHint() {
    if (_game.status != GameStatus.ready) return null;
    final limit = _game.timeLimit;
    final text = StringBuffer(
      'Toca una pieza junto al espacio vacío, desliza el dedo '
      'o usa las flechas del teclado. El cronómetro empieza con '
      'el primer movimiento.',
    );
    if (limit != null) {
      text.write(' Tienes ${limit.inMinutes} minutos.');
    }
    return Text(
      text.toString(),
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }

  Widget _buildBoard() {
    return Focus(
      focusNode: _boardFocus,
      autofocus: true,
      onKeyEvent: _onKey,
      child: GestureDetector(
        onPanEnd: _game.canPlay ? _onSwipe : null,
        child: PuzzleBoardView(
          board: _game.board,
          style: widget.tileStyle,
          animate: widget.animationsEnabled,
          enabled: _game.canPlay,
          onTileTap: (index) {
            _game.tapTile(index);
            _boardFocus.requestFocus();
          },
        ),
      ),
    );
  }
}
