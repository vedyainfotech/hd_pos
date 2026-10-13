
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  final List<String> _roles = [
    'Admin',
    'Manager',
    'Staff',
    'Delivery Person',
  ];

  final List<String> _screens = [
    'Dashboard',
    'Customers',
    'Customer Delivery Details',
    'Delivery Schedule',
    'Delivery Persons',
    'Assign Deliveries',
    'Categories',
    'Sub Categories',
    'Items',
    'Prices',
    'Payment',
    'Menu Scheduling',
    'Units',
    'Inventory Categories',
    'Inventory Sub Categories',
    'Inventory Items',
    'Suppliers',
    'Reports',
    'Operators / Users',
    'Roles',
    'Permissions',
    'KOT Settings',
    'Printer Settings',
    'System Settings',
  ];

  String _selectedRole = 'Admin';

  late Map<String, Map<String, bool>> _permissions;
  late Map<String, Map<String, bool>> _savedPermissions;

  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();

    _permissions = {
      for (final role in _roles)
        role: {
          for (final screen in _screens)
            screen: role == 'Admin' ||
                (role == 'Manager' &&
                    [
                      'Dashboard',
                      'Customers',
                      'Customer Delivery Details',
                      'Delivery Schedule',
                      'Delivery Persons',
                      'Assign Deliveries',
                      'Categories',
                      'Sub Categories',
                      'Items',
                      'Prices',
                      'Payment',
                      'Menu Scheduling',
                      'Units',
                      'Inventory Categories',
                      'Inventory Sub Categories',
                      'Inventory Items',
                      'Suppliers',
                      'Reports',
                    ].contains(screen)) ||
                (role == 'Staff' &&
                    [
                      'Dashboard',
                      'Customers',
                      'Customer Delivery Details',
                      'Delivery Schedule',
                    ].contains(screen)) ||
                (role == 'Delivery Person' &&
                    [
                      'Dashboard',
                      'Delivery Schedule',
                      'Customer Delivery Details',
                    ].contains(screen)),
        },
    };

    _savedPermissions = _copyPermissions(_permissions);
  }

  Map<String, Map<String, bool>> _copyPermissions(
    Map<String, Map<String, bool>> source,
  ) {
    return {
      for (final entry in source.entries)
        entry.key: Map<String, bool>.from(entry.value),
    };
  }


  
Future<bool> _showConfirmationDialog({
  required String title,
  required String message,
  required String confirmText,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'No',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(confirmText),
          ),
        ],
      );
    },
  );

  return result ?? false;
}


 
Future<void> _selectRole(String role) async {
  if (role == _selectedRole) return;

  if (_hasChanges) {
    final confirmed = await _showConfirmationDialog(
      title: 'Discard Changes?',
      message:
          'You have unsaved changes for $_selectedRole. '
          'Do you want to discard them and switch to $role?',
      confirmText: 'Yes, Switch',
    );

    if (!confirmed || !mounted) return;

    setState(() {
      _permissions = _copyPermissions(_savedPermissions);
      _hasChanges = false;
      _selectedRole = role;
    });

    return;
  }

  setState(() {
    _selectedRole = role;
  });
}


  void _toggleScreen(String screen, bool value) {
    setState(() {
      _permissions[_selectedRole]![screen] = value;
      _hasChanges = true;
    });
  }



Future<void> _saveChanges() async {
  final confirmed = await _showConfirmationDialog(
    title: 'Save Changes?',
    message: 'Do you want to save the updated permissions for $_selectedRole?',
    confirmText: 'Yes, Save',
  );

  if (!confirmed || !mounted) return;

  setState(() {
    _savedPermissions = _copyPermissions(_permissions);
    _hasChanges = false;
  });

  _showTopToast(
    '$_selectedRole permissions saved successfully',
  );
}


void _showTopToast(String message) {
  final overlay = Overlay.of(context);
  late final OverlayEntry entry;

  entry = OverlayEntry(
    builder: (overlayContext) {
      final screenWidth = MediaQuery.sizeOf(overlayContext).width;

      return Positioned(
        top: MediaQuery.paddingOf(overlayContext).top + 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: screenWidth < 360 ? screenWidth - 32 : 300,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 17,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  overlay.insert(entry);

  Future.delayed(const Duration(seconds: 3), () {
    entry.remove();
  });
}


Future<void> _cancelChanges() async {
  final confirmed = await _showConfirmationDialog(
    title: 'Discard Changes?',
    message: 'Are you sure you want to discard your unsaved changes?',
    confirmText: 'Yes, Discard',
  );

  if (!confirmed || !mounted) return;

  setState(() {
    _permissions = _copyPermissions(_savedPermissions);
    _hasChanges = false;
  });

  _showTopToast('Changes discarded');
}



  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = width < 600;
        final isTablet = width >= 600 && width < 1000;

      

return PopScope<Object?>(
  canPop: !_hasChanges,
  onPopInvokedWithResult: (didPop, result) async {
    if (didPop || !_hasChanges) return;

    final confirmed = await _showConfirmationDialog(
      title: 'Discard Changes?',
      message:
          'You have unsaved changes. '
          'Do you want to leave without saving?',
      confirmText: 'Yes, Leave',
    );

    if (!confirmed || !mounted) return;

    setState(() {
      _permissions = _copyPermissions(_savedPermissions);
      _hasChanges = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  },
  child: Scaffold(
    backgroundColor: AppColors.background,


  appBar: AppBar(
    backgroundColor: AppColors.white,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => Navigator.maybePop(context),
    ),
    title: const Text(
      'Permissions',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  body: SafeArea(
    child: Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 12 : 24,
              24,
              isMobile ? 12 : 24,
              24,
            ),
            child: Center(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(isMobile),

                    const SizedBox(height: 24),

                    _buildRoleSection(isMobile),

                    const SizedBox(height: 24),

                    _buildScreenSection(
                      isMobile: isMobile,
                      isTablet: isTablet,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        _buildBottomActions(isMobile),
      ],
    ),
    ),
  ), // Closes Scaffold
); // Closes PopScope
      },
    );
  }


Widget _buildHeader(bool isMobile) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 4),
      Text(
        'Manage screen access for each role.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    ],
  );
}



  Widget _buildRoleSection(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Role',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),

          // Fixed-height section with its own horizontal scroll.
          SizedBox(
            height: isMobile ? 105 : 120,
            child: Scrollbar(
              thumbVisibility: _roles.length > 4,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _roles.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final role = _roles[index];
                  final selected = role == _selectedRole;

                  return SizedBox(
                    width: isMobile ? 145 : 180,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _selectRole(role),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primarySoft
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.borderLight,
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              role,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: isMobile ? 13 : 15,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              _roleDescription(role),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _roleDescription(String role) {
    switch (role) {
      case 'Admin':
        return 'Full application access';
      case 'Manager':
        return 'Manage operations and staff';
      case 'Staff':
        return 'Daily operational tasks';
      case 'Delivery Person':
        return 'Assigned deliveries only';
      default:
        return 'Configure screen access';
    }
  }

  Widget _buildScreenSection({
    required bool isMobile,
    required bool isTablet,
  }) {
    final columns = isMobile ? 1 : (isTablet ? 2 : 3);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Screen Access',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Enable the screens this role can access',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 12.0;
              final cardWidth =
                  (constraints.maxWidth - (spacing * (columns - 1))) /
                      columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: _screens.map((screen) {
                  final enabled =
                      _permissions[_selectedRole]![screen] ?? false;

                  return SizedBox(
                    width: cardWidth,
                    child: _buildScreenCard(
                      screen: screen,
                      enabled: enabled,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScreenCard({
    required String screen,
    required bool enabled,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 68),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              screen,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: enabled,
            onChanged: (value) => _toggleScreen(screen, value),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(bool isMobile) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 24,
        12,
        isMobile ? 16 : 24,
        12,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: const Border(
          top: BorderSide(color: AppColors.borderLight),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _hasChanges ? _cancelChanges : null,
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _hasChanges ? _saveChanges : null,
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.white.withValues(alpha: 0.88),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.white),
      boxShadow: const [
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: 16,
          offset: Offset(0, 5),
        ),
      ],
    );
  }
}
