import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:paddy_app/constants/styles.dart';
import 'package:paddy_app/models/session_provider.dart';

class ProfileWindow extends StatelessWidget {
  const ProfileWindow({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
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
  }

  @override
  Widget build(BuildContext context) {
    final user = "Free User Account";

    return Scaffold(
      backgroundColor: Styles.primaryColor,
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/profile.png'), // Use a placeholder image
                  ),
                  SizedBox(height: 20),
                  Text(
                    user ?? "Username", // Display user's name
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    user ?? "user@example.com", // Display user's email
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            Spacer(),
            // ElevatedButton(
            //   onPressed: () {
            //     // Navigate to edit profile page
            //     Navigator.pushNamed(context, '/editProfile');
            //   },
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Styles.warningColor,
            //     foregroundColor: Colors.white,
            //     minimumSize: Size(double.infinity, 50),
            //   ),
            //   child: Text('Edit Profile'),
            // ),
            // SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetailRow(IconData icon, String title, String detail) {
    return Row(
      children: [
        Icon(icon, color: Colors.white),
        SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 5),
            Text(
              detail,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
