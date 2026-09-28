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

  final TextEditingController _categoryController = TextEditingController();

  final TextEditingController _searchController = TextEditingController();

  List<CategoryModel> _categories = [];

  bool _isLoading = true;
  bool _isSaving = false;

  int? _editingId;

  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {});
    });

    _loadCategories();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // API
  // ============================================================

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final categories = await _apiService.getCategories(includeInactive: true);

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

      _showMessage('Failed to load categories', isError: true);
    }
  }

  Future<void> _saveCategory() async {
    final name = _categoryController.text.trim();

    if (name.isEmpty) {
      _showMessage('Please enter category name', isError: true);
      return;
    }

    final isEditing = _editingId != null;

    setState(() {
      _isSaving = true;
    });

    try {
      if (!isEditing) {
        await _apiService.createCategory(name);
      } else {
        await _apiService.updateCategory(_editingId!, name);
      }

      if (!mounted) return;

      Navigator.of(context).pop();

      await _loadCategories();

      if (!mounted) return;

      _showMessage(
        isEditing
            ? 'Category updated successfully'
            : 'Category added successfully',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage('Failed to save category', isError: true);
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
      await _apiService.updateCategoryStatus(category.id, !category.isActive);

      await _loadCategories();
    } catch (e) {
      if (!mounted) return;

      _showMessage('Failed to update category status', isError: true);
    }
  }

  // ============================================================
  // FORM
  // ============================================================

  void _openAddPanel() {
    _editingId = null;
    _categoryController.clear();

    _showCategoryPanel(title: 'Add Category', buttonText: 'Add Category');
  }

  void _openEditPanel(CategoryModel category) {
    _editingId = category.id;
    _categoryController.text = category.name;

    _showCategoryPanel(title: 'Edit Category', buttonText: 'Update Category');
  }

  void _showCategoryPanel({required String title, required String buttonText}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
                              : () => Navigator.of(context).pop(),
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
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),

                    const SizedBox(height: 32),

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
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _saveCategory(),
                      decoration: InputDecoration(
                        hintText: 'Enter category name',
                        hintStyle: const TextStyle(color: AppColors.textTertiary),
                        filled: true,
                        fillColor: AppColors.inputBackground,
                        contentPadding: const EdgeInsets.symmetric(
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

                    const Spacer(),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSaving
                                ? null
                                : () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                             side: BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: AppColors.icon),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveCategory,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textOnPrimary,
                              minimumSize: const Size(double.infinity, 48),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                     color: AppColors.textOnPrimary,
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
    final search = _searchController.text.trim().toLowerCase();

    return _categories.where((category) {
      final matchesSearch = category.name.toLowerCase().contains(search);

      final matchesStatus =
          _statusFilter == 'All' ||
          (_statusFilter == 'Active' && category.isActive) ||
          (_statusFilter == 'Inactive' && !category.isActive);

      return matchesSearch && matchesStatus;
    }).toList();
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
backgroundColor: isError ? AppColors.error : null,
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
                      padding: const EdgeInsets.fromLTRB(32, 28, 32, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPageHeader(),

                          const SizedBox(height: 24),

                          _buildToolbar(),

                          const SizedBox(height: 14),

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
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
border: Border(
  bottom: BorderSide(color: AppColors.borderLight),
),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).pop(),
icon: const Icon(Icons.arrow_back, color: AppColors.icon),
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

          const Spacer(),

          ElevatedButton.icon(
            onPressed: _openAddPanel,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Category'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAGE HEADER
  // ============================================================

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(width: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_categories.length}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        const Text(
          'Manage your product categories.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  // ============================================================
  // TOOLBAR
  // ============================================================

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search categories...',
                hintStyle: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 20,
                  color: AppColors.textTertiary,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                        },
                        icon: const Icon(Icons.close, size: 18),
                      )
                    : null,
                filled: true,
                fillColor: AppColors.inputBackground,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
            color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _statusFilter,
                icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All Status')),
                  DropdownMenuItem(value: 'Active', child: Text('Active')),
                  DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                ],
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _statusFilter = value;
                  });
                },
              ),
            ),
          ),
        ],
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
        padding: const EdgeInsets.symmetric(vertical: 70),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
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
              _searchController.text.isNotEmpty || _statusFilter != 'All'
                  ? 'Try changing your search or filter.'
                  : 'Add your first category to get started.',
              style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          _buildTableHeader(),

          const Divider(height: 1),

          ...List.generate(categories.length, (index) {
            final category = categories[index];

            return Column(
              children: [
                _buildCategoryRow(category),

                if (index != categories.length - 1)
                  const Divider(height: 1, color: AppColors.borderLight),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 22, vertical: 15),
      child: Row(
        children: [
          Expanded(
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

          SizedBox(
            width: 155,
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

  Widget _buildCategoryRow(CategoryModel category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
      child: Row(
        children: [
          Expanded(
            child: Text(
              category.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          SizedBox(
            width: 155,
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
                  category.isActive ? 'Active' : 'Inactive',
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
                    activeThumbColor: AppColors.primary,
                    onChanged: (_) {
                      _toggleStatus(category);
                    },
                  ),
                ),
              ],
            ),
          ),

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
