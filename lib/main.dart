import 'package:flutter/material.dart';

void main() {
  runApp(const HDPosApp());
}

class HDPosApp extends StatelessWidget {
  const HDPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Home Delivery POS',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF8C421F),
      ),
      home: const SettingsPage(),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          // SETTINGS
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          _settingsItem(
            context,
            title: 'Category',
            icon: Icons.category_outlined,
          ),

          _settingsItem(
            context,
            title: 'Subcategory',
            icon: Icons.account_tree_outlined,
          ),

          _settingsItem(
            context,
            title: 'Item',
            icon: Icons.restaurant_menu_outlined,
          ),

          const SizedBox(height: 30),

          // INVENTORY SETTINGS
          const Text(
            'Inventory Settings',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          _settingsItem(
            context,
            title: 'Units',
            icon: Icons.straighten_outlined,
          ),

          _settingsItem(
            context,
            title: 'Category',
            icon: Icons.category_outlined,
          ),

          _settingsItem(
            context,
            title: 'Subcategory',
            icon: Icons.account_tree_outlined,
          ),

          _settingsItem(
            context,
            title: 'Items',
            icon: Icons.inventory_2_outlined,
          ),
        ],
      ),
    );
  }

  Widget _settingsItem(
    BuildContext context, {
    required String title,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
        onTap: () {
          // Page navigation will be added here later.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title page'),
            ),
          );
        },
      ),
    );
  }
}