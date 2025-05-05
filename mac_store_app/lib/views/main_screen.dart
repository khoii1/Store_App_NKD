import 'package:flutter/material.dart';
import 'package:mac_store_app/views/screens/nav_screen/account_screen.dart';
import 'package:mac_store_app/views/screens/nav_screen/cart_screen.dart';
import 'package:mac_store_app/views/screens/nav_screen/category_screen.dart';
import 'package:mac_store_app/views/screens/nav_screen/favorite_screen.dart';
import 'package:mac_store_app/views/screens/nav_screen/home_screen.dart';
import 'package:mac_store_app/views/screens/nav_screen/store_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _pageIndex = 0;
  final List<Widget> _pages = [
    const HomeScreen(),
    const FavoriteScreen(),
    const CategoryScreen(),
    const StoreScreen(),
    const CartScreen(),
     AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        currentIndex: _pageIndex,
        onTap: (value) {
          setState(() {
            _pageIndex = value;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset("assets/icons/home.png", width: 25),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/icons/love.png", width: 25),
            label: "Favorite",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: "Categories",
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/icons/mart.png", width: 25),
            label: "Stores",
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/icons/cart.png", width: 25),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/icons/user.png", width: 25),
            label: "Account",
          ),
        ],
      ),
      body: _pages[_pageIndex],
    );
  }
}
