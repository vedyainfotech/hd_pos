import 'package:flutter/material.dart';

import 'core/theme/theme.dart';
import 'features/auth/screens/login_Screen.dart';

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
      theme: AppTheme.lightTheme,
     home: const LoginScreen(),
    );
  }
}