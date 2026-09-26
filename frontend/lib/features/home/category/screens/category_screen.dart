import 'package:flutter/material.dart';

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

  List<CategoryModel> _categories = [];

  bool _isLoading = true;
  bool _isSaving = false;

  bool _showForm = false;
  int? _editingId;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

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

  void _openAddForm() {
    setState(() {
      _editingId = null;
      _categoryController.clear();
      _showForm = true;
    });
  }

  void _openEditForm(CategoryModel category) {
    setState(() {
      _editingId = category.id;
      _categoryController.text = category.name;
      _showForm = true;
    });
  }

  void _closeForm() {
    setState(() {
      _showForm = false;
      _editingId = null;
      _categoryController.clear();
    });
  }

  Future<void> _saveCategory() async {
    final name = _categoryController.text.trim();

    if (name.isEmpty) {
      _showMessage(
        'Please enter category name',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (_editingId == null) {
        await _apiService.createCategory(name);
      } else {
        await _apiService.updateCategory(
          _editingId!,
          name,
        );
      }

      if (!mounted) return;

      _closeForm();

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
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to update category status',
        isError: true,
      );
    }
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: _showForm ? _closeForm : _openAddForm,
              icon: Icon(
                _showForm ? Icons.close : Icons.add,
                size: 18,
              ),
              label: Text(
                _showForm ? 'Close' : 'Add Category',
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_showForm) _buildCategoryForm(),

                  if (_showForm)
                    const SizedBox(height: 24),

                  _buildCategoryList(),
                ],
              ),
            ),
    );
  }

  Widget _buildCategoryForm() {
    final isEditing = _editingId != null;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'Edit Category' : 'Add Category',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 18),

            TextField(
              controller: _categoryController,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _saveCategory(),
              decoration: InputDecoration(
                labelText: 'Category Name',
                hintText: 'Enter category name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _isSaving ? null : _closeForm,
                  child: const Text('Cancel'),
                ),

                const SizedBox(width: 12),

                ElevatedButton(
                  onPressed: _isSaving ? null : _saveCategory,
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isEditing ? 'Update' : 'Save',
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    if (_categories.isEmpty) {
      return Card(
        elevation: 0,
        child: SizedBox(
          width: double.infinity,
          height: 180,
          child: Center(
            child: Text(
              'No categories found',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),

          const Divider(height: 1),

          ..._categories.map(
            (category) => _buildCategoryRow(category),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Category Name',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              'Status',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              'Edit',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(CategoryModel category) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  category.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              SizedBox(
                width: 120,
                child: Switch(
                  value: category.isActive,
                  onChanged: (_) {
                    _toggleStatus(category);
                  },
                ),
              ),

              SizedBox(
                width: 80,
                child: IconButton(
                  tooltip: 'Edit',
                  onPressed: () {
                    _openEditForm(category);
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),

        if (category != _categories.last)
          const Divider(height: 1),
      ],
    );
  }
}