import 'package:flutter/material.dart';

class NumberStepper extends StatefulWidget {
  final int initialValue;
  final ValueChanged<int> onChanged;
  final ValueNotifier<bool> resetNotifier;

  const NumberStepper({
    super.key,
    this.initialValue = 1,
    required this.onChanged,
    required this.resetNotifier,
  });

  @override
  State<NumberStepper> createState() => _NumberStepperState();
}

class _NumberStepperState extends State<NumberStepper> {
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    widget.resetNotifier.addListener(_reset);
  }

  @override
  void dispose() {
    widget.resetNotifier.removeListener(_reset);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant NumberStepper oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        _currentValue = widget.initialValue;
      });
    }
  }

  void _reset() {
    setState(() {
      _currentValue = 1;
      widget.onChanged(_currentValue);
    });
  }

  void _increment([int cantidad = 1]) {
    setState(() {
      _currentValue = _currentValue + cantidad;
      widget.onChanged(_currentValue);
    });
  }

  void _decrement([int cantidad = 1]) {
    if (_currentValue > 1) {
      setState(() {
        _currentValue = _currentValue - cantidad;
        widget.onChanged(_currentValue);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle, color: Colors.white, size: 40),
          onPressed: _currentValue > 1 ? _decrement : null,
          onLongPress: _currentValue > 10 ? () => _decrement(10) : null,
        ),
        SizedBox(
          width: 56, // Puedes ajustar este valor según el tamaño de tu fuente
          child: Text(
            '$_currentValue',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
            textAlign:
                TextAlign.center, // Centramos el número dentro del espacio
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle, color: Colors.white, size: 40),
          onPressed: _currentValue < 99 ? _increment : null,
          onLongPress: _currentValue < 90 ? () => _increment(10) : null,
        ),
      ],
    );
  }
}
