import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../models/units_model.dart';
import '../services/units_service.dart';

class UnitsScreen extends StatefulWidget {
  const UnitsScreen({super.key});

  @override
  State<UnitsScreen> createState() => _UnitsScreenState();
}

class _UnitsScreenState extends State<UnitsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final UnitApiService _unitApiService = UnitApiService();

  List<UnitModel> _units = [];
  String _statusFilter = 'All';
  bool _isLoading = true;

  String? _message;
  bool _messageIsError = false;
  bool _messageIsWarning = false;
  int _messageVersion = 0;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    _loadUnits();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD UNITS
  // ============================================================

  Future<void> _loadUnits() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      final units = await _unitApiService.getUnits(
        includeInactive: true,
      );

      if (!mounted) return;

      setState(() {
        _units = units;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Failed to load units',
        isError: true,
      );
    }
  }

  // ============================================================
  // FILTER
  // ============================================================

  List<UnitModel> get _filteredUnits {
    final search = _searchController.text.trim().toLowerCase();

    return _units.where((unit) {
      final matchesSearch =
          unit.name.toLowerCase().contains(search);

      final matchesStatus =
          _statusFilter == 'All' ||
          (_statusFilter == 'Active' && unit.status) ||
          (_statusFilter == 'Inactive' && !unit.status);

      return matchesSearch && matchesStatus;
    }).toList();
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    bool isError = false,
    bool isWarning = false,
  }) {
    if (!mounted) return;

    final version = ++_messageVersion;

    setState(() {
      _message = message;
      _messageIsError = isError;
      _messageIsWarning = isWarning;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted || version != _messageVersion) return;

      setState(() {
        _message = null;
      });
    });
  }

  Widget _buildTopRightMessage() {
    final message = _message;

    if (message == null) {
      return const SizedBox.shrink();
    }

    final backgroundColor = _messageIsError
        ? const Color(0xFFFFE5E5)
        : _messageIsWarning
            ? const Color(0xFFFFF3CD)
            : const Color(0xFFE5F7E9);

    final iconColor = _messageIsError
        ? const Color(0xFFD32F2F)
        : _messageIsWarning
            ? const Color(0xFFE59A00)
            : const Color(0xFF1E9E45);

    final icon = _messageIsError
        ? Icons.close_rounded
        : _messageIsWarning
            ? Icons.warning_amber_rounded
            : Icons.check_rounded;

    return Positioned(
      top: 12,
      right: 16,
      left: 16,
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.topRight,
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
        ),
      ),
    );
  }

  // ============================================================
  // ADD UNIT
  // ============================================================

  Future<void> _openAddDialog() async {
    final controller = TextEditingController();
    String? nameError;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final screenWidth = MediaQuery.of(context).size.width;

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
                      'Add Unit',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Unit Name',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Fixed height keeps the dialog stable
                      // when the validation message appears.
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
                            hintText: 'Enter unit name',
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
                    final name = controller.text.trim();

                    setDialogState(() {
                      nameError = name.isEmpty
                          ? 'Please enter unit name'
                          : name.length >= 50
                              ? 'Please enter up to 50 characters'
                              : null;
                    });

                    if (nameError != null) {
                      return;
                    }

                    final duplicate = _units.any(
                      (unit) =>
                          unit.name.trim().toLowerCase() ==
                          name.toLowerCase(),
                    );

                    if (duplicate) {
                      _showMessage(
                        'Unit already exists',
                        isWarning: true,
                      );
                      return;
                    }

                    Navigator.pop(dialogContext);
                    await _createUnit(name);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
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

  // ============================================================
  // CREATE UNIT API
  // ============================================================

  Future<void> _createUnit(String name) async {
    try {
      final unit = await _unitApiService.createUnit(
        name: name,
      );

      if (!mounted) return;

      setState(() {
        _units.add(unit);
      });

      _showMessage('Unit added successfully');
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to add unit',
        isError: true,
      );
    }
  }

  // ============================================================
  // EDIT UNIT
  // ============================================================

  Future<void> _openEditDialog(UnitModel unit) async {
    final controller =
        TextEditingController(text: unit.name);

    String? nameError;
    bool status = unit.status;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final screenWidth = MediaQuery.of(context).size.width;

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
                      'Update Unit',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Unit Name',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Fixed height keeps the dialog stable
                      // when the validation message appears.
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
                            hintText: 'Enter unit name',
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
                          borderRadius: BorderRadius.circular(10),
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
                                      fontWeight: FontWeight.w600,
                                      color:
                                          AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    status ? 'Active' : 'Inactive',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: status
                                          ? AppColors.active
                                          : AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SwitchTheme(
                              data: SwitchThemeData(
                                thumbColor:
                                    WidgetStateProperty.resolveWith(
                                  (_) => Colors.white,
                                ),
                                trackColor:
                                    WidgetStateProperty.resolveWith(
                                  (states) {
                                    if (states.contains(
                                      WidgetState.selected,
                                    )) {
                                      return AppColors.primary;
                                    }

                                    return Colors.grey.withValues(
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
                                value: status,
                                onChanged: (value) {
                                  setDialogState(() {
                                    status = value;
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
                    final name = controller.text.trim();

                    setDialogState(() {
                      nameError = name.isEmpty
                          ? 'Please enter unit name'
                          : name.length >= 50
                              ? 'Please enter up to 50 characters'
                              : null;
                    });

                    if (nameError != null) {
                      return;
                    }

                    final duplicate = _units.any(
                      (item) =>
                          item.id != unit.id &&
                          item.name.trim().toLowerCase() ==
                              name.toLowerCase(),
                    );

                    if (duplicate) {
                      _showMessage(
                        'Unit already exists',
                        isWarning: true,
                      );
                      return;
                    }

                    Navigator.pop(dialogContext);

                    await _updateUnit(
                      unit.id,
                      name,
                      status,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    minimumSize: const Size(130, 44),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: const Text(
                    'Update Unit',
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

  // ============================================================
  // UPDATE UNIT API
  // ============================================================

  Future<void> _updateUnit(
    int id,
    String name,
    bool status,
  ) async {
    try {
      final updated = await _unitApiService.updateUnit(
        id: id,
        name: name,
        status: status,
      );

      if (!mounted) return;

      setState(() {
        final index =
            _units.indexWhere((unit) => unit.id == id);

        if (index != -1) {
          _units[index] = updated;
        }
      });

      _showMessage('Unit updated successfully');
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to update unit',
        isError: true,
      );
    }
  }

  // ============================================================
  // UPDATE STATUS
  // ============================================================

  Future<void> _toggleStatus(UnitModel unit) async {
    final newStatus = !unit.status;

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
          contentPadding: const EdgeInsets.fromLTRB(
            28,
            24,
            28,
            12,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            24,
            8,
            24,
            24,
          ),
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
                  isActivating
                      ? 'Activate Unit?'
                      : 'Deactivate Unit?',
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
                      ? 'Are you sure you want to activate this unit?'
                      : 'Are you sure you want to deactivate this unit?',
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
                    onPressed: () {
                      Navigator.pop(dialogContext, false);
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(
                        double.infinity,
                        52,
                      ),
                      side: const BorderSide(
                        color: AppColors.border,
                      ),
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
                    onPressed: () {
                      Navigator.pop(dialogContext, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(
                        double.infinity,
                        52,
                      ),
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

    if (confirmed != true) {
      return;
    }

    try {
      await _unitApiService.updateUnitStatus(
        unit.id,
        newStatus,
      );

      if (!mounted) return;

      setState(() {
        final index =
            _units.indexWhere((item) => item.id == unit.id);

        if (index != -1) {
          _units[index] = UnitModel(
            id: unit.id,
            name: unit.name,
            status: newStatus,
          );
        }
      });

      _showMessage(
        newStatus
            ? 'Unit activated successfully'
            : 'Unit deactivated successfully',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to update status',
        isError: true,
      );
    }
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
      hintStyle: const TextStyle(
        fontSize: 14,
        color: AppColors.textTertiary,
      ),
      errorText: errorText,
      errorStyle: const TextStyle(
        fontSize: 12,
        color: AppColors.error,
      ),
      filled: true,
      fillColor: AppColors.inputBackground,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
    );
  }

  // ============================================================
  // DIALOG WIDTH
  // ============================================================

  double _dialogWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 360) {
      return width * 0.78;
    }

    if (width < 500) {
      return width * 0.82;
    }

    return 380;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final units = _filteredUnits;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final isSmallMobile = width < 400;
        final isMobile = width < 600;
        final isTablet = width >= 600 && width < 1000;
        final isDesktop = width >= 1000;

        final horizontalPadding =
            _horizontalPadding(context);

        final topBarHeight = isSmallMobile
            ? 60.0
            : isMobile
                ? 64.0
                : 72.0;

        final contentTopSpacing = isSmallMobile
            ? 18.0
            : isMobile
                ? 22.0
                : 28.0;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    // ======================================================
                    // TOP BAR
                    // ======================================================

                    Container(
                      height: topBarHeight,
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
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            tooltip: 'Back',
                            onPressed: () =>
                                Navigator.of(context).pop(),
                            icon: Icon(
                              Icons.arrow_back_rounded,
                              size: isSmallMobile ? 21 : 23,
                              color: AppColors.icon,
                            ),
                          ),
                          SizedBox(
                            width: isSmallMobile ? 4 : 8,
                          ),
                          Flexible(
                            child: Text(
                              'Units',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: isSmallMobile
                                    ? 17
                                    : isMobile
                                        ? 18
                                        : 19,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ======================================================
                    // CONTENT
                    // ======================================================

                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          contentTopSpacing,
                          horizontalPadding,
                          isSmallMobile ? 16 : 24,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            if (isDesktop || isTablet) ...[
                              // ==================================================
                              // WEB + TABLET: DESCRIPTION + ADD
                              // ==================================================

                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Manage your inventory units.',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color:
                                            AppColors.textSecondary,
                                        fontWeight:
                                            FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  SizedBox(
                                    width: 126,
                                    height: 42,
                                    child: ElevatedButton.icon(
                                      onPressed: _openAddDialog,
                                      icon: const Icon(
                                        Icons.add_rounded,
                                        size: 18,
                                      ),
                                      label: const Text(
                                        'Add',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                      style:
                                          ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppColors.primary,
                                        foregroundColor:
                                            AppColors.textOnPrimary,
                                        elevation: 0,
                                        padding:
                                            const EdgeInsets
                                                .symmetric(
                                          horizontal: 14,
                                        ),
                                        shape:
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(
                                                  9),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 22),

                              // ==================================================
                              // WEB + TABLET: SEARCH + STATUS
                              // ==================================================

                              Container(
                                padding:
                                    const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.border,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 46,
                                        child: TextField(
                                          controller:
                                              _searchController,
                                          textInputAction:
                                              TextInputAction.search,
                                          decoration:
                                              InputDecoration(
                                            hintText:
                                                'Search units...',
                                            hintStyle:
                                                const TextStyle(
                                              color: AppColors
                                                  .textTertiary,
                                              fontSize: 14,
                                            ),
                                            prefixIcon:
                                                const Icon(
                                              Icons.search_rounded,
                                              size: 22,
                                              color: AppColors
                                                  .textTertiary,
                                            ),
                                            suffixIcon:
                                                _searchController
                                                        .text
                                                        .isNotEmpty
                                                    ? IconButton(
                                                        padding:
                                                            EdgeInsets
                                                                .zero,
                                                        onPressed:
                                                            () {
                                                          _searchController
                                                              .clear();
                                                        },
                                                        icon:
                                                            const Icon(
                                                          Icons
                                                              .close_rounded,
                                                          size: 19,
                                                        ),
                                                      )
                                                    : null,
                                            filled: true,
                                            fillColor:
                                                AppColors.surface,
                                            contentPadding:
                                                const EdgeInsets
                                                    .symmetric(
                                              horizontal: 10,
                                              vertical: 8,
                                            ),
                                            border:
                                                OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(10),
                                              borderSide:
                                                  const BorderSide(
                                                color:
                                                    AppColors.border,
                                              ),
                                            ),
                                            enabledBorder:
                                                OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(10),
                                              borderSide:
                                                  const BorderSide(
                                                color:
                                                    AppColors.border,
                                              ),
                                            ),
                                            focusedBorder:
                                                OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(10),
                                              borderSide:
                                                  const BorderSide(
                                                color:
                                                    AppColors.primary,
                                                width: 1.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Container(
                                      padding:
                                          const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius:
                                            BorderRadius.circular(28),
                                        border: Border.all(
                                          color: AppColors.border,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize:
                                            MainAxisSize.min,
                                        children: [
                                          _buildStatusFilter(
                                            'All',
                                            compact: false,
                                          ),
                                          _buildStatusFilter(
                                            'Active',
                                            compact: false,
                                          ),
                                          _buildStatusFilter(
                                            'Inactive',
                                            compact: false,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              // ==================================================
                              // MOBILE: DESCRIPTION + SEARCH + ADD
                              // ==================================================

                              Text(
                                'Manage your inventory units.',
                                style: TextStyle(
                                  fontSize:
                                      isSmallMobile ? 13 : 15,
                                  color:
                                      AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(
                                height:
                                    isSmallMobile ? 16 : 22,
                              ),
                              _buildSearchAndAdd(
                                isMobile: isMobile,
                                isSmallMobile:
                                    isSmallMobile,
                              ),
                              SizedBox(
                                height:
                                    isSmallMobile ? 10 : 14,
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius:
                                      BorderRadius.circular(28),
                                  border: Border.all(
                                    color: AppColors.border,
                                  ),
                                ),
                                child:
                                    SingleChildScrollView(
                                  scrollDirection:
                                      Axis.horizontal,
                                  child: Row(
                                    mainAxisSize:
                                        MainAxisSize.min,
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
                                ),
                              ),
                            ],

                            SizedBox(
                              height:
                                  isSmallMobile ? 12 : 16,
                            ),

                            // ==================================================
                            // UNIT LIST
                            // ==================================================

                            Expanded(
                              child: _isLoading
                                  ? const Center(
                                      child:
                                          CircularProgressIndicator(
                                        color:
                                            AppColors.primary,
                                      ),
                                    )
                                  : units.isEmpty
                                      ? _buildEmptyState()
                                      : ListView.separated(
                                          padding:
                                              EdgeInsets.zero,
                                          itemCount: units.length,
                                          separatorBuilder:
                                              (_, __) =>
                                                  SizedBox(
                                            height:
                                                isSmallMobile
                                                    ? 8
                                                    : 10,
                                          ),
                                          itemBuilder:
                                              (context, index) {
                                            return _buildUnitCard(
                                              units[index],
                                            );
                                          },
                                        ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_message != null)
                _buildTopRightMessage(),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // RESPONSIVE SEARCH + ADD
  // ============================================================

  Widget _buildSearchAndAdd({
    required bool isMobile,
    required bool isSmallMobile,
  }) {
    final searchField = SizedBox(
      height: isMobile ? 40 : 46,
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search units...',
          hintStyle: TextStyle(
            color: AppColors.textTertiary,
            fontSize: isMobile ? 12 : 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: isMobile ? 18 : 22,
            color: AppColors.textTertiary,
          ),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        _searchController.clear();
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        size: isMobile ? 16 : 19,
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
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppColors.border,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppColors.border,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),
        ),
      ),
    );

    final addButton = SizedBox(
      width: isMobile ? 70 : 140,
      height: isMobile ? 40 : 46,
      child: ElevatedButton.icon(
        onPressed: _openAddDialog,
        style: ElevatedButton.styleFrom(
          padding:
              const EdgeInsets.symmetric(horizontal: 10),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
        ),
        icon: const Icon(
          Icons.add_rounded,
          size: 18,
        ),
        label: Text(
          'Add',
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

    return Row(
      children: [
        Expanded(child: searchField),
        SizedBox(width: isMobile ? 7 : 12),
        addButton,
      ],
    );
  }

  // ============================================================
  // RESPONSIVE PADDING
  // ============================================================

  double _horizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 400) {
      return 12;
    }

    if (width < 600) {
      return 16;
    }

    if (width < 1000) {
      return 24;
    }

    return 32;
  }

  // ============================================================
  // STATUS FILTER
  // ============================================================

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
  // RESPONSIVE UNIT CARD
  // ============================================================

  Widget _buildUnitCard(UnitModel unit) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final isSmallMobile = width < 380;
        final isMobile = width < 600;
        final isTablet =
            width >= 600 && width < 850;

        final horizontalPadding = isSmallMobile
            ? 12.0
            : isMobile
                ? 16.0
                : isTablet
                    ? 18.0
                    : 20.0;

        final verticalPadding =
            isSmallMobile ? 12.0 : 15.0;

        return Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: 78,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.borderLight,
            ),
          ),
          child: _buildResponsiveCardContent(
            unit,
            isSmallMobile: isSmallMobile,
            isMobile: isMobile,
            isTablet: isTablet,
          ),
        );
      },
    );
  }

  Widget _buildResponsiveCardContent(
    UnitModel unit, {
    required bool isSmallMobile,
    required bool isMobile,
    required bool isTablet,
  }) {
    // ==========================================================
    // MOBILE
    // ==========================================================

    if (isMobile) {
      return Row(
        children: [
          Expanded(
            child: Text(
              unit.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isSmallMobile ? 15 : 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _buildSwitch(unit),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            tooltip: 'Edit',
            onPressed: () => _openEditDialog(unit),
            icon: Icon(
              Icons.edit_outlined,
              size: isSmallMobile ? 20 : 21,
              color: AppColors.icon,
            ),
          ),
        ],
      );
    }

    // ==========================================================
    // TABLET
    // ==========================================================

    if (isTablet) {
      return Row(
        children: [
          Expanded(
            child: Text(
              unit.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _buildSwitch(unit),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            tooltip: 'Edit',
            onPressed: () => _openEditDialog(unit),
            icon: const Icon(
              Icons.edit_outlined,
              size: 21,
              color: AppColors.icon,
            ),
          ),
        ],
      );
    }

    // ==========================================================
    // DESKTOP / WEB / WINDOWS
    // ==========================================================

    return Row(
      children: [
        Expanded(
          child: Text(
            unit.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        _buildSwitch(unit),
        IconButton(
          tooltip: 'Edit',
          onPressed: () => _openEditDialog(unit),
          icon: const Icon(
            Icons.edit_outlined,
            size: 22,
            color: AppColors.icon,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SWITCH
  // ============================================================

  Widget _buildSwitch(UnitModel unit) {
    return SwitchTheme(
      data: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (_) => Colors.white,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return AppColors.primary;
            }

            return Colors.grey.withValues(alpha: 0.35);
          },
        ),
        trackOutlineColor:
            WidgetStateProperty.all(
          Colors.transparent,
        ),
      ),
      child: Switch(
        value: unit.status,
        onChanged: (_) {
          _toggleStatus(unit);
        },
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 220,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderLight,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.straighten_outlined,
                size: 50,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 14),
              const Text(
                'No units found',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Add your first unit to get started.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
