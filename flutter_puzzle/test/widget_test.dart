import 'package:flutter/material.dart';
import 'package:flutter_puzzle/main.dart';
import 'package:flutter_puzzle/models/difficulty.dart';
import 'package:flutter_puzzle/models/tile_style.dart';
import 'package:flutter_puzzle/screens/game_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Abre la app y espera a que la pantalla de inicio pase al menú.
Future<void> openMenu(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const MyApp());
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

GameScreen currentGame(WidgetTester tester) =>
    tester.widget<GameScreen>(find.byType(GameScreen));

Future<void> goBack(WidgetTester tester) async {
  await tester.tap(find.byType(BackButton));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('la pantalla de inicio pasa al menú principal', (tester) async {
    await openMenu(tester);
    for (final label in ['Jugar', 'Marcadores', 'Configuración', 'Instrucciones']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('Jugar usa la dificultad por defecto (Medio)', (tester) async {
    await openMenu(tester);
    expect(find.text('Medio · 4x4'), findsOneWidget);

    await tester.tap(find.text('Jugar'));
    await tester.pumpAndSettle();
    expect(currentGame(tester).difficulty, Difficulty.medium);
    expect(find.text('Medio · 4x4'), findsWidgets);
  });

  testWidgets('cada partida rápida abre su dificultad', (tester) async {
    await openMenu(tester);
    for (final difficulty in Difficulty.values) {
      await tester.tap(find.text(difficulty.gridLabel));
      await tester.pumpAndSettle();
      expect(currentGame(tester).difficulty, difficulty);
      await goBack(tester);
    }
  });

  testWidgets('el juego recibe las preferencias guardadas', (tester) async {
    SharedPreferences.setMockInitialValues({
      'selected_difficulty': 'hard',
      'selected_tile_style': 'retro',
      'animations_enabled': false,
      'time_limit_enabled': false,
    });
    await openMenu(tester);
    expect(find.text('Difícil · 5x5'), findsOneWidget);

    await tester.tap(find.text('Jugar'));
    await tester.pumpAndSettle();
    final game = currentGame(tester);
    expect(game.difficulty, Difficulty.hard);
    expect(game.tileStyle, TileStyle.retro);
    expect(game.animationsEnabled, isFalse);
    expect(game.timeLimitEnabled, isFalse);
  });
}
