# 15-Puzzle Flutter

Rompecabezas deslizante (15-Puzzle) hecho en Flutter para el micro-proyecto de Sistemas de Información.
Se ordenan las piezas de menor a mayor deslizándolas hacia el espacio vacío.

**Jugar en línea:** https://as-jpg-quqjue.github.io/FlutterPuzzleProject/
(se puede instalar como app y funciona sin conexión).

## Funcionalidades

- **Pantalla de inicio** animada que pasa sola al menú (o con el botón *Saltar*).
- **Menú principal:** *Jugar* (con la dificultad guardada), partida rápida 3x3 / 4x4 / 5x5, *Marcadores*, *Configuración* e *Instrucciones*.
- **Tres dificultades:** Fácil 3x3, Medio 4x4 y Difícil 5x5. El tablero se mezcla al azar y **siempre tiene solución** (validación por paridad de inversiones).
- **Partida:** contador de movimientos, cronómetro que arranca con el primer movimiento, pausa, reiniciar y rendirse. Se juega tocando las piezas, deslizando el dedo o con las flechas del teclado.
- **Victoria y derrota:** se gana al ordenar todas las piezas; se pierde si se acaba el tiempo límite (3, 12 o 25 minutos según la dificultad) o si el jugador se rinde.
- **Marcadores:** por dificultad se guarda el mejor tiempo y la menor cantidad de movimientos, con su fecha. Se pueden borrar (con confirmación).
- **Configuración guardada en el dispositivo:** dificultad por defecto, límite de tiempo, animaciones, tema (claro / oscuro / del sistema) y estilo de las piezas (clásico, colorido, retro, minimalista).
- **Diseño adaptable** a teléfono, tablet y escritorio.

## Cómo correrlo

Requisitos: [Flutter](https://docs.flutter.dev/get-started/install) estable.

```bash
cd flutter_puzzle
flutter pub get
flutter run -d chrome      # o cualquier otro dispositivo
flutter test               # pruebas
```

## Estructura

```
flutter_puzzle/lib/
├── main.dart              # App, temas y menú principal
├── logic/                 # Lógica pura, sin UI
│   ├── puzzle_board.dart  # Tablero, mezcla resoluble y movimientos
│   └── game_controller.dart  # Partida: cronómetro, movimientos, pausa, victoria/derrota
├── models/                # Dificultad, resultado, récord, estilo de piezas
├── services/              # Persistencia con shared_preferences (récords y preferencias)
├── screens/               # Inicio, juego, marcadores, configuración, instrucciones
├── widgets/               # Tablero, piezas, HUD, botones y capas de pausa/fin
└── utils/                 # Formato de tiempo y fechas
```

La lógica del juego (`logic/`) no depende de ningún widget: la pantalla de juego
escucha al `GameController` y solo se encarga de dibujar. `setState` se usa para el
estado propio de cada pantalla (preferencias, récords, diálogos).

## Integración continua y despliegue

- **`.github/workflows/ci.yml`:** análisis estático y pruebas en cada push y pull request.
- **`.github/workflows/deploy.yml`:** compila la versión web, verifica en un navegador real
  que siga siendo una PWA (manifest, service worker y que cargue **sin conexión**) y, en `main`,
  la publica en GitHub Pages.

## Flujo de trabajo

Usamos gitflow: ramas `feature/*` → `develop` → `main`, con pull requests.

## Integrantes

- [@as-jpg-quqjue](https://github.com/as-jpg-quqjue)
- [@AlejandroSimanca](https://github.com/AlejandroSimanca)
