import 'package:flutter_puzzle/models/difficulty.dart';
import 'package:flutter_puzzle/models/game_result.dart';
import 'package:flutter_puzzle/services/score_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

GameResult win({
  Difficulty difficulty = Difficulty.medium,
  required int seconds,
  required int moves,
  DateTime? date,
}) {
  return GameResult(
    difficulty: difficulty,
    won: true,
    moves: moves,
    duration: Duration(seconds: seconds),
    date: date ?? DateTime(2026, 10, 16),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ScoreRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = ScoreRepository();
  });

  test('sin partidas no hay marcadores', () async {
    expect(await repository.load(Difficulty.easy), isNull);
    final all = await repository.loadAll();
    expect(all.keys, Difficulty.values);
    expect(all.values.every((score) => score == null), isTrue);
  });

  test('la primera victoria es récord en tiempo y movimientos', () async {
    final update = await repository.submit(win(seconds: 90, moves: 120));
    expect(update, isNotNull);
    expect(update!.isNewBestTime, isTrue);
    expect(update.isNewFewestMoves, isTrue);

    final saved = await repository.load(Difficulty.medium);
    expect(saved!.bestTime, const Duration(seconds: 90));
    expect(saved.fewestMoves, 120);
    expect(saved.gamesWon, 1);
  });

  test('cada récord se actualiza por separado', () async {
    await repository.submit(win(seconds: 90, moves: 120));

    // Más rápido pero con más movimientos.
    final faster = await repository.submit(
      win(seconds: 60, moves: 150, date: DateTime(2026, 10, 17)),
    );
    expect(faster!.isNewBestTime, isTrue);
    expect(faster.isNewFewestMoves, isFalse);

    // Ni más rápido ni con menos movimientos.
    final worse = await repository.submit(win(seconds: 200, moves: 300));
    expect(worse!.isNewRecord, isFalse);

    final saved = await repository.load(Difficulty.medium);
    expect(saved!.bestTime, const Duration(seconds: 60));
    expect(saved.bestTimeDate, DateTime(2026, 10, 17));
    expect(saved.fewestMoves, 120);
    expect(saved.fewestMovesDate, DateTime(2026, 10, 16));
    expect(saved.gamesWon, 3);
  });

  test('las derrotas no se guardan', () async {
    final update = await repository.submit(
      GameResult(
        difficulty: Difficulty.easy,
        won: false,
        moves: 10,
        duration: const Duration(seconds: 5),
        date: DateTime(2026, 10, 16),
        lossReason: LossReason.surrendered,
      ),
    );
    expect(update, isNull);
    expect(await repository.load(Difficulty.easy), isNull);
  });

  test('cada dificultad tiene sus propios récords', () async {
    await repository.submit(
      win(difficulty: Difficulty.easy, seconds: 20, moves: 30),
    );
    expect(await repository.load(Difficulty.easy), isNotNull);
    expect(await repository.load(Difficulty.hard), isNull);
  });

  test('borrar elimina todos los marcadores', () async {
    await repository.submit(
      win(difficulty: Difficulty.easy, seconds: 20, moves: 30),
    );
    await repository.submit(win(seconds: 90, moves: 120));
    await repository.clearAll();
    final all = await repository.loadAll();
    expect(all.values.every((score) => score == null), isTrue);
  });

  test('ignora datos guardados dañados', () async {
    SharedPreferences.setMockInitialValues({
      'high_score_easy': 'esto no es json',
      'high_score_medium': '{"bestTimeMs": "x"}',
    });
    final repo = ScoreRepository();
    expect(await repo.load(Difficulty.easy), isNull);
    expect(await repo.load(Difficulty.medium), isNull);
  });
}
