import 'dart:async';
import 'package:flutter/material.dart';
import 'package:paddy_app/constants/env.dart';
import 'package:paddy_app/constants/styles.dart';
import 'package:paddy_app/models/session_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardWindow extends StatefulWidget {
  const DashboardWindow({super.key});

  @override
  State<DashboardWindow> createState() => _DashboardWindowState();
}

class _DashboardWindowState extends State<DashboardWindow> {
  List<Map<String, dynamic>> collectionData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCollectionData();
  }

  Future<void> _fetchCollectionData() async {
    final apiUrl = '${ENVConfig.serverUrl}/complaints';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          collectionData = List<Map<String, dynamic>>.from(json.decode(response.body));
          isLoading = false;
        });
      } else {
        print('Failed to fetch collection data');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching collection data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to generate a rectangular status card for each achievement
  Widget _buildAchievementCard(Map<String, dynamic> data) {
    return Container(
      width: MediaQuery.of(context).size.width - 20,
      margin: EdgeInsets.symmetric(vertical: 5.0),
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Styles.primaryAccent,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Shadow color
            spreadRadius: 2, // Spread radius
            blurRadius: 4, // Blur radius
            offset: Offset(0, 4), // Shadow offset
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${data['title']} (${data['area']})",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5),
          Text(
            data['instruction'].length > 150
                ? "${data['instruction'].substring(0, 150)}..."
                : data['instruction'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5),
          Text(
            data['createdDate'],
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authEmployeeID = Provider.of<SessionProvider>(context).authEmployeeID;
    return Scaffold(
      backgroundColor: Styles.primaryColor,
      appBar: AppBar(
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
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(height: 1,),
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: ShaderMask(
                        shaderCallback: (rect) {
                          return LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(1),
                            ],
                          ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                        },
                        blendMode: BlendMode.dstIn,
                        child: Container(
                          height: 100, // Adjust height to fit content
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/back.jpg'), // Replace with your image asset
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Welcome to", style: Styles.subTitleFont,),
                            SizedBox(height: 5,),
                            Text("AGRI CARE TECH", style: Styles.titleFont,),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Recent Updates", style: Styles.subTitleFont,),
                    InkWell(
                      child: Text("View All", style: Styles.defaultFont,),
                      onTap: (){

                      },
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                isLoading
                    ? CircularProgressIndicator()
                    : SizedBox(
                  height: collectionData.length * 140.0, // Adjust height based on number of cards
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(), // Prevent scrolling within ListView
                    itemCount: collectionData.length,
                    itemBuilder: (context, index) {
                      return _buildAchievementCard(collectionData[index]);
                    },
                  ),
                ),
                SizedBox(height: 20,),
              ],
            ),
          )
        ],
      ),
    );
  }
}
