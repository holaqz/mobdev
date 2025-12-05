import 'dart:convert';
import 'package:http/http.dart' as http;
import 'weather_model.dart';

class WeatherService {
  String apiKey = '707f8d53-a650-4533-9c7c-01431ffcd9fd';
  String baseUrl = 'https://api.weather.yandex.ru/v2';

  // Только 5 городов
  Map<String, Map<String, double>> cities = {
    'Ханты-Мансийск': {'lat': 61.0042, 'lon': 69.0019},
    'Москва': {'lat': 55.7558, 'lon': 37.6176},
    'Санкт-Петербург': {'lat': 59.9391, 'lon': 30.3159},
    'Екатеринбург': {'lat': 56.8389, 'lon': 60.6057},
    'Казань': {'lat': 55.7961, 'lon': 49.1064},
  };

  Future<Weather> getWeather(String city) async {
    var coords = cities[city];
    var url = Uri.parse('$baseUrl/forecast?lat=${coords!['lat']}&lon=${coords['lon']}&lang=ru_RU');
    
    var response = await http.get(url, headers: {'X-Yandex-Weather-Key': apiKey});
    
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return Weather.fromJson(data, city);
    } else {
      throw Exception('Ошибка ${response.statusCode}');
    }
  }

  List<String> getCityNames() => cities.keys.toList();
}