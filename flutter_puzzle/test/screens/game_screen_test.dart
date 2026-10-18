import 'package:flutter/material.dart';
import 'package:flutter_puzzle/logic/puzzle_board.dart';
import 'package:flutter_puzzle/models/difficulty.dart';
import 'package:flutter_puzzle/screens/game_screen.dart';
import 'package:flutter_puzzle/services/score_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget buildApp({PuzzleBoard? board}) {
  return MaterialApp(
    home: GameScreen(
      difficulty: Difficulty.easy,
      scoreRepository: ScoreRepository(),
      initialBoard:
          board ?? PuzzleBoard.fromTiles(3, [1, 2, 3, 4, 5, 6, 7, 0, 8]),
    ),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('muestra el tablero y el contador en cero', (tester) async {
    await tester.pumpWidget(buildApp());
    for (var value = 1; value <= 8; value++) {
      expect(find.text('$value'), findsOneWidget);
    }
    expect(find.text('Movimientos'), findsOneWidget);
    expect(find.text('00:00'), findsWidgets);
  });

  testWidgets('al resolver el puzzle aparece la pantalla de victoria',
      (tester) async {
    await tester.pumpWidget(buildApp());

    await tester.tap(find.text('8'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('¡Ganaste!'), findsOneWidget);
    expect(find.text('¡Nuevo récord!'), findsOneWidget);
    expect(find.text('Reiniciar'), findsOneWidget);
    expect(find.text('Menú principal'), findsOneWidget);
  });

  testWidgets('tocar una pieza lejana no la mueve', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('1'));
    await tester.pump();
    expect(find.text('¡Ganaste!'), findsNothing);
  });

  testWidgets('rendirse muestra la pantalla de derrota', (tester) async {
    await tester.pumpWidget(
      buildApp(board: PuzzleBoard.fromTiles(3, [1, 2, 3, 4, 5, 6, 0, 7, 8])),
    );

    await tester.tap(find.text('7'));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byTooltip('Rendirse'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Rendirme'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Perdiste'), findsOneWidget);
    expect(find.text('Te rendiste'), findsOneWidget);
  });
}
