import 'package:flutter/material.dart';

import 'models/difficulty.dart';
import 'screens/game_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: _appBarColor, title: Text(widget.title)),
      body: Center(
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
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            const SizedBox(
              height: 240,
              width: 240,
              child: MatrixGrid(
                matrix: [
                  [1, 2, 3],
                  [4, 5, 6],
                  [7, 8, 9],
                ],
              ),
            ),
          ],
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
