import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../category/models/category_model.dart';
import '../../category/services/category_api_service.dart';
import '../models/sub_category_model.dart';
import '../services/sub_category_services.dart';

class SubCategoriesScreen extends StatefulWidget {
  const SubCategoriesScreen({super.key});

  @override
  State<SubCategoriesScreen> createState() =>
      _SubCategoriesScreenState();
}

class _SubCategoriesScreenState
    extends State<SubCategoriesScreen> {
  final CategoryApiService _categoryApiService =
      CategoryApiService();

  final SubCategoryService _subCategoryService =
      SubCategoryService();

  final TextEditingController _searchController =
      TextEditingController();

  List<CategoryModel> _categories = [];
  List<SubCategoryModel> _subCategories = [];

  int? _selectedCategoryId;

  String _statusFilter = 'All';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(
      _onSearchChanged,
    );

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
        _categoryApiService.getCategories(
          includeInactive: true,
        ),
        _subCategoryService.getSubCategories(),
      ]);

      final categories =
          results[0] as List<CategoryModel>;

      final subCategories =
          results[1] as List<SubCategoryModel>;

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

      _showSnackBar(
        'Failed to load subcategories',
        isError: true,
      );
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
    final searchText =
        _searchController.text.trim().toLowerCase();

    return _subCategories.where((subCategory) {
      final matchesCategory =
          _selectedCategoryId == null ||
          subCategory.categoryId ==
              _selectedCategoryId;

      final matchesStatus =
          _statusFilter == 'All' ||
          (_statusFilter == 'Active' &&
              subCategory.isActive) ||
          (_statusFilter == 'Inactive' &&
              !subCategory.isActive);

      final matchesSearch =
          searchText.isEmpty ||
          subCategory.name
              .toLowerCase()
              .contains(searchText);

      return matchesCategory &&
          matchesStatus &&
          matchesSearch;
    }).toList();
  }

  // ============================================================
  // CATEGORY NAME
  // ============================================================

  String _categoryName(int categoryId) {
    final category =
        _categories.cast<CategoryModel?>().firstWhere(
              (item) => item?.id == categoryId,
              orElse: () => null,
            );

    return category?.name ?? 'Unknown Category';
  }

  // ============================================================
  // STATUS UPDATE
  // ============================================================

  Future<void> _toggleStatus(
    SubCategoryModel subCategory,
  ) async {
    final newStatus =
        !subCategory.isActive;

    try {
      final updated =
          await _subCategoryService
              .updateSubCategoryStatus(
        subCategory.id,
        newStatus,
      );

      if (!mounted) return;

      setState(() {
        final index =
            _subCategories.indexWhere(
          (item) =>
              item.id == subCategory.id,
        );

        if (index != -1) {
          _subCategories[index] =
              updated;
        }
      });

      _showSnackBar(
        newStatus
            ? 'Subcategory activated'
            : 'Subcategory deactivated',
      );
    } catch (error) {
      _showSnackBar(
        'Failed to update status: $error',
        isError: true,
      );
    }
  }

  // ============================================================
  // ADD / EDIT
  // ============================================================

  Future<void> _openAddPanel() async {
    await _openSubCategoryPanel();
  }

  Future<void> _openEditPanel(
    SubCategoryModel subCategory,
  ) async {
    await _openSubCategoryPanel(
      subCategory: subCategory,
    );
  }

  Future<void> _openSubCategoryPanel({
    SubCategoryModel? subCategory,
  }) async {
    final result =
        await showDialog<SubCategoryModel>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(
        alpha: 0.45,
      ),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding:
              const EdgeInsets.symmetric(
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
        final created =
            await _subCategoryService
                .createSubCategory(
          categoryId: result.categoryId,
          name: result.name,
          price: result.price,
        );

        if (!mounted) return;

        setState(() {
          _subCategories.add(created);
        });

        _showSnackBar(
          'Subcategory created successfully',
        );
      } else {
        final updated =
            await _subCategoryService
                .updateSubCategory(
          result,
        );

        if (!mounted) return;

        setState(() {
          final index =
              _subCategories.indexWhere(
            (item) => item.id == updated.id,
          );

          if (index != -1) {
            _subCategories[index] =
                updated;
          }
        });

        _showSnackBar(
          'Subcategory updated successfully',
        );
      }
    } catch (error) {
      _showSnackBar(
        'Operation failed: $error',
        isError: true,
      );
    }
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showSnackBar(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError
                  ? AppColors.error
                  : AppColors.success,
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
       title: const Text('Sub Categories'),
      ),
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
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
            constraints.maxWidth >= 600 &&
            constraints.maxWidth < 1200;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 16 : 28,
            isMobile ? 16 : 28,
            isMobile ? 16 : 28,
            8,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight -
                  (isMobile ? 24 : 48),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _buildPageHeader(isMobile),

                const SizedBox(height: 24),

                _buildFilters(
                  isMobile,
                  isTablet,
                ),

                const SizedBox(height: 20),

                _buildSubCategoryTable(isMobile),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // PAGE HEADER
  // ============================================================

  Widget _buildPageHeader(
    bool isCompact,
  ) {
    if (isCompact) {
      return Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          const Text(
            'Manage your menu subcategories',
            style: TextStyle(
              fontSize: 14,
              color:
                  AppColors.textSecondary,
            ),
          ),
        
        ],
      );
    }

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              SizedBox(height: 6),
              Text(
                'Manage your menu subcategories',
                style: TextStyle(
                  fontSize: 14,
                  color:
                      AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        _buildAddButton(),
      ],
    );
  }

  // ============================================================
  // ADD BUTTON
  // ============================================================

  Widget _buildAddButton() {
    return ElevatedButton.icon(
      onPressed: _openAddPanel,
      icon: const Icon(
        Icons.add,
        size: 19,
      ),
      label:
          const Text('Add'),
      style: ElevatedButton.styleFrom(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        backgroundColor:
            AppColors.primary,
        foregroundColor:
            AppColors.textOnPrimary,
        elevation: 0,
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(10),
        ),
      ),
    );
  }

  // ============================================================
  // FILTERS
  // ============================================================

  Widget _buildFilters(
    bool isMobile,
    bool isTablet,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(
            color: AppColors.border,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: isMobile
              ? Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildSearchField(),
                        ),
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
    child: const Icon(
      Icons.add,
      size: 20,
    ),
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
                    Expanded(
                      child: _buildSearchField(),
                    ),
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
      initialValue:
          _selectedCategoryId,
      decoration:
          const InputDecoration(
        labelText: 'Category',

      ),
      items: [
        const DropdownMenuItem<int?>(
          value: null,
          child:
              Text('All Categories'),
        ),
        ..._categories.map(
          (category) =>
              DropdownMenuItem<int?>(
            value: category.id,
            child: Text(
              category.name,
              overflow:
                  TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedCategoryId =
              value;
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
        hintText:
            'Search subcategories...',
        prefixIcon: const Icon(
          Icons.search,
        ),
        suffixIcon:
            _searchController
                    .text
                    .isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController
                          .clear();
                    },
                    icon: const Icon(
                      Icons.clear,
                    ),
                  )
                : null,
      ),
    );
  }

  // ============================================================
  // STATUS FILTER
  // ============================================================

  Widget _buildStatusFilter(bool isMobile) {
    const options = <String>[
      'All',
      'Active',
      'Inactive',
    ];

    return Container(
      height: 48,
      width: isMobile ? 190 : null,
      padding:
          const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color:
            AppColors.surfaceSoft,
        border: Border.all(
          color: AppColors.border,
        ),
        borderRadius:
            BorderRadius.circular(28),
      ),
     child: Row(
  children:
      options.map((option) {
          final isSelected =
              _statusFilter ==
                  option;

         return Expanded(
  child: Padding(
            
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 1,
              ),
              child: Material(
                color:
                    Colors.transparent,
                child: InkWell(
                  borderRadius:
                      BorderRadius
                          .circular(22),
                  onTap: () {
                    if (_statusFilter ==
                        option) {
                      return;
                    }

                    setState(() {
                      _statusFilter =
                          option;
                    });
                  },
                  child:
                      AnimatedContainer(
                    duration:
                        const Duration(
                      milliseconds: 180,
                    ),
                    curve:
                        Curves.easeOutCubic,
                    height:
                        double.infinity,
                    alignment:
                        Alignment.center,
                    decoration:
                        BoxDecoration(
                      color: isSelected
                          ? AppColors
                              .primarySoft
                          : Colors
                              .transparent,
                      borderRadius:
                          BorderRadius
                              .circular(
                        22,
                      ),
                    ),
                   child: Row(
  mainAxisAlignment:
      MainAxisAlignment.center,
  children: [
    Text(
      option,
                          maxLines: 1,
                          softWrap: false,
                          textAlign:
                              TextAlign
                                  .center,
                          style:
                              TextStyle(
                            fontSize: 13,
                            fontWeight:
                                isSelected
                                    ? FontWeight
                                        .w700
                                    : FontWeight
                                        .w600,
                            color: isSelected
                                ? AppColors
                                    .primary
                                : AppColors
                                    .textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
  )
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // SUBCATEGORY TABLE
  // ============================================================

  Widget _buildSubCategoryTable(
    bool isMobile,
  ) {
    final items =
        _filteredSubCategories;

    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 0,
        color: AppColors.surface,
        clipBehavior:
            Clip.antiAlias,
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(14),
          side: const BorderSide(
            color: AppColors.border,
          ),
        ),
        child: items.isEmpty
            ? _buildEmptyState()
            : Column(
                children: [
                  _buildTableHeader(isMobile),
                  const Divider(
                    height: 1,
                    color:
                        AppColors.divider,
                  ),
                  ...items.map(
                    (item) =>
                        _buildTableRow(
                          item,
                          isMobile,
                        ),
                  ),
                ],
              ),
      ),
    );
  }

  // ============================================================
  // TABLE HEADER
  // ============================================================

  Widget _buildTableHeader(
    bool isMobile,
  ) {
    if (isMobile) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Subcategories',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 15,
      ),
      color: AppColors.surfaceSoft,
      child: const Row(
        children: [
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'SUBCATEGORY',
                style: _headerStyle,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                'CATEGORY',
                style: _headerStyle,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                'PRICE',
                style: _headerStyle,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'ACTION',
                style: _headerStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABLE ROW
  // ============================================================

  Widget _buildTableRow(
    SubCategoryModel item,
    bool isMobile,
  ) {
    if (isMobile) {
      return _buildCompactRow(item);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 15,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: _buildNameCell(item),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                _categoryName(item.categoryId),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                '₹${item.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: item.isActive,
                    onChanged: (_) => _toggleStatus(item),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Edit',
                    onPressed: () => _openEditPanel(item),
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 19,
                      color: AppColors.icon,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMPACT ROW
  // ============================================================

  Widget _buildCompactRow(
    SubCategoryModel item,
  ) {
    return InkWell(
      onTap: () =>
          _openEditPanel(item),
      child: Container(
        padding:
            const EdgeInsets.all(16),
        decoration:
            const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color:
                  AppColors.divider,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child:
                      _buildNameCell(
                    item,
                  ),
                ),
                Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Switch(
      value: item.isActive,
      onChanged: (_) =>
          _toggleStatus(
        item,
      ),
    ),
    IconButton(
      tooltip: 'Edit',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 40,
        minHeight: 40,
      ),
      onPressed: () => _openEditPanel(item),
      icon: const Icon(
        Icons.edit_outlined,
        size: 20,
        color: AppColors.icon,
      ),
    ),
  ],
),
              ],
            ),

   const SizedBox(
  height: 6,
),

Text(
  '₹${item.price.toStringAsFixed(2)}',
  style: const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  ),
),

const SizedBox(
  height: 4,
),

Text(
  _categoryName(
    item.categoryId,
  ),
  style: const TextStyle(
    fontSize: 13,
    color: AppColors.textSecondary,
  ),
  overflow: TextOverflow.ellipsis,
),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NAME CELL
  // ============================================================

  Widget _buildNameCell(
    SubCategoryModel item,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            item.name,
            style:
                const TextStyle(
              fontSize: 14,
              fontWeight:
                  FontWeight.w600,
              color:
                  AppColors.textPrimary,
            ),
            overflow:
                TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return SizedBox(
      width: double.infinity,
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(
          minHeight: 450,
        ),
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.all(40),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                const Text(
                  'No subcategories found',
                  textAlign:
                      TextAlign.center,
                  style:
                      TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w700,
                    color: AppColors
                        .textPrimary,
                  ),
                ),

                const SizedBox(
                  height: 7,
                ),

                const Text(
                  'Try changing your filters or add a new subcategory.',
                  textAlign:
                      TextAlign.center,
                  style:
                      TextStyle(
                    fontSize: 13,
                    color: AppColors
                        .textSecondary,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// TABLE HEADER STYLE
// ================================================================

const TextStyle _headerStyle =
    TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  letterSpacing: 0.6,
  color: AppColors.textTertiary,
);

// ================================================================
// ADD / EDIT FORM
// ================================================================

class _SubCategoryFormSheet
    extends StatefulWidget {
  final List<CategoryModel> categories;
  final SubCategoryModel? subCategory;

  const _SubCategoryFormSheet({
    required this.categories,
    this.subCategory,
  });

  @override
  State<_SubCategoryFormSheet> createState() =>
      _SubCategoryFormSheetState();
}

class _SubCategoryFormSheetState
    extends State<_SubCategoryFormSheet> {
  final GlobalKey<FormState>
      _formKey =
      GlobalKey<FormState>();

  late final TextEditingController
      _nameController;

  late final TextEditingController
      _priceController;

  int? _selectedCategoryId;

  bool get _isEditing =>
      widget.subCategory != null;

  @override
  void initState() {
    super.initState();

    _nameController =
        TextEditingController(
      text:
          widget.subCategory?.name ??
              '',
    );

    _priceController =
        TextEditingController(
      text: widget.subCategory == null
          ? ''
          : widget.subCategory!.price
              .toStringAsFixed(2),
    );

    _selectedCategoryId =
        widget.subCategory?.categoryId;
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
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final categoryId =
        _selectedCategoryId;

    if (categoryId == null) {
      return;
    }

    final price =
        double.tryParse(
      _priceController.text
          .trim(),
    );

    if (price == null) {
      return;
    }

    final existing =
        widget.subCategory;

    final result =
        SubCategoryModel(
      id: existing?.id ?? 0,
      categoryId: categoryId,
      name:
          _nameController.text.trim(),
      price: price,
      isActive:
          existing?.isActive ?? true,
    );

    Navigator.of(context)
        .pop(result);
  }

  // ============================================================
  // BUILD FORM
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final screenWidth =
        MediaQuery.sizeOf(context)
            .width;

    final dialogWidth =
        screenWidth < 560
            ? screenWidth - 32
            : 500.0;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: dialogWidth,
        constraints:
            const BoxConstraints(
          maxWidth: 500,
        ),
        decoration:
            BoxDecoration(
          color:
              AppColors.surface,
          borderRadius:
              BorderRadius.circular(
            22,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(
                alpha: 0.14,
              ),
              blurRadius: 30,
              offset:
                  const Offset(0, 12),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              _buildHeader(),

              const Divider(
                height: 1,
                color:
                    AppColors.divider,
              ),

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
      padding:
          const EdgeInsets.fromLTRB(
        24,
        22,
        16,
        20,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _isEditing
                  ? 'Edit Subcategory'
                  : 'Add Subcategory',
              style:
                  const TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.w700,
                color: AppColors
                    .textPrimary,
              ),
            ),
          ),

          IconButton(
            tooltip: 'Close',
            onPressed: () {
              Navigator.of(context)
                  .pop();
            },
            icon: const Icon(
              Icons.close,
              color:
                  AppColors.textSecondary,
            ),
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
      padding:
          const EdgeInsets.fromLTRB(
        24,
        22,
        24,
        24,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Category',
            style:
                TextStyle(
              fontSize: 15,
              fontWeight:
                  FontWeight.w600,
              color: AppColors
                  .textPrimary,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          _buildCategoryField(),

          const SizedBox(
            height: 18,
          ),

          const Text(
            'Subcategory Name',
            style:
                TextStyle(
              fontSize: 15,
              fontWeight:
                  FontWeight.w600,
              color: AppColors
                  .textPrimary,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          _buildNameField(),

          const SizedBox(
            height: 18,
          ),

          const Text(
            'Subcategory Price',
            style:
                TextStyle(
              fontSize: 15,
              fontWeight:
                  FontWeight.w600,
              color: AppColors
                  .textPrimary,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          _buildPriceField(),
        ],
      ),
    );
  }

  // ============================================================
  // NAME FIELD
  // ============================================================

  Widget _buildNameField() {
    return TextFormField(
      controller:
          _nameController,
      textCapitalization:
          TextCapitalization.words,
      decoration:
          const InputDecoration(
        hintText:
            'Enter subcategory name',

      ),
      validator: (value) {
        final name =
            value?.trim() ?? '';

        if (name.isEmpty) {
          return 'Please enter a subcategory name';
        }

        if (name.length < 2) {
          return 'Name must contain at least 2 characters';
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
      initialValue:
          _selectedCategoryId,
      decoration:
          const InputDecoration(
        hintText:
            'Select category',

      ),
      items: widget.categories
          .map(
            (category) =>
                DropdownMenuItem<int>(
              value: category.id,
              child: Text(
                category.name,
                overflow:
                    TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategoryId =
              value;
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
      controller:
          _priceController,
      keyboardType:
          const TextInputType
              .numberWithOptions(
        decimal: true,
      ),
      decoration:
          const InputDecoration(
        hintText:
            'Enter subcategory price',
        prefixIcon: Padding(
          padding:
              EdgeInsets.only(
            left: 16,
            right: 10,
          ),
          child: Text(
            '₹',
            style:
                TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.w600,
              color: AppColors
                  .textSecondary,
            ),
          ),
        ),
      ),
      validator: (value) {
        final text =
            value?.trim() ?? '';

        if (text.isEmpty) {
          return 'Please enter a price';
        }

        final price =
            double.tryParse(text);

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
      padding:
          const EdgeInsets.fromLTRB(
        24,
        16,
        24,
        22,
      ),
      decoration:
          const BoxDecoration(
        border: Border(
          top: BorderSide(
            color:
                AppColors.divider,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child:
                OutlinedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pop();
              },
              style:
                  OutlinedButton
                      .styleFrom(
                padding:
                    const EdgeInsets
                        .symmetric(
                  vertical: 14,
                ),
                foregroundColor:
                    AppColors
                        .textSecondary,
                side:
                    const BorderSide(
                  color:
                      AppColors.border,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    10,
                  ),
                ),
              ),
              child:
                  const Text(
                'Cancel',
              ),
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child:
                ElevatedButton(
              onPressed:
                  _submit,
              style:
                  ElevatedButton
                      .styleFrom(
                padding:
                    const EdgeInsets
                        .symmetric(
                  vertical: 14,
                ),
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
              child: Text(
                _isEditing
                    ? 'Update'
                    : 'Add',
              ),
            ),
          ),
        ],
      ),
    );
  }
}