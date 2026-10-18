import 'package:flutter/material.dart';
import 'package:flutter_puzzle/main.dart';
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

    // Avanza el tiempo 3 segundos para superar la SplashScreen y completar la transición al menú
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    for (final (button, title) in [
      ('Iniciar 3x3', 'Fácil · 3x3'),
      ('Iniciar 4x4', 'Medio · 4x4'),
      ('Iniciar 5x5', 'Difícil · 5x5'),
    ]) {
      await tester.tap(find.text(button));
      await tester.pumpAndSettle();
      expect(find.text(title), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text(button), findsOneWidget);
    }
  });
}