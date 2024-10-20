import 'package:flutter/material.dart';
import 'package:formula_composer/features/formula_list/presentation/formula_list_page.dart';
import 'package:formula_composer/features/ingredient_list/presentation/ingredient_list_page.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/theme_provider.dart';

class NavWidgetPage extends StatefulWidget {
  @override
  _NavWidgetPageState createState() => _NavWidgetPageState();
}

class _NavWidgetPageState extends State<NavWidgetPage> {
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
      // appBar: AppBar(),
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
            // ListTile(
            //   leading: const Icon(Icons.settings),
            //   title: const Text('Settings'),
            //   onTap: () {
            //     Navigator.push(
            //               context,
            //               MaterialPageRoute(
            //                 builder: (context) =>
            //                     SettingsPage(),
            //               ),
            //             );
            //   },
            // ),
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

