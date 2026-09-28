import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../models/category_model.dart';
import '../services/category_api_service.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _categoryController =
      TextEditingController();

  final TextEditingController _searchController =
      TextEditingController();

  final CategoryApiService _categoryApiService =
      CategoryApiService();

  List<CategoryModel> _categories = [];

  String _statusFilter = 'All';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD CATEGORIES
  // ============================================================

  Future<void> _loadCategories() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final categories =
          await _categoryApiService.getCategories(
        includeInactive: true,
      );

      if (!mounted) return;

      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Failed to load categories',
        isError: true,
      );
    }
  }

  // ============================================================
  // FILTER
  // ============================================================

  List<CategoryModel> get _filteredCategories {
    final search =
        _searchController.text.trim().toLowerCase();

    return _categories.where((category) {
      final matchesSearch =
          category.name.toLowerCase().contains(search);

      final matchesStatus =
          _statusFilter == 'All' ||
          (_statusFilter == 'Active' &&
              category.isActive) ||
          (_statusFilter == 'Inactive' &&
              !category.isActive);

      return matchesSearch && matchesStatus;
    }).toList();
  }

  // ============================================================
  // ADD CATEGORY
  // ============================================================

  Future<void> _openAddDialog() async {
    final controller = TextEditingController();

    String selectedAllotmentTime = '';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              titlePadding: const EdgeInsets.fromLTRB(
                24,
                22,
                18,
                8,
              ),
              contentPadding: const EdgeInsets.fromLTRB(
                24,
                8,
                24,
                10,
              ),
              actionsPadding: const EdgeInsets.fromLTRB(
                24,
                8,
                24,
                20,
              ),
              title: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Add Category',
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
              content: SizedBox(
                width: _dialogWidth(context),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Category Name',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: controller,
                      autofocus: true,
                      textCapitalization:
                          TextCapitalization.words,
                      decoration: _inputDecoration(
                        hintText: 'Enter category name',
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Allowance Time',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    InkWell(
                      borderRadius:
                          BorderRadius.circular(10),
                      onTap: () async {
                        final picked =
                            await _showTimePicker(
                          selectedAllotmentTime,
                        );

                        if (picked != null) {
                          setDialogState(() {
                            selectedAllotmentTime =
                                picked;
                          });
                        }
                      },
                      child: _timeField(
                        selectedAllotmentTime,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize:
                        const Size(100, 44),
                    side: const BorderSide(
                      color: AppColors.border,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(9),
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

                    if (name.isEmpty) {
                      _showMessage(
                        'Please enter category name',
                        isError: true,
                      );
                      return;
                    }

                    if (selectedAllotmentTime
                        .isEmpty) {
                      _showMessage(
                        'Please select allowance time',
                        isError: true,
                      );
                      return;
                    }

                    Navigator.pop(dialogContext);

                    await _createCategory(
                      name,
                      selectedAllotmentTime,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.primary,
                    foregroundColor:
                        AppColors.textOnPrimary,
                    minimumSize:
                        const Size(100, 44),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(9),
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

    controller.dispose();
  }

  // ============================================================
  // CREATE CATEGORY API
  // ============================================================

  Future<void> _createCategory(
    String name,
    String allotmentTime,
  ) async {
    try {
      final category =
          await _categoryApiService.createCategory(
        name: name,
        allotmentTime: allotmentTime,
        status: true,
      );

      if (!mounted) return;

      setState(() {
        _categories.add(category);
      });

      _showMessage(
        'Category added successfully',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to add category',
        isError: true,
      );
    }
  }

  // ============================================================
  // EDIT CATEGORY
  // ============================================================

  Future<void> _openEditDialog(
    CategoryModel category,
  ) async {
    final controller =
        TextEditingController(text: category.name);

    String selectedAllotmentTime =
        category.allotmentTime;

    bool isActive = category.isActive;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              titlePadding: const EdgeInsets.fromLTRB(
                24,
                22,
                18,
                8,
              ),
              contentPadding: const EdgeInsets.fromLTRB(
                24,
                8,
                24,
                10,
              ),
              actionsPadding: const EdgeInsets.fromLTRB(
                24,
                8,
                24,
                20,
              ),
              title: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Update Category',
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
              content: SizedBox(
                width: _dialogWidth(context),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Category Name',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: controller,
                      autofocus: true,
                      textCapitalization:
                          TextCapitalization.words,
                      decoration: _inputDecoration(
                        hintText: 'Enter category name',
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Allowance Time',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    InkWell(
                      borderRadius:
                          BorderRadius.circular(10),
                      onTap: () async {
                        final picked =
                            await _showTimePicker(
                          selectedAllotmentTime,
                        );

                        if (picked != null) {
                          setDialogState(() {
                            selectedAllotmentTime =
                                picked;
                          });
                        }
                      },
                      child: _timeField(
                        selectedAllotmentTime,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // STATUS
                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color:
                            AppColors.inputBackground,
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
                                    color: AppColors
                                        .textPrimary,
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
                                    return AppColors
                                        .primary;
                                  }

                                  return Colors.grey
                                      .withValues(
                                    alpha: 0.35,
                                  );
                                },
                              ),
                              trackOutlineColor:
                                  WidgetStateProperty
                                      .all(
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
              actions: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize:
                        const Size(100, 44),
                    side: const BorderSide(
                      color: AppColors.border,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(9),
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

                    if (name.isEmpty) {
                      _showMessage(
                        'Please enter category name',
                        isError: true,
                      );
                      return;
                    }

                    if (selectedAllotmentTime
                        .isEmpty) {
                      _showMessage(
                        'Please select allowance time',
                        isError: true,
                      );
                      return;
                    }

                    Navigator.pop(dialogContext);

                    await _updateCategory(
                      category.id,
                      name,
                      selectedAllotmentTime,
                      isActive,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.primary,
                    foregroundColor:
                        AppColors.textOnPrimary,
                    minimumSize:
                        const Size(130, 44),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(9),
                    ),
                  ),
                  child: const Text(
                    'Update Category',
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

    controller.dispose();
  }

  // ============================================================
  // UPDATE CATEGORY API
  // ============================================================

  Future<void> _updateCategory(
    int id,
    String name,
    String allotmentTime,
    bool status,
  ) async {
    try {
      final updated =
          await _categoryApiService.updateCategory(
        id: id,
        name: name,
        allotmentTime: allotmentTime,
        status: status,
      );

      if (!mounted) return;

      setState(() {
        final index = _categories.indexWhere(
          (category) => category.id == id,
        );

        if (index != -1) {
          _categories[index] = updated;
        }
      });

      _showMessage(
        'Category updated successfully',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to update category',
        isError: true,
      );
    }
  }

  // ============================================================
  // UPDATE STATUS
  // ============================================================

  Future<void> _toggleStatus(
    CategoryModel category,
  ) async {
    final newStatus = !category.isActive;

    try {
      await _categoryApiService.updateCategoryStatus(
        category.id,
        newStatus,
      );

      if (!mounted) return;

      setState(() {
        final index = _categories.indexWhere(
          (item) => item.id == category.id,
        );

        if (index != -1) {
          _categories[index] = CategoryModel(
            id: category.id,
            name: category.name,
            allotmentTime: category.allotmentTime,
            isActive: newStatus,
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
  // TIME PICKER
  // ============================================================

  Future<String?> _showTimePicker(
    String currentTime,
  ) async {
    final parsed = _parseTime(currentTime);

    int selectedHour = parsed.hour;
    int selectedMinute = parsed.minute;
    int selectedPeriod = parsed.period;

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final selectedTime =
                _formatTime(
              selectedHour,
              selectedMinute,
              selectedPeriod,
            );

            return SafeArea(
              child: Container(
                height: 500,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 14),

                    Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Select Allowance Time',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      selectedTime,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildTimeWheel(
                              label: 'Hour',
                              itemCount: 12,
                              selectedIndex:
                                  selectedHour - 1,
                              onChanged: (index) {
                                setSheetState(() {
                                  selectedHour =
                                      index + 1;
                                });
                              },
                              itemBuilder: (index) {
                                return (index + 1)
                                    .toString()
                                    .padLeft(2, '0');
                              },
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: _buildTimeWheel(
                              label: 'Minute',
                              itemCount: 60,
                              selectedIndex:
                                  selectedMinute,
                              onChanged: (index) {
                                setSheetState(() {
                                  selectedMinute =
                                      index;
                                });
                              },
                              itemBuilder: (index) {
                                return index
                                    .toString()
                                    .padLeft(2, '0');
                              },
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: _buildTimeWheel(
                              label: 'Period',
                              itemCount: 2,
                              selectedIndex:
                                  selectedPeriod,
                              onChanged: (index) {
                                setSheetState(() {
                                  selectedPeriod =
                                      index;
                                });
                              },
                              itemBuilder: (index) {
                                return index == 0
                                    ? 'AM'
                                    : 'PM';
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(
                        20,
                        8,
                        20,
                        20,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(
                              sheetContext,
                              selectedTime,
                            );
                          },
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors.primary,
                            foregroundColor:
                                AppColors.textOnPrimary,
                            elevation: 0,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                10,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Done',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // TIME WHEEL
  // ============================================================

  Widget _buildTimeWheel({
    required String label,
    required int itemCount,
    required int selectedIndex,
    required ValueChanged<int> onChanged,
    required String Function(int index) itemBuilder,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 8),

        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius:
                  BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: ListWheelScrollView.useDelegate(
              itemExtent: 52,
              diameterRatio: 1.8,
              perspective: 0.002,
              physics:
                  const FixedExtentScrollPhysics(),
              controller:
                  FixedExtentScrollController(
                initialItem: selectedIndex,
              ),
              onSelectedItemChanged: onChanged,
              childDelegate:
                  ListWheelChildBuilderDelegate(
                childCount: itemCount,
                builder: (context, index) {
                  final isSelected =
                      index == selectedIndex;

                  return Center(
                    child: Text(
                      itemBuilder(index),
                      style: TextStyle(
                        fontSize:
                            isSelected ? 19 : 16,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors
                                .textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PARSE TIME
  // ============================================================

  _ParsedTime _parseTime(String value) {
    if (value.trim().isEmpty) {
      return const _ParsedTime(
        hour: 12,
        minute: 0,
        period: 0,
      );
    }

    try {
      final parts = value.trim().split(' ');

      final timePart = parts[0];

      final period =
          parts.length > 1 &&
                  parts[1].toUpperCase() == 'PM'
              ? 1
              : 0;

      final timeParts =
          timePart.split(':');

      final hour =
          int.parse(timeParts[0]);

      final minute =
          int.parse(timeParts[1]);

      return _ParsedTime(
        hour: hour.clamp(1, 12),
        minute: minute.clamp(0, 59),
        period: period,
      );
    } catch (_) {
      return const _ParsedTime(
        hour: 12,
        minute: 0,
        period: 0,
      );
    }
  }

  // ============================================================
  // FORMAT TIME
  // ============================================================

  String _formatTime(
    int hour,
    int minute,
    int period,
  ) {
    final hourText =
        hour.toString().padLeft(2, '0');

    final minuteText =
        minute.toString().padLeft(2, '0');

    final periodText =
        period == 0 ? 'AM' : 'PM';

    return '$hourText:$minuteText $periodText';
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
      fillColor: AppColors.inputBackground,
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
    );
  }

  // ============================================================
  // TIME FIELD
  // ============================================================

  Widget _timeField(String value) {
    final hasValue = value.isNotEmpty;

    return Container(
      width: double.infinity,
      height: 52,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 15,
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
          Text(
            hasValue ? value : '--:-- --',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: hasValue
                  ? AppColors.textPrimary
                  : AppColors.textTertiary,
            ),
          ),

          const Spacer(),

          const Icon(
            Icons.access_time_rounded,
            size: 21,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DIALOG WIDTH
  // ============================================================

  double _dialogWidth(BuildContext context) {
    final width =
        MediaQuery.of(context).size.width;

    if (width < 500) {
      return width * 0.82;
    }

    return 380;
  }

  // ============================================================
  // MESSAGE
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
            fontSize: 14,
          ),
        ),
        behavior:
            SnackBarBehavior.floating,
        backgroundColor:
            isError
                ? AppColors.error
                : null,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final categories =
        _filteredCategories;

    return Scaffold(
      backgroundColor:
          AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ========================================================
            // TOP BAR
            // ========================================================

            Container(
              height: 72,
              padding:
                  EdgeInsets.symmetric(
                horizontal:
                    _horizontalPadding(
                  context,
                ),
              ),
              decoration:
                  const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  bottom: BorderSide(
                    color:
                        AppColors.borderLight,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () =>
                        Navigator.of(
                          context,
                        ).pop(),
                    icon:
                        const Icon(
                      Icons
                          .arrow_back_rounded,
                      size: 23,
                      color:
                          AppColors.icon,
                    ),
                  ),

                  const SizedBox(width: 8),

                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight:
                          FontWeight.w700,
                      color:
                          AppColors
                              .textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // ========================================================
            // CONTENT
            // ========================================================

            Expanded(
              child: Padding(
                padding:
                    EdgeInsets.fromLTRB(
                  _horizontalPadding(
                    context,
                  ),
                  28,
                  _horizontalPadding(
                    context,
                  ),
                  24,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Manage your product categories.',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors
                            .textSecondary,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ==================================================
                    // SEARCH + ADD
                    // ==================================================

                    LayoutBuilder(
                      builder:
                          (
                        context,
                        constraints,
                      ) {
                        final isSmall =
                            constraints.maxWidth <
                                600;

                        final searchField =
                            TextField(
                          controller:
                              _searchController,
                          decoration:
                              InputDecoration(
                            hintText:
                                'Search categories...',
                            hintStyle:
                                const TextStyle(
                              color: AppColors
                                  .textTertiary,
                              fontSize: 14,
                            ),
                            prefixIcon:
                                const Icon(
                              Icons
                                  .search_rounded,
                              size: 22,
                              color: AppColors
                                  .textTertiary,
                            ),
                            suffixIcon:
                                _searchController
                                        .text
                                        .isNotEmpty
                                    ? IconButton(
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
                              vertical: 14,
                            ),
                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                10,
                              ),
                              borderSide:
                                  const BorderSide(
                                color: AppColors
                                    .border,
                              ),
                            ),
                            enabledBorder:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                10,
                              ),
                              borderSide:
                                  const BorderSide(
                                color: AppColors
                                    .border,
                              ),
                            ),
                            focusedBorder:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                10,
                              ),
                              borderSide:
                                  const BorderSide(
                                color: AppColors
                                    .primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                        );

                        final addButton =
                            SizedBox(
                          width:
                              isSmall
                                  ? double.infinity
                                  : 180,
                          height: 46,
                          child:
                              ElevatedButton
                                  .icon(
                            onPressed:
                                _openAddDialog,
                            icon:
                                const Icon(
                              Icons
                                  .add_rounded,
                              size: 19,
                            ),
                            label:
                                const Text(
                              'Add Category',
                              style:
                                  TextStyle(
                                fontSize: 13,
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  AppColors
                                      .primary,
                              foregroundColor:
                                  AppColors
                                      .textOnPrimary,
                              elevation: 0,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  10,
                                ),
                              ),
                            ),
                          ),
                        );

                        if (isSmall) {
                          return Column(
                            children: [
                              searchField,
                              const SizedBox(
                                height: 10,
                              ),
                              addButton,
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(
                              child:
                                  searchField,
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            addButton,
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    // ==================================================
                    // STATUS FILTER
                    // ==================================================

                    SingleChildScrollView(
                      scrollDirection:
                          Axis.horizontal,
                      child: Row(
                        children: [
                          _buildStatusFilter(
                            'All',
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          _buildStatusFilter(
                            'Active',
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          _buildStatusFilter(
                            'Inactive',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // CATEGORY LIST
                    // ==================================================

                    Expanded(
                      child: _isLoading
                          ? const Center(
                              child:
                                  CircularProgressIndicator(
                                color:
                                    AppColors
                                        .primary,
                              ),
                            )
                          : categories.isEmpty
                              ? _buildEmptyState()
                              : ListView.separated(
                                  padding:
                                      EdgeInsets
                                          .zero,
                                  itemCount:
                                      categories
                                          .length,
                                  separatorBuilder:
                                      (
                                    _,
                                    __,
                                  ) =>
                                          const SizedBox(
                                    height: 10,
                                  ),
                                  itemBuilder:
                                      (
                                    context,
                                    index,
                                  ) {
                                    return _buildCategoryCard(
                                      categories[
                                          index],
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
    );
  }

  // ============================================================
  // RESPONSIVE PADDING
  // ============================================================

  double _horizontalPadding(
    BuildContext context,
  ) {
    final width =
        MediaQuery.of(context).size.width;

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
    String status,
  ) {
    final isSelected =
        _statusFilter == status;

    return ChoiceChip(
      showCheckmark: false,
      label: Text(
        status,
        style: const TextStyle(
          fontSize: 13,
        ),
      ),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _statusFilter = status;
        });
      },
      selectedColor:
          AppColors.primary.withValues(
        alpha: 0.12,
      ),
      backgroundColor:
          AppColors.surface,
      labelStyle: TextStyle(
        color: isSelected
            ? AppColors.primary
            : AppColors.textSecondary,
        fontWeight:
            FontWeight.w600,
      ),
      side: BorderSide(
        color: isSelected
            ? AppColors.primary
            : AppColors.border,
      ),
    );
  }

  // ============================================================
  // CATEGORY CARD
  // ============================================================

  Widget _buildCategoryCard(
    CategoryModel category,
  ) {
    return Container(
      width: double.infinity,
      constraints:
          const BoxConstraints(
        minHeight: 78,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderLight,
        ),
      ),
      child: LayoutBuilder(
        builder:
            (context, constraints) {
          final isSmall =
              constraints.maxWidth < 500;

          if (isSmall) {
            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        category.name,
                        style:
                            const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w700,
                          color: AppColors
                              .textPrimary,
                        ),
                      ),
                    ),

                    IconButton(
                      tooltip: 'Edit',
                      onPressed: () =>
                          _openEditDialog(
                        category,
                      ),
                      icon:
                          const Icon(
                        Icons
                            .edit_outlined,
                        size: 21,
                        color:
                            AppColors.icon,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  'Allowance Time: ${category.allotmentTime}',
                  style:
                      const TextStyle(
                    fontSize: 13,
                    color: AppColors
                        .textSecondary,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Text(
                      category.isActive
                          ? 'Active'
                          : 'Inactive',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w600,
                        color: category
                                .isActive
                            ? AppColors
                                .active
                            : AppColors
                                .textSecondary,
                      ),
                    ),

                    const SizedBox(
                      width: 5,
                    ),

                    _buildSwitch(
                      category,
                    ),
                  ],
                ),
              ],
            );
          }

          // ==========================================================
          // DESKTOP / WEB / WINDOWS
          // ALLOWANCE TIME UNDER CATEGORY NAME
          // ==========================================================

          return Row(
            children: [
              // CATEGORY NAME + ALLOWANCE TIME
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style:
                          const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w700,
                        color: AppColors
                            .textPrimary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Allowance Time: ${category.allotmentTime}',
                      style:
                          const TextStyle(
                        fontSize: 13,
                        color: AppColors
                            .textSecondary,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 24),

              // STATUS
              Text(
                category.isActive
                    ? 'Active'
                    : 'Inactive',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w600,
                  color: category
                          .isActive
                      ? AppColors.active
                      : AppColors
                          .textSecondary,
                ),
              ),

              const SizedBox(width: 5),

              // SWITCH
              _buildSwitch(category),

              // EDIT
              IconButton(
                tooltip: 'Edit',
                onPressed: () =>
                    _openEditDialog(
                  category,
                ),
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 22,
                  color: AppColors.icon,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // SWITCH
  // ============================================================

  Widget _buildSwitch(
    CategoryModel category,
  ) {
    return SwitchTheme(
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
        value: category.isActive,
        onChanged: (_) {
          _toggleStatus(category);
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
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderLight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.grid_view_outlined,
              size: 50,
              color:
                  AppColors.textTertiary,
            ),

            const SizedBox(height: 14),

            const Text(
              'No categories found',
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.w600,
                color:
                    AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Add your first category to get started.',
              style: TextStyle(
                fontSize: 13,
                color:
                    AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PARSED TIME CLASS
// ============================================================

class _ParsedTime {
  final int hour;
  final int minute;
  final int period;

  const _ParsedTime({
    required this.hour,
    required this.minute,
    required this.period,
  });
}