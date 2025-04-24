import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'saved_recipes_screen.dart';
import 'grocery_list_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Map<String, dynamic>> savedRecipes = [];

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _buildScreens(); // Use helper to avoid duplication
  }

  void _buildScreens() {
    _screens = [
      HomeScreen(savedRecipes: savedRecipes),
      SavedRecipesScreen(
        savedRecipes: savedRecipes,
        onBack: () {
          setState(() {
            _currentIndex = 0;
          });
        },
      ),
      GroceryListScreen(),
      ProfileScreen(),
      SettingsScreen(),
    ];
  }

  void _updateScreens() {
    setState(() {
      if (savedRecipes.isEmpty && _currentIndex == 1) {
        _currentIndex = 0;
      }
      _buildScreens();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Saved"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Grocery"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}







// import 'package:flutter/material.dart';
// // ignore: unused_import
// import 'package:get/get.dart';
// import 'home_screen.dart';
// import 'saved_recipes_screen.dart';
// import 'grocery_list_screen.dart';
// import 'profile_screen.dart';
// import 'settings_screen.dart';

// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});

//   @override
//   _MainScreenState createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   int _currentIndex = 0;

//   final List<Widget> _screens = [
//     HomeScreen(),
//     SavedRecipesScreen(),
//     GroceryListScreen(),
//     ProfileScreen(),
//     SettingsScreen(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_currentIndex], // Switches between screens
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//         selectedItemColor: Colors.orange, // Highlighted color
//         unselectedItemColor: Colors.grey,
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//           BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Saved"),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.shopping_cart),
//             label: "Grocery",
//           ),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.settings),
//             label: "Settings",
//           ),
//         ],
//       ),
//     );
//   }
// }
