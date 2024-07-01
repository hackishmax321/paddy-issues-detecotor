import 'package:flutter/material.dart';
import 'package:paddy_app/constants/styles.dart';

class BottomBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomBar({Key? key, required this.selectedIndex, required this.onItemTapped}) : super(key: key);

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.selectedIndex,
      onTap: widget.onItemTapped,
      selectedItemColor: Styles.warningColor,
      unselectedItemColor: Styles.primaryColor,
      type: BottomNavigationBarType.shifting,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
          backgroundColor: Styles.primaryAccent,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Routes',
          backgroundColor: Styles.primaryAccent,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Profile',
          backgroundColor: Styles.primaryAccent,
        ),
      ],
    );
  }
}
