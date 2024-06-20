import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'weather_provider.dart';

class WeatherScreen extends StatefulWidget {
  final String city;

  WeatherScreen({required this.city});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final city = widget.city;
    try {
      await Provider.of<WeatherProvider>(context, listen: false).fetchWeather(city);
    } catch (e) {
      print('Error fetching weather: $e');

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Details'),
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          final weatherData = weatherProvider.weatherData;
          if (weatherData.isEmpty) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detailed Weather for ${widget.city}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWeatherInfoRow('Temperature', '${weatherData['temp']}°C'),
                          _buildWeatherInfoRow('Feels Like', '${weatherData['feels_like']}°C'),
                          _buildWeatherInfoRow('Max Temperature', '${weatherData['temp_max']}°C'),
                          _buildWeatherInfoRow('Min Temperature', '${weatherData['temp_min']}°C'),
                          _buildWeatherInfoRow('Condition', weatherData['description']),
                          _buildWeatherInfoRow('Humidity', '${weatherData['humidity']}%'),
                          _buildWeatherInfoRow('Wind Speed', '${weatherData['wind_speed']} m/s'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeatherInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
