import 'package:flutter/material.dart';

void main() => runApp(Calendar());

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {

  List<DateTime?> _getCalendarDays() {
    final List<DateTime?> days = [];
    
    final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    final lastDayOfMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;

    for (int i = 1; i < firstWeekday; i++) {
      days.add(null);
    }
    
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      days.add(DateTime(_currentDate.year, _currentDate.month, day));
    }
    
    final totalCells = 42;
    while (days.length < totalCells) {
      days.add(null);
    }
    
    return days;
  }

  DateTime _currentDate = DateTime.now();
  final DateTime _today = DateTime.now();
  
  String get _displayedMonth {
    const months = [
      'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
      'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
    ];
    return '${months[_currentDate.month - 1]} ${_currentDate.year}';
  }

    bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.blueGrey),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 175, 230, 255),
          title: Text('Календарь'),
          ),
        body: Container(
          color: const Color.fromARGB(255, 175, 230, 255),
          margin: EdgeInsets.only(top: 20, bottom: 300, right: 20, left: 20),
          padding: EdgeInsets.only(top:30, left: 30, right: 30, bottom: 30),
          child:
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              Text('${_currentDate.year}'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  IconButton(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    onPressed: () {
                      _goToPrevYear();
                    },
                    icon: Icon(Icons.keyboard_double_arrow_left_rounded),
                  ),
                  IconButton(
                    padding: EdgeInsets.symmetric(vertical: 3),
                    onPressed: () {
                      _goToPreviousMonth();
                    },
                    icon: Icon(Icons.arrow_back_ios),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child:
                      Text(
                        _displayedMonth, 
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15),
                        ),
                    ),
                  IconButton(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    onPressed: () {
                      _goToNextMonth();
                    },
                    icon: Icon(Icons.arrow_forward_ios),
                  ),
                  IconButton(
                    padding: EdgeInsets.symmetric(vertical: 3),
                    onPressed: () {
                      _goToNextYear();
                    },
                    icon: Icon(Icons.keyboard_double_arrow_right_rounded),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child:
                    Text('Пн', style: TextStyle(fontWeight: FontWeight.w300)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child:
                    Text('Вт', style: TextStyle(fontWeight: FontWeight.w300)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child:
                    Text('Ср', style: TextStyle(fontWeight: FontWeight.w300)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child:
                    Text('Чт', style: TextStyle(fontWeight: FontWeight.w300)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child:
                    Text('Пт', style: TextStyle(fontWeight: FontWeight.w300)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child:
                    Text('Сб', style: TextStyle(fontWeight: FontWeight.w300)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child:
                    Text('Вс', style: TextStyle(fontWeight: FontWeight.w300)),
                  ),
                ],
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _getCalendarDays().length,
                  itemBuilder: (context, index) {
                    final day = _getCalendarDays()[index];
                    return Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: day == null 
                            ? Colors.transparent 
                            : _isToday(day) 
                                ? Colors.blue 
                                : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: day != null && _isToday(day) 
                              ? Colors.blue 
                              : Color.fromARGB(255, 175, 230, 255),
                        ),
                      ),
                      child: day == null 
                        ? null 
                        : Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                color: _isToday(day) 
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: _isToday(day)
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              OutlinedButton(
                onPressed: _goToCurrentMonth, 
                child: Text('Вернуться к сегодняшнему дню'),
              )
            ],
            )
          ), 
        ),
      );
  }
    
  void _goToPreviousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
    });
  }
  void _goToNextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
    });
  }
  void _goToCurrentMonth() {
    setState(() {
      _currentDate = DateTime(_today.year, _today.month);
    });
  }

  void _goToNextYear() {
    setState(() {
      _currentDate = DateTime(_currentDate.year + 1, _currentDate.month);
    });
  }

    void _goToPrevYear() {
    setState(() {
      _currentDate = DateTime(_currentDate.year - 1, _currentDate.month);
    });
  }
}
