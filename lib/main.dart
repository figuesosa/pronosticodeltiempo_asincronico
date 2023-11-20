// ignore_for_file: depend_on_referenced_packages, prefer_const_constructors, library_private_types_in_public_api, avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WeatherApp(),
    );
  }
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  late WeatherData _weatherData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    const String apiKey = 'f3331d172581407182a02703231511';
    const String apiUrl =
        'https://api.weatherapi.com/v1/current.json?q=city&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _weatherData = WeatherData.fromJson(data);
          _loading = false;
        });
      } else {
        // Handle error
        print('Error fetching weather data: ${response.statusCode}');
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      // Handle exception
      print('Exception during weather data fetch: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _refreshWeatherData() async {
    setState(() {
      _loading = true;
    });
    await _fetchWeatherData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : WeatherWidget(
              weatherData: _weatherData, onRefresh: _refreshWeatherData),
    );
  }
}

class WeatherWidget extends StatelessWidget {
  final WeatherData weatherData;
  final VoidCallback onRefresh;

  const WeatherWidget(
      {super.key, required this.weatherData, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Temperature: ${weatherData.temperature}°C'),
        Text('Conditions: ${weatherData.conditions}'),
        Text('Wind Speed: ${weatherData.windSpeed} km/h'),
        // Add more weather information widgets as needed
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: onRefresh,
          child: Text('Refresh'),
        ),
      ],
    );
  }
}

class WeatherData {
  final double temperature;
  final String conditions;
  final double windSpeed;

  WeatherData(
      {required this.temperature,
      required this.conditions,
      required this.windSpeed});

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: json['current']['temp_c'],
      conditions: json['current']['condition']['text'],
      windSpeed: json['current']['wind_kph'],
    );
  }
}
