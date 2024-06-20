import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_screen.dart';
import 'weather_provider.dart';
import 'weather_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _name = '';
  String _email = '';
  String _location = '';
  final TextEditingController _searchController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? '';
      _email = prefs.getString('email') ?? '';
      _location = prefs.getString('location') ?? '';
      _searchController.text = _location;
    });

    if (_location.isNotEmpty) {
      await _fetchWeather(_location);
    }
  }

  Future<void> _fetchWeather(String city) async {
    setState(() {
      _loading = true;
    });
    await Provider.of<WeatherProvider>(context, listen: false).fetchWeather(city);
    setState(() {
      _loading = false;
    });
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => ProfileScreen()),
    );
  }

  void _navigateToWeatherScreen(String city) {
    if (city.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WeatherScreen(city: city),
        ),
      );
    }
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey.shade900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text('Profile', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Name: $_name',
                style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Email: $_email',
                style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'HomeCity: $_location',
                style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                child: Text(
                    style:  TextStyle(
                      color: Colors.white
                    ),
                    'Log Out'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        title: TextField(
          controller: _searchController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade800,
            hintText: 'Enter city name',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            enabledBorder: OutlineInputBorder(
              //borderSide: BorderSide(color: Colors.grey.shade700),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                //color: Colors.white,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              _fetchWeather(value);
            }
          },
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.person, size: 30, color: Colors.white),
            onPressed: _showProfileDialog,
          ),
        ],
      ),
      body:Stack(
        children: [
      Container(
      decoration: BoxDecoration(
      image: DecorationImage(
          image: AssetImage('assets/background.jpeg'),
      fit: BoxFit.cover,
    ),
    ),
    ),

      Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          if (_loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return Padding(

            padding: const EdgeInsets.all(16.0),
            child: weatherProvider.weatherData.isNotEmpty
                ? GestureDetector(
              onTap: () => _navigateToWeatherScreen(weatherProvider.city),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: WeatherCard(weatherProvider: weatherProvider),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Click on the card for detailed weather',
                    style: TextStyle(color: Colors.black87, fontSize: 16),
                  ),
                ],
              ),
            )
                : Center(
              child: Text(
                'No weather data available',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
            ),
          );
        },
      ),
      //backgroundColor: Colors.grey,
],
      ),

    );
  }
}

class WeatherCard extends StatelessWidget {
  final WeatherProvider weatherProvider;

  const WeatherCard({required this.weatherProvider});

  @override
  Widget build(BuildContext context) {
    return Card(

      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  '${weatherProvider.city.toUpperCase()}',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${weatherProvider.weatherData['temp']}°',
                  style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'High: ${weatherProvider.weatherData['temp_max']}° | Low: ${weatherProvider.weatherData['temp_min']}°',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
