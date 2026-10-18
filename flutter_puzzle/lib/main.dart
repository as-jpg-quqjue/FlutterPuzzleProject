import 'package:flutter/material.dart';

import 'models/difficulty.dart';
import 'screens/game_screen.dart';
import 'screens/high_scores_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Juego de Rompecabezas 3x3',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Un Juego de Rompecabezas'),
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
  int _counter = 0;
  Color _appBarColor = Colors.amber;

  void _incrementCounter() {
    setState(() => _counter++);
  }

  /// Abre la pantalla de juego con la dificultad elegida.
  void _startGame(Difficulty difficulty) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => GameScreen(difficulty: difficulty),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: _appBarColor, title: Text(widget.title)),
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
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 100,
                  width: 540,

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
                  height: 100,
                  width: 540,

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
                  height: 100,
                  width: 540,

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
                  height: 100,
                  width: 540,

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
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
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