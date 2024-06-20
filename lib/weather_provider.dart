import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherProvider with ChangeNotifier {
  final String _apiKey = '68efc10942ab85726523776691a4607b';
  Map<String, dynamic> _weatherData = {};
  String _city = '';

  Map<String, dynamic> get weatherData => _weatherData;
  String get city => _city;

  set city(String value) {
    _city = value;
    notifyListeners();
  }

  Future<void> fetchWeather(String cityName) async {
    try {
      final coordinates = await _fetchCoordinates(cityName);
      if (coordinates != null) {
        await _fetchWeatherData(coordinates['lat']!, coordinates['lon']!);
        _city = cityName;
        notifyListeners();
      } else {
        throw Exception('Failed to get coordinates for city: $cityName');
      }
    } catch (error) {
      print('Error fetching weather data: $error');
      _weatherData = {};
      notifyListeners();
    }
  }

  Future<Map<String, double>?> _fetchCoordinates(String cityName) async {
    final url = Uri.parse('http://api.openweathermap.org/geo/1.0/direct?q=$cityName&limit=1&appid=$_apiKey');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          final lat = data[0]['lat'];
          final lon = data[0]['lon'];
          return {'lat': lat, 'lon': lon};
        } else {
          return null;
        }
      } else {
        print('Failed to load coordinates: ${response.reasonPhrase}');
        return null;
      }
    } catch (error) {
      print('Error fetching coordinates: $error');
      return null;
    }
  }

  Future<void> _fetchWeatherData(double lat, double lon) async {
    final url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric');
    final response = await http.get(url);
    print('Weather API Response Status Code: ${response.statusCode}');
    print('Weather API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _weatherData = {
        'temp': data['main']['temp'].toString(),
        'humidity': data['main']['humidity'].toString(),
        'wind_speed': data['wind']['speed'].toString(),
        'temp_max': data['main']['temp_max'].toString(),
        'temp_min':data['main']['temp_min'].toString(),
        'description': data['weather'][0]['description'],
        'feels_like': data['main']['feels_like'].toString(),

      };
      print('Weather data fetched successfully: $_weatherData');
      //notifyListeners();
    } else {
      print('Failed to load weather data: ${response.reasonPhrase}');
      throw Exception('Failed to load weather data: ${response.reasonPhrase}');
    }
  }
}
