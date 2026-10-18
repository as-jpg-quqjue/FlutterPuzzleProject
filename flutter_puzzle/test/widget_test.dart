import 'package:flutter/material.dart';
import 'package:flutter_puzzle/main.dart';
import 'package:flutter_puzzle/screens/game_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('cada botón del menú abre el juego con su dificultad',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MyApp());

    // Pasa la SplashScreen
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    for (final button in ['Iniciar 3x3', 'Iniciar 4x4', 'Iniciar 5x5']) { //maldita sea la IA que esta convencida en usar carácteres raros, ojala este sea el ultimo test
      await tester.tap(find.text(button));
      await tester.pumpAndSettle();

      // Confirma que se abrió la pantalla de juego
      expect(find.byType(GameScreen), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text(button), findsOneWidget);
    }
  });
}