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
              constraints: const BoxConstraints(maxWidth: 320),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

    Future.delayed(const Duration(seconds: 3), () {
      if (entry.mounted) {
        entry.remove();
      }
    });
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
              constraints: const BoxConstraints(maxWidth: 320),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

    Future.delayed(const Duration(seconds: 3), () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }

  List<SubCategoryModel> get _filteredSubCategoryOptions {
    if (_selectedCategoryFilter == null) {
      return _subCategories;
    }

    return _subCategories
        .where(
          (subCategory) => subCategory.categoryId == _selectedCategoryFilter,
        )
        .toList();
  }

  List<ItemModel> get _filteredItems {
    final search = _searchController.text.trim().toLowerCase();

    return _items.where((item) {
      final matchesCategory =
          _selectedCategoryFilter == null ||
          item.categoryId == _selectedCategoryFilter;

      final matchesSubCategory =
          _selectedSubCategoryFilter == null ||
          item.subCategories.any(
            (mapping) => mapping.subCategoryId == _selectedSubCategoryFilter,
          );

      final matchesStatus =
          _statusFilter == 'All' ||
          (_statusFilter == 'Active' && item.isActive) ||
          (_statusFilter == 'Inactive' && !item.isActive);

      final categoryName = _categoryName(item.categoryId).toLowerCase();
      final subCategoryName = item.subCategories
          .map((mapping) => _subCategoryName(mapping.subCategoryId))
          .join(' ')
          .toLowerCase();

      final matchesSearch =
          search.isEmpty ||
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

    // The API intentionally reuses an item with the same normalized name
    // in the same category. Check whether this submission changes anything so
    // the UI never reports a successful add for a no-op submission.
    final normalizedName = result.name.toLowerCase().replaceAll(RegExp(r'\s+'), '');
    final existingByName = item == null
        ? _items.where((entry) =>
            entry.categoryId == result.categoryId &&
            entry.name.toLowerCase().replaceAll(RegExp(r'\s+'), '') == normalizedName,
          ).firstOrNull
        : null;

    bool hasChanges = true;
    if (existingByName != null) {
      hasChanges = result.subCategories.any((requested) {
        final oldMapping = existingByName.subCategories
            .where((mapping) => mapping.subCategoryId == requested.subCategoryId)
            .firstOrNull;
        return oldMapping == null ||
            oldMapping.price != requested.price ||
            oldMapping.sameAsSubCategory != requested.sameAsSubCategory ||
            oldMapping.status != requested.status;
      });
      if (!hasChanges) {
        // This is a duplicate submission with no mapping/price changes.
        // Show it as an error (red), never as a successful add (green).
        _showError('Already there is item with the same name and sub-category');
        return;
      }
    }

    try {
      setState(() {
        _isSaving = true;
      });

      if (item == null) {
        await _itemService.createItem(
          categoryId: result.categoryId,
          itemName: result.name,
          subCategories: result.subCategories,
          status: true,
        );

        _showSuccess(existingByName == null
            ? 'Item added successfully'
            : 'Existing item and subcategory prices updated successfully');
      } else {
        await _itemService.updateItem(
          id: item.id,
          categoryId: result.categoryId,
          itemName: result.name,
          subCategories: result.subCategories,
          status: result.isActive,
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

    final newStatus = !item.isActive;

    final confirmed = await _showStatusConfirmation(newStatus);

    if (!confirmed || !mounted) return;

    try {
      await _itemService.updateItemStatus(item.id, newStatus);

      await _refreshItems();

      if (!mounted) return;
    } catch (e) {
      if (mounted) {
        _showError(_cleanError(e));
      }
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
                    '$action Item?',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Are you sure you want to $actionLower this item?',
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
                            foregroundColor: AppColors.textPrimary,
                            backgroundColor: AppColors.surface,
                            side: const BorderSide(color: AppColors.border),
                            minimumSize: const Size.fromHeight(50),
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
                        child: FilledButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 28, 30, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(),
          const SizedBox(height: 22),
          _buildFilterCard(),
          const SizedBox(height: 18),
          Expanded(child: _buildItemListCard()),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(),
          const SizedBox(height: 18),
          _buildFilterCard(tablet: true),
          const SizedBox(height: 16),
          Expanded(child: _buildItemListCard(compact: true)),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(mobile: true),
          const SizedBox(height: 14),
          _buildFilterCard(mobile: true),
          const SizedBox(height: 14),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _refreshItems,
              child: _buildItemListCard(mobile: true),
            ),
          ),
        ],
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
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 17),
              minimumSize: const Size(110, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 19),
                SizedBox(width: 6),
                Text(
                  'Add',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFilterCard({bool tablet = false, bool mobile = false}) {
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
                      Expanded(child: _buildFilterSearch()),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : () => _openItemForm(),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
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
        const DropdownMenuItem<int>(value: 0, child: Text('All Categories')),
        ..._categories.map(
          (category) => DropdownMenuItem<int>(
            value: category.id,
            child: Text(category.name, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: (value) {
        _onCategoryFilterChanged(value == null || value == 0 ? null : value);
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
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
    );
  }

  Widget _buildStatusFilter({bool compact = false, bool mobile = false}) {
    const options = ['All', 'Active', 'Inactive'];

    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) {
          final selected = _statusFilter == option;

          return SizedBox(
            width: compact ? 64 : 70,
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
                  color: selected ? AppColors.primarySoft : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: selected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildItemListCard({bool compact = false, bool mobile = false}) {
    final items = _filteredItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Item List',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        if (_isLoading)
          const SizedBox(
            height: 260,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (items.isEmpty)
          _buildEmptyState()
        else
          Expanded(child: _buildItemTableWithCards(items, mobile: mobile)),
      ],
    );
  }

  Widget _buildItemTableWithCards(
    List<ItemModel> items, {
    required bool mobile,
  }) {
    Widget buildRows() => ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return _ItemCard(
          item: item,
          categoryName: _categoryName(item.categoryId),
          subCategoryName: item.subCategories
              .map((mapping) => _subCategoryName(mapping.subCategoryId))
              .join(', '),
          onEdit: _isSaving ? null : () => _openItemForm(item: item),
          onToggle: _isSaving ? null : () => _toggleStatus(item),
        );
      },
    );

    if (!mobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildItemColumnHeader(false),
          const SizedBox(height: 10),
          Expanded(child: buildRows()),
        ],
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 820,
        child: Column(
          children: [
            _buildItemColumnHeader(true),
            const SizedBox(height: 10),
            Expanded(child: buildRows()),
          ],
        ),
      ),
    );
  }

  Widget _buildItemColumnHeader(bool isMobile) {
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
            child: _buildItemColumnHeading(
              'Item Name',
              align: TextAlign.left,
              isMobile: isMobile,
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildItemColumnHeading(
              'Category',
              align: TextAlign.center,
              isMobile: isMobile,
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildItemColumnHeading(
              'Sub Category',
              align: TextAlign.center,
              isMobile: isMobile,
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildItemColumnHeading(
              'Price (₹)',
              align: TextAlign.center,
              isMobile: isMobile,
            ),
          ),
          SizedBox(
            width: isMobile ? 108 : 140,
            child: _buildItemColumnHeading(
              'Actions',
              align: TextAlign.right,
              isMobile: isMobile,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemColumnHeading(
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

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 350),
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
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
  final Map<int, TextEditingController> _subCategoryPriceControllers = {};

  List<SubCategoryModel> _subCategories = [];

  int? _selectedCategoryId;
  final Set<int> _selectedSubCategoryIds = <int>{};
  double? _categoryPrice;
  bool status = true;
  bool _sameAsCategory = false;
  bool _loadingSubCategories = false;

  @override
  void initState() {
    super.initState();

    final existing = widget.existingItem;

    if (existing != null) {
      _nameController.text = existing.itemName;
      _selectedCategoryId = existing.categoryId;
      _selectedSubCategoryIds.addAll(
        existing.subCategories.map((mapping) => mapping.subCategoryId),
      );
      for (final mapping in existing.subCategories) {
        _priceControllerFor(mapping.subCategoryId).text =
            mapping.price.toStringAsFixed(2);
      }
      _sameAsCategory = existing.subCategories.length == 1 &&
          existing.subCategories.first.sameAsSubCategory;
      status = existing.status;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadSubCategories(
          existing.categoryId,
          initialSubCategoryIds: existing.subCategories
              .map((mapping) => mapping.subCategoryId)
              .toList(),
        );
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final controller in _subCategoryPriceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadSubCategories(
    int categoryId, {
    List<int> initialSubCategoryIds = const [],
  }) async {
    if (mounted) {
      setState(() {
        _loadingSubCategories = true;
        if (initialSubCategoryIds.isNotEmpty) {
          _selectedSubCategoryIds
            ..clear()
            ..addAll(initialSubCategoryIds);
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

        _selectedSubCategoryIds.removeWhere(
          (id) => !data.any((subCategory) => subCategory.id == id),
        );
        for (final subCategory in data) {
          final controller = _priceControllerFor(subCategory.id);
          if (controller.text.isEmpty &&
              _selectedSubCategoryIds.contains(subCategory.id)) {
            final existingMapping = widget.existingItem?.subCategories
                .where((mapping) => mapping.subCategoryId == subCategory.id)
                .firstOrNull;
            controller.text = (existingMapping?.price ?? subCategory.price)
                .toStringAsFixed(2);
          }
        }
        final firstSelected = _selectedSubCategoryIds.isNotEmpty
            ? _selectedSubCategoryIds.first
            : null;
        _categoryPrice = firstSelected == null
            ? null
            : data.where((entry) => entry.id == firstSelected).firstOrNull?.price;
      });
    } catch (e) {
      if (mounted) {
        _showError(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingSubCategories = false;
        });
      }
    }
  }

  TextEditingController _priceControllerFor(int subCategoryId) {
    return _subCategoryPriceControllers.putIfAbsent(
      subCategoryId,
      TextEditingController.new,
    );
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

          final controller = _priceControllerFor(subCategoryId);
          if (controller.text.isEmpty || _sameAsCategory || updateItemPrice) {
            controller.text = subCategory.price.toStringAsFixed(2);
          }
        });

        return;
      }
    }
  }

  void _onCategoryChanged(int? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _selectedSubCategoryIds.clear();
      _sameAsCategory = false;
      _subCategories = [];
      _categoryPrice = null;
      for (final controller in _subCategoryPriceControllers.values) {
        controller.clear();
      }
    });

    if (categoryId != null) {
      _loadSubCategories(categoryId);
    }
  }

  void _onSubCategoryToggled(int subCategoryId, bool selected) {
    setState(() {
      if (selected) {
        _selectedSubCategoryIds.add(subCategoryId);
      } else {
        _selectedSubCategoryIds.remove(subCategoryId);
      }
      if (selected) {
        final subCategory = _subCategories.where((entry) => entry.id == subCategoryId).firstOrNull;
        final controller = _priceControllerFor(subCategoryId);
        if (controller.text.isEmpty && subCategory != null) {
          controller.text = subCategory.price.toStringAsFixed(2);
        }
      } else {
        _priceControllerFor(subCategoryId).clear();
      }
      if (_selectedSubCategoryIds.length != 1) {
        _sameAsCategory = false;
      }
      _categoryPrice = null;
      if (_selectedSubCategoryIds.length == 1) {
        _setCategoryPrice(_selectedSubCategoryIds.first, _subCategories, updateItemPrice: _sameAsCategory);
      }
    });
  }

  void _onSameAsCategoryChanged(bool? value) {
    final checked = value ?? false;
    if (_selectedSubCategoryIds.length != 1) return;

    setState(() {
      _sameAsCategory = checked;
      if (checked && _categoryPrice != null && _selectedSubCategoryIds.length == 1) {
        _priceControllerFor(_selectedSubCategoryIds.first).text =
            _categoryPrice!.toStringAsFixed(2);
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      _showError('Please select a category');
      return;
    }
    if (_selectedSubCategoryIds.isEmpty) {
      _showError('Please select at least one sub category');
      return;
    }

    for (final id in _selectedSubCategoryIds) {
      final priceText = _priceControllerFor(id).text.trim();
      final price = double.tryParse(priceText);
      if (price == null || price < 0) {
        final subCategory = _subCategories.where((entry) => entry.id == id).firstOrNull;
        _showError('Enter a valid price for ${subCategory?.name ?? 'the selected sub category'}');
        return;
      }
    }

    Navigator.pop(
      context,
      _ItemFormResult(
        categoryId: _selectedCategoryId!,
        subCategories: _selectedSubCategoryIds.map((id) {
          return ItemSubCategoryRequest(
            subCategoryId: id,
            price: _sameAsCategory && _selectedSubCategoryIds.length == 1
                ? (_categoryPrice ?? double.parse(_priceControllerFor(id).text.trim()))
                : double.parse(_priceControllerFor(id).text.trim()),
            sameAsSubCategory:
                _selectedSubCategoryIds.length == 1 && _sameAsCategory,
            status: true,
          );
        }).toList(),
        name: _nameController.text.trim(),
        isActive: status,
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
              constraints: const BoxConstraints(maxWidth: 320),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

    Future.delayed(const Duration(seconds: 3), () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingItem != null;
    final width = MediaQuery.sizeOf(context).width;
    final dialogWidth = width < 600 ? width - 28 : 620.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(14),
      child: SizedBox(
        width: dialogWidth,
        // Keep the dialog's outer height constant before and after
        // subcategory selection. Overflowing form content scrolls inside it.
        height: MediaQuery.sizeOf(context).height * 0.82,
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
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
                    decoration: _inputDecoration(hint: 'Select Category'),
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
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 170),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _selectedCategoryId == null
                        ? const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 15,
                            ),
                            child: Text(
                              'Select category first',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        : _loadingSubCategories
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          )
                        : _subCategories.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: Text(
                              'No sub categories available',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        : ListView(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            children: _subCategories.map((subCategory) {
                              final selected = _selectedSubCategoryIds
                                  .contains(subCategory.id);
                              return CheckboxListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                controlAffinity: ListTileControlAffinity.leading,
                                activeColor: AppColors.primary,
                                title: Text(
                                  subCategory.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                value: selected,
                                onChanged: (value) => _onSubCategoryToggled(
                                  subCategory.id,
                                  value ?? false,
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                  if (_selectedSubCategoryIds.isEmpty &&
                      _selectedCategoryId != null)
                    const Padding(
                      padding: EdgeInsets.only(top: 5, left: 12),
                      child: Text(
                        'Select at least one sub category',
                        style: TextStyle(fontSize: 11, color: AppColors.error),
                      ),
                    ),
                  const SizedBox(height: 18),
                  if (_selectedSubCategoryIds.isNotEmpty) ...[
                    _buildLabel(
                      _selectedSubCategoryIds.length == 1
                          ? 'Sub Category Price'
                          : 'Sub Category Prices',
                    ),
                    const SizedBox(height: 7),
                    ..._subCategories
                        .where((subCategory) =>
                            _selectedSubCategoryIds.contains(subCategory.id))
                        .map((subCategory) {
                      final priceController =
                          _priceControllerFor(subCategory.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subCategory.name,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 5),
                            TextFormField(
                              controller: priceController,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              readOnly: _sameAsCategory &&
                                  _selectedSubCategoryIds.length == 1,
                              decoration: _inputDecoration(
                                hint: 'Enter price for ${subCategory.name}',
                              ).copyWith(
                                fillColor: _sameAsCategory &&
                                        _selectedSubCategoryIds.length == 1
                                    ? AppColors.surfaceSoft
                                    : AppColors.inputBackground,
                              ),
                              validator: (value) {
                                if (!_selectedSubCategoryIds.contains(subCategory.id)) {
                                  return null;
                                }
                                if (value == null || value.trim().isEmpty) {
                                  return 'Enter price';
                                }
                                final price = double.tryParse(value.trim());
                                if (price == null || price < 0) {
                                  return 'Enter a valid price';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 8),
                  _buildLabel('Item Name', required: true),
                  const SizedBox(height: 7),
                  TextFormField(
                    controller: _nameController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textCapitalization: TextCapitalization.sentences,
                    maxLength: 50,
                    buildCounter:
                        (
                          context, {
                          required currentLength,
                          required isFocused,
                          maxLength,
                        }) {
                          return null;
                        },
                    decoration: _inputDecoration(hint: 'Enter Item Name'),
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
                  const SizedBox(height: 16),
                  if (_selectedSubCategoryIds.length == 1)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        border: Border.all(color: AppColors.border),
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
                  if (isEditing) ...[
                    const SizedBox(height: 18),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
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
                              thumbColor: WidgetStateProperty.resolveWith(
                                (_) => Colors.white,
                              ),
                              trackColor: WidgetStateProperty.resolveWith((
                                states,
                              ) {
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
                              value: status,
                              onChanged: (value) {
                                setState(() {
                                  status = value;
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
                  ),
                ),
              ),
              Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    minimumSize: const Size(88, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 14),
                FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(100, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    isEditing ? 'Update Item' : 'Save Item',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
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
                  style: TextStyle(color: AppColors.error),
                ),
              ]
            : null,
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.inputBackground,

      // Reserve one validation line even when there is no error.
      // This prevents live validation from changing the dialog height.
      helperText: ' ',
      helperStyle: const TextStyle(
        fontSize: 12,
        height: 1,
        color: Colors.transparent,
      ),
      errorStyle: const TextStyle(
        fontSize: 12,
        height: 1,
        color: AppColors.error,
      ),
      errorMaxLines: 1,

      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.2),
      ),
    );
  }
}

class _ItemFormResult {
  final int categoryId;
  final List<ItemSubCategoryRequest> subCategories;
  final String name;
  final bool isActive;

  const _ItemFormResult({
    required this.categoryId,
    required this.subCategories,
    required this.name,
    required this.isActive,
  });
}

class _SurfaceCard extends StatelessWidget {
  final Widget child;

  const _SurfaceCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
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
            : Icon(icon, size: 19, color: AppColors.icon),
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
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
            color: isActive ? AppColors.primary : const Color(0xFFBDBDBD),
            borderRadius: BorderRadius.circular(20),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 160),
            alignment: isActive ? Alignment.centerRight : Alignment.centerLeft,
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

class _ItemCard extends StatelessWidget {
  final ItemModel item;
  final String categoryName;
  final String subCategoryName;
  final VoidCallback? onEdit;
  final VoidCallback? onToggle;

  const _ItemCard({
    required this.item,
    required this.categoryName,
    required this.subCategoryName,
    required this.onEdit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 700;

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
            child: _cellText(
              item.name,
              align: TextAlign.left,
              bold: true,
              isMobile: isMobile,
            ),
          ),
          Expanded(
            flex: 2,
            child: _cellText(
              categoryName,
              align: TextAlign.center,
              isMobile: isMobile,
            ),
          ),
          Expanded(
            flex: 2,
            child: _cellText(
              subCategoryName,
              align: TextAlign.center,
              isMobile: isMobile,
            ),
          ),
          Expanded(
            flex: 2,
            child: _cellText(
              '₹${item.subCategories.isNotEmpty ? item.subCategories.first.price.toStringAsFixed(2) : '0.00'}',
              align: TextAlign.center,
              bold: true,
              isMobile: isMobile,
            ),
          ),
          SizedBox(
            width: isMobile ? 108 : 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _StatusSwitch(
                  isActive: item.isActive,
                  enabled: onToggle != null,
                  onChanged: (_) => onToggle?.call(),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: isMobile ? 34 : 40,
                  height: 36,
                  child: IconButton(
                    tooltip: 'Edit item',
                    onPressed: onEdit,
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 19,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cellText(
    String value, {
    required TextAlign align,
    required bool isMobile,
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        value,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: align,
        style: TextStyle(
          fontSize: isMobile ? 12 : 14,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          color: bold ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
