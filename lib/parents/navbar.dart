import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'home.dart';
import 'QRscanner.dart';
import 'profile.dart';

class NavBar_screen extends StatefulWidget {
  final int initialPage;

  const NavBar_screen({this.initialPage = 0});

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar_screen> {
  late int _pageIndex;

  @override
  void initState() {
    super.initState();
    _pageIndex = widget.initialPage;
    _selectedIndex = widget.initialPage;
  }

  final List<Widget> _pages = [
    homeScreen(),
    QRScanPage(),
    ProfileScreen(),
  ];

  late int _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_pageIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1.5,
              blurRadius: 5,
              offset: Offset(3, 0),
            ),
          ],
        ),
        child: CurvedNavigationBar(
          color: Colors.white,
          backgroundColor: Colors.grey.shade200,
          buttonBackgroundColor: Color(0xFFFFBBE0),
          height: 50,
          items: <Widget>[
            Icon(
              Icons.home,
              size: 30,
              color: _selectedIndex == 0 ? Colors.white : Color(0xFF877777),
            ),
            Icon(
              Icons.qr_code_scanner,
              size: 30,
              color: _selectedIndex == 1 ? Colors.white : Color(0xFF877777),
            ),
            Icon(
              Icons.person,
              size: 30,
              color: _selectedIndex == 2 ? Colors.white : Color(0xFF877777),
            ),
          ],
          animationDuration: Duration(milliseconds: 200),
          index: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
              _pageIndex = index;
            });
          },
        ),
      ),
    );
  }
}