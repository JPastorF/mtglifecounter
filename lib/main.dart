import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:mtglifecounter/player_counter.dart';
import 'package:mtglifecounter/number_stepper.dart';
import 'dart:math';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Asegura que la barra de estado y la barra de navegación estén visibles
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // 2. Configura el estilo de la barra de estado
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      // Iconos de navegación blancos
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  WakelockPlus.enable();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MTG Life Counter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'MTG Life Counter'),
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
  final ValueNotifier<bool> _resetNotifier = ValueNotifier<bool>(false);
  int _lifeChangeAmount = 1;
  Random _random = Random();
  bool _isRotated = false;

  void _toggleRotation() {
    setState(() {
      _isRotated = !_isRotated;
    });
  }

  void _resetGame() {
    _lifeChangeAmount = 1;
    _resetNotifier.value = !_resetNotifier.value;
  }

  void _onLifeChanged() {
    setState(() {
      _lifeChangeAmount = 1;
    });
  }

  // <--- Añade este nuevo método para el lanzamiento de moneda
  void _coinFlip() {
    String result = _random.nextBool() ? 'Cara' : 'Cruz';
    _showCoinFlipDialog(result);
  }

  // <--- Añade este nuevo método para mostrar el diálogo
  void _showCoinFlipDialog(String result) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text(
            'Lanzamiento de moneda',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            '$result',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cerrar',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _rollDice() {
    final random = Random();
    final diceRoll = random.nextInt(19) + 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text(
            'Lanzamiento de dado D20',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            '$diceRoll',
            style: const TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cerrar',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text(
            'Reiniciar partida',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            '¿Estás seguro de que quieres reiniciar la partida se perderán todos los datos?',
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Aceptar',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                _resetGame();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // El color de fondo del Scaffold se usará para la barra de estado
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          // La imagen de fondo solo se aplica al body del Scaffold
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/tap.png'),
              fit: BoxFit.cover,
            ),
          ),
          // El contenido de la app se coloca dentro de un SafeArea
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Transform.rotate(
                    angle: _isRotated ? 3.14159 : 0,
                    child: PlayerCounter(
                      initialLife: 20,
                      color: Color(0xFF9B1D20).withAlpha(225),
                      resetNotifier: _resetNotifier,
                      lifeChangeAmount: _lifeChangeAmount,
                      onLifeChanged: _onLifeChanged,
                    ),
                  ),
                ),
                Container(
                  height: 78,
                  color: Colors.grey[800]!.withAlpha(248),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 30,
                        ),
                        tooltip: 'Reiniciar vidas',
                        onPressed: _showResetConfirmationDialog,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.crop_rotate,
                          color: Colors.white,
                          size: 30,
                        ),
                        tooltip: 'Reiniciar vidas',
                        onPressed: _toggleRotation,
                      ),
                      NumberStepper(
                        resetNotifier: _resetNotifier,
                        initialValue: _lifeChangeAmount,
                        onChanged: (newValue) {
                          setState(() {
                            _lifeChangeAmount = newValue;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.monetization_on,
                          color: Colors.white,
                          size: 30,
                        ),
                        tooltip: 'Lanzar moneda',
                        onPressed: _coinFlip,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.casino,
                          color: Colors.white,
                          size: 30,
                        ),
                        tooltip: 'Lanzar dado',
                        onPressed: _rollDice,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: PlayerCounter(
                    initialLife: 20,
                    color: Color(0xFF3D2B3D).withAlpha(225),
                    resetNotifier: _resetNotifier,
                    lifeChangeAmount: _lifeChangeAmount,
                    onLifeChanged: _onLifeChanged,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
