import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../home/category/screens/category_screen.dart';
import '../../home/sub_categories/screens/sub_category_screens.dart';
import '../../home/items/screens/items_screens.dart';
import '../../home/delivery_persons/screens/delivery_person_screens.dart';

class HomeDeliverySettingsScreen extends StatelessWidget {
  const HomeDeliverySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Row(
          children: [
            _buildSidebar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 24),
                    _buildPageHeader(),
                    const SizedBox(height: 24),

                    // --------------------------------------------------
                    // BUSINESS SETUP
                    // --------------------------------------------------
                    _buildSection(
                      icon: Icons.business_outlined,
                      title: 'Business Setup',
                      subtitle:
                          'Manage your business information and basic configuration',
                      children: [
                        _settingCard(
                          context,
                          title: 'Business Profile',
                          subtitle:
                              'Edit your business name, address and contact details',
                          icon: Icons.storefront_outlined,
                          iconBackground: const Color(0xFFEDE9FE),
                          iconColor: const Color(0xFF7C3AED),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // --------------------------------------------------
                    // MENU & PRODUCTS
                    // --------------------------------------------------
                    _buildSection(
                      icon: Icons.restaurant_menu_outlined,
                      title: 'Menu & Products',
                      subtitle:
                          'Manage your categories, items, pricing and menu schedule',
                      children: [
                        // ------------------------------------------------
                        // CATEGORIES
                        // ------------------------------------------------

                        _settingCard(
                          context,
                          title: 'Categories',
                          subtitle: 'Add and manage product categories',
                          icon: Icons.grid_view_rounded,
                          iconBackground: const Color(0xFFFFE8E5),
                          iconColor: const Color(0xFFEF4444),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CategoryScreen(),
                              ),
                            );
                          },
                        ),

                        // ------------------------------------------------
                        // SUB CATEGORIES
                        // ------------------------------------------------
                        _settingCard(
                          context,
                          title: 'Sub Categories',
                          subtitle: 'Add and manage sub categories',
                          icon: Icons.layers_outlined,
                          iconBackground: const Color(0xFFE6F0FF),
                          iconColor: const Color(0xFF3B82F6),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SubCategoriesScreen(),
                              ),
                            );
                          },
                        ),

                        // ------------------------------------------------
                        // ITEMS
                        // ------------------------------------------------
                        _settingCard(
                          context,
                          title: 'Items',
                          subtitle: 'Add and manage your products',
                          icon: Icons.fastfood_outlined,
                          iconBackground: const Color(0xFFFFF0DA),
                          iconColor: const Color(0xFFD97706),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ItemsScreen(),
                              ),
                            );
                          },
                        ),

                        // ------------------------------------------------
                        // PRICES
                        // ------------------------------------------------
                        _settingCard(
                          context,
                          title: 'Prices',
                          subtitle: 'Set and manage item prices',
                          icon: Icons.sell_outlined,
                          iconBackground: const Color(0xFFF0E9FF),
                          iconColor: const Color(0xFF7C3AED),
                        ),

                        // ------------------------------------------------
                        // MENU SCHEDULING
                        // ------------------------------------------------
                        _settingCard(
                          context,
                          title: 'Menu Scheduling',
                          subtitle:
                              'Manage daily menu availability and schedules',
                          icon: Icons.calendar_month_outlined,
                          iconBackground: const Color(0xFFE3F8F1),
                          iconColor: const Color(0xFF059669),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // --------------------------------------------------
                    // CUSTOMERS
                    // --------------------------------------------------
                    _buildSection(
                      icon: Icons.people_outline,
                      title: 'Customers',
                      subtitle:
                          'Manage customers and their delivery information',
                      children: [
                        _settingCard(
                          context,
                          title: 'Customers',
                          subtitle: 'Add and manage customer information',
                          icon: Icons.people_outline,
                          iconBackground: const Color(0xFFE6F0FF),
                          iconColor: const Color(0xFF2563EB),
                        ),
                        _settingCard(
                          context,
                          title: 'Customer Delivery Details',
                          subtitle:
                              'Manage addresses, timings and special instructions',
                          icon: Icons.location_on_outlined,
                          iconBackground: const Color(0xFFFFE8EE),
                          iconColor: const Color(0xFFE11D48),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // --------------------------------------------------
                    // DELIVERY MANAGEMENT
                    // --------------------------------------------------
                    _buildSection(
                      icon: Icons.local_shipping_outlined,
                      title: 'Delivery Management',
                      subtitle:
                          'Manage delivery persons and daily delivery schedules',
                      children: [
                        _settingCard(
                          context,
                          title: 'Delivery Persons',
                          subtitle: 'Add and manage delivery staff',
                          icon: Icons.delivery_dining_outlined,
                          iconBackground: const Color(0xFFE5F0FF),
                          iconColor: const Color(0xFF2563EB),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DeliveryPersonsScreen(),
                              ),
                            );
                          },
                        ),
                        _settingCard(
                          context,
                          title: 'Delivery Schedule',
                          subtitle:
                              'Create and manage daily delivery schedules',
                          icon: Icons.calendar_today_outlined,
                          iconBackground: const Color(0xFFF0E9FF),
                          iconColor: const Color(0xFF7C3AED),
                        ),
                        _settingCard(
                          context,
                          title: 'Assign Deliveries',
                          subtitle: 'Assign customers and deliveries to staff',
                          icon: Icons.route_outlined,
                          iconBackground: const Color(0xFFE2F8EF),
                          iconColor: const Color(0xFF059669),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // --------------------------------------------------
                    // INVENTORY
                    // --------------------------------------------------
                    _buildSection(
                      icon: Icons.inventory_2_outlined,
                      title: 'Inventory',
                      subtitle:
                          'Manage stock items, units, inventory categories and suppliers',
                      children: [
                        _settingCard(
                          context,
                          title: 'Units',
                          subtitle:
                              'Manage measurement units such as kg, litre and piece',
                          icon: Icons.straighten_outlined,
                          iconBackground: const Color(0xFFE6F0FF),
                          iconColor: const Color(0xFF2563EB),
                        ),
                        _settingCard(
                          context,
                          title: 'Inventory Categories',
                          subtitle: 'Create and manage inventory categories',
                          icon: Icons.category_outlined,
                          iconBackground: const Color(0xFFFFE8E5),
                          iconColor: const Color(0xFFEF4444),
                        ),
                        _settingCard(
                          context,
                          title: 'Inventory Sub Categories',
                          subtitle:
                              'Organize inventory items into sub categories',
                          icon: Icons.account_tree_outlined,
                          iconBackground: const Color(0xFFF0E9FF),
                          iconColor: const Color(0xFF7C3AED),
                        ),
                        _settingCard(
                          context,
                          title: 'Inventory Items',
                          subtitle:
                              'Add and manage raw materials and stock items',
                          icon: Icons.inventory_outlined,
                          iconBackground: const Color(0xFFFFF0DA),
                          iconColor: const Color(0xFFD97706),
                        ),
                        _settingCard(
                          context,
                          title: 'Suppliers',
                          subtitle:
                              'Manage suppliers for your inventory purchases',
                          icon: Icons.local_shipping_outlined,
                          iconBackground: const Color(0xFFE3F8F1),
                          iconColor: const Color(0xFF059669),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // --------------------------------------------------
                    // USERS & SYSTEM
                    // --------------------------------------------------
                    _buildSection(
                      icon: Icons.manage_accounts_outlined,
                      title: 'Users & System',
                      subtitle:
                          'Manage operators, printers and application settings',
                      children: [
                        _settingCard(
                          context,
                          title: 'Operators / Users',
                          subtitle: 'Add and manage system users and operators',
                          icon: Icons.group_outlined,
                          iconBackground: const Color(0xFFFFF0DA),
                          iconColor: const Color(0xFFD97706),
                        ),
                        _settingCard(
                          context,
                          title: 'Printer Settings',
                          subtitle: 'Configure printers for orders and bills',
                          icon: Icons.print_outlined,
                          iconBackground: const Color(0xFFE6F0FF),
                          iconColor: const Color(0xFF2563EB),
                        ),
                        _settingCard(
                          context,
                          title: 'System Settings',
                          subtitle: 'Manage general application settings',
                          icon: Icons.settings_outlined,
                          iconBackground: const Color(0xFFFFE8EE),
                          iconColor: const Color(0xFFE11D48),
                        ),
                      ],
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

  // ============================================================
  // SIDEBAR
  // ============================================================

  Widget _buildSidebar() {
    return Container(
      width: 225,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.07),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),

          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.delivery_dining_outlined,
              color: AppColors.primary,
              size: 28,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Home Delivery',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),

          const Text(
            'Management System',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),

          const SizedBox(height: 32),

          _sidebarItem(icon: Icons.dashboard_outlined, title: 'Dashboard'),

          _sidebarItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            selected: true,
          ),

          _sidebarItem(icon: Icons.grid_view_outlined, title: 'Management'),

          const Spacer(),

          Container(
            margin: const EdgeInsets.all(14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.help_outline, color: AppColors.primary, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Manage your business, customers and deliveries all in one place.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem({
    required IconData icon,
    required String title,
    bool selected = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? AppColors.primarySoft : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontSize: 14,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (selected) ...[
              const Spacer(),
              const Icon(
                Icons.chevron_right,
                color: AppColors.primary,
                size: 19,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar() {
    return Row(
      children: [
        const Spacer(),

        Container(
          width: 220,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: Colors.white),
          ),
          child: const Row(
            children: [
              SizedBox(width: 13),
              Icon(Icons.search, color: AppColors.textSecondary, size: 19),
              SizedBox(width: 9),
              Text(
                'Search...',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),

        const SizedBox(width: 14),

        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: Colors.white),
          ),
          child: const Icon(
            Icons.notifications_none_outlined,
            color: AppColors.textPrimary,
            size: 21,
          ),
        ),

        const SizedBox(width: 12),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white),
          ),
          child: const Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: AppColors.primary,
                child: Text(
                  'B',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Owner',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 3),
              Icon(
                Icons.keyboard_arrow_down,
                size: 17,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PAGE HEADER
  // ============================================================

  Widget _buildPageHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEFF4FF), Color(0xFFF8F6FF)],
        ),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.settings_outlined,
              color: AppColors.primary,
              size: 29,
            ),
          ),

          const SizedBox(width: 16),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Configure your business, products, customers, deliveries and inventory',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION
  // ============================================================

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.95)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.045),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),

              const SizedBox(width: 11),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          LayoutBuilder(
            builder: (context, constraints) {
              int columns;

              if (constraints.maxWidth >= 1000) {
                columns = 3;
              } else if (constraints.maxWidth >= 650) {
                columns = 2;
              } else {
                columns = 1;
              }

              final width =
                  (constraints.maxWidth - ((columns - 1) * 14)) / columns;

              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: children.map((child) {
                  return SizedBox(width: width, child: child);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SETTING CARD
  // ============================================================

  Widget _settingCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap:
            onTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$title will be implemented here.'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
        child: Container(
          constraints: const BoxConstraints(minHeight: 88),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: AppColors.white),
            boxShadow: [
              BoxShadow(
                color: AppColors.textSecondary.withValues(alpha: 0.045),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F7FC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
