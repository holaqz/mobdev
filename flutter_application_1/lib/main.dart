import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Калькулятор',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CalculatorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  static const _maxDisplayLength = 12;
  
  String _display = "0";
  String _currentInput = "";
  double? _firstOperand;
  String? _pendingOperation;
  bool _shouldResetInput = false;

  void _handleInput(String input) {
    setState(() {
      if (_display == "Ошибка" || _display == "Слишком длинное") {
        _resetCalculator();
      }

      switch (input) {
        case "C":
          _resetCalculator();
          break;
        case "⌫":
          _handleBackspace();
          break;
        case "=":
          _handleEquals();
          break;
        case "√":
          _handleSquareRoot();
          break;
        case "+": case "-": case "×": case "÷": case "^":
          _handleOperation(input);
          break;
        default:
          _handleDigitOrDecimal(input);
      }
    });
  }

  void _resetCalculator() {
    _display = "0";
    _currentInput = "";
    _firstOperand = null;
    _pendingOperation = null;
    _shouldResetInput = false;
  }

  void _handleBackspace() {
    if (_currentInput.isNotEmpty) {
      _currentInput = _currentInput.substring(0, _currentInput.length - 1);
      _display = _currentInput.isEmpty ? "0" : _currentInput;
    }
  }

  void _handleEquals() {
    if (_pendingOperation == null || _currentInput.isEmpty) return;

    final secondOperand = double.parse(_currentInput);
    
    // Обработка деления на ноль перед вычислением
    if (_pendingOperation == "÷" && secondOperand == 0) {
      _display = "Ошибка";
      _currentInput = _display;
      _pendingOperation = null;
      _shouldResetInput = true;
      return;
    }
    
    final result = _calculate(_firstOperand!, secondOperand, _pendingOperation!);
    
    _updateDisplay(result);
    _currentInput = _display;
    _pendingOperation = null;
    _shouldResetInput = true;
  }

  void _handleSquareRoot() {
    if (_currentInput.isEmpty) return;
    
    final number = double.parse(_currentInput);
    if (number < 0) {
      _display = "Ошибка";
      _currentInput = _display;
      return;
    }
    
    final result = math.sqrt(number);
    _updateDisplay(result);
    _currentInput = _display;
    _shouldResetInput = true;
  }

  void _handleOperation(String operation) {
    if (_currentInput.isNotEmpty) {
      _firstOperand = double.parse(_currentInput);
      _pendingOperation = operation;
      _display = "$_currentInput $operation ";
      _currentInput = "";
    }
  }

  void _handleDigitOrDecimal(String input) {
    if (_shouldResetInput) {
      _currentInput = "";
      _shouldResetInput = false;
    }

    if (_currentInput.length >= _maxDisplayLength) return;

    if (input == ".") {
      if (!_currentInput.contains(".")) {
        _currentInput += _currentInput.isEmpty ? "0." : ".";
      }
    } else {
      if (_currentInput == "0") {
        _currentInput = input;
      } else {
        _currentInput += input;
      }
    }
    _display = _currentInput;
  }

  double? _calculate(double a, double b, String operation) {
    try {
      switch (operation) {
        case "+": return a + b;
        case "-": return a - b;
        case "×": return a * b;
        case "÷": 
          // Проверка деления на ноль
          if (b == 0) return null;
          return a / b;
        case "^": 
          // Проверка на слишком большие числа
          final result = math.pow(a, b);
          if (result.isInfinite) return null;
          return result.toDouble();
        default: return 0;
      }
    } catch (e) {
      // Обработка любых других математических ошибок
      return null;
    }
  }

  void _updateDisplay(double? result) {
    // Если результат null (ошибка) или бесконечность/NaN
    if (result == null || result.isInfinite || result.isNaN) {
      _display = "Ошибка";
      return;
    }

    String resultString = result.toString();
    
    // Убираем .0 для целых чисел
    if (resultString.endsWith('.0')) {
      resultString = resultString.substring(0, resultString.length - 2);
    }

    // Обработка длинных чисел
    if (resultString.length > _maxDisplayLength) {
      if (resultString.contains('.')) {
        try {
          _display = double.parse(resultString).toStringAsPrecision(8);
        } catch (e) {
          _display = "Слишком длинное";
        }
      } else {
        _display = "Слишком длинное";
      }
    } else {
      _display = resultString;
    }
  }

  Widget _buildButton(
    String text, {
    Color backgroundColor = const Color(0xFF333333),
    Color textColor = Colors.white,
  }) {
    return Container(
      margin: const EdgeInsets.all(6),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(20),
          minimumSize: const Size(86, 86),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.3),
        ),
        onPressed: () => _handleInput(text),
        child: Text(
          text,
          style: TextStyle(
            fontSize: _getFontSize(text),
            fontWeight: FontWeight.w400,
            color: textColor,
          ),
        ),
      ),
    );
  }

  double _getFontSize(String text) {
    switch (text) {
      case "√": return 24;
      case "⌫": return 22;
      case "×": case "÷": case "^": return 26;
      default: return 28;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Калькулятор'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Дисплей
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        _display,
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Клавиатура
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    // Первый ряд
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton("C", 
                            backgroundColor: const Color(0xFFA5A5A5), 
                            textColor: Colors.black),
                          _buildButton("⌫", 
                            backgroundColor: const Color(0xFFA5A5A5), 
                            textColor: Colors.black),
                          _buildButton("√", 
                            backgroundColor: const Color(0xFFA5A5A5), 
                            textColor: Colors.black),
                          _buildButton("÷", 
                            backgroundColor: Colors.orange),
                        ],
                      ),
                    ),
                    
                    // Второй ряд
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton("7"),
                          _buildButton("8"),
                          _buildButton("9"),
                          _buildButton("×", 
                            backgroundColor: Colors.orange),
                        ],
                      ),
                    ),
                    
                    // Третий ряд
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton("4"),
                          _buildButton("5"),
                          _buildButton("6"),
                          _buildButton("-", 
                            backgroundColor: Colors.orange),
                        ],
                      ),
                    ),
                    
                    // Четвертый ряд
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton("1"),
                          _buildButton("2"),
                          _buildButton("3"),
                          _buildButton("+", 
                            backgroundColor: Colors.orange),
                        ],
                      ),
                    ),
                    
                    // Пятый ряд
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton("."),
                          _buildButton("0"),
                          _buildButton("^", 
                            backgroundColor: Colors.orange),
                          _buildButton("=", 
                            backgroundColor: Colors.orange),
                        ],
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