import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/settings_data/presentation/settings_data_page.dart';
import '../providers/theme_provider.dart';
import 'package:formula_composer/features/formula_list/presentation/formula_list_page.dart';
import 'package:formula_composer/features/ingredient_list/presentation/ingredient_list_page.dart';

class MainNavBar extends StatefulWidget {
  @override
  _MainNavBarState createState() => _MainNavBarState();
}

class _MainNavBarState extends State<MainNavBar> {
  int _currentIndex = 0;

  // Method to handle index changes when a new tab is selected
  void onTabTapped(int index) {
    if (_currentIndex == index) {
      // If tapping the same tab, navigate to root
      switch (index) {
        case 0:
        case 1:
          Navigator.of(context).popUntil((route) => route.isFirst);
          break;
      }
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Access the theme provider

    return Scaffold(
      drawer: Drawer(
        // Add a navigation drawer
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/momo.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Text(
                'Navigation Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.light_mode_outlined),
              title: const Text('Light Mode/Dark Mode'),
              onTap: () {
                themeProvider.toggleTheme();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsDataPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          Navigator(
            key: GlobalKey<NavigatorState>(),
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => FormulaListPage(),
              );
            },
          ),
          Navigator(
            key: GlobalKey<NavigatorState>(),
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => IngredientListPage(),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Formulas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.colorize),
            label: 'Ingredients',
          ),
        ],
      ),
    );
  }
}
