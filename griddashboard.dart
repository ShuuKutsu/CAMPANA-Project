import 'dart:async';
import 'dart:convert';
import 'package:dashboard_flutter_01/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class GridDashboard extends StatefulWidget {
  final String barangayName;

  const GridDashboard({Key? key, required this.barangayName}) : super(key: key);

  @override
  _GridDashboardState createState() => _GridDashboardState();
}

class _GridDashboardState extends State<GridDashboard> {
  Map<String, dynamic> weatherData = {};
  Timer? _timer;
  bool isLoading = true;
  String error = '';
  DateTime currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        currentTime = DateTime.now();
      });
      fetchWeatherData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchWeatherData() async {
    try {
      // Test different water levels by changing this value
      final testData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'humidity': '75',
        'amount_of_rain': '35',
        'temperature': '32',
        'windspeed': '40',
        'waterlevel': '680', // This will trigger "Severe" notification (9 cm)
      };

      setState(() {
        weatherData = testData;
        isLoading = false;
        error = '';
      });

      double humidity = double.tryParse(testData['humidity']?.toString() ?? '0') ?? 0;
      double rainAmount = double.tryParse(testData['amount_of_rain']?.toString() ?? '0') ?? 0;
      double temperature = double.tryParse(testData['temperature']?.toString() ?? '0') ?? 0;
      double windSpeed = double.tryParse(testData['windspeed']?.toString() ?? '0') ?? 0;
      double waterLevel = double.tryParse(testData['waterlevel']?.toString() ?? '0') ?? 0;

      await NotificationService.showWeatherAlert(
        humidity: humidity,
        rainAmount: rainAmount,
        temperature: temperature,
        windSpeed: windSpeed,
        waterLevel: waterLevel,
      );

    } catch (e) {
      print('Error occurred: $e');
      setState(() {
        error = 'Connection error: $e';
        isLoading = false;
      });
    }
  }

  String getWindCondition(double windSpeed) {
    const double calmThreshold = 4.83;
    const double lightAirMax = 4.83;
    const double lightBreezeMax = 11.27;
    const double gentleBreezeMax = 19.31;
    const double moderateBreezeMax = 28.97;
    const double freshBreezeMax = 38.62;

    const double signal1Min = 39.0;
    const double signal1Max = 61.0;
    const double signal2Max = 88.0;
    const double signal3Max = 117.0;
    const double signal4Max = 184.0;

    if (windSpeed >= signal1Min) {
      if (windSpeed <= signal1Max) return "Signal No. 1";
      if (windSpeed <= signal2Max) return "Signal No. 2";
      if (windSpeed <= signal3Max) return "Signal No. 3";
      if (windSpeed <= signal4Max) return "Signal No. 4";
      return "Super Typhoon";
    } else {
      if (windSpeed < calmThreshold) return "Calm";
      if (windSpeed <= lightAirMax) return "Light Air";
      if (windSpeed <= lightBreezeMax) return "Light Breeze";
      if (windSpeed <= gentleBreezeMax) return "Gentle Breeze";
      if (windSpeed <= moderateBreezeMax) return "Moderate Breeze";
      if (windSpeed <= freshBreezeMax) return "Fresh Breeze";
      return "Strong Breeze";
    }
  }

  String getFloodRisk(double rainAmount) {
    if (rainAmount < 10) {
      return "Very Low";
    } else if (rainAmount < 30) {
      return "Low";
    } else if (rainAmount < 50) {
      return "Moderate";
    } else if (rainAmount < 100) {
      return "High";
    } else if (rainAmount < 150) {
      return "Very High";
    } else {
      return "Severe";
    }
  }

  String getTemperatureDescription(double temperature) {
    if (temperature <= 10) {
      return "Cold";
    } else if (temperature <= 20) {
      return "Cool";
    } else if (temperature <= 25) {
      return "Mild";
    } else if (temperature <= 30) {
      return "Warm";
    } else if (temperature <= 35) {
      return "Hot";
    } else if (temperature <= 40) {
      return "Very Hot";
    } else {
      return "Extremely Hot";
    }
  }

  String getWeatherCondition() {
    if (weatherData.isEmpty) return "Loading...";

    try {
      final amountOfRain = double.tryParse(weatherData['amount_of_rain']?.toString() ?? '0') ?? 0;
      final windSpeed = double.tryParse(weatherData['windspeed']?.toString() ?? '0') ?? 0;
      final humidity = double.tryParse(weatherData['humidity']?.toString() ?? '0') ?? 0;
      final temperature = double.tryParse(weatherData['temperature']?.toString() ?? '0') ?? 0;

      if (windSpeed >= 39.0 || (windSpeed >= 20.0 && amountOfRain >= 7.5)) {
        return "Stormy";
      }
      if (amountOfRain >= 2.5) {
        return "Rainy";
      }
      if (windSpeed >= 15.0) {
        return "Windy";
      }
      if (humidity >= 70.0 || temperature <= 20.0) {
        return "Cloudy";
      }
      return "Sunny";
    } catch (e) {
      print('Error in getWeatherCondition: $e');
      return "Unknown";
    }
  }

  IconData getWeatherIcon() {
    String condition = getWeatherCondition();
    switch (condition) {
      case "Sunny":
        return Icons.wb_sunny;
      case "Cloudy":
        return Icons.cloud;
      case "Rainy":
        return Icons.grain;
      case "Windy":
        return Icons.air;
      case "Stormy":
        return Icons.thunderstorm;
      default:
        return Icons.question_mark;
    }
  }

  String getWaterLevelStatus(double waterLevel) {
    if (waterLevel >= 1024) return "Critical (9.5 cm)";
    if (waterLevel >= 750) return "Severe (9 cm)";
    if (waterLevel >= 680) return "Very High (8.5 cm)";
    if (waterLevel >= 660) return "High (8 cm)";
    if (waterLevel >= 640) return "Moderate High (7.5 cm)";
    if (waterLevel >= 600) return "Moderate (7 cm)";
    if (waterLevel >= 430) return "Low (6.5 cm)";
    if (waterLevel >= 150) return "Very Low (6 cm)";
    return "Normal (<6 cm)";
  }

  Color getWaterLevelColor(double waterLevel) {
    if (waterLevel >= 1024) return Colors.purple;    // Critical
    if (waterLevel >= 750) return Colors.red;        // Severe
    if (waterLevel >= 680) return Colors.deepOrange; // Very High
    if (waterLevel >= 660) return Colors.orange;     // High
    if (waterLevel >= 640) return Colors.amber;      // Moderate High
    if (waterLevel >= 600) return Colors.yellow;     // Moderate
    if (waterLevel >= 430) return Colors.lightGreen; // Low
    if (waterLevel >= 150) return Colors.green;      // Very Low
    return Colors.blue;                              // Normal
  }

  List<DashboardItem> get items {
    try {
      double windSpeed = double.tryParse(weatherData['windspeed']?.toString() ?? '0') ?? 0;
      double rainAmount = double.tryParse(weatherData['amount_of_rain']?.toString() ?? '0') ?? 0;
      double temperature = double.tryParse(weatherData['temperature']?.toString() ?? '0') ?? 0;
      double humidity = double.tryParse(weatherData['humidity']?.toString() ?? '0') ?? 0;
      double waterLevel = double.tryParse(weatherData['waterlevel']?.toString() ?? '0') ?? 0;

      String windCondition = getWindCondition(windSpeed);
      String floodRisk = getFloodRisk(rainAmount);
      String tempDesc = getTemperatureDescription(temperature);
      String chanceOfRain = getChanceOfRain(humidity);

      return [
        DashboardItem(
          title: "Humidity",
          value: "${humidity.toStringAsFixed(1)}%",
          pairedTitle: "Chance of Rain",
          pairedValue: chanceOfRain,
          icon: Icons.water_drop,
          valueColor: Colors.blue,
          pairedValueColor: getChanceOfRainColor(chanceOfRain),
        ),
        DashboardItem(
          title: "Amount of Rain",
          value: "${rainAmount.toStringAsFixed(1)} mm",
          pairedTitle: "Flood Risk",
          pairedValue: floodRisk,
          icon: Icons.umbrella,
          valueColor: Colors.blue,
          pairedValueColor: getFloodRiskColor(floodRisk),
        ),
        DashboardItem(
          title: "Temperature",
          value: "${temperature.toStringAsFixed(1)}°C",
          pairedTitle: "Description",
          pairedValue: tempDesc,
          icon: Icons.thermostat,
          valueColor: Colors.blue,
          pairedValueColor: getTemperatureColor(tempDesc),
        ),
        DashboardItem(
          title: "Wind Speed",
          value: "${windSpeed.toStringAsFixed(1)} km/h",
          pairedTitle: "Wind Condition",
          pairedValue: windCondition,
          icon: Icons.air,
          valueColor: Colors.blue,
          pairedValueColor: getWindConditionColor(windCondition),
        ),
        DashboardItem(
          title: "Water Level",
          value: "${_convertToHeight(waterLevel)} cm",
          pairedTitle: "Status",
          pairedValue: getWaterLevelStatus(waterLevel),
          icon: Icons.waves,
          valueColor: getWaterLevelColor(waterLevel),
          pairedValueColor: getWaterLevelColor(waterLevel),
        ),
      ];
    } catch (e) {
      print('Error creating items: $e');
      return [];
    }
  }

  Color getWindConditionColor(String condition) {
    switch (condition) {
      case "Calm":
      case "Light Air":
      case "Light Breeze":
        return Colors.green;
      case "Gentle Breeze":
      case "Moderate Breeze":
        return Colors.blue;
      case "Fresh Breeze":
      case "Strong Breeze":
        return Colors.orange;
      case "Signal No. 1":
        return Colors.yellow.shade700;
      case "Signal No. 2":
        return Colors.orange.shade700;
      case "Signal No. 3":
        return Colors.red.shade500;
      case "Signal No. 4":
      case "Super Typhoon":
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color getFloodRiskColor(String risk) {
    switch (risk) {
      case "Very Low":
        return Colors.green;
      case "Low":
        return Colors.lightGreen;
      case "Moderate":
        return Colors.yellow;
      case "High":
        return Colors.orange;
      case "Very High":
        return Colors.red;
      case "Severe":
        return Colors.red[900] ?? Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color getTemperatureColor(String description) {
    switch (description) {
      case "Cold":
        return Colors.blue[900] ?? Colors.blue;
      case "Cool":
        return Colors.blue;
      case "Mild":
        return Colors.green;
      case "Warm":
        return Colors.orange;
      case "Hot":
        return Colors.deepOrange;
      case "Very Hot":
        return Colors.red;
      case "Extremely Hot":
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildHeader(BuildContext context, BoxConstraints constraints, Orientation orientation) {
    double headerHeight = orientation == Orientation.portrait
        ? constraints.maxHeight * 0.25
        : constraints.maxHeight * 0.3;

    return Container(
      width: double.infinity,
      height: headerHeight,
      color: Colors.blue,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Text(
                'CAMPANA Dashboard',
                style: GoogleFonts.openSans(
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: orientation == Orientation.portrait ? 22 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Text(
            'Barangay ${widget.barangayName}',
            style: GoogleFonts.openSans(
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: orientation == Orientation.portrait ? 16 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            DateFormat('MMMM d, y - h:mm a').format(currentTime),
            style: GoogleFonts.openSans(
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: orientation == Orientation.portrait ? 14 : 12,
              ),
            ),
          ),
          Text(
            'Condition: ${getWeatherCondition()}',
            style: GoogleFonts.openSans(
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: orientation == Orientation.portrait ? 14 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, BoxConstraints constraints, Orientation orientation) {
    int crossAxisCount = orientation == Orientation.portrait ? 2 : 4;

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.0,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        return _buildCard(items[index], orientation);
      },
    );
  }

  Widget _buildCard(DashboardItem item, Orientation orientation) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon,
                size: orientation == Orientation.portrait ? 32 : 28,
                color: Colors.blue),
            const SizedBox(height: 4),
            Text(
              item.title,
              style: GoogleFonts.openSans(
                textStyle: TextStyle(
                  fontSize: orientation == Orientation.portrait ? 12 : 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              item.value,
              style: GoogleFonts.openSans(
                textStyle: TextStyle(
                  fontSize: orientation == Orientation.portrait ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  color: item.valueColor,
                ),
              ),
            ),
            const Divider(height: 8),
            Text(
              item.pairedTitle,
              style: GoogleFonts.openSans(
                textStyle: TextStyle(
                  fontSize: orientation == Orientation.portrait ? 10 : 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              item.pairedValue,
              style: GoogleFonts.openSans(
                textStyle: TextStyle(
                  fontSize: orientation == Orientation.portrait ? 14 : 12,
                  fontWeight: FontWeight.w600,
                  color: item.pairedValueColor ?? Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error.isNotEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                error,
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  textStyle: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: fetchWeatherData,
                child: const Text('Retry'),
              ),
            ],
          ),
        )
            : LayoutBuilder(
          builder: (context, constraints) {
            return OrientationBuilder(
              builder: (context, orientation) {
                return Column(
                  children: [
                    _buildHeader(context, constraints, orientation),
                    Expanded(
                      child: _buildGrid(context, constraints, orientation),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class DashboardItem {
  final String title;
  final String value;
  final String pairedTitle;
  final String pairedValue;
  final IconData icon;
  final Color valueColor;
  final Color? pairedValueColor;

  DashboardItem({
    required this.title,
    required this.value,
    required this.pairedTitle,
    required this.pairedValue,
    required this.icon,
    required this.valueColor,
    this.pairedValueColor,
  });
}

String getChanceOfRain(double humidity) {
  if (humidity <= 20) return "0-10%";
  if (humidity <= 40) return "10-30%";
  if (humidity <= 60) return "30-50%";
  if (humidity <= 80) return "50-70%";
  return "70-100%";
}

Color getChanceOfRainColor(String chance) {
  switch (chance) {
    case "0-10%":
      return Colors.green;
    case "10-30%":
      return Colors.lightGreen;
    case "30-50%":
      return Colors.yellow;
    case "50-70%":
      return Colors.orange;
    case "70-100%":
      return Colors.red;
    default:
      return Colors.grey;
  }
}

double _convertToHeight(double sensorValue) {
  if (sensorValue >= 1024) return 9.5;
  if (sensorValue >= 750) return 9.0;
  if (sensorValue >= 680) return 8.5;
  if (sensorValue >= 660) return 8.0;
  if (sensorValue >= 640) return 7.5;
  if (sensorValue >= 600) return 7.0;
  if (sensorValue >= 430) return 6.5;
  if (sensorValue >= 150) return 6.0;
  return 5.5; // Below minimum threshold
}