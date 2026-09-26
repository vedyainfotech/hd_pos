import 'package:flutter/material.dart';

import 'features/settings/screens/home_delivery_settings_screen.dart';

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
        colorSchemeSeed: const Color(0xFF26734D),
      ),
      home: const HomeDeliverySettingsScreen(),
    );
  }
}