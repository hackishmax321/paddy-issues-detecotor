import 'package:flutter/material.dart';
import 'package:paddy_app/constants/styles.dart';
import 'package:paddy_app/models/session_provider.dart';
import 'package:paddy_app/widgerts/social_link_button.dart';
import 'package:paddy_app/windows/issues_upload_window.dart';
import 'package:provider/provider.dart';

class LandingWindow extends StatefulWidget {
  @override
  _LandingWindowState createState() => _LandingWindowState();
}

class _LandingWindowState extends State<LandingWindow> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.primaryColor,
      body: Center(
        child: Consumer<SessionProvider>(
          builder: (context, sessionProvider, _) {
            // Check if session is available
            final bool sessionAvailable = sessionProvider.authEmployeeID != null;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Padding(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: Container(
                    width: 200, // Adjust the width as needed
                    height: 200, // Adjust the height as needed
                    // decoration: BoxDecoration(
                    //   shape: BoxShape.circle,
                    //   color: Color(0xFF84D19B),
                    //   border: Border.all(
                    //     color: Colors.black, // Change the border color as needed
                    //     width: 2.0, // Adjust the border width as needed
                    //   ),
                    // ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 5,),
                Text("AGRI CARE TECH", style: TextStyle(fontSize: 32, color: Styles.fontColorWhite, fontWeight: FontWeight.bold)),
                SizedBox(height: 5,),
                // SizedBox(
                //   width: 250,
                //   child: ElevatedButton(
                //     onPressed: () {
                //       Navigator.pushNamed(context, '/home');
                //     },
                //     child: Text('Visit Home'),
                //   ),
                // ),
                SizedBox(height: 10.0),

                SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/home');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Styles.warningColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Visit Home'),
                  ),
                ),

                SizedBox(height: 20.0),

                // Social Links
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocialLinkButton(icon: Icons.facebook),
                    SizedBox(width: 10.0),
                    SocialLinkButton(icon: Icons.rocket),
                    SizedBox(width: 10.0),
                    SocialLinkButton(icon: Icons.android),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
