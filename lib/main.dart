import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(CalculadoraAppleStyle());

class CalculadoraAppleStyle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apple Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  String _operationLabel = '';
  double _firstOperand = 0;
  String _operator = '';
  bool _shouldClear = false;

  double _toRadians(double deg) => deg * pi / 180;

  void _input(String value) {
    setState(() {
      if (_shouldClear || _display == 'Error') {
        _display = value;
        _shouldClear = false;
      } else {
        if (_display == '0') {
          _display = value;
        } else {
          _display += value;
        }
      }
    });
  }

  void _clear() {
    setState(() {
      _display = '0';
      _operationLabel = '';
      _firstOperand = 0;
      _operator = '';
      _shouldClear = false;
    });
  }

  void _toggleSign() {
    setState(() {
      if (_display.startsWith('-')) {
        _display = _display.substring(1);
      } else {
        _display = '-$_display';
      }
    });
  }

  void _percentage() {
    setState(() {
      _display = (double.parse(_display) / 100).toString();
    });
  }

  void _setOperator(String op) {
    setState(() {
      _firstOperand = double.tryParse(_display) ?? 0;
      _operator = op;
      _operationLabel = '${_firstOperand.toString().replaceAll(RegExp(r"\.0$"), '')} $op';
      _shouldClear = true;
    });
  }

  void _calculate() {
    double secondOperand = double.tryParse(_display) ?? 0;
    double result = 0;

    switch (_operator) {
      case '+':
        result = _firstOperand + secondOperand;
        break;
      case '-':
        result = _firstOperand - secondOperand;
        break;
      case '×':
        result = _firstOperand * secondOperand;
        break;
      case '÷':
        result = secondOperand == 0 ? double.nan : _firstOperand / secondOperand;
        break;
    }

    setState(() {
      _display = result.isNaN || result.isInfinite
          ? 'Error'
          : result.toStringAsFixed(8).replaceAll(RegExp(r"\.?0+$"), '');
      _operationLabel = '';
      _shouldClear = true;
    });
  }

  double _factorialSafe(double n) {
    if (n < 0 || n != n.floorToDouble()) return double.nan;
    return List.generate(n.toInt(), (i) => i + 1).fold(1.0, (a, b) => a * b);
  }

  void _applyUnaryFn(double Function(double) fn) {
    try {
      final input = double.parse(_display);
      final result = fn(input);
      setState(() {
        _display = (result.isNaN || result.isInfinite)
            ? 'Error'
            : result.toStringAsFixed(8).replaceAll(RegExp(r'\.?0+$'), '');
        _operationLabel = '';
        _shouldClear = true;
      });
    } catch (e) {
      setState(() => _display = 'Error');
    }
  }

  Widget _buildButton(String text,
      {Color color = const Color(0xFF505050),
      Color textColor = Colors.white,
      double fontSize = 28,
      Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(6),
        width: text == '0' ? 160 : 75,
        height: 75,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(40),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(fontSize: fontSize, color: textColor),
        ),
      ),
    );
  }

  Widget _buildScientificFunctions() {
    final btnColor = Color(0xFF505050);
    final textColor = Colors.white;

    final functions = [
      {'label': 'sin', 'action': () => _applyUnaryFn((x) => sin(_toRadians(x)))},
      {'label': 'cos', 'action': () => _applyUnaryFn((x) => cos(_toRadians(x)))},
      {'label': 'tan', 'action': () => _applyUnaryFn((x) => tan(_toRadians(x)))},
      {'label': 'ln', 'action': () => _applyUnaryFn((x) => x > 0 ? log(x) : double.nan)},
      {'label': 'log', 'action': () => _applyUnaryFn((x) => x > 0 ? log(x) / ln10 : double.nan)},
      {'label': '√', 'action': () => _applyUnaryFn((x) => x >= 0 ? sqrt(x) : double.nan)},
      {'label': 'x²', 'action': () => _applyUnaryFn((x) => pow(x, 2).toDouble())},
      {'label': 'x!', 'action': () => _applyUnaryFn((x) => _factorialSafe(x))},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Wrap(
        spacing: 12,    // espacio horizontal
        runSpacing: 12, // espacio vertical
        children: functions.map((fn) {
          return GestureDetector(
            onTap: fn['action'] as VoidCallback,
            child: Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: btnColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                fn['label'] as String,
                style: TextStyle(color: textColor, fontSize: 20),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Etiqueta de la operación (pequeña)
            Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _operationLabel,
                style: TextStyle(fontSize: 20, color: Colors.grey),
                maxLines: 1,
              ),
            ),
            // Pantalla principal (grande)
            Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                _display,
                style: TextStyle(fontSize: 80, color: Colors.white),
                maxLines: 1,
              ),
            ),
            // Funciones científicas en dos filas
            _buildScientificFunctions(),
            // Teclado numérico y botones básicos
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButton('AC',
                        color: Colors.grey,
                        textColor: Colors.black,
                        onTap: _clear),
                    _buildButton('+/-',
                        color: Colors.grey,
                        textColor: Colors.black,
                        onTap: _toggleSign),
                    _buildButton('%',
                        color: Colors.grey,
                        textColor: Colors.black,
                        onTap: _percentage),
                    _buildButton('÷',
                        color: Colors.orange, onTap: () => _setOperator('÷')),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButton('7', onTap: () => _input('7')),
                    _buildButton('8', onTap: () => _input('8')),
                    _buildButton('9', onTap: () => _input('9')),
                    _buildButton('×',
                        color: Colors.orange, onTap: () => _setOperator('×')),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButton('4', onTap: () => _input('4')),
                    _buildButton('5', onTap: () => _input('5')),
                    _buildButton('6', onTap: () => _input('6')),
                    _buildButton('-',
                        color: Colors.orange, onTap: () => _setOperator('-')),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButton('1', onTap: () => _input('1')),
                    _buildButton('2', onTap: () => _input('2')),
                    _buildButton('3', onTap: () => _input('3')),
                    _buildButton('+',
                        color: Colors.orange, onTap: () => _setOperator('+')),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButton('0', onTap: () => _input('0')),
                    _buildButton('.', onTap: () => _input('.')),
                    _buildButton('=',
                        color: Colors.orange, onTap: _calculate),
                  ],
                ),
                SizedBox(height: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
