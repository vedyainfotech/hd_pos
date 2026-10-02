import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../category/models/category_model.dart';
import '../../category/services/category_api_service.dart';
import '../../sub_categories/models/sub_category_model.dart';
import '../../sub_categories/services/sub_category_services.dart';
import '../models/items_model.dart';
import '../services/items_services.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  final CategoryApiService _categoryService = CategoryApiService();
  final SubCategoryService _subCategoryService = SubCategoryService();
  final ItemApiService _itemService = ItemApiService();

  final TextEditingController _searchController = TextEditingController();

  List<CategoryModel> _categories = [];
  List<SubCategoryModel> _subCategories = [];
  List<ItemModel> _items = [];

  bool _isLoading = true;
  bool _isSaving = false;

  int? _selectedCategoryFilter;
  int? _selectedSubCategoryFilter;
  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final results = await Future.wait([
        _categoryService.getCategories(includeInactive: true),
        _subCategoryService.getSubCategories(includeInactive: true),
        _itemService.getItems(includeInactive: true),
      ]);

      if (!mounted) return;

      setState(() {
        _categories = results[0] as List<CategoryModel>;
        _subCategories = results[1] as List<SubCategoryModel>;
        _items = results[2] as List<ItemModel>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showError('Failed to load items');
    }
  }

  Future<void> _refreshItems() async {
    try {
      final results = await Future.wait([
        _subCategoryService.getSubCategories(includeInactive: true),
        _itemService.getItems(includeInactive: true),
      ]);

      if (!mounted) return;

      setState(() {
        _subCategories = results[0] as List<SubCategoryModel>;
        _items = results[1] as List<ItemModel>;
      });
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to load items');
    }
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  void _showError(String message) {
    if (!mounted) return;

    final overlay = Overlay.of(context);

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
                color: const Color(0xFFFFE5E5),
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
                  const Icon(
                    Icons.close_rounded,
                    size: 22,
                    color: Color(0xFFD32F2F),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      message,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD32F2F),
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

  void _showSuccess(String message) {
    if (!mounted) return;

    final overlay = Overlay.of(context);

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
                color: const Color(0xFFE5F7E9),
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
                  const Icon(
                    Icons.check_rounded,
                    size: 22,
                    color: Color(0xFF1E9E45),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      message,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E9E45),
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

  List<SubCategoryModel> get _filteredSubCategoryOptions {
    if (_selectedCategoryFilter == null) {
      return _subCategories;
    }

    return _subCategories
        .where(
          (subCategory) =>
              subCategory.categoryId == _selectedCategoryFilter,
        )
        .toList();
  }

  List<ItemModel> get _filteredItems {
    final search = _searchController.text.trim().toLowerCase();

    return _items.where((item) {
      final matchesCategory = _selectedCategoryFilter == null ||
          item.categoryId == _selectedCategoryFilter;

      final matchesSubCategory = _selectedSubCategoryFilter == null ||
          item.subCategoryId == _selectedSubCategoryFilter;

      final matchesStatus = _statusFilter == 'All' ||
          (_statusFilter == 'Active' && item.isActive) ||
          (_statusFilter == 'Inactive' && !item.isActive);

      final categoryName = _categoryName(item.categoryId).toLowerCase();
      final subCategoryName =
          _subCategoryName(item.subCategoryId).toLowerCase();

      final matchesSearch = search.isEmpty ||
          item.name.toLowerCase().contains(search) ||
          categoryName.contains(search) ||
          subCategoryName.contains(search);

      return matchesCategory &&
          matchesSubCategory &&
          matchesStatus &&
          matchesSearch;
    }).toList();
  }

  String _categoryName(int categoryId) {
    for (final category in _categories) {
      if (category.id == categoryId) {
        return category.name;
      }
    }
    return 'Unknown';
  }

  String _subCategoryName(int subCategoryId) {
    for (final subCategory in _subCategories) {
      if (subCategory.id == subCategoryId) {
        return subCategory.name;
      }
    }
    return 'Sub Category';
  }

  Future<void> _openItemForm({ItemModel? item}) async {
    final result = await showDialog<_ItemFormResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _ItemFormDialog(
          categories: _categories,
          existingItem: item,
          subCategoryService: _subCategoryService,
        );
      },
    );

    if (result == null) return;

    try {
      setState(() {
        _isSaving = true;
      });

      if (item == null) {
        await _itemService.createItem(
          categoryId: result.categoryId,
          subCategoryId: result.subCategoryId,
          name: result.name,
          price: result.price,
          sameAsCategory: result.sameAsCategory,
        );

        _showSuccess('Item added successfully');
      } else {
        await _itemService.updateItem(
          id: item.id,
          categoryId: result.categoryId,
          subCategoryId: result.subCategoryId,
          name: result.name,
          price: result.price,
          sameAsCategory: result.sameAsCategory,
          status: item.isActive,
        );

        _showSuccess('Item updated successfully');
      }

      await _refreshItems();
    } catch (e) {
      if (mounted) {
        _showError(_cleanError(e));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _toggleStatus(ItemModel item) async {
    if (_isSaving) return;

    try {
      await _itemService.updateItemStatus(
        item.id,
        !item.isActive,
      );

      await _refreshItems();

      if (!mounted) return;

      
    } catch (e) {
      if (mounted) {
        _showError(_cleanError(e));
      }
    }
  }

  void _onCategoryFilterChanged(int? categoryId) {
    setState(() {
      _selectedCategoryFilter = categoryId;

      if (categoryId == null) {
        _selectedSubCategoryFilter = null;
        return;
      }

      final selectedSubCategory = _selectedSubCategoryFilter;

      if (selectedSubCategory != null &&
          !_subCategories.any(
            (subCategory) =>
                subCategory.id == selectedSubCategory &&
                subCategory.categoryId == categoryId,
          )) {
        _selectedSubCategoryFilter = null;
      }
    });
  }

  void _onSubCategoryFilterChanged(int? subCategoryId) {
    setState(() {
      _selectedSubCategoryFilter = subCategoryId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Items',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            if (width < 700) {
              return _buildMobileLayout();
            }

            if (width < 1100) {
              return _buildTabletLayout();
            }

            return _buildDesktopLayout();
          },
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(30, 28, 30, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(),
          const SizedBox(height: 22),
          _buildFilterCard(),
          const SizedBox(height: 18),
          _buildItemListCard(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(),
          const SizedBox(height: 18),
          _buildFilterCard(tablet: true),
          const SizedBox(height: 16),
          _buildItemListCard(compact: true),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _refreshItems,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPageHeader(mobile: true),
            const SizedBox(height: 18),
            _buildFilterCard(mobile: true),
            const SizedBox(height: 16),
            _buildItemListCard(mobile: true),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader({bool mobile = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            'Manage your items',
            style: TextStyle(
              fontSize: mobile ? 16 : 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        if (!mobile)
          FilledButton(
            onPressed: _isSaving ? null : () => _openItemForm(),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 17,
              ),
              minimumSize: const Size(132, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          child: const Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Icon(
      Icons.add,
      size: 19,
    ),
    SizedBox(width: 6),
    Text(
      'Add Item',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    ),
  ],
),
          ),
      ],
    );
  }

  Widget _buildFilterCard({
    bool tablet = false,
    bool mobile = false,
  }) {
    return _SurfaceCard(
      child: Padding(
        padding: EdgeInsets.all(mobile ? 14 : 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 14),
            if (mobile)
              Column(
                children: [
                  Row(
  children: [
    Expanded(
      child: _buildFilterSearch(),
    ),
    const SizedBox(width: 10),
    SizedBox(
      width: 48,
      height: 48,
      child: ElevatedButton(
        onPressed: _isSaving
            ? null
            : () => _openItemForm(),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
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
const SizedBox(height: 12),
                  _buildCategoryFilter(),
                  const SizedBox(height: 12),
                  _buildSubCategoryFilter(),
                  const SizedBox(height: 12),
                  Align(
  alignment: Alignment.centerLeft,
  child: _buildStatusFilter(mobile: true),
),
                ],
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 900) {
                    return Column(
                      children: [
                        _buildFilterSearch(),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildCategoryFilter()),
                            const SizedBox(width: 12),
                            Expanded(child: _buildSubCategoryFilter()),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _buildStatusFilter(compact: true),
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(flex: 3, child: _buildFilterSearch()),
                      const SizedBox(width: 12),
                      Expanded(flex: 2, child: _buildCategoryFilter()),
                      const SizedBox(width: 12),
                      Expanded(flex: 2, child: _buildSubCategoryFilter()),
                      const SizedBox(width: 12),
                      _buildStatusFilter(),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return _FilterDropdown<int>(
      label: 'Category',
      hint: 'All Categories',
      value: _selectedCategoryFilter ?? 0,
      icon: null,
      items: [
        const DropdownMenuItem<int>(
          value: 0,
          child: Text('All Categories'),
        ),
        ..._categories.map(
          (category) => DropdownMenuItem<int>(
            value: category.id,
            child: Text(
              category.name,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
      onChanged: (value) {
        _onCategoryFilterChanged(
          value == null || value == 0 ? null : value,
        );
      },
    );
  }

  Widget _buildSubCategoryFilter() {
  return _FilterDropdown<int>(
    label: 'Sub Category',
    hint: _selectedCategoryFilter == null
        ? 'Select category first'
        : 'All Sub Categories',
    value: _selectedCategoryFilter == null
        ? 0
        : _selectedSubCategoryFilter ?? 0,
    icon: null,
    items: _selectedCategoryFilter == null
        ? const []
        : [
            const DropdownMenuItem<int>(
              value: 0,
              child: Text('All Sub Categories'),
            ),
            ..._filteredSubCategoryOptions.map(
              (subCategory) => DropdownMenuItem<int>(
                value: subCategory.id,
                child: Text(
                  subCategory.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
    onChanged: _selectedCategoryFilter == null
        ? null
        : (value) {
            _onSubCategoryFilterChanged(
              value == null || value == 0 ? null : value,
            );
          },
  );
}

  Widget _buildFilterSearch() {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: 'Search',
        hintText: 'Search items...',
        prefixIcon: const Icon(
          Icons.search_rounded,
          size: 20,
          color: AppColors.icon,
        ),
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildItemListCard({
    bool compact = false,
    bool mobile = false,
  }) {
    final items = _filteredItems;

    return _SurfaceCard(
      child: Padding(
        padding: EdgeInsets.all(mobile ? 14 : 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mobile)
              _buildMobileListHeader()
            else
              _buildDesktopListHeader(compact: compact),
            const SizedBox(height: 14),
            if (_isLoading)
              const SizedBox(
                height: 260,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              )
            else if (items.isEmpty)
              _buildEmptyState()
            else if (mobile)
              _buildMobileItems(items)
            else
              _buildItemsTable(items),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopListHeader({bool compact = false}) {
    return const Text(
      'Item List',
      style: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildMobileListHeader() {
    return const Text(
      'Item List',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildStatusFilter({
    bool compact = false,
    bool mobile = false,
  }) {
    const options = ['All', 'Active', 'Inactive'];

    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        border: Border.all(
          color: AppColors.border,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) {
          final selected = _statusFilter == option;

          return SizedBox(
  width: compact ? 64 : 70,
  child: InkWell(
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  setState(() {
                    _statusFilter = option;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primarySoft
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w600,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textPrimary,
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

  Widget _buildItemsTable(List<ItemModel> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: constraints.maxWidth,
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(1.45),
                1: FlexColumnWidth(1.05),
                2: FlexColumnWidth(1.25),
                3: FlexColumnWidth(0.80),
                4: FlexColumnWidth(1.05),
              },
              border: TableBorder.all(
                color: AppColors.borderLight,
                width: 0.7,
              ),
              children: [
                TableRow(
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                  ),
                  children: [
                    _tableHeader('Item Name'),
                    _tableHeader('Category'),
                    _tableHeader('Sub Category'),
                    _tableHeader('Price (₹)'),
                    _tableHeader('Actions'),
                  ],
                ),
                ...items.map(
                  (item) => TableRow(
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                    ),
                    children: [
                      _tableCell(item.name),
                      _tableCell(_categoryName(item.categoryId)),
                      _tableCell(_subCategoryName(item.subCategoryId)),
                      _tableCell('₹ ${item.price.toStringAsFixed(2)}'),
                      _tableActionsCell(item),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 13,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _tableCell(String text, {bool bold = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
          fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _tableActionsCell(ItemModel item) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _StatusSwitch(
            isActive: item.isActive,
            enabled: !_isSaving,
            onChanged: (_) => _toggleStatus(item),
          ),
          const SizedBox(width: 12),
          IconButton(
            tooltip: 'Edit item',
            onPressed: _isSaving
                ? null
                : () => _openItemForm(item: item),
            icon: const Icon(
              Icons.edit_outlined,
              size: 19,
            ),
            color: const Color.fromARGB(255, 20, 20, 20),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileItems(List<ItemModel> items) {
    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _MobileItemCard(
            item: item,
            categoryName: _categoryName(item.categoryId),
            subCategoryName: _subCategoryName(item.subCategoryId),
            onEdit: _isSaving
                ? null
                : () => _openItemForm(item: item),
            onToggle: _isSaving
                ? null
                : () => _toggleStatus(item),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 350,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'No items found',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add a new item or change your filters.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemFormDialog extends StatefulWidget {
  final List<CategoryModel> categories;
  final ItemModel? existingItem;
  final SubCategoryService subCategoryService;

  const _ItemFormDialog({
    required this.categories,
    required this.existingItem,
    required this.subCategoryService,
  });

  @override
  State<_ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends State<_ItemFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  List<SubCategoryModel> _subCategories = [];

  int? _selectedCategoryId;
  int? _selectedSubCategoryId;
  double? _categoryPrice;

  bool _sameAsCategory = false;
  bool _loadingSubCategories = false;

  @override
  void initState() {
    super.initState();

    final existing = widget.existingItem;

    if (existing != null) {
      _nameController.text = existing.name;
      _priceController.text = existing.price.toStringAsFixed(2);
      _selectedCategoryId = existing.categoryId;
      _selectedSubCategoryId = existing.subCategoryId;
      _sameAsCategory = existing.sameAsCategory;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadSubCategories(
          existing.categoryId,
          initialSubCategoryId: existing.subCategoryId,
        );
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadSubCategories(
    int categoryId, {
    int? initialSubCategoryId,
  }) async {
    if (mounted) {
      setState(() {
        _loadingSubCategories = true;
        if (initialSubCategoryId != null) {
          _selectedSubCategoryId = initialSubCategoryId;
        }
      });
    }

    try {
      final data = await widget.subCategoryService.getSubCategories(
       includeInactive: true,
        categoryId: categoryId,
      );

      if (!mounted) return;

      setState(() {
        _subCategories = data;

        if (initialSubCategoryId != null &&
            data.any((item) => item.id == initialSubCategoryId)) {
          _selectedSubCategoryId = initialSubCategoryId;
          _setCategoryPrice(
            initialSubCategoryId,
            data,
            updateItemPrice: false,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        _showError(
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingSubCategories = false;
        });
      }
    }
  }

  void _setCategoryPrice(
    int subCategoryId,
    List<SubCategoryModel> data, {
    bool updateItemPrice = false,
  }) {
    for (final subCategory in data) {
      if (subCategory.id == subCategoryId) {
        setState(() {
          _categoryPrice = subCategory.price;

          if (_sameAsCategory || updateItemPrice) {
            _priceController.text =
                subCategory.price.toStringAsFixed(2);
          }
        });

        return;
      }
    }
  }

  void _onCategoryChanged(int? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _selectedSubCategoryId = null;
      _subCategories = [];
      _categoryPrice = null;
      _priceController.clear();
    });

    if (categoryId != null) {
      _loadSubCategories(categoryId);
    }
  }

  void _onSubCategoryChanged(int? subCategoryId) {
    if (subCategoryId == null) {
      setState(() {
        _selectedSubCategoryId = null;
        _categoryPrice = null;

        if (_sameAsCategory) {
          _priceController.clear();
        }
      });

      return;
    }

    setState(() {
      _selectedSubCategoryId = subCategoryId;
    });

    _setCategoryPrice(
      subCategoryId,
      _subCategories,
    );
  }

  void _onSameAsCategoryChanged(bool? value) {
    final checked = value ?? false;

    setState(() {
      _sameAsCategory = checked;

      if (checked && _categoryPrice != null) {
        _priceController.text =
            _categoryPrice!.toStringAsFixed(2);
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryId == null) {
      _showError('Please select a category');
      return;
    }

    if (_selectedSubCategoryId == null) {
      _showError('Please select a sub category');
      return;
    }

    final price = double.tryParse(
      _priceController.text.trim(),
    );

    if (price == null || price < 0) {
      _showError('Please enter a valid item price');
      return;
    }

    Navigator.pop(
      context,
      _ItemFormResult(
        categoryId: _selectedCategoryId!,
        subCategoryId: _selectedSubCategoryId!,
        name: _nameController.text.trim(),
        price: price,
        sameAsCategory: _sameAsCategory,
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;

    final overlay = Overlay.of(context);

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
                color: const Color(0xFFFFE5E5),
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
                  const Icon(
                    Icons.close_rounded,
                    size: 22,
                    color: Color(0xFFD32F2F),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      message,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD32F2F),
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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingItem != null;
    final width = MediaQuery.sizeOf(context).width;
    final dialogWidth = width < 600 ? width - 28 : 620.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(14),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEditing ? 'Edit Item' : 'Add Item',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              isEditing
                                  ? 'Update item details'
                                  : 'Add a new menu item',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildLabel('Category', required: true),
                  const SizedBox(height: 7),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedCategoryId,
                    decoration: _inputDecoration(
                      hint: 'Select Category',
                    ),
                    items: widget.categories
                        .map(
                          (category) => DropdownMenuItem<int>(
                            value: category.id,
                            child: Text(
                              category.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: _onCategoryChanged,
                    validator: (value) {
                      if (value == null) {
                        return 'Select a category';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  _buildLabel('Sub Category', required: true),
                  const SizedBox(height: 7),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedSubCategoryId,
                    decoration: _inputDecoration(
                      hint: _selectedCategoryId == null
                          ? 'Select category first'
                          : _loadingSubCategories
                              ? 'Loading...'
                              : 'Select Sub Category',
                    ),
                    items: _subCategories
                        .map(
                          (subCategory) => DropdownMenuItem<int>(
                            value: subCategory.id,
                            child: Text(
                              subCategory.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: _selectedCategoryId == null ||
                            _loadingSubCategories
                        ? null
                        : _onSubCategoryChanged,
                    validator: (value) {
                      if (value == null) {
                        return 'Select a sub category';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  _buildLabel('Sub Category Price'),
                  const SizedBox(height: 7),
                  TextFormField(
  readOnly: true,
  controller: TextEditingController(
    text: _categoryPrice != null
        ? '₹ ${_categoryPrice!.toStringAsFixed(2)}'
        : '',
  ),
  decoration: _inputDecoration(
    hint: _categoryPrice != null
        ? 'Selected sub category price'
        : 'Same as Sub Category price',
  ),
),
                  const SizedBox(height: 18),
                  _buildLabel('Item Name', required: true),
                  const SizedBox(height: 7),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.sentences,
                    maxLength: 50,
                    buildCounter: (
                      context, {
                      required currentLength,
                      required isFocused,
                      maxLength,
                    }) {
                      return null;
                    },
                    decoration: _inputDecoration(
                      hint: 'Enter Item Name',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter item name';
                      }
                      if (value.trim().length >= 50) {
                        return 'Please enter up to 50 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  _buildLabel('Item Price', required: true),
                  const SizedBox(height: 7),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    readOnly: _sameAsCategory,
                    decoration: _inputDecoration(
                      hint: 'Enter Price',
                    ).copyWith(
                      fillColor: _sameAsCategory
                          ? AppColors.surfaceSoft
                          : AppColors.inputBackground,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter item price';
                      }

                      final price = double.tryParse(value.trim());

                      if (price == null || price < 0) {
                        return 'Enter a valid price';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSoft,
                      border: Border.all(
                        color: AppColors.border,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _sameAsCategory,
                          activeColor: AppColors.primary,
                          onChanged: _onSameAsCategoryChanged,
                        ),
                        const SizedBox(width: 4),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Same as Sub Category',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Use the selected sub category price',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(
                              color: AppColors.border,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isEditing ? 'Update Item' : 'Save Item',
                            style: const TextStyle(
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
        ),
      ),
    );
  }

  Widget _buildLabel(
    String text, {
    bool required = false,
  }) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        children: required
            ? const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: AppColors.error,
                  ),
                ),
              ]
            : null,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.inputBackground,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.error,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1.2,
        ),
      ),
    );
  }
}

class _ItemFormResult {
  final int categoryId;
  final int subCategoryId;
  final String name;
  final double price;
  final bool sameAsCategory;

  const _ItemFormResult({
    required this.categoryId,
    required this.subCategoryId,
    required this.name,
    required this.price,
    required this.sameAsCategory,
  });
}

class _SurfaceCard extends StatelessWidget {
  final Widget child;

  const _SurfaceCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final String hint;
  final IconData? icon;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.hint,
    required this.icon,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon == null
            ? null
            : Icon(
                icon,
                size: 19,
                color: AppColors.icon,
              ),
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.4,
          ),
        ),
      ),
      hint: Text(hint),
      items: items,
      onChanged: onChanged,
    );
  }
}

class _StatusSwitch extends StatelessWidget {
  final bool isActive;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _StatusSwitch({
    required this.isActive,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: isActive,
      label: isActive ? 'Active' : 'Inactive',
      child: GestureDetector(
        onTap: enabled ? () => onChanged(!isActive) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 48,
          height: 26,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
        color: isActive
    ? AppColors.primary
    : const Color(0xFFBDBDBD),
            borderRadius: BorderRadius.circular(20),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 160),
            alignment: isActive
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileItemCard extends StatelessWidget {
  final ItemModel item;
  final String categoryName;
  final String subCategoryName;
  final VoidCallback? onEdit;
  final VoidCallback? onToggle;

  const _MobileItemCard({
    required this.item,
    required this.categoryName,
    required this.subCategoryName,
    required this.onEdit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                 Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),

Text(
  'Price: ₹${item.price.toStringAsFixed(2)}',
  style: const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  ),
),

const SizedBox(height: 2),

Text(
  'Category: $categoryName',
  style: const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Color.fromARGB(255, 112, 100, 92),
  ),
),
const SizedBox(height: 2),

Text(
  'Sub Category: $subCategoryName',
  style: const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Color.fromARGB(255, 112, 100, 92),
  ),
),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              _StatusSwitch(
                isActive: item.isActive,
                enabled: onToggle != null,
                onChanged: (_) => onToggle?.call(),
              ),

              const SizedBox(width: 6),

              
                SizedBox(
              width: 26,
             height: 26,
              child: IconButton(
              tooltip: 'Edit item',
               onPressed: onEdit,
              padding: EdgeInsets.zero,
              icon: const Icon(
              Icons.edit_outlined,
              size: 19,
                ),
               color: Colors.black,
               ),
               ),
                
            ],
          ),

          

        
        ],
      ),
    );
  }
}
