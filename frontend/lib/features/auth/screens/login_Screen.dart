import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../settings/screens/home_delivery_settings_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // UI-only login for now.
    // Backend authentication will be connected later.
    await Future.delayed(
      const Duration(milliseconds: 700),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
      builder: (_) => HomeDeliverySettingsScreen(
  userName: _usernameController.text.trim(),
),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            final bool isMobile = width < 600;
            final bool isTablet = width >= 600 && width < 1000;

            final double cardWidth = isMobile
                ? width - 32
                : isTablet
                    ? 440
                    : 460;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: cardWidth,
                    minHeight: height > 700 ? 0 : height - 48,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildBranding(
                        isMobile: isMobile,
                      ),

                      SizedBox(
                        height: isMobile ? 24 : 30,
                      ),

                      _buildLoginCard(
                        isMobile: isMobile,
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // BRANDING
  // ============================================================

  Widget _buildBranding({
    required bool isMobile,
  }) {
    return Column(
      children: [
        Container(
          width: isMobile ? 64 : 72,
          height: isMobile ? 64 : 72,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(
              isMobile ? 18 : 20,
            ),
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.delivery_dining_outlined,
            color: AppColors.primary,
            size: isMobile ? 32 : 36,
          ),
        ),

        const SizedBox(height: 14),

        Text(
          'Home Delivery',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: isMobile ? 24 : 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          'Management System',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: isMobile ? 12 : 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LOGIN CARD
  // ============================================================

  Widget _buildLoginCard({
    required bool isMobile,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        isMobile ? 20 : 28,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.88,
        ),
        borderRadius: BorderRadius.circular(
          isMobile ? 20 : 24,
        ),
        border: Border.all(
          color: Colors.white,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(
              alpha: 0.08,
            ),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======================================================
            // TITLE
            // ======================================================

            Text(
              'Welcome back',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: isMobile ? 22 : 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 6),

            SizedBox(
              height: isMobile ? 24 : 28,
            ),

            // ======================================================
            // USERNAME
            // ======================================================

            const Text(
              'Username',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              height: 68,
              child: TextFormField(
                controller: _usernameController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  hintText: 'Enter your username',
                  prefixIcon: Icon(
                    Icons.person_outline,
                  ),
                  errorStyle: TextStyle(
                    fontSize: 11,
                    height: 1.1,
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter your username';
                  }

                  return null;
                },
              ),
            ),

            const SizedBox(height: 18),

            // ======================================================
            // PASSWORD
            // ======================================================

            const Text(
              'Password',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              height: 68,
              child: TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _login(),
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                  ),
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword
                        ? 'Show password'
                        : 'Hide password',
                    onPressed: () {
                      setState(() {
                        _obscurePassword =
                            !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                  errorStyle: const TextStyle(
                    fontSize: 11,
                    height: 1.1,
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return 'Please enter your password';
                  }

                  return null;
                },
              ),
            ),

            const SizedBox(height: 24),

            // ======================================================
            // SIGN IN BUTTON
            // ======================================================

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : _login,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Text('Sign In'),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}