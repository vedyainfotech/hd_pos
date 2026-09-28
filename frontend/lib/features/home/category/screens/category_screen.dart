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
  final CategoryApiService _apiService = CategoryApiService();

  final TextEditingController _categoryController =
      TextEditingController();

  final TextEditingController _allotmentTimeController =
      TextEditingController();

  List<CategoryModel> _categories = [];

  bool _isLoading = true;
  bool _isSaving = false;

  int? _editingId;

  bool _formStatus = true;

  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _allotmentTimeController.dispose();
    super.dispose();
  }

  // ============================================================
  // API
  // ============================================================

  Future<void> _loadCategories() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final categories = await _apiService.getCategories(
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

  Future<void> _saveCategory() async {
    final name = _categoryController.text.trim();
    final allotmentTime = _allotmentTimeController.text.trim();

    if (name.isEmpty) {
      _showMessage(
        'Please enter category name',
        isError: true,
      );
      return;
    }

    if (allotmentTime.isEmpty) {
      _showMessage(
        'Please select allotment time',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (_editingId == null) {
        await _apiService.createCategory(
          name: name,
          allotmentTime: allotmentTime,
          status: _formStatus,
        );
      } else {
        await _apiService.updateCategory(
          id: _editingId!,
          name: name,
          allotmentTime: allotmentTime,
          status: _formStatus,
        );
      }

      if (!mounted) return;

      Navigator.of(context).pop();

      await _loadCategories();

      if (!mounted) return;

      _showMessage(
        _editingId == null
            ? 'Category added successfully'
            : 'Category updated successfully',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to save category',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _toggleStatus(CategoryModel category) async {
    try {
      await _apiService.updateCategoryStatus(
        category.id,
        !category.isActive,
      );

      await _loadCategories();

      if (!mounted) return;

      _showMessage(
        category.isActive
            ? 'Category deactivated'
            : 'Category activated',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to update category status',
        isError: true,
      );
    }
  }

  // ============================================================
  // FORM
  // ============================================================

  void _openAddPanel() {
    _editingId = null;

    _categoryController.clear();

    _allotmentTimeController.text = '23:55:00';

    _formStatus = true;

    _showCategoryPanel(
      title: 'Add Category',
      buttonText: 'Add Category',
    );
  }

  void _openEditPanel(CategoryModel category) {
    _editingId = category.id;

    _categoryController.text = category.name;

    _allotmentTimeController.text = _formatTime(
      category.allotmentTime,
    );

    _formStatus = category.isActive;

    _showCategoryPanel(
      title: 'Edit Category',
      buttonText: 'Update Category',
    );
  }

  String _formatTime(String value) {
    if (value.length >= 8) {
      return value.substring(0, 8);
    }

    return value;
  }

  Future<void> _selectAllotmentTime(BuildContext panelContext) async {
    TimeOfDay initialTime = const TimeOfDay(
      hour: 23,
      minute: 55,
    );

    final currentValue = _allotmentTimeController.text.trim();

    final parts = currentValue.split(':');

    if (parts.length >= 2) {
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);

      if (hour != null &&
          minute != null &&
          hour >= 0 &&
          hour <= 23 &&
          minute >= 0 &&
          minute <= 59) {
        initialTime = TimeOfDay(
          hour: hour,
          minute: minute,
        );
      }
    }

    final selectedTime = await showTimePicker(
      context: panelContext,
      initialTime: initialTime,
    );

    if (selectedTime == null) return;

    final hour = selectedTime.hour.toString().padLeft(2, '0');
    final minute = selectedTime.minute.toString().padLeft(2, '0');

    _allotmentTimeController.text = '$hour:$minute:00';
  }

  void _showCategoryPanel({
    required String title,
    required String buttonText,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (panelContext) {
        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 430,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22),
                bottomLeft: Radius.circular(22),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // HEADER
                    // ==================================================

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _isSaving
                              ? null
                              : () {
                                  Navigator.of(panelContext).pop();
                                },
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.icon,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Create and manage your product category.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ==================================================
                    // CATEGORY NAME
                    // ==================================================

                    const Text(
                      'Category Name',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: _categoryController,
                      autofocus: true,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: 'Enter category name',
                        hintStyle: const TextStyle(
                          color: AppColors.textTertiary,
                        ),
                        filled: true,
                        fillColor: AppColors.inputBackground,
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 15,
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

                    const SizedBox(height: 22),

                    // ==================================================
                    // ALLOTMENT TIME
                    // ==================================================

                    const Text(
                      'Allotment Time',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: _allotmentTimeController,
                      readOnly: true,
                      onTap: () {
                        _selectAllotmentTime(panelContext);
                      },
                      decoration: InputDecoration(
                        hintText: 'Select allotment time',
                        hintStyle: const TextStyle(
                          color: AppColors.textTertiary,
                        ),
                        filled: true,
                        fillColor: AppColors.inputBackground,
                        suffixIcon: const Icon(
                          Icons.access_time_outlined,
                          color: AppColors.icon,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 15,
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

                    const SizedBox(height: 22),

                    // ==================================================
                    // STATUS
                    // ==================================================

                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
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
                          Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: _formStatus
                                  ? AppColors.active
                                  : AppColors.inactive,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _formStatus
                                  ? 'Active'
                                  : 'Inactive',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _formStatus
                                    ? AppColors.active
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          Switch(
                            value: _formStatus,
                            activeThumbColor: AppColors.primary,
                            onChanged: _isSaving
                                ? null
                                : (value) {
                                    setState(() {
                                      _formStatus = value;
                                    });
                                  },
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // ==================================================
                    // BUTTONS
                    // ==================================================

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSaving
                                ? null
                                : () {
                                    Navigator.of(panelContext).pop();
                                  },
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(
                                double.infinity,
                                48,
                              ),
                              side: const BorderSide(
                                color: AppColors.border,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: AppColors.icon,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                _isSaving ? null : _saveCategory,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppColors.primary,
                              foregroundColor:
                                  AppColors.textOnPrimary,
                              minimumSize: const Size(
                                double.infinity,
                                48,
                              ),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10),
                              ),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors
                                          .textOnPrimary,
                                    ),
                                  )
                                : Text(buttonText),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // FILTER
  // ============================================================

  List<CategoryModel> get _filteredCategories {
    if (_statusFilter == 'Active') {
      return _categories
          .where((category) => category.isActive)
          .toList();
    }

    if (_statusFilter == 'Inactive') {
      return _categories
          .where((category) => !category.isActive)
          .toList();
    }

    return _categories;
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            isError ? AppColors.error : null,
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
        child: Column(
          children: [
            _buildTopBar(),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        32,
                        28,
                        32,
                        40,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                        children: [
                          _buildActionRow(),

                          const SizedBox(height: 20),

                          _buildCategoryTable(),
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
  // TOP BAR
  // ============================================================

  Widget _buildTopBar() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(
        horizontal: 32,
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
            tooltip: 'Back',
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.icon,
            ),
          ),

          const SizedBox(width: 8),

          const Text(
            'Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTERS + ADD CATEGORY
  // ============================================================

  Widget _buildActionRow() {
    return Row(
      children: [
        _buildFilterButton(
          label: 'All',
          value: 'All',
        ),

        const SizedBox(width: 12),

        _buildFilterButton(
          label: 'Active',
          value: 'Active',
        ),

        const SizedBox(width: 12),

        _buildFilterButton(
          label: 'Inactive',
          value: 'Inactive',
        ),

        const Spacer(),

        ElevatedButton.icon(
          onPressed: _openAddPanel,
          icon: const Icon(
            Icons.add,
            size: 18,
          ),
          label: const Text(
            'Add Category',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FILTER BUTTON
  // ============================================================

  Widget _buildFilterButton({
    required String label,
    required String value,
  }) {
    final isSelected = _statusFilter == value;

    return OutlinedButton(
      onPressed: () {
        setState(() {
          _statusFilter = value;
        });
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected
            ? AppColors.primary
            : AppColors.surface,
        foregroundColor: isSelected
            ? AppColors.textOnPrimary
            : AppColors.textPrimary,
        side: BorderSide(
          color: isSelected
              ? AppColors.primary
              : AppColors.border,
          width: 1.2,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY TABLE
  // ============================================================

  Widget _buildCategoryTable() {
    final categories = _filteredCategories;

    if (categories.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 70,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.grid_view_outlined,
              size: 42,
              color: Color(0xFFCBD5E1),
            ),

            const SizedBox(height: 12),

            const Text(
              'No categories found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),

            const SizedBox(height: 5),

            Text(
              _statusFilter == 'All'
                  ? 'Add your first category to get started.'
                  : 'No $_statusFilter categories found.',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          _buildTableHeader(),

          const Divider(height: 1),

          ...List.generate(
            categories.length,
            (index) {
              final category = categories[index];

              return Column(
                children: [
                  _buildCategoryRow(category),

                  if (index != categories.length - 1)
                    const Divider(
                      height: 1,
                      color: AppColors.borderLight,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABLE HEADER
  // ============================================================

  Widget _buildTableHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 15,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              'CATEGORY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.icon,
                letterSpacing: 0.5,
              ),
            ),
          ),

          Expanded(
            flex: 2,
            child: Text(
              'ALLOTMENT TIME',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.icon,
                letterSpacing: 0.5,
              ),
            ),
          ),

          SizedBox(
            width: 190,
            child: Text(
              'STATUS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.icon,
                letterSpacing: 0.5,
              ),
            ),
          ),

          SizedBox(
            width: 70,
            child: Text(
              'ACTION',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.icon,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORY ROW
  // ============================================================

  Widget _buildCategoryRow(
    CategoryModel category,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 15,
      ),
      child: Row(
        children: [
          // CATEGORY
          Expanded(
            flex: 4,
            child: Text(
              category.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // ALLOTMENT TIME
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_outlined,
                  size: 16,
                  color: AppColors.icon,
                ),
                const SizedBox(width: 7),
                Text(
                  _formatTime(category.allotmentTime),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // STATUS
          SizedBox(
            width: 190,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: category.isActive
                        ? AppColors.active
                        : AppColors.inactive,
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 8),

                Text(
                  category.isActive
                      ? 'Active'
                      : 'Inactive',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: category.isActive
                        ? AppColors.active
                        : AppColors.textSecondary,
                  ),
                ),

                const SizedBox(width: 8),

                Transform.scale(
                  scale: 0.72,
                  child: Switch(
                    value: category.isActive,
                    activeThumbColor:
                        AppColors.primary,
                    onChanged: (_) {
                      _toggleStatus(category);
                    },
                  ),
                ),
              ],
            ),
          ),

          // ACTION
          SizedBox(
            width: 70,
            child: IconButton(
              tooltip: 'Edit',
              onPressed: () {
                _openEditPanel(category);
              },
              icon: const Icon(
                Icons.edit_outlined,
                size: 19,
                color: AppColors.icon,
              ),
            ),
          ),
        ],
      ),
    );
  }
}