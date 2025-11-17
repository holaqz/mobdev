import 'package:flutter/material.dart';

void main() {
  runApp(const UnitConverterApp());
}

class UnitConverterApp extends StatelessWidget {
  const UnitConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Конвертер единиц',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Конвертер единиц'),
        elevation: 2,
      ),
      body: _buildCategoryList(),
    );
  }

  Widget _buildCategoryList() {
    const categories = [
      _CategoryItem('📏', 'Длина', Colors.blue),
      _CategoryItem('⚖️', 'Вес', Colors.green),
      _CategoryItem('🌡️', 'Температура', Colors.orange),
      _CategoryItem('📐', 'Площадь', Colors.purple),
      _CategoryItem('🧪', 'Объем', Colors.red),
      _CategoryItem('⏰', 'Время', Colors.teal),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final category = categories[index];
        return _CategoryCard(
          icon: category.icon,
          title: category.title,
          color: category.color,
          onTap: () => _navigateToConverter(context, category.title),
        );
      },
    );
  }

  void _navigateToConverter(BuildContext context, String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConverterScreen(category: category),
      ),
    );
  }
}

class _CategoryItem {
  final String icon;
  final String title;
  final Color color;

  const _CategoryItem(this.icon, this.title, this.color);
}

class _CategoryCard extends StatelessWidget {
  final String icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(icon, style: const TextStyle(fontSize: 20)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class ConverterScreen extends StatefulWidget {
  final String category;

  const ConverterScreen({super.key, required this.category});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  static const _maxInputLength = 12;
  String _input = '';
  String _result = '0';
  String _fromUnit = '';
  String _toUnit = '';

  late final ConversionManager _conversionManager;

  @override
  void initState() {
    super.initState();
    _conversionManager = ConversionManager();
    final units = _conversionManager.getAvailableUnits(widget.category);
    _fromUnit = units.first;
    _toUnit = units.length > 1 ? units[1] : units.first;
    _calculateResult();
  }

  void _onDigitPressed(String digit) {
    if (_input.length >= _maxInputLength) return;
    
    setState(() {
      _input += digit;
      _calculateResult();
    });
  }

  void _onDecimalPressed() {
    if (_input.length >= _maxInputLength || _input.contains('.')) return;
    
    setState(() {
      _input += _input.isEmpty ? '0.' : '.';
      _calculateResult();
    });
  }

  void _calculateResult() {
    if (_input.isEmpty) {
      setState(() => _result = '0');
      return;
    }

    try {
      final value = double.parse(_input);
      final converted = _conversionManager.convert(
        value: value,
        category: widget.category,
        fromUnit: _fromUnit,
        toUnit: _toUnit,
      );
      setState(() => _result = _formatNumber(converted));
    } catch (e) {
      setState(() => _result = 'Ошибка');
    }
  }

  String _formatNumber(double number) {
    if (number == 0) return '0';
    
    final absValue = number.abs();
    if (absValue > 1e6 || absValue < 1e-6) {
      return number.toStringAsExponential(4);
    } else if (absValue < 1) {
      return number.toStringAsPrecision(6);
    } else {
      return number.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '');
    }
  }

  void _swapUnits() {
    setState(() {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
      _calculateResult();
    });
  }

  void _clearInput() {
    setState(() {
      _input = '';
      _result = '0';
    });
  }

  void _backspace() {
    if (_input.isNotEmpty) {
      setState(() {
        _input = _input.substring(0, _input.length - 1);
        _calculateResult();
      });
    }
  }

  bool get _isInputLimitReached => _input.length >= _maxInputLength;

  @override
  Widget build(BuildContext context) {
    final availableUnits = _conversionManager.getAvailableUnits(widget.category);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Ввод
            _ConversionCard(
              title: 'Из',
              value: _input.isEmpty ? '0' : _input,
              selectedUnit: _fromUnit,
              availableUnits: availableUnits,
              isInput: true,
              characterCount: '${_input.length}/$_maxInputLength',
              showWarning: _isInputLimitReached,
              onUnitChanged: (unit) {
                setState(() {
                  _fromUnit = unit!;
                  _calculateResult();
                });
              },
            ),

            const SizedBox(height: 16),

            // Кнопка обмена
            IconButton(
              onPressed: _swapUnits,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.swap_vert, size: 24),
              ),
            ),

            const SizedBox(height: 16),

            // Результат
            _ConversionCard(
              title: 'В',
              value: _result,
              selectedUnit: _toUnit,
              availableUnits: availableUnits,
              isResult: true,
              onUnitChanged: (unit) {
                setState(() {
                  _toUnit = unit!;
                  _calculateResult();
                });
              },
            ),

            const Spacer(),

            // Цифровая клавиатура
            _NumberPad(
              onDigitPressed: _onDigitPressed,
              onDecimalPressed: _onDecimalPressed,
              onBackspace: _backspace,
              onClear: _clearInput,
              isInputLimitReached: _isInputLimitReached,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversionCard extends StatelessWidget {
  final String title;
  final String value;
  final String selectedUnit;
  final List<String> availableUnits;
  final bool isInput;
  final bool isResult;
  final String? characterCount;
  final bool? showWarning;
  final ValueChanged<String?> onUnitChanged;

  const _ConversionCard({
    required this.title,
    required this.value,
    required this.selectedUnit,
    required this.availableUnits,
    required this.onUnitChanged,
    this.isInput = false,
    this.isResult = false,
    this.characterCount,
    this.showWarning,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isResult ? Theme.of(context).primaryColor : Colors.black;
    final warningColor = Colors.red;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isResult ? Theme.of(context).primaryColor : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                if (characterCount != null)
                  Text(
                    characterCount!,
                    style: TextStyle(
                      color: (showWarning ?? false) ? warningColor : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: selectedUnit,
                  onChanged: onUnitChanged,
                  items: availableUnits.map((unit) {
                    return DropdownMenuItem<String>(
                      value: unit,
                      child: Text(unit),
                    );
                  }).toList(),
                ),
              ],
            ),
            if (showWarning ?? false) ...[
              const SizedBox(height: 8),
              Text(
                'Достигнут лимит ввода',
                style: TextStyle(
                  color: warningColor,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NumberPad extends StatelessWidget {
  final Function(String) onDigitPressed;
  final VoidCallback onDecimalPressed;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final bool isInputLimitReached;

  const _NumberPad({
    required this.onDigitPressed,
    required this.onDecimalPressed,
    required this.onBackspace,
    required this.onClear,
    required this.isInputLimitReached,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.5,
          ),
          itemCount: 12,
          itemBuilder: (context, index) {
            if (index < 9) {
              // Цифры 1-9
              return _NumberButton(
                label: (index + 1).toString(),
                onPressed: () => onDigitPressed((index + 1).toString()),
                isDisabled: isInputLimitReached,
              );
            } else if (index == 9) {
              // Точка
              return _NumberButton(
                label: '.',
                onPressed: isInputLimitReached ? null : onDecimalPressed,
                isDisabled: isInputLimitReached,
              );
            } else if (index == 10) {
              // Ноль
              return _NumberButton(
                label: '0',
                onPressed: () => onDigitPressed('0'),
                isDisabled: isInputLimitReached,
              );
            } else {
              // Backspace
              return _NumberButton(
                label: '⌫',
                onPressed: onBackspace,
                backgroundColor: Colors.orange[100],
                textColor: Colors.orange[800],
              );
            }
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: onClear,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Очистить'),
          ),
        ),
      ],
    );
  }
}

class _NumberButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isDisabled;

  const _NumberButton({
    required this.label,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
        foregroundColor: textColor ?? Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 1,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class ConversionManager {
  final Map<String, Map<String, double>> _conversionFactors = {
    'Длина': {
      'Миллиметры': 0.001,
      'Сантиметры': 0.01,
      'Метры': 1.0,
      'Километры': 1000.0,
      'Дюймы': 0.0254,
      'Футы': 0.3048,
      'Ярды': 0.9144,
      'Мили': 1609.344,
    },
    'Вес': {
      'Миллиграммы': 0.000001,
      'Граммы': 0.001,
      'Килограммы': 1.0,
      'Тонны': 1000.0,
      'Фунты': 0.453592,
      'Унции': 0.0283495,
    },
    'Температура': {
      'Цельсий': 1.0,
      'Фаренгейт': 1.0,
      'Кельвин': 1.0,
    },
    'Площадь': {
      'Кв. миллиметры': 0.000001,
      'Кв. сантиметры': 0.0001,
      'Кв. метры': 1.0,
      'Гектары': 10000.0,
      'Кв. километры': 1000000.0,
      'Акры': 4046.86,
      'Кв. мили': 2589988.11,
    },
    'Объем': {
      'Миллилитры': 0.001,
      'Литры': 1.0,
      'Кубические метры': 1000.0,
      'Галлоны (US)': 3.78541,
      'Пинты (US)': 0.473176,
    },
    'Время': {
      'Миллисекунды': 0.001,
      'Секунды': 1.0,
      'Минуты': 60.0,
      'Часы': 3600.0,
      'Дни': 86400.0,
      'Недели': 604800.0,
    },
  };

  List<String> getAvailableUnits(String category) {
    return _conversionFactors[category]?.keys.toList() ?? [];
  }

  double convert({
    required double value,
    required String category,
    required String fromUnit,
    required String toUnit,
  }) {
    if (fromUnit == toUnit) return value;

    if (category == 'Температура') {
      return _convertTemperature(value, fromUnit, toUnit);
    }

    final factors = _conversionFactors[category];
    if (factors == null) throw Exception('Категория не найдена');

    final fromFactor = factors[fromUnit];
    final toFactor = factors[toUnit];
    
    if (fromFactor == null || toFactor == null) {
      throw Exception('Единица измерения не найдена');
    }

    return value * fromFactor / toFactor;
  }

  double _convertTemperature(double value, String from, String to) {
    if (from == to) return value;

    double celsius;
    switch (from) {
      case 'Фаренгейт':
        celsius = (value - 32) * 5 / 9;
        break;
      case 'Кельвин':
        celsius = value - 273.15;
        break;
      default:
        celsius = value;
    }

    switch (to) {
      case 'Фаренгейт':
        return (celsius * 9 / 5) + 32;
      case 'Кельвин':
        return celsius + 273.15;
      default:
        return celsius;
    }
  }
}
