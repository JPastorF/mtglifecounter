// Puedes crear este widget en un archivo separado para mayor orden

import 'package:flutter/material.dart';

class PlayerCounter extends StatefulWidget {
  final int initialLife;
  final Color color;
  final ValueNotifier<bool> resetNotifier;
  final int lifeChangeAmount;
  final VoidCallback onLifeChanged;

  const PlayerCounter({
    super.key,
    required this.initialLife,
    required this.color,
    required this.resetNotifier,
    required this.lifeChangeAmount,
    required this.onLifeChanged,
  });

  @override
  State<PlayerCounter> createState() => _PlayerCounterState();
}

class _PlayerCounterState extends State<PlayerCounter> {
  late int _life;
  List<String> _history = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _life = widget.initialLife;
    widget.resetNotifier.addListener(_reset);
  }

  @override
  void dispose() {
    // 3. ¡Muy importante! Se desuscribe cuando el widget se elimina
    widget.resetNotifier.removeListener(_reset);
    _scrollController.dispose(); // También liberamos el controlador de scroll
    super.dispose();
  }

  void _reset() {
    setState(() {
      _life = widget.initialLife;
      _history = [];
    });
  }

  void _onTap(TapDownDetails details) {
    final width = context.size!.width;
    final height = context.size!.height;
    final tapX = details.localPosition.dx;
    final tapY = details.localPosition.dy;
    int change;
    if (tapX < width - 78) {
      if (tapY < height / 2) {
        change = widget.lifeChangeAmount; // Toca la mitad izquierda, resta
      } else {
        change = -1 * (widget.lifeChangeAmount); // Toca la mitad derecha, suma
      }

      // Calcula el nuevo valor de vida
      final newLife = _life + change;

      // Comprueba si el nuevo valor está dentro del rango permitido
      if (newLife >= -999 && newLife <= 999) {
        setState(() {
          _life += change;
          // Añade el cambio al historial
          _history.add(' ${change > 0 ? '+' : ''}$change = $_life');

          // Realiza el scroll al final del historial
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          });
          // Llamamos al callback para notificar al padre
          widget.onLifeChanged();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el número de dígitos en la vida actual.
    final int digits = _life.toString().length;
    final double fontSize;

    // Asignamos un tamaño de fuente basado en el número de dígitos.
    if (digits <= 2) {
      fontSize = 140.0; // Para números como 20 o 9
    } else if (digits == 3) {
      fontSize = 140.0; // Para números como 120
    } else {
      fontSize = 132.0; // Para números con 4 o más dígitos
    }

    return GestureDetector(
      onTapDown: _onTap,
      child: Container(
        color: widget.color,
        child: Row(
          children: [
            // El contador de vida (ocupa 2/3 del espacio, por ejemplo)
            Expanded(
              flex: 4,
              child: Center(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Centra verticalmente
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Centra horizontalmente
                  children: [
                    //const SizedBox(height: 10),
                    const Icon(Icons.add_circle, color: Colors.white, size: 24),

                    // El número de vida
                    Center(
                      child: Text(
                        '$_life',
                        style: TextStyle(
                          fontSize: fontSize,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Icono visual para sumar (ya no es un botón)
                    const Icon(
                      Icons.remove_circle,
                      color: Colors.white,
                      size: 24,
                    ),
                    // const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            // El panel del historial (ocupa 1/3 del espacio)
            SizedBox(
              width: 78,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          return Text(
                            _history[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
