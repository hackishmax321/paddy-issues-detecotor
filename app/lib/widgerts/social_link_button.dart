import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:paddy_app/constants/styles.dart';

class SocialLinkButton extends StatelessWidget {
  final IconData icon;

  const SocialLinkButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Styles.warningColor.withOpacity(0.8), // Adjust opacity for glass effect
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Adjust blur intensity as needed
          child: IconButton(
            icon: Icon(icon),
            color: Colors.white, // Change icon color to white for visibility
            onPressed: () {
              // Handle social link button press
            },
          ),
        ),
      ),
    );
  }
}
