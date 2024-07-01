import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:paddy_app/constants/env.dart';
import 'package:paddy_app/constants/styles.dart';
import 'package:paddy_app/models/session_provider.dart';
import 'package:paddy_app/windows/complaints_window.dart';
import 'package:paddy_app/windows/issues_upload_window.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportsWindow extends StatefulWidget {
  final String? nutrition;
  final String? micro;
  final List<dynamic> pesticides;
  final XFile? selectedFile;

  const ReportsWindow({
    Key? key,
    required this.nutrition,
    required this.pesticides,
    required this.selectedFile,
    required this.micro,
  }) : super(key: key);

  @override
  State<ReportsWindow> createState() => _ReportsWindowState();
}

class _ReportsWindowState extends State<ReportsWindow> {
  final TextEditingController _detailsController = TextEditingController();
  String _selectedCategory = 'BUG'; // Default category
  List<Map<String, String>> uniquePesticides = [];
  String _selectedDistrict = 'Colombo'; // Default district
  Map<String, dynamic>? _weatherData;

  final List<String> _districts = [
    'Ampara', 'Anuradhapura', 'Badulla', 'Batticaloa', 'Colombo', 'Galle',
    'Gampaha', 'Hambantota', 'Jaffna', 'Kalutara', 'Kandy', 'Kegalle',
    'Kilinochchi', 'Kurunegala', 'Mannar', 'Matale', 'Matara', 'Monaragala',
    'Mullaitivu', 'Nuwara Eliya', 'Polonnaruwa', 'Puttalam', 'Ratnapura',
    'Trincomalee', 'Vavuniya'
  ];

  @override
  void initState() {
    super.initState();
    _countUniquePesticides();
    _fetchWeatherData(); // Initial fetch for the default district
  }

  void _countUniquePesticides() {
    Set<String> uniqueSet = Set.from(widget.pesticides);
    uniqueSet.forEach((pest) {
      var pestDetails = ENVConfig.pesticidesList.firstWhere((element) => element['name'] == pest, orElse: () => null);
      if (pestDetails != null) {
        uniquePesticides.add({"name": pestDetails['title'], "image": pestDetails['image']});
      }
    });
  }

  Future<void> _fetchWeatherData() async {
    const apiKey = '3ca1b71cf73d793ea485f6d257cedd49'; // Replace with your API key
    final apiUrl = 'https://api.openweathermap.org/data/2.5/weather?q=${Uri.encodeComponent(_selectedDistrict)}&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          _weatherData = json.decode(response.body);
        });
        print('Weather Data: $_weatherData');
      } else {
        print('Failed to fetch weather data');
      }
    } catch (e) {
      print('Error fetching weather data: $e');
    }
  }

  Widget _buildAchievementCard(int index, String name, String imageUrl) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Styles.secondaryColor,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), // Shadow color
                spreadRadius: 2, // Spread radius
                blurRadius: 4, // Blur radius
                offset: Offset(0, 4), // Shadow offset
              ),
            ],
            image: DecorationImage(
              image: AssetImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 35,
                color: Styles.bgColor,
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            color: Styles.fontColorWhite,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.primaryColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detection Summary',
              style: TextStyle(color: Colors.white), // Make screen name white
            ),
            Text(
              'Details and discoveries made for uploaded image', // Add your subtitle text here
              style: TextStyle(color: Colors.white, fontSize: 12), // Adjust font size and color as needed
            ),
          ],
        ),
        backgroundColor: Colors.transparent, // Make background transparent
        iconTheme: IconThemeData(color: Colors.white), // Make icons white
        actions: [
          IconButton(
            icon: Icon(Icons.logout), // Logout icon
            onPressed: () async {
              // Clear session
              Provider.of<SessionProvider>(context, listen: false).clearSession();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('accessToken');
              await prefs.remove('refreshToken');
              await prefs.remove('accessTokenExpireDate');
              await prefs.remove('refreshTokenExpireDate');
              await prefs.remove('userRole');
              await prefs.remove('authEmployeeID');
              Navigator.pushReplacementNamed(context, '/landing');
            },
          ),
        ],
      ),
      body: SingleChildScrollView( // Wrap with SingleChildScrollView
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Form section
            Card(
              margin: EdgeInsets.all(16.0),
              color: Styles.primaryAccent,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 2.0),
                    Text("Summary", style: Styles.titleFont,),
                    Text("Fertilizer Condition: Needs ${widget.nutrition} fertilization", style: Styles.subTitleFont,),
                    SizedBox(height: 5.0),
                    Text("Micro Disease Condition: ${widget.micro}", style: Styles.subTitleFont,),
                    SizedBox(height: 15.0),
                    Text("Pest Condition:", style: Styles.subTitleFont,),
                    SizedBox(height: 5.0),
                    if(widget.pesticides.length>0) SizedBox(
                      height: 130,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: uniquePesticides.asMap().entries.map((entry) {
                          int index = entry.key;
                          String name = entry.value['name']!;
                          String imageUrl = entry.value['image']!;
                          return Padding(
                            padding: const EdgeInsets.only(right: 30),
                            child: _buildAchievementCard(index, name, imageUrl),
                          );
                        }).toList(),
                      ),
                    ),
                    if(widget.pesticides.length==0) Text("No Pesticide detected", style: Styles.subTitleFont,),
                    SizedBox(height: 15.0),
                    Text("Weather Details:", style: Styles.subTitleFont,),
                    SizedBox(height: 10.0),
                    DropdownButtonFormField<String>(
                      value: _selectedDistrict,
                      onChanged: (value) {
                        setState(() {
                          _selectedDistrict = value!;
                          _fetchWeatherData(); // Fetch weather data for the selected district
                        });
                      },
                      items: _districts.map((district) {
                        return DropdownMenuItem<String>(
                          value: district,
                          child: Text(
                            district,
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Select District',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      dropdownColor: Styles.primaryColor,
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 5.0),
                    if (_weatherData != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Image.network(
                              'https://openweathermap.org/img/wn/${_weatherData!["weather"][0]["icon"]}@2x.png',
                            ),
                          ),
                          SizedBox(height: 5.0),
                          Text(
                            'Temperature: ${(_weatherData!["main"]["temp"] - 273.15).toStringAsFixed(2)}°C',
                            style: Styles.subTitleFont,
                          ),
                          Text(
                            'Humidity: ${_weatherData!["main"]["humidity"]}%',
                            style: Styles.subTitleFont,
                          ),
                          Text(
                            'Wind Speed: ${_weatherData!["wind"]["speed"]} m/s',
                            style: Styles.subTitleFont,
                          ),
                          Text(
                            'Weather: ${_weatherData!["weather"][0]["description"]}',
                            style: Styles.subTitleFont,
                          ),
                          if (widget.pesticides.isNotEmpty &&
                              _weatherData!["main"]["humidity"] > 60 &&
                              _weatherData!["wind"]["speed"] > 3)
                            Card(
                              color: Colors.red,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Warning: Pesticides have a higher probability of spreading due to high humidity and wind speed.',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      ),
                    SizedBox(height: 5.0),
                    ElevatedButton(
                      onPressed: () {
                        // Create the summary for pesticides
                        String pesticideSummary = uniquePesticides.map((pest) => pest["name"]).join(", ");
                        // Create the weather warning message if needed
                        String weatherWarning = '';
                        if (widget.pesticides.isNotEmpty &&
                            _weatherData!["main"]["humidity"] > 60 &&
                            _weatherData!["wind"]["speed"] > 3) {
                          weatherWarning = ' Warning: Pesticides have a higher probability of spreading due to high humidity and wind speed.';
                        }
                        // Combine all parts to form the instruction
                        String instruction = "Pesticides: $pesticideSummary. Nutrition: ${widget.nutrition}. Micro Disease Condition: ${widget.micro}." + weatherWarning;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ComplaintsWindow(
                              title: "Case ${widget.nutrition} + ${widget.micro}",
                              instruction: instruction,
                              selectedFile: widget.selectedFile,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Styles.warningColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Report Issues'),
                    ),
                    SizedBox(height: 5.0),
                    SizedBox(
                      width: 250,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => IssuesUploadWindow(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Styles.warningColor,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Try Again'),
                      ),
                    ),
                    SizedBox(height: 5.0),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/home");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Styles.secondaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('To Home'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }
}
