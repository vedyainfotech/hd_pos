import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../models/role_model.dart';
import '../services/role_service.dart';

class RoleScreen extends StatefulWidget {
  const RoleScreen({super.key});

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  final RoleApiService _roleApiService = RoleApiService();

  List<RoleModel> _roles = [];

  String _statusFilter = 'All';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD ROLES
  // ============================================================

  Future<void> _loadRoles() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final roles = await _roleApiService.getRoles(
        includeInactive: true,
      );

      if (!mounted) return;

      setState(() {
        _roles = roles;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Failed to load roles',
        isError: true,
      );
    }
  }

  // ============================================================
  // FILTER + SEARCH
  // ============================================================

  List<RoleModel> get _filteredRoles {
    final search =
        _searchController.text.trim().toLowerCase();

    return _roles.where((role) {
      final matchesSearch =
          search.isEmpty ||
          role.name.toLowerCase().contains(search);

      final matchesStatus =
          _statusFilter == 'All' ||
          (_statusFilter == 'Active' && role.status) ||
          (_statusFilter == 'Inactive' && !role.status);

      return matchesSearch && matchesStatus;
    }).toList();
  }

  // ============================================================
  // ADD ROLE
  // ============================================================

  Future<void> _openAddDialog() async {
    final controller = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Expanded(
                child: Text(
                  'Add Role',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.icon,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: _dialogWidth(context),
            child: TextField(
              controller: controller,
              autofocus: true,
              textCapitalization:
                  TextCapitalization.words,
              decoration: _inputDecoration(
                hintText: 'Enter role name',
              ),
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = controller.text.trim();

                if (name.isEmpty) {
                  _showMessage(
                    'Please enter role name',
                    isError: true,
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                await _createRole(name);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor:
                    AppColors.textOnPrimary,
                elevation: 0,
              ),
              child: const Text('Add Role'),
            ),
          ],
        );
      },
    );

    controller.dispose();
  }

  Future<void> _createRole(String name) async {
    try {
      final role =
          await _roleApiService.createRole(
        name: name,
      );

      if (!mounted) return;

      setState(() {
        _roles.add(role);
      });

      _showMessage(
        'Role added successfully',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        _getErrorMessage(
          e,
          'Failed to add role',
        ),
        isError: true,
      );
    }
  }

  // ============================================================
  // EDIT ROLE
  // ============================================================

  Future<void> _openEditDialog(
    RoleModel role,
  ) async {
    final controller =
        TextEditingController(text: role.name);

    bool isActive = role.status;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              surfaceTintColor: Colors.transparent,
              insetPadding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Update Role',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color:
                            AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(
                        dialogContext,
                      );
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.icon,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: _dialogWidth(context),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      autofocus: true,
                      textCapitalization:
                          TextCapitalization.words,
                      decoration:
                          _inputDecoration(
                        hintText:
                            'Enter role name',
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            AppColors.inputBackground,
                        borderRadius:
                            BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                const Text(
                                  'Status',
                                  style:
                                      TextStyle(
                                    fontSize: 13,
                                    fontWeight:
                                        FontWeight.w600,
                                    color:
                                        AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  isActive
                                      ? 'Active'
                                      : 'Inactive',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isActive
                                        ? AppColors
                                            .active
                                        : AppColors
                                            .textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: isActive,
                            onChanged: (value) {
                              setDialogState(() {
                                isActive = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name =
                        controller.text.trim();

                    if (name.isEmpty) {
                      _showMessage(
                        'Please enter role name',
                        isError: true,
                      );
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                    );

                    await _updateRole(
                      role.id,
                      name,
                      isActive,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.primary,
                    foregroundColor:
                        AppColors.textOnPrimary,
                    elevation: 0,
                  ),
                  child:
                      const Text('Update Role'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
  }

  Future<void> _updateRole(
    int id,
    String name,
    bool status,
  ) async {
    try {
      final updated =
          await _roleApiService.updateRole(
        id: id,
        name: name,
        status: status,
      );

      if (!mounted) return;

      setState(() {
        final index = _roles.indexWhere(
          (role) => role.id == id,
        );

        if (index != -1) {
          _roles[index] = updated;
        }
      });

      _showMessage(
        'Role updated successfully',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        _getErrorMessage(
          e,
          'Failed to update role',
        ),
        isError: true,
      );
    }
  }

  // ============================================================
  // STATUS
  // ============================================================

  Future<void> _toggleStatus(
    RoleModel role,
  ) async {
    final newStatus = !role.status;

    try {
      await _roleApiService.updateRoleStatus(
        role.id,
        newStatus,
      );

      if (!mounted) return;

      setState(() {
        final index = _roles.indexWhere(
          (item) => item.id == role.id,
        );

        if (index != -1) {
          _roles[index] = RoleModel(
            id: role.id,
            name: role.name,
            status: newStatus,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to update status',
        isError: true,
      );
    }
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
          builder: (
            context,
            constraints,
          ) {
            final width = constraints.maxWidth;

            final isVerySmall =
                width < 360;

            final isMobile =
                width < 600;

            final isTablet =
                width >= 600 &&
                width < 1000;

            final isWide =
                width >= 1000;

            final horizontalPadding =
                _getHorizontalPadding(width);

            return Column(
              children: [
                _buildAppBar(
                  horizontalPadding,
                  isVerySmall,
                ),

                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(
                        maxWidth: isWide
                            ? 1400
                            : double.infinity,
                      ),
                      child: Padding(
                        padding:
                            EdgeInsets.fromLTRB(
                          horizontalPadding,
                          isMobile
                              ? 14
                              : 24,
                          horizontalPadding,
                          isMobile
                              ? 10
                              : 24,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              'Manage user roles.',
                              style: TextStyle(
                                fontSize:
                                    isMobile
                                        ? 13
                                        : 15,
                                color: AppColors
                                    .textSecondary,
                                fontWeight:
                                    FontWeight.w500,
                              ),
                            ),

                            SizedBox(
                              height:
                                  isMobile
                                      ? 10
                                      : 20,
                            ),

                            _buildSearchArea(
                              isMobile: isMobile,
                              isTablet: isTablet,
                            ),

                            SizedBox(
                              height:
                                  isMobile
                                      ? 8
                                      : 14,
                            ),

                            _buildFilters(
                              isMobile,
                            ),

                            SizedBox(
                              height:
                                  isMobile
                                      ? 8
                                      : 16,
                            ),

                            Expanded(
                              child:
                                  _buildRoleList(
                                isMobile,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  Widget _buildAppBar(
    double horizontalPadding,
    bool isVerySmall,
  ) {
    return Container(
      height: isVerySmall ? 54 : 62,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints:
                const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back_rounded,
              size: isVerySmall ? 20 : 22,
              color: AppColors.icon,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Roles',
            style: TextStyle(
              fontSize:
                  isVerySmall ? 17 : 19,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH AREA
  // ============================================================

  Widget _buildSearchArea({
    required bool isMobile,
    required bool isTablet,
  }) {
    // ALL MOBILE DEVICES
    //
    // Search and + remain on the same row.
    if (isMobile) {
      return Row(
        children: [
          Expanded(
            child: _buildSearchField(
              compact: true,
            ),
          ),
          const SizedBox(width: 7),
          _buildCompactAddButton(),
        ],
      );
    }

    // TABLET
    if (isTablet) {
      return Row(
        children: [
          Expanded(
            child: _buildSearchField(),
          ),
          const SizedBox(width: 10),
          _buildAddButton(
            width: 130,
          ),
        ],
      );
    }

    // DESKTOP / LARGE TABLET
    return Row(
      children: [
        Expanded(
          child: _buildSearchField(),
        ),
        const SizedBox(width: 12),
        _buildAddButton(
          width: 145,
        ),
      ],
    );
  }

  // ============================================================
  // SEARCH FIELD
  // ============================================================

  Widget _buildSearchField({
    bool compact = false,
  }) {
    return SizedBox(
      height: compact ? 40 : 46,
      child: TextField(
        controller: _searchController,

        // Search updates immediately.
        onChanged: (_) {
          setState(() {});
        },

        style: TextStyle(
          fontSize: compact ? 13 : 14,
          color: AppColors.textPrimary,
        ),

        decoration: InputDecoration(
          hintText: 'Search roles...',
          hintStyle: TextStyle(
            fontSize: compact ? 12 : 14,
            color: AppColors.textTertiary,
          ),

          prefixIcon: Icon(
            Icons.search_rounded,
            size: compact ? 18 : 21,
            color: AppColors.textTertiary,
          ),

          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        size: compact ? 16 : 19,
                      ),
                    )
                  : null,

          filled: true,
          fillColor: AppColors.surface,

          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),

          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(9),
            borderSide:
                const BorderSide(
              color: AppColors.border,
            ),
          ),

          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(9),
            borderSide:
                const BorderSide(
              color: AppColors.border,
            ),
          ),

          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(9),
            borderSide:
                const BorderSide(
              color: AppColors.primary,
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MOBILE ADD BUTTON
  // ============================================================

  Widget _buildCompactAddButton() {
    return SizedBox(
      width: 40,
      height: 40,
      child: ElevatedButton(
        onPressed: _openAddDialog,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor:
              AppColors.primary,
          foregroundColor:
              AppColors.textOnPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(9),
          ),
        ),
        child: const Icon(
          Icons.add_rounded,
          size: 20,
        ),
      ),
    );
  }

  // ============================================================
  // DESKTOP / TABLET ADD BUTTON
  // ============================================================

  Widget _buildAddButton({
    required double width,
  }) {
    return SizedBox(
      width: width,
      height: 46,
      child: ElevatedButton.icon(
        onPressed: _openAddDialog,
        icon: const Icon(
          Icons.add_rounded,
          size: 19,
        ),
        label: const Text(
          'Add Role',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              AppColors.primary,
          foregroundColor:
              AppColors.textOnPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(9),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FILTERS
  // ============================================================

 Widget _buildFilters(
  bool isMobile,
) {
  return Container(
    height: 48,
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: AppColors.surfaceSoft,
      border: Border.all(
        color: AppColors.border,
      ),
      borderRadius: BorderRadius.circular(28),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatusFilter(
          'All',
          compact: isMobile,
        ),
        _buildStatusFilter(
          'Active',
          compact: isMobile,
        ),
        _buildStatusFilter(
          'Inactive',
          compact: isMobile,
        ),
      ],
    ),
  );
}

Widget _buildStatusFilter(
  String status, {
  bool compact = false,
}) {
  final isSelected = _statusFilter == status;

  return GestureDetector(
    onTap: () {
      setState(() {
        _statusFilter = status;
      });
    },
    child: Container(
      height: 40,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 18 : 22,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primarySoft
            : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: compact ? 11 : 13,
          fontWeight: FontWeight.w600,
          color: isSelected
              ? AppColors.primary
              : AppColors.textPrimary,
        ),
      ),
    ),
  );
}

  // ============================================================
  // ROLE LIST
  // ============================================================

  Widget _buildRoleList(
    bool isMobile,
  ) {
    if (_isLoading) {
      return const Center(
        child:
            CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    final roles = _filteredRoles;

    if (roles.isEmpty) {
      return _buildEmptyState(
        isMobile,
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: roles.length,
      separatorBuilder: (_, __) {
        return SizedBox(
          height: isMobile ? 5 : 9,
        );
      },
      itemBuilder: (
        context,
        index,
      ) {
        return _buildRoleCard(
          roles[index],
          isMobile,
        );
      },
    );
  }

  // ============================================================
  // ROLE CARD
  // ============================================================

  Widget _buildRoleCard(
    RoleModel role,
    bool isMobile,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal:
            isMobile ? 10 : 18,
        vertical:
            isMobile ? 5 : 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          isMobile ? 9 : 11,
        ),
        border: Border.all(
          color: AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          // ROLE NAME
          Expanded(
            child: Text(
              role.name,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: TextStyle(
                fontSize:
                    isMobile ? 13 : 15,
                fontWeight:
                    FontWeight.w600,
                color:
                    AppColors.textPrimary,
              ),
            ),
          ),

          // DESKTOP STATUS TEXT
          if (!isMobile) ...[
            const SizedBox(width: 10),
            Text(
              role.status
                  ? 'Active'
                  : 'Inactive',
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w600,
                color: role.status
                    ? AppColors.active
                    : AppColors
                        .textSecondary,
              ),
            ),
          ],

          // STATUS SWITCH
          Transform.scale(
            scale:
                isMobile ? 0.68 : 0.80,
            child: Switch(
              value: role.status,
              onChanged: (_) {
                _toggleStatus(role);
              },
            ),
          ),

          // EDIT
          SizedBox(
            width: isMobile ? 30 : 36,
            height: isMobile ? 30 : 36,
            child: IconButton(
              padding: EdgeInsets.zero,
              tooltip: 'Edit',
              onPressed: () {
                _openEditDialog(role);
              },
              icon: Icon(
                Icons.edit_outlined,
                size:
                    isMobile ? 17 : 20,
                color: AppColors.icon,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState(
    bool isMobile,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(11),
        border: Border.all(
          color: AppColors.borderLight,
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(
            isMobile ? 20 : 30,
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Icon(
                Icons.badge_outlined,
                size:
                    isMobile ? 38 : 48,
                color:
                    AppColors.textTertiary,
              ),
              const SizedBox(height: 9),
              Text(
                'No roles found',
                style: TextStyle(
                  fontSize:
                      isMobile ? 14 : 16,
                  fontWeight:
                      FontWeight.w600,
                  color:
                      AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Add your first role to get started.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize:
                      isMobile ? 11 : 13,
                  color:
                      AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String hintText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontSize: 14,
        color: AppColors.textTertiary,
      ),
      filled: true,
      fillColor:
          AppColors.inputBackground,
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(9),
        borderSide:
            const BorderSide(
          color: AppColors.border,
        ),
      ),
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(9),
        borderSide:
            const BorderSide(
          color: AppColors.border,
        ),
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(9),
        borderSide:
            const BorderSide(
          color: AppColors.primary,
          width: 1.4,
        ),
      ),
    );
  }

  // ============================================================
  // RESPONSIVE PADDING
  // ============================================================

double _getHorizontalPadding(
  double width,
) {
  if (width < 320) {
    return 8;
  }

  if (width < 360) {
    return 10;
  }

  if (width < 600) {
    return 14;
  }

  if (width < 840) {
    return 20;
  }

  if (width < 1200) {
    return 28;
  }

  if (width < 1600) {
    return 40;
  }

  return 48;
}
  // ============================================================
  // DIALOG WIDTH
  // ============================================================

  double _dialogWidth(
    BuildContext context,
  ) {
    final width =
        MediaQuery.of(context).size.width;

    if (width < 360) {
      return width * 0.84;
    }

    if (width < 600) {
      return width * 0.82;
    }

    if (width < 900) {
      return 400;
    }

    return 420;
  }

  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  String _getErrorMessage(
    Object error,
    String fallback,
  ) {
    final message =
        error.toString();

    if (message.contains(
      'Role already exists',
    )) {
      return 'Role already exists';
    }

    return fallback;
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 13,
          ),
        ),
        behavior:
            SnackBarBehavior.floating,
        backgroundColor: isError
            ? AppColors.error
            : null,
      ),
    );
  }
}