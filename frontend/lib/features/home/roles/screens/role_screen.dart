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

_searchController.addListener(() {

setState(() {});

});

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

String? nameError;

await showDialog<void>(

context: context,

builder: (dialogContext) {

return StatefulBuilder(

builder: (context, setDialogState) {

final screenWidth =

MediaQuery.of(context).size.width;

return AlertDialog(

backgroundColor: AppColors.surface,

surfaceTintColor: Colors.transparent,

insetPadding: EdgeInsets.symmetric(

horizontal: screenWidth < 400 ? 12 : 24,

vertical: 24,

),

shape: RoundedRectangleBorder(

borderRadius: BorderRadius.circular(16),

),

titlePadding: const EdgeInsets.fromLTRB(

20,

18,

12,

8,

),

contentPadding: const EdgeInsets.fromLTRB(

20,

8,

20,

10,

),

actionsPadding: const EdgeInsets.fromLTRB(

20,

8,

20,

18,

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

size: 21,

color: AppColors.icon,

),

),

],

),

content: ConstrainedBox(

constraints: const BoxConstraints(

maxWidth: 420,

),

child: SizedBox(

width: _dialogWidth(context),

child: Column(

mainAxisSize: MainAxisSize.min,

crossAxisAlignment:

CrossAxisAlignment.start,

children: [

const Text(

'Role Name',

style: TextStyle(

fontSize: 14,

fontWeight: FontWeight.w600,

color: AppColors.textPrimary,

),

),

const SizedBox(height: 8),

SizedBox(

height: 72,

child: TextField(

controller: controller,

autofocus: true,

textCapitalization:

TextCapitalization.words,

maxLength: 50,

buildCounter: (

context, {

required currentLength,

required isFocused,

maxLength,

}) {

return null;

},

onChanged: (value) {

setDialogState(() {

nameError = value.length >= 50

? 'Please enter up to 50 characters'

: null;

});

},

decoration: _inputDecoration(

hintText: 'Enter role name',

errorText: nameError,

),

),

),

],

),

),

),

actions: [

OutlinedButton(

onPressed: () {

Navigator.pop(dialogContext);

},

style: OutlinedButton.styleFrom(

minimumSize: const Size(100, 44),

side: const BorderSide(

color: AppColors.border,

),

shape: RoundedRectangleBorder(

borderRadius: BorderRadius.circular(9),

),

),

child: const Text(

'Cancel',

style: TextStyle(

fontSize: 14,

color: AppColors.icon,

),

),

),

const SizedBox(width: 8),

ElevatedButton(

onPressed: () async {

final name =

controller.text.trim();

setDialogState(() {

nameError = name.isEmpty

? 'Please enter role name'

: name.length >= 50

? 'Please enter up to 50 characters'

: null;

});

if (nameError != null) {

return;

}

Navigator.pop(dialogContext);

await _createRole(name);

},

style: ElevatedButton.styleFrom(

backgroundColor: AppColors.primary,

foregroundColor:

AppColors.textOnPrimary,

minimumSize: const Size(100, 44),

elevation: 0,

shape: RoundedRectangleBorder(

borderRadius: BorderRadius.circular(9),

),

),

child: const Text(

'Add',

style: TextStyle(

fontSize: 14,

fontWeight: FontWeight.w600,

),

),

),

],

);

},

);

},

);

WidgetsBinding.instance.addPostFrameCallback((_) {

controller.dispose();

});

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

final message = _getErrorMessage(

e,

'Failed to add role',

);

_showMessage(

message,

isError: message != 'Role already exists',

isWarning: message == 'Role already exists',

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

String? nameError;

await showDialog<void>(

context: context,

builder: (dialogContext) {

return StatefulBuilder(

builder: (context, setDialogState) {

final screenWidth =

MediaQuery.of(context).size.width;

return AlertDialog(

backgroundColor: AppColors.surface,

surfaceTintColor: Colors.transparent,

insetPadding: EdgeInsets.symmetric(

horizontal: screenWidth < 400 ? 12 : 24,

vertical: 24,

),

shape: RoundedRectangleBorder(

borderRadius: BorderRadius.circular(16),

),

titlePadding: const EdgeInsets.fromLTRB(

20,

18,

12,

8,

),

contentPadding: const EdgeInsets.fromLTRB(

20,

8,

20,

10,

),

actionsPadding: const EdgeInsets.fromLTRB(

20,

8,

20,

18,

),

title: Row(

children: [

const Expanded(

child: Text(

'Update Role',

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

size: 21,

color: AppColors.icon,

),

),

],

),

content: ConstrainedBox(

constraints: const BoxConstraints(

maxWidth: 420,

),

child: SizedBox(

width: _dialogWidth(context),

child: Column(

mainAxisSize: MainAxisSize.min,

crossAxisAlignment:

CrossAxisAlignment.start,

children: [

const Text(

'Role Name',

style: TextStyle(

fontSize: 14,

fontWeight: FontWeight.w600,

color: AppColors.textPrimary,

),

),

const SizedBox(height: 8),

SizedBox(

height: 72,

child: TextField(

controller: controller,

autofocus: true,

textCapitalization:

TextCapitalization.words,

maxLength: 50,

buildCounter: (

context, {

required currentLength,

required isFocused,

maxLength,

}) {

return null;

},

onChanged: (value) {

setDialogState(() {

nameError = value.length >= 50

? 'Please enter up to 50 characters'

: null;

});

},

decoration: _inputDecoration(

hintText: 'Enter role name',

errorText: nameError,

),

),

),

const SizedBox(height: 20),

Container(

width: double.infinity,

padding: const EdgeInsets.symmetric(

horizontal: 14,

vertical: 11,

),

decoration: BoxDecoration(

color: AppColors.inputBackground,

borderRadius:

BorderRadius.circular(10),

border: Border.all(

color: AppColors.border,

),

),

child: Row(

children: [

Expanded(

child: Column(

crossAxisAlignment:

CrossAxisAlignment.start,

children: [

const Text(

'Status',

style: TextStyle(

fontSize: 14,

fontWeight:

FontWeight.w600,

color:

AppColors.textPrimary,

),

),

const SizedBox(height: 3),

Text(

isActive

? 'Active'

: 'Inactive',

style: TextStyle(

fontSize: 12,

color: isActive

? AppColors.active

: AppColors

.textSecondary,

fontWeight:

FontWeight.w600,

),

),

],

),

),

SwitchTheme(

data: SwitchThemeData(

thumbColor:

WidgetStateProperty

.resolveWith(

(_) => Colors.white,

),

trackColor:

WidgetStateProperty

.resolveWith(

(states) {

if (states.contains(

WidgetState.selected,

)) {

return AppColors.primary;

}

return Colors.grey

.withValues(

alpha: 0.35,

);

},

),

trackOutlineColor:

WidgetStateProperty.all(

Colors.transparent,

),

),

child: Switch(

value: isActive,

onChanged: (value) {

setDialogState(() {

isActive = value;

});

},

),

),

],

),

),

],

),

),

),

actions: [

OutlinedButton(

onPressed: () {

Navigator.pop(dialogContext);

},

style: OutlinedButton.styleFrom(

minimumSize: const Size(100, 44),

side: const BorderSide(

color: AppColors.border,

),

shape: RoundedRectangleBorder(

borderRadius: BorderRadius.circular(9),

),

),

child: const Text(

'Cancel',

style: TextStyle(

fontSize: 14,

color: AppColors.icon,

),

),

),

const SizedBox(width: 8),

ElevatedButton(

onPressed: () async {

final name =

controller.text.trim();

setDialogState(() {

nameError = name.isEmpty

? 'Please enter role name'

: name.length >= 50

? 'Please enter up to 50 characters'

: null;

});

if (nameError != null) {

return;

}

Navigator.pop(dialogContext);

await _updateRole(

role.id,

name,

isActive,

);

},

style: ElevatedButton.styleFrom(

backgroundColor: AppColors.primary,

foregroundColor:

AppColors.textOnPrimary,

minimumSize: const Size(130, 44),

elevation: 0,

shape: RoundedRectangleBorder(

borderRadius: BorderRadius.circular(9),

),

),

child: const Text(

'Update Role',

style: TextStyle(

fontSize: 14,

fontWeight: FontWeight.w600,

),

),

),

],

);

},

);

},

);

WidgetsBinding.instance.addPostFrameCallback((_) {

controller.dispose();

});

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

final message = _getErrorMessage(

e,

'Failed to update role',

);

_showMessage(

message,

isError: message != 'Role already exists',

isWarning: message == 'Role already exists',

);

}

}

// ============================================================

// STATUS

Future<void> _toggleStatus(
    RoleModel role,
  ) async {
    final newStatus = !role.status;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (dialogContext) {
        final isActivating = newStatus;

        return AlertDialog(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          contentPadding: const EdgeInsets.fromLTRB(28, 24, 28, 12),
          actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isActivating
                        ? const Color(0xFFEAF7E8)
                        : const Color(0xFFFFE9E3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isActivating
                        ? Icons.check_rounded
                        : Icons.priority_high_rounded,
                    size: 34,
                    color: isActivating
                        ? const Color(0xFF2E7D32)
                        : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  isActivating ? 'Activate Role?' : 'Deactivate Role?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isActivating
                      ? 'Are you sure you want to activate this role?'
                      : 'Are you sure you want to deactivate this role?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      isActivating ? 'Activate' : 'Deactivate',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _roleApiService.updateRoleStatus(role.id, newStatus);

      if (!mounted) return;

      setState(() {
        final index = _roles.indexWhere((item) => item.id == role.id);
        if (index != -1) {
          _roles[index] = RoleModel(
            id: role.id,
            name: role.name,
            status: newStatus,
          );
        }
      });

      _showMessage(
        newStatus
            ? 'Role activated successfully'
            : 'Role deactivated successfully',
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage('Failed to update status', isError: true);
    }
  }

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

            final isVerySmall = width < 360;

            final isMobile = width < 600;

            final isTablet = width >= 600 && width < 1000;

            final isDesktop = width >= 1000;

            final horizontalPadding = _getHorizontalPadding(width);

return Column(

              children: [

                _buildAppBar(

                  horizontalPadding,

                  isVerySmall,

                ),

                Expanded(
                  child: Padding(

                        padding: EdgeInsets.fromLTRB(

                          horizontalPadding,

                          isMobile ? 14 : 24,

                          horizontalPadding,

                          isMobile ? 10 : 24,

                        ),

                        child: Column(

                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [

                            if (isDesktop || isTablet) ...[

                              Row(

                                children: [

                                  const Expanded(

                                    child: Text(

                                      'Manage user roles.',

                                      style: TextStyle(

                                        fontSize: 15,

                                        color: AppColors.textSecondary,

                                        fontWeight: FontWeight.w500,

                                      ),

                                    ),

                                  ),

                                  _buildAddButton(

                                    width: isTablet ? 126 : 148,

                                  ),

                                ],

                              ),

                              const SizedBox(height: 22),

                              _buildDesktopSearchAndFilters(),

                            ] else ...[

                              const Text(

                                'Manage user roles.',

                                style: TextStyle(

                                  fontSize: 13,

                                  color: AppColors.textSecondary,

                                  fontWeight: FontWeight.w500,

                                ),

                              ),

                              const SizedBox(height: 10),

                              _buildMobileSearchAndAdd(),

                              const SizedBox(height: 8),

                              _buildFilters(true),

                            ],

                            SizedBox(

                              height: isMobile ? 8 : 16,

                            ),

                            Expanded(

                              child: _buildRoleList(isMobile),

                            ),

                          ],

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

// APP BAR

// ============================================================

Widget _buildAppBar(

double horizontalPadding,

bool isVerySmall,

) {

return Container(

height: isVerySmall ? 54 : 54,

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

Widget _buildMobileSearchAndAdd() {

    return Row(

      children: [

        Expanded(

          child: _buildSearchField(compact: true),

        ),

        const SizedBox(width: 7),

        _buildCompactAddButton(),

      ],

    );

  }

Widget _buildDesktopSearchAndFilters() {

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(

        color: AppColors.surface,

        borderRadius: BorderRadius.circular(12),

        border: Border.all(

          color: AppColors.borderLight,

        ),

      ),

      child: Row(

        children: [

          Expanded(

            child: _buildSearchField(),

          ),

          const SizedBox(width: 16),

          _buildFilters(false),

        ],

      ),

    );

  }

// SEARCH FIELD

Widget _buildSearchField({

    bool compact = false,

  }) {

    return SizedBox(

      height: compact ? 40 : 46,

      child: TextField(

        controller: _searchController,

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

          suffixIcon: _searchController.text.isNotEmpty

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

          contentPadding: const EdgeInsets.symmetric(

            horizontal: 10,

            vertical: 8,

          ),

          border: OutlineInputBorder(

            borderRadius: BorderRadius.circular(9),

            borderSide: const BorderSide(

              color: AppColors.border,

            ),

          ),

          enabledBorder: OutlineInputBorder(

            borderRadius: BorderRadius.circular(9),

            borderSide: const BorderSide(

              color: AppColors.border,

            ),

          ),

          focusedBorder: OutlineInputBorder(

            borderRadius: BorderRadius.circular(9),

            borderSide: const BorderSide(

              color: AppColors.primary,

              width: 1.4,

            ),

          ),

        ),

      ),

    );

  }

// MOBILE ADD BUTTON

Widget _buildCompactAddButton() {

    return SizedBox(

      width: 82,

      height: 40,

      child: ElevatedButton.icon(

        onPressed: _openAddDialog,

        icon: const Icon(

          Icons.add_rounded,

          size: 18,

        ),

        label: const Text(

          'Add',

          style: TextStyle(

            fontSize: 13,

            fontWeight: FontWeight.w600,

          ),

        ),

        style: ElevatedButton.styleFrom(

          padding: const EdgeInsets.symmetric(horizontal: 10),

          backgroundColor: AppColors.primary,

          foregroundColor: AppColors.textOnPrimary,

          elevation: 0,

          shape: RoundedRectangleBorder(

            borderRadius: BorderRadius.circular(9),

          ),

        ),

      ),

    );

  }

// DESKTOP / TABLET ADD BUTTON

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

          'Add',

          style: TextStyle(

            fontSize: 13,

            fontWeight: FontWeight.w600,

          ),

        ),

        style: ElevatedButton.styleFrom(

          backgroundColor: AppColors.primary,

          foregroundColor: AppColors.textOnPrimary,

          elevation: 0,

          shape: RoundedRectangleBorder(

            borderRadius: BorderRadius.circular(9),

          ),

        ),

      ),

    );

  }

// FILTERS

Widget _buildFilters(bool isMobile) {

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

          _buildStatusFilter('All', compact: isMobile),

          _buildStatusFilter('Active', compact: isMobile),

          _buildStatusFilter('Inactive', compact: isMobile),

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

Widget _buildRoleCard(

    RoleModel role,

    bool isMobile,

  ) {

    return Container(

      width: double.infinity,

      constraints: const BoxConstraints(
        minHeight: 90,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 20,
        vertical: 15,
      ),

      decoration: BoxDecoration(

        color: AppColors.surface,

        borderRadius: BorderRadius.circular(12),

        border: Border.all(

          color: AppColors.borderLight,

        ),

      ),

      child: Row(

        children: [

          Expanded(

            child: Text(

              role.name,

              maxLines: 1,

              overflow: TextOverflow.ellipsis,

              style: TextStyle(

                fontSize: isMobile ? 15 : 17,

                fontWeight: FontWeight.w700,

                color: AppColors.textPrimary,

              ),

            ),

          ),

          SwitchTheme(

            data: SwitchThemeData(

              thumbColor: WidgetStateProperty.resolveWith(

                (_) => Colors.white,

              ),

              trackColor: WidgetStateProperty.resolveWith(

                (states) {

                  if (states.contains(WidgetState.selected)) {

                    return AppColors.primary;

                  }

                  return Colors.grey.withValues(alpha: 0.35);

                },

              ),

              trackOutlineColor:

                  WidgetStateProperty.all(Colors.transparent),

            ),

            child: Switch(

              value: role.status,

              onChanged: (_) {

                _toggleStatus(role);

              },

            ),

          ),

          const SizedBox(width: 2),

          IconButton(

            tooltip: 'Edit',

            padding: EdgeInsets.zero,

            constraints: const BoxConstraints(

              minWidth: 40,

              minHeight: 40,

            ),

            onPressed: () {

              _openEditDialog(role);

            },

            icon: const Icon(

              Icons.edit_outlined,

              size: 21,

              color: AppColors.icon,

            ),

          ),

        ],

      ),

    );

  }

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

String? errorText,

}) {

return InputDecoration(

hintText: hintText,

errorText: errorText,

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

bool isWarning = false,

}) {

final overlay = Overlay.of(context);

final backgroundColor = isError

? const Color(0xFFFFE5E5)

: isWarning

? const Color(0xFFFFF3CD)

: const Color(0xFFE5F7E9);

final iconColor = isError

? const Color(0xFFD32F2F)

: isWarning

? const Color(0xFFE59A00)

: const Color(0xFF1E9E45);

final icon = isError

? Icons.close_rounded

: isWarning

? Icons.warning_amber_rounded

: Icons.check_rounded;

late OverlayEntry entry;

entry = OverlayEntry(

builder: (context) {

return Positioned(

top: MediaQuery.of(context).padding.top + 12,

right: 16,

child: Material(

color: Colors.transparent,

child: Container(

constraints: const BoxConstraints(

maxWidth: 320,

),

padding: const EdgeInsets.symmetric(

horizontal: 14,

vertical: 12,

),

decoration: BoxDecoration(

color: backgroundColor,

borderRadius: BorderRadius.circular(12),

boxShadow: [

BoxShadow(

color: Colors.black.withValues(alpha: 0.12),

blurRadius: 12,

offset: const Offset(0, 4),

),

],

),

child: Row(

mainAxisSize: MainAxisSize.min,

children: [

Icon(

icon,

size: 22,

color: iconColor,

),

const SizedBox(width: 10),

Flexible(

child: Text(

message,

style: TextStyle(

fontSize: 13,

fontWeight: FontWeight.w600,

color: iconColor,

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

Future.delayed(

const Duration(seconds: 3),

() {

if (entry.mounted) {

entry.remove();

}

},

);

}

}
