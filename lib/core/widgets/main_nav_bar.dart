import 'package:flutter/material.dart';
import 'package:formula_composer/features/formula_list/presentation/formula_list_page.dart';
import 'package:formula_composer/features/ingredient_list/presentation/ingredient_list_page.dart';
import 'package:formula_composer/features/settings_categories_color/presentation/settings_category_page.dart';
import 'package:provider/provider.dart';
import '../../features/settings_data/presentation/settings_data_page.dart';
import '../providers/theme_provider.dart';

class MainNavBar extends StatefulWidget {
  @override
  _MainNavBarState createState() => _MainNavBarState();
}

class _MainNavBarState extends State<MainNavBar> {
  int _currentIndex = 0;

  // List of pages (widgets) to display in the body
  final List<Widget> _pages = [
    // HomePage(),
    FormulaListPage(),
    IngredientListPage(),
  ];
  
  get themeProvider => null;

  // Method to handle index changes when a new tab is selected
  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Access the theme provider

    return Scaffold(
  //     appBar: AppBar(
  //       leading: Builder(
  //     builder: (context) {
  //       return IconButton(
  //         icon: const Icon(Icons.menu),
  //         onPressed: () {
  //           Scaffold.of(context).openDrawer();
  //         },
  //       );
  //     },
  //   ),
  // // ),
  //     ),
      drawer: Drawer( // Add a navigation drawer
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/momo.jpg'), // Path to your image
                  fit: BoxFit.cover, // Adjust how the image fits in the box
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
                            builder: (context) =>
                                SettingsDataPage(),
                          ),
                        );
              },
            ),

            ListTile(
              leading: const Icon(Icons.format_color_fill_rounded),
              title: const Text('Category manager'),
              onTap: () {
                Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SettingsCategoryPage(),
                          ),
                        );
              },
            ),
          ],
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // This will highlight the selected icon
        onTap: onTabTapped, // Update the content when a tab is selected
        items: [
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.home),
          //   label: 'Home',
          // ),
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

