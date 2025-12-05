import 'package:flutter/material.dart';
import 'weather_model.dart';
import 'weather_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  WeatherService service = WeatherService();
  Weather? weather;
  String city = 'Ханты-Мансийск';
  bool loading = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    setState(() => loading = true);
    try {
      var w = await service.getWeather(city);
      setState(() => weather = w);
    } catch (e) {
      print(e);
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Погода')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : weather == null
              ? Center(child: Text('Нет данных'))
              : Column(children: [
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: city,
                      isExpanded: true,
                      items: service.getCityNames().map((c) {
                        return DropdownMenuItem(value: c, child: Text(c));
                      }).toList(),
                      onChanged: (newCity) {
                        if (newCity != null) {
                          setState(() => city = newCity);
                          load();
                        }
                      },
                    ),
                  ),

                  Card(
                    margin: EdgeInsets.all(16),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(children: [
                        Text(weather!.cityName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(weather!.icon, style: TextStyle(fontSize: 48)),
                            SizedBox(width: 20),
                            Text('${weather!.temp.round()}°C', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Text(weather!.condition),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(children: [Text('💧'), Text('${weather!.humidity}%')]),
                            Column(children: [Text('🌡️'), Text('${weather!.pressure} мм')]),
                            Column(children: [Text('💨'), Text('${weather!.windSpeed} м/с')]),
                          ],
                        ),
                      ]),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Прогноз на 5 дней', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),

                  Expanded(
                    child: ListView.builder(
                      itemCount: weather!.forecast.length,
                      itemBuilder: (context, i) {
                        var day = weather!.forecast[i];
                        var date = DateTime.parse(day.date);
                        var days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
                        
                        return ListTile(
                          leading: Text(day.icon, style: TextStyle(fontSize: 40)), // ИСПОЛЬЗУЕМ ИКОНКУ ИЗ МОДЕЛИ
                          title: Text('${days[date.weekday - 1]} ${i == 0 ? '  Сегодня' : ''}'),
                          subtitle: Text('День: ${day.dayTemp.round()}° | Ночь: ${day.nightTemp.round()}°'),
                          trailing: Text(day.condition),
                        );
                      },
                    ),
                  ),
                ]),
    );
  }
}