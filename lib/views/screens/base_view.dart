import 'package:alpha_go/views/screens/home_screen.dart';
import 'package:alpha_go/views/screens/profile_screen.dart';
import 'package:alpha_go/views/screens/rooms.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 2;
  static final List<Widget> _widgetOptions = <Widget>[
    const RoomsPage(),
    const ProfilePage(),
    const MapHomePage(),
  ];
  static final List<IconData> iconList = <IconData>[
    Icons.chat,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                'assets/bg.jpg',
              ),
              fit: BoxFit.cover)),
      child: Scaffold(
        extendBody: _selectedIndex == 2 ? true : false,
        backgroundColor: Colors.transparent,
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          shape: const CircleBorder(side: BorderSide(color: Color(0xffb4914b))),
          child: Center(
            child: Icon(
              _selectedIndex == 2 ? Icons.camera : Icons.home,
              size: 28.sp,
              color: const Color(0xffb4914b),
            ),
          ),
          onPressed: () {
            setState(() {
              _selectedIndex = 2;
            });
          },
          //params
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: AnimatedBottomNavigationBar.builder(
          borderColor: const Color(0xffb4914b),
          backgroundColor: Colors.black,
          itemCount: _widgetOptions.length - 1,
          tabBuilder: (int index, bool isActive) {
            return Icon(
              iconList[index],
              size: 26.sp,
              color: const Color(0xffb4914b),
            );
          },
          activeIndex: _selectedIndex,
          gapLocation: GapLocation.center,
          notchSmoothness: NotchSmoothness.verySmoothEdge,
          leftCornerRadius: 21.sp,
          rightCornerRadius: 21.sp,
          onTap: (index) => setState(() => _selectedIndex = index),
        ),
      ),
    );
  }
}
