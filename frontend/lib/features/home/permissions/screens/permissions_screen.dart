import 'package:flutter/material.dart';

import '../models/permissions_model.dart';
import '../services/permissions_service.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  final PermissionsService _service = PermissionsService();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  List<PermissionRole> _roles = [];
  List<PermissionScreen> _screens = [];
  List<ScreenPermission> _permissions = [];
  int? _selectedRoleId;

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final roles = await _service.getRoles();
      final screens = await _service.getScreens();

      if (!mounted) return;

      setState(() {
        _roles = roles;
        _screens = screens;
        _selectedRoleId ??= roles.isNotEmpty ? roles.first.id : null;
      });

      if (_selectedRoleId != null) {
        await _loadRolePermissions(_selectedRoleId!);
      } else {
        setState(() => _isLoading = false);
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _selectRole(PermissionRole role) async {
    setState(() {
      _selectedRoleId = role.id;
      _isLoading = true;
      _errorMessage = null;
    });

    await _loadRolePermissions(role.id);
  }

  Future<void> _loadRolePermissions(int roleId) async {
    try {
      final savedPermissions = await _service.getRolePermissions(roleId);

      final savedByScreenId = {
        for (final permission in savedPermissions)
          permission.screenId: permission.canView,
      };

      if (!mounted) return;

      setState(() {
        _permissions = _screens
            .map(
              (screen) => ScreenPermission(
                screenId: screen.id,
                canView: savedByScreenId[screen.id] ?? false,
              ),
            )
            .toList();
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  void _togglePermission(int screenId, bool value) {
    setState(() {
      final index = _permissions.indexWhere(
        (permission) => permission.screenId == screenId,
      );

      if (index != -1) {
        _permissions[index].canView = value;
      }
    });
  }

  Future<void> _savePermissions() async {
    if (_selectedRoleId == null) return;

    setState(() => _isSaving = true);

    try {
      await _service.saveRolePermissions(
        _selectedRoleId!,
        _permissions,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permissions saved successfully')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save permissions: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _resetPermissions() async {
    if (_selectedRoleId != null) {
      await _loadRolePermissions(_selectedRoleId!);
    }
  }

  String _headingFor(String screenName) {
    final name = screenName.toLowerCase();

    if (name.contains('dashboard')) return 'Dashboard';

    if (name.contains('categor') ||
        name.contains('item') ||
        name.contains('menu')) {
      return 'Menu Management';
    }

    if (name.contains('customer') ||
        name.contains('delivery') ||
        name.contains('kot')) {
      return 'Operations';
    }

    return 'Administration';
  }

  IconData _iconFor(String screenName) {
    final name = screenName.toLowerCase();

    if (name.contains('dashboard')) return Icons.dashboard_outlined;
    if (name.contains('categor')) return Icons.grid_view_rounded;
    if (name.contains('item')) return Icons.inventory_2_outlined;
    if (name.contains('schedule')) return Icons.calendar_month_outlined;
    if (name.contains('customer')) return Icons.people_outline;
    if (name.contains('delivery')) return Icons.delivery_dining_outlined;
    if (name.contains('kot')) return Icons.print_outlined;
    if (name.contains('payment')) return Icons.payment_outlined;
    if (name.contains('operator')) return Icons.person_outline;
    if (name.contains('role')) return Icons.groups_outlined;
    if (name.contains('permission')) return Icons.shield_outlined;

    return Icons.circle_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permissions'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadRoles,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadRoles,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_roles.isEmpty) {
      return const Center(child: Text('No roles found.'));
    }

    final selectedRole = _roles.firstWhere(
      (role) => role.id == _selectedRoleId,
      orElse: () => _roles.first,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Fixed roles section
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Roles',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Optional Add Role button can be connected later.
                ],
              ),
              const SizedBox(height: 10),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _roles.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 1 : 2,
                  mainAxisExtent: 78,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final role = _roles[index];
                  final isSelected = role.id == _selectedRoleId;

                  return Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: isSelected
                            ? Colors.brown
                            : Colors.brown.shade100,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      onTap: () => _selectRole(role),
                      leading: const CircleAvatar(
                        child: Icon(Icons.people_outline),
                      ),
                      title: Text(
                        role.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        role.name.toLowerCase() == 'admin'
                            ? 'Full access to all modules'
                            : 'Role access',
                      ),
                      trailing: Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: isSelected ? Colors.brown : Colors.grey,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Center permissions panel: only this section scrolls.
              Expanded(
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.shield_outlined,
                              color: Colors.brown,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Role Permissions',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Manage screen access for the selected role',
                                  ),
                                ],
                              ),
                            ),
                            Chip(label: Text('Role: ${selectedRole.name}')),
                          ],
                        ),
                      ),
                      const Divider(height: 1),

                      Expanded(
                        child: _screens.isEmpty
                            ? const Center(child: Text('No screens found.'))
                            : SingleChildScrollView(
                                padding: const EdgeInsets.all(12),
                                child: _buildPermissionGroups(isMobile),
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Fixed action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: _resetPermissions,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _savePermissions,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPermissionGroups(bool isMobile) {
    const headings = [
      'Dashboard',
      'Menu Management',
      'Operations',
      'Administration',
    ];

    return Column(
      children: headings.map((heading) {
        final groupScreens = _screens
            .where((screen) => _headingFor(screen.name) == heading)
            .toList();

        if (groupScreens.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.brown.shade100),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.brown.shade50,
                child: Text(
                  heading,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: groupScreens.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isMobile ? 1 : 2,
                    mainAxisExtent: 54,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    final screen = groupScreens[index];

                    final permissionIndex = _permissions.indexWhere(
                      (item) => item.screenId == screen.id,
                    );

                    final canView = permissionIndex == -1
                        ? false
                        : _permissions[permissionIndex].canView;

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.brown.shade100),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(_iconFor(screen.name), color: Colors.brown),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              screen.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Switch(
                            value: canView,
                            activeColor: Colors.brown,
                            onChanged: (value) =>
                                _togglePermission(screen.id, value),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}