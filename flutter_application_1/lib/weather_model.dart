class Weather {
  String cityName;
  double temp;
  int humidity;
  int pressure;
  double windSpeed;
  String condition;
  String icon;
  List<Forecast> forecast;

  Weather({
    required this.cityName,
    required this.temp,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.condition,
    required this.icon,
    required this.forecast,
  });

  factory Weather.fromJson(Map<String, dynamic> json, String city) {
    var fact = json['fact'];
    var forecasts = json['forecasts'];
    
    return Weather(
      cityName: city,
      temp: fact['temp'].toDouble(),
      humidity: fact['humidity'],
      pressure: fact['pressure_mm'],
      windSpeed: fact['wind_speed'].toDouble(),
      condition: _translate(fact['condition']),
      icon: _getIcon(fact['condition']),
      forecast: _getForecast(forecasts),
    );
  }

  static String _translate(String cond) {
    var dict = {
      'clear': 'Ясно',
      'partly-cloudy': 'Малооблачно',
      'cloudy': 'Облачно',
      'overcast': 'Пасмурно',
      'light-rain': 'Дождь',
      'rain': 'Дождь',
      'snow': 'Снег',
    };
    return dict[cond] ?? 'Ясно';
  }

  static String _getIcon(String cond) {
    var dict = {
      'clear': '☀️',
      'partly-cloudy': '⛅',
      'cloudy': '☁️',
      'overcast': '☁️',
      'light-rain': '🌧️',
      'rain': '🌧️',
      'snow': '❄️',
    };
    return dict[cond] ?? '☀️';
  }

  static List<Forecast> _getForecast(List<dynamic> data) {
    var result = <Forecast>[];
    for (var i = 0; i < 5 && i < data.length; i++) {
      var day = data[i];
      var parts = day['parts'];
      var dayShort = parts['day_short'];
      
      result.add(Forecast(
        date: day['date'],
        dayTemp: dayShort['temp']?.toDouble() ?? 0,
        nightTemp: parts['night_short']['temp']?.toDouble() ?? 0,
        condition: _translate(dayShort['condition'] ?? 'clear'),
        icon: _getIcon(dayShort['condition'] ?? 'clear'),
      ));
    }
    return result;
  }
}

class Forecast {
  String date;
  double dayTemp;
  double nightTemp;
  String condition;
  String icon;

  Forecast({
    required this.date,
    required this.dayTemp,
    required this.nightTemp,
    required this.condition,
    required this.icon,
  });
}

