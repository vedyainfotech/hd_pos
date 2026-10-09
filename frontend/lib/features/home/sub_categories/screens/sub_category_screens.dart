import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

import '../../category/models/category_model.dart';

import '../../category/services/category_api_service.dart';

import '../models/sub_category_model.dart';

import '../services/sub_category_services.dart';

class SubCategoriesScreen extends StatefulWidget {
  const SubCategoriesScreen({super.key});

  @override
  State<SubCategoriesScreen> createState() => _SubCategoriesScreenState();
}

class _SubCategoriesScreenState extends State<SubCategoriesScreen> {
  final CategoryApiService _categoryApiService = CategoryApiService();

  final SubCategoryService _subCategoryService = SubCategoryService();

  final TextEditingController _searchController = TextEditingController();

  List<CategoryModel> _categories = [];

  List<SubCategoryModel> _subCategories = [];

  int? _selectedCategoryId;

  String _statusFilter = 'All';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);

    _loadData();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();

    super.dispose();
  }

  // ============================================================

  // LOAD DATA

  // ============================================================

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        _categoryApiService.getCategories(includeInactive: true),

        _subCategoryService.getSubCategories(),
      ]);

      final categories = results[0] as List<CategoryModel>;

      final subCategories = results[1] as List<SubCategoryModel>;

      if (!mounted) return;

      setState(() {
        _categories = categories;

        _subCategories = subCategories;

        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showSnackBar('Failed to load subcategories', isError: true);
    }
  }

  // ============================================================

  // SEARCH

  // ============================================================

  void _onSearchChanged() {
    setState(() {});
  }

  // ============================================================

  // FILTERED SUBCATEGORIES

  // ============================================================

  List<SubCategoryModel> get _filteredSubCategories {
    final searchText = _searchController.text.trim().toLowerCase();

    return _subCategories.where((subCategory) {
      final matchesCategory =
          _selectedCategoryId == null ||
          subCategory.categoryId == _selectedCategoryId;

      final matchesStatus =
          _statusFilter == 'All' ||
          (_statusFilter == 'Active' && subCategory.isActive) ||
          (_statusFilter == 'Inactive' && !subCategory.isActive);

      final matchesSearch =
          searchText.isEmpty ||
          subCategory.name.toLowerCase().contains(searchText);

      return matchesCategory && matchesStatus && matchesSearch;
    }).toList();
  }

  // ============================================================

  // CATEGORY NAME

  // ============================================================

  String _categoryName(int categoryId) {
    final category = _categories.cast<CategoryModel?>().firstWhere(
      (item) => item?.id == categoryId,

      orElse: () => null,
    );

    return category?.name ?? 'Unknown Category';
  }

  // ============================================================

  // STATUS UPDATE

  // ============================================================

  Future<void> _toggleStatus(SubCategoryModel subCategory) async {
    final newStatus = !subCategory.isActive;

    final confirmed = await _showStatusConfirmation(newStatus);

    if (!confirmed || !mounted) return;

    try {
      final updated = await _subCategoryService.updateSubCategoryStatus(
        subCategory.id,
        newStatus,
      );

      if (!mounted) return;

      setState(() {
        final index = _subCategories.indexWhere(
          (item) => item.id == subCategory.id,
        );

        if (index != -1) {
          _subCategories[index] = updated;
        }
      });

      _showSnackBar(
        newStatus ? 'Subcategory activated' : 'Subcategory deactivated',
      );
    } catch (error) {
      if (!mounted) return;

      _showSnackBar('Failed to update status: $error', isError: true);
    }
  }

  Future<bool> _showStatusConfirmation(bool activate) async {
    final action = activate ? 'Activate' : 'Deactivate';
    final actionLower = activate ? 'activate' : 'deactivate';

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 545),
            child: Container(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 26),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      color: activate
                          ? const Color(0xFFEAF5E8)
                          : AppColors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      activate
                          ? Icons.check_rounded
                          : Icons.priority_high_rounded,
                      size: 42,
                      color: activate
                          ? const Color(0xFF2E7D32)
                          : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '$action Sub Category?',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Are you sure you want to $actionLower this sub category?',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.45,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                            foregroundColor: AppColors.textPrimary,
                            backgroundColor: AppColors.surface,
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            action,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    return result ?? false;
  }

  // ============================================================

  // ADD / EDIT

  // ============================================================

  Future<void> _openAddPanel() async {
    await _openSubCategoryPanel();
  }

  Future<void> _openEditPanel(SubCategoryModel subCategory) async {
    await _openSubCategoryPanel(subCategory: subCategory);
  }

  Future<void> _openSubCategoryPanel({SubCategoryModel? subCategory}) async {
    final result = await showDialog<SubCategoryModel>(
      context: context,

      barrierDismissible: true,

      barrierColor: Colors.black.withValues(alpha: 0.45),

      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,

          elevation: 0,

          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,

            vertical: 24,
          ),

          child: _SubCategoryFormSheet(
            categories: _categories,

            subCategory: subCategory,
          ),
        );
      },
    );

    if (result == null) return;

    try {
      if (subCategory == null) {
        final created = await _subCategoryService.createSubCategory(
          categoryId: result.categoryId,

          name: result.name,

          price: result.price,
        );

        if (!mounted) return;

        setState(() {
          _subCategories.add(created);
        });

        _showSnackBar('Subcategory created successfully');
      } else {
        final updated = await _subCategoryService.updateSubCategory(result);

        if (!mounted) return;

        setState(() {
          final index = _subCategories.indexWhere(
            (item) => item.id == updated.id,
          );

          if (index != -1) {
            _subCategories[index] = updated;
          }
        });

        _showSnackBar('Subcategory updated successfully');
      }
    } catch (error) {
      _showSnackBar('Operation failed: $error', isError: true);
    }
  }

  // ============================================================

  // SNACKBAR

  // ============================================================

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    final overlay = Overlay.of(context);

    final backgroundColor = isError
        ? const Color(0xFFFFE5E5)
        : const Color(0xFFE5F7E9);

    final iconColor = isError
        ? const Color(0xFFD32F2F)
        : const Color(0xFF1E9E45);

    final icon = isError ? Icons.close_rounded : Icons.check_rounded;

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 12,

          right: 16,

          child: Material(
            color: Colors.transparent,

            child: Container(
              constraints: const BoxConstraints(maxWidth: 320),

              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),

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
                  Icon(icon, size: 22, color: iconColor),

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

    Future.delayed(const Duration(seconds: 3), () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }

  // ============================================================

  // BUILD

  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text('Sub Categories')),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  // ============================================================

  // CONTENT

  // ============================================================

  Widget _buildContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 1200;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 16 : 28,
            isMobile ? 16 : 28,
            isMobile ? 16 : 28,
            8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPageHeader(isMobile, constraints.maxWidth >= 1200),
              const SizedBox(height: 24),
              _buildFilters(isMobile, isTablet),
              const SizedBox(height: 20),

              // Fixed column heading.
              _buildSubCategoryColumnHeader(isMobile),
              const SizedBox(height: 10),

              // Only the subcategory cards scroll.
              Expanded(
                child: _buildSubCategoryCards(isMobile, includeHeader: false),
              ),
            ],
          ),
        );
      },
    );
  }

  // PAGE HEADER

  // ============================================================

  Widget _buildPageHeader(bool isCompact, bool isDesktop) {
    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const SizedBox(height: 6),

          const Text(
            'Manage your menu subcategories',

            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              SizedBox(height: 6),

              Text(
                'Manage your menu subcategories',

                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),

        _buildAddButton(isDesktop),
      ],
    );
  }

  // ============================================================

  // ADD BUTTON

  // ============================================================

  Widget _buildAddButton(bool isDesktop) {
    return ElevatedButton.icon(
      onPressed: _openAddPanel,

      icon: const Icon(Icons.add, size: 19),

      label: const Text('Add'),

      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 28 : 12,

          vertical: isDesktop ? 20 : 14,
        ),

        backgroundColor: AppColors.primary,

        foregroundColor: AppColors.textOnPrimary,

        elevation: 0,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ============================================================

  // FILTERS

  // ============================================================

  Widget _buildFilters(bool isMobile, bool isTablet) {
    return SizedBox(
      width: double.infinity,

      child: Card(
        elevation: 0,

        color: AppColors.surface,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),

          side: const BorderSide(color: AppColors.border),
        ),

        child: Padding(
          padding: const EdgeInsets.all(18),

          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,

                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildSearchField()),

                        const SizedBox(width: 10),

                        SizedBox(
                          width: 48,

                          height: 48,

                          child: ElevatedButton(
                            onPressed: _openAddPanel,

                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,

                              backgroundColor: AppColors.primary,

                              foregroundColor: AppColors.textOnPrimary,

                              elevation: 0,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),

                            child: const Icon(Icons.add, size: 20),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    _buildCategoryDropdown(),

                    const SizedBox(height: 14),

                    Align(
                      alignment: Alignment.centerLeft,

                      child: _buildStatusFilter(isMobile),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: _buildSearchField()),

                    const SizedBox(width: 14),

                    SizedBox(
                      width: isTablet ? 210 : 250,

                      child: _buildCategoryDropdown(),
                    ),

                    const SizedBox(width: 14),

                    SizedBox(
                      width: isTablet ? 250 : 290,

                      child: _buildStatusFilter(isMobile),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ============================================================

  // CATEGORY DROPDOWN

  // ============================================================

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<int?>(
      initialValue: _selectedCategoryId,

      decoration: const InputDecoration(labelText: 'Category'),

      items: [
        const DropdownMenuItem<int?>(
          value: null,

          child: Text('All Categories'),
        ),

        ..._categories.map(
          (category) => DropdownMenuItem<int?>(
            value: category.id,

            child: Text(category.name, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],

      onChanged: (value) {
        setState(() {
          _selectedCategoryId = value;
        });
      },
    );
  }

  // ============================================================

  // SEARCH

  // ============================================================

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,

      decoration: InputDecoration(
        hintText: 'Search subcategories...',

        prefixIcon: const Icon(Icons.search),

        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                },

                icon: const Icon(Icons.clear),
              )
            : null,
      ),
    );
  }

  // ============================================================

  // STATUS FILTER

  // ============================================================

  Widget _buildStatusFilter(bool isMobile) {
    const options = <String>['All', 'Active', 'Inactive'];

    return Container(
      height: 48,

      width: isMobile ? 190 : null,

      padding: const EdgeInsets.all(3),

      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,

        border: Border.all(color: AppColors.border),

        borderRadius: BorderRadius.circular(28),
      ),

      child: Row(
        children: options.map((option) {
          final isSelected = _statusFilter == option;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),

              child: Material(
                color: Colors.transparent,

                child: InkWell(
                  borderRadius: BorderRadius.circular(22),

                  onTap: () {
                    if (_statusFilter == option) {
                      return;
                    }

                    setState(() {
                      _statusFilter = option;
                    });
                  },

                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),

                    curve: Curves.easeOutCubic,

                    height: double.infinity,

                    alignment: Alignment.center,

                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primarySoft
                          : Colors.transparent,

                      borderRadius: BorderRadius.circular(22),
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Text(
                          option,

                          maxLines: 1,

                          softWrap: false,

                          textAlign: TextAlign.center,

                          style: TextStyle(
                            fontSize: 13,

                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w600,

                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // SUBCATEGORY CARDS
  // ============================================================

  Widget _buildSubCategoryCards(bool isMobile, {bool includeHeader = true}) {
    final items = _filteredSubCategories;

    if (items.isEmpty) {
      return _buildEmptyState();
    }

    final cards = ListView.builder(
      padding: const EdgeInsets.only(bottom: 8),
      primary: false,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildSubCategoryCard(item, isMobile: isMobile),
        );
      },
    );

    if (!includeHeader) {
      return cards;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSubCategoryColumnHeader(isMobile),
        const SizedBox(height: 10),
        Expanded(child: cards),
      ],
    );
  }

  // COLUMN HEADER
  // ============================================================

  Widget _buildSubCategoryColumnHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 14 : 22,
        vertical: isMobile ? 13 : 15,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _buildColumnHeading(
              'SUBCATEGORY',
              align: TextAlign.left,
              isMobile: isMobile,
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildColumnHeading(
              'CATEGORY',
              align: TextAlign.center,
              isMobile: isMobile,
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildColumnHeading(
              'PRICE',
              align: TextAlign.center,
              isMobile: isMobile,
            ),
          ),
          SizedBox(
            width: isMobile ? 108 : 140,
            child: _buildColumnHeading(
              'ACTION',
              align: TextAlign.right,
              isMobile: isMobile,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnHeading(
    String text, {
    required TextAlign align,
    required bool isMobile,
  }) {
    return Text(
      text,
      textAlign: align,
      style: TextStyle(
        fontSize: isMobile ? 10 : 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: AppColors.textTertiary,
      ),
    );
  }

  // ============================================================
  // SUBCATEGORY CARD
  // ============================================================

  Widget _buildSubCategoryCard(
    SubCategoryModel item, {
    required bool isMobile,
  }) {
    final categoryName = _categoryName(item.categoryId);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 14 : 22,
        vertical: isMobile ? 15 : 18,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              item.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isMobile ? 13 : 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                categoryName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '₹${item.price.toStringAsFixed(2)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(
            width: isMobile ? 108 : 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildStatusSwitch(item),
                SizedBox(width: isMobile ? 2 : 8),
                _buildEditButton(item),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSwitch(SubCategoryModel item) {
    return SwitchTheme(
      data: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((_) => Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.grey.withValues(alpha: 0.35);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      child: Switch(
        value: item.isActive,
        onChanged: (_) => _toggleStatus(item),
      ),
    );
  }

  Widget _buildEditButton(SubCategoryModel item) {
    return IconButton(
      tooltip: 'Edit',
      onPressed: () => _openEditPanel(item),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      icon: const Icon(Icons.edit_outlined, size: 19, color: Colors.black),
    );
  }

  // ============================================================

  // EMPTY STATE

  // ============================================================

  Widget _buildEmptyState() {
    return SizedBox(
      width: double.infinity,

      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 450),

        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                const Text(
                  'No subcategories found',

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 17,

                    fontWeight: FontWeight.w700,

                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  'Try changing your filters or add a new subcategory.',

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 13,

                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================

// ADD / EDIT FORM

// ================================================================

class _SubCategoryFormSheet extends StatefulWidget {
  final List<CategoryModel> categories;

  final SubCategoryModel? subCategory;

  const _SubCategoryFormSheet({required this.categories, this.subCategory});

  @override
  State<_SubCategoryFormSheet> createState() => _SubCategoryFormSheetState();
}

class _SubCategoryFormSheetState extends State<_SubCategoryFormSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;

  late final TextEditingController _priceController;

  int? _selectedCategoryId;

  late bool _isActive;

  bool get _isEditing => widget.subCategory != null;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.subCategory?.name ?? '',
    );

    _priceController = TextEditingController(
      text: widget.subCategory == null
          ? ''
          : widget.subCategory!.price.toStringAsFixed(2),
    );

    _selectedCategoryId = widget.subCategory?.categoryId;

    _isActive = widget.subCategory?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();

    _priceController.dispose();

    super.dispose();
  }

  // ============================================================

  // SUBMIT

  // ============================================================

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final categoryId = _selectedCategoryId;

    if (categoryId == null) {
      return;
    }

    final price = double.tryParse(_priceController.text.trim());

    if (price == null) {
      return;
    }

    final existing = widget.subCategory;

    final result = SubCategoryModel(
      id: existing?.id ?? 0,

      categoryId: categoryId,

      name: _nameController.text.trim(),

      price: price,

      isActive: _isActive,
    );

    Navigator.of(context).pop(result);
  }

  // ============================================================

  // BUILD FORM

  // ============================================================

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    final dialogWidth = screenWidth < 560 ? screenWidth - 32 : 500.0;

    return Material(
      color: Colors.transparent,

      child: Container(
        width: dialogWidth,

        constraints: const BoxConstraints(maxWidth: 500),

        decoration: BoxDecoration(
          color: AppColors.surface,

          borderRadius: BorderRadius.circular(22),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),

              blurRadius: 30,

              offset: const Offset(0, 12),
            ),
          ],
        ),

        child: Form(
          key: _formKey,

          child: Column(
            mainAxisSize: MainAxisSize.min,

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              _buildHeader(),

              const Divider(height: 1, color: AppColors.divider),

              _buildFormBody(),

              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================

  // FORM HEADER

  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 22, 16, 20),

      child: Row(
        children: [
          Expanded(
            child: Text(
              _isEditing ? 'Edit Subcategory' : 'Add Subcategory',

              style: const TextStyle(
                fontSize: 22,

                fontWeight: FontWeight.w700,

                color: AppColors.textPrimary,
              ),
            ),
          ),

          IconButton(
            tooltip: 'Close',

            onPressed: () {
              Navigator.of(context).pop();
            },

            icon: const Icon(Icons.close, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  // ============================================================

  // FORM BODY

  // ============================================================

  Widget _buildFormBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Category',

            style: TextStyle(
              fontSize: 15,

              fontWeight: FontWeight.w600,

              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          _buildCategoryField(),

          const SizedBox(height: 18),

          const Text(
            'Subcategory Name',

            style: TextStyle(
              fontSize: 15,

              fontWeight: FontWeight.w600,

              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          _buildNameField(),

          const SizedBox(height: 18),

          const Text(
            'Subcategory Price',

            style: TextStyle(
              fontSize: 15,

              fontWeight: FontWeight.w600,

              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          _buildPriceField(),

          if (_isEditing) ...[
            const SizedBox(height: 18),

            Container(
              width: double.infinity,

              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),

              decoration: BoxDecoration(
                color: AppColors.inputBackground,

                borderRadius: BorderRadius.circular(10),

                border: Border.all(color: AppColors.border),
              ),

              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const Text(
                          'Status',

                          style: TextStyle(
                            fontSize: 13,

                            fontWeight: FontWeight.w600,

                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          _isActive ? 'Active' : 'Inactive',

                          style: TextStyle(
                            fontSize: 12,

                            color: _isActive
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
                      thumbColor: WidgetStateProperty.resolveWith(
                        (_) => Colors.white,
                      ),

                      trackColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return AppColors.primary;
                        }

                        return Colors.grey.withValues(alpha: 0.35);
                      }),

                      trackOutlineColor: WidgetStateProperty.all(
                        Colors.transparent,
                      ),
                    ),

                    child: Switch(
                      value: _isActive,

                      onChanged: (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================

  // NAME FIELD

  // ============================================================

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,

      autovalidateMode: AutovalidateMode.onUserInteraction,

      textCapitalization: TextCapitalization.words,

      maxLength: 50,

      buildCounter:
          (context, {required currentLength, required isFocused, maxLength}) {
            return null;
          },

      decoration: const InputDecoration(
        hintText: 'Enter subcategory name',

        helperText: ' ',

        helperStyle: TextStyle(
          fontSize: 12,

          height: 1.2,

          color: Colors.transparent,
        ),

        errorMaxLines: 1,
      ),

      validator: (value) {
        final name = value?.trim() ?? '';

        if (name.isEmpty) {
          return 'Please enter a subcategory name';
        }

        if (name.length < 2) {
          return 'Name must contain at least 2 characters';
        }

        if (name.length >= 50) {
          return 'Please enter up to 50 characters';
        }

        return null;
      },
    );
  }

  // ============================================================

  // CATEGORY FIELD

  // ============================================================

  Widget _buildCategoryField() {
    return DropdownButtonFormField<int>(
      initialValue: _selectedCategoryId,

      decoration: const InputDecoration(
        hintText: 'Select category',

        helperText: ' ',

        helperStyle: TextStyle(
          fontSize: 12,

          height: 1.2,

          color: Colors.transparent,
        ),

        errorMaxLines: 1,
      ),

      items: widget.categories
          .map(
            (category) => DropdownMenuItem<int>(
              value: category.id,

              child: Text(category.name, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),

      onChanged: (value) {
        setState(() {
          _selectedCategoryId = value;
        });
      },

      validator: (value) {
        if (value == null) {
          return 'Please select a category';
        }

        return null;
      },
    );
  }

  // ============================================================

  // PRICE FIELD

  // ============================================================

  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,

      keyboardType: const TextInputType.numberWithOptions(decimal: true),

      decoration: const InputDecoration(
        hintText: 'Enter subcategory price',

        helperText: ' ',

        helperStyle: TextStyle(
          fontSize: 12,

          height: 1.2,

          color: Colors.transparent,
        ),

        errorMaxLines: 1,

        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 16, right: 10),

          child: Text(
            '₹',

            style: TextStyle(
              fontSize: 17,

              fontWeight: FontWeight.w600,

              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),

      validator: (value) {
        final text = value?.trim() ?? '';

        if (text.isEmpty) {
          return 'Please enter a price';
        }

        final price = double.tryParse(text);

        if (price == null) {
          return 'Please enter a valid price';
        }

        if (price < 0) {
          return 'Price cannot be negative';
        }

        return null;
      },
    );
  }

  // ============================================================

  // FORM FOOTER

  // ============================================================

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 22),

      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),

      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },

              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),

                foregroundColor: AppColors.textSecondary,

                side: const BorderSide(color: AppColors.border),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              child: const Text('Cancel'),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: ElevatedButton(
              onPressed: _submit,

              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),

                backgroundColor: AppColors.primary,

                foregroundColor: AppColors.textOnPrimary,

                elevation: 0,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              child: Text(_isEditing ? 'Update' : 'Add'),
            ),
          ),
        ],
      ),
    );
  }
}
