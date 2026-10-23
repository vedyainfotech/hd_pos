import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../inventory_category/models/inventory_category_model.dart';
import '../../inventory_category/services/inventory_category_service.dart';
import '../models/inv_subcategory_model.dart';
import '../services/inv_subcategory_service.dart';

class InvSubCategoryScreen extends StatefulWidget {
  const InvSubCategoryScreen({super.key});

  @override
  State<InvSubCategoryScreen> createState() => _InvSubCategoryScreenState();
}

class _InvSubCategoryScreenState extends State<InvSubCategoryScreen> {
  final InventoryCategoryApiService _categoryService =
      InventoryCategoryApiService();

  final InvSubCategoryApiService _subCategoryService =
      InvSubCategoryApiService();

  final TextEditingController _searchController = TextEditingController();

  List<InventoryCategoryModel> _categories = [];
  List<InvSubCategoryModel> _subCategories = [];

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

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _categoryService.getCategories(includeInactive: true),
        _subCategoryService.getSubCategories(includeInactive: true),
      ]);

      if (!mounted) return;

      setState(() {
        _categories = results[0] as List<InventoryCategoryModel>;
        _subCategories = results[1] as List<InvSubCategoryModel>;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      _showMessage('Failed to load inventory subcategories', isError: true);
    }
  }

  void _onSearchChanged() => setState(() {});

  List<InvSubCategoryModel> get _filteredSubCategories {
    final search = _searchController.text.trim().toLowerCase();

    return _subCategories.where((item) {
      final categoryMatch =
          _selectedCategoryId == null ||
          item.categoryId == _selectedCategoryId;

      final statusMatch = _statusFilter == 'All' ||
          (_statusFilter == 'Active' && item.status) ||
          (_statusFilter == 'Inactive' && !item.status);

      final searchMatch =
          search.isEmpty || item.name.toLowerCase().contains(search);

      return categoryMatch && statusMatch && searchMatch;
    }).toList();
  }

  String _categoryName(int categoryId) {
    for (final category in _categories) {
      if (category.id == categoryId) return category.name;
    }
    return 'Unknown Category';
  }

  Future<void> _toggleStatus(InvSubCategoryModel item) async {
    final newStatus = !item.status;
    final confirmed = await _showStatusConfirmation(newStatus);
    if (!confirmed || !mounted) return;

    try {
      final updated = await _subCategoryService.updateSubCategoryStatus(
        item.id,
        newStatus,
      );
      if (!mounted) return;
      setState(() {
        final index = _subCategories.indexWhere((e) => e.id == item.id);
        if (index != -1) _subCategories[index] = updated;
      });
      _showMessage(
        newStatus
            ? 'Inventory subcategory activated successfully'
            : 'Inventory subcategory deactivated successfully',
      );
    } catch (error) {
      if (!mounted) return;
      _showMessage('Failed to update status: $error', isError: true);
    }
  }

  Future<bool> _showStatusConfirmation(bool activate) async {
    final action = activate ? 'Activate' : 'Deactivate';
    final actionLower = activate ? 'activate' : 'deactivate';
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                    activate ? Icons.check_rounded : Icons.priority_high_rounded,
                    size: 42,
                    color: activate ? const Color(0xFF2E7D32) : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '$action Inventory Subcategory?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to $actionLower this inventory subcategory?',
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
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(action),
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
    return result ?? false;
  }

  Future<void> _openAddPanel() async {
    await _openSubCategoryPanel();
  }

  Future<void> _openEditPanel(InvSubCategoryModel item) async {
    await _openSubCategoryPanel(subCategory: item);
  }

  Future<void> _openSubCategoryPanel({
    InvSubCategoryModel? subCategory,
  }) async {
    final result = await showDialog<InvSubCategoryFormResult>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 24,
        ),
        child: _InvSubCategoryFormSheet(
          categories: _categories,
          subCategory: subCategory,
        ),
      ),
    );

    if (result == null) return;

    try {
      if (subCategory == null) {
        final created = await _subCategoryService.createSubCategory(
          categoryId: result.categoryId,
          name: result.name,
        );

        if (!mounted) return;

        setState(() => _subCategories.add(created));
        _showMessage('Inventory subcategory created successfully');
      } else {
        final updated = await _subCategoryService.updateSubCategory(
          id: subCategory.id,
          categoryId: result.categoryId,
          name: result.name,
          status: result.status,
        );

        if (!mounted) return;

        setState(() {
          final index =
              _subCategories.indexWhere((item) => item.id == updated.id);
          if (index != -1) {
            _subCategories[index] = updated;
          }
        });

        _showMessage('Inventory subcategory updated successfully');
      }
    } catch (error) {
      _showMessage('Operation failed: $error', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    final overlay = Overlay.of(context);
    final backgroundColor =
        isError ? const Color(0xFFFFE5E5) : const Color(0xFFE5F7E9);
    final iconColor =
        isError ? const Color(0xFFD32F2F) : const Color(0xFF1E9E45);
    final icon = isError ? Icons.close_rounded : Icons.check_rounded;

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 12,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 320),
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
      ),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 3), () {
      if (entry.mounted) entry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Inventory Sub Categories'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1200;
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
              const SizedBox(height: 16),
              if (!isMobile) ...[
                _buildListHeading(),
                const SizedBox(height: 10),
              ],
              Expanded(child: _buildSubCategoryCards(isMobile)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPageHeader(bool isCompact, bool isDesktop) {
    if (isCompact) {
      return const Padding(
        padding: EdgeInsets.only(top: 6),
        child: Text(
          'Manage your inventory subcategories',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              'Manage your inventory subcategories',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ),
        ),
        _buildAddButton(isDesktop),
      ],
    );
  }

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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

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
                        ElevatedButton.icon(
                          onPressed: _openAddPanel,
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text('Add'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(96, 48),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textOnPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
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
                      child: _buildStatusFilter(true),
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
                      child: _buildStatusFilter(false),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

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
            child: Text(
              category.name,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() => _selectedCategoryId = value);
      },
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search inventory subcategories...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                onPressed: _searchController.clear,
                icon: const Icon(Icons.clear),
              )
            : null,
      ),
    );
  }

  Widget _buildStatusFilter(bool isMobile) {
    const options = ['All', 'Active', 'Inactive'];

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
          final selected = _statusFilter == option;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () {
                    if (_statusFilter == option) return;
                    setState(() => _statusFilter = option);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    height: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primarySoft
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Text(
                      option,
                      maxLines: 1,
                      softWrap: false,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
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
            ),
          );
        }).toList(),
      ),
    );
  }

  // Fixed heading: stays visible while only the item list scrolls.
  // Price is intentionally omitted for inventory subcategories.
  Widget _buildListHeading() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Expanded(
            flex: 3,
            child: Text(
              'SUBCATEGORY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'CATEGORY',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 140,
            child: Text(
              'ACTION',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubCategoryCards(bool isMobile) {
    final items = _filteredSubCategories;
    if (items.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildSubCategoryCard(item, isMobile: isMobile),
        );
      },
    );
  }

  Widget _buildSubCategoryCard(
    InvSubCategoryModel item, {
    required bool isMobile,
  }) {
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
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    _buildStatusSwitch(item),
                    const SizedBox(width: 4),
                    _buildEditButton(item),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _categoryName(item.categoryId),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      _categoryName(item.categoryId),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildStatusSwitch(item),
                      const SizedBox(width: 8),
                      _buildEditButton(item),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatusSwitch(InvSubCategoryModel item) {
    return SwitchTheme(
      data: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((_) => Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.grey.withValues(alpha: 0.35);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      child: Switch(
        value: item.status,
        onChanged: (_) => _toggleStatus(item),
      ),
    );
  }

  Widget _buildEditButton(InvSubCategoryModel item) {
    return IconButton(
      tooltip: 'Edit',
      onPressed: () => _openEditPanel(item),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      icon: const Icon(Icons.edit_outlined, size: 19, color: AppColors.icon),
    );
  }



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
              children: const [
                Text(
                  'No inventory subcategories found',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Try changing your filters or add a new inventory subcategory.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InvSubCategoryFormResult {
  final int categoryId;
  final String name;
  final bool status;

  const InvSubCategoryFormResult({
    required this.categoryId,
    required this.name,
    required this.status,
  });
}

class _InvSubCategoryFormSheet extends StatefulWidget {
  final List<InventoryCategoryModel> categories;
  final InvSubCategoryModel? subCategory;

  const _InvSubCategoryFormSheet({
    required this.categories,
    this.subCategory,
  });

  @override
  State<_InvSubCategoryFormSheet> createState() =>
      _InvSubCategoryFormSheetState();
}

class _InvSubCategoryFormSheetState
    extends State<_InvSubCategoryFormSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;

  int? _selectedCategoryId;
  late bool _status;

  bool get _isEditing => widget.subCategory != null;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.subCategory?.name ?? '',
    );

    _selectedCategoryId = widget.subCategory?.categoryId;
    _status = widget.subCategory?.status ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final categoryId = _selectedCategoryId;
    if (categoryId == null) return;

    final result = InvSubCategoryFormResult(
      categoryId: categoryId,
      name: _nameController.text.trim(),
      status: _status,
    );

    Navigator.of(context).pop(result);
  }

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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 22, 16, 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _isEditing
                  ? 'Edit Inventory Subcategory'
                  : 'Add Inventory Subcategory',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.close,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Inventory Category',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _buildCategoryField(),
          const SizedBox(height: 10),
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
          if (_isEditing) ...[
            const SizedBox(height: 10),
            _buildStatusField(),
          ],
        ],
      ),
    );
  }

 
Widget _buildCategoryField() {
  return SizedBox(
    height: 72,
    child: DropdownButtonFormField<int>(
      initialValue: _selectedCategoryId,
      decoration: const InputDecoration(
        hintText: 'Select inventory category',
        errorMaxLines: 1,
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
      onChanged: (value) {
        setState(() => _selectedCategoryId = value);
      },
      validator: (value) {
        if (value == null) return 'Please select a category';
        return null;
      },
    ),
  );
}


 
Widget _buildNameField() {
  return SizedBox(
    height: 88,
    child: TextFormField(
      controller: _nameController,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textCapitalization: TextCapitalization.words,
      maxLength: 50,
      buildCounter: (
        context, {
        required currentLength,
        required isFocused,
        maxLength,
      }) {
        return null;
      },
      decoration: const InputDecoration(
        hintText: 'Enter inventory subcategory name',
        errorMaxLines: 2,
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
    ),
  );
}

  Widget _buildStatusField() {
    return Container(
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
                  _status ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 12,
                    color: _status
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
                  WidgetStateProperty.resolveWith((_) => Colors.white),
              trackColor:
                  WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.primary;
                }
                return Colors.grey.withValues(alpha: 0.35);
              }),
              trackOutlineColor:
                  WidgetStateProperty.all(Colors.transparent),
            ),
            child: Switch(
              value: _status,
              onChanged: (value) {
                setState(() => _status = value);
              },
            ),
          ),
        ],
      ),
    );
  }

  
Widget _buildFooter() {
  return Container(
    padding: const EdgeInsets.fromLTRB(24, 16, 24, 22),
    decoration: const BoxDecoration(
      border: Border(
        top: BorderSide(color: AppColors.divider),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(100, 44),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            foregroundColor: AppColors.textSecondary,
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(fontSize: 14),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(_isEditing ? 130 : 100, 44),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
          ),
          child: Text(
            _isEditing ? 'Update' : 'Add',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
    }