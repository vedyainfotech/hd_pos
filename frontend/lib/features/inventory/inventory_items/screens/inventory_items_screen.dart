import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../units/models/units_model.dart';
import '../../units/services/units_service.dart';
import '../../inventory_category/models/inventory_category_model.dart';
import '../../inventory_category/services/inventory_category_service.dart';
import '../../inventory_sub_category/models/inv_subcategory_model.dart';
import '../../inventory_sub_category/services/inv_subcategory_service.dart';
import '../models/inventory_item_model.dart';

class InventoryItemsScreen extends StatefulWidget {
  const InventoryItemsScreen({super.key});

  @override
  State<InventoryItemsScreen> createState() => _InventoryItemsScreenState();
}

class _InventoryItemsScreenState extends State<InventoryItemsScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  final InventoryCategoryApiService _categoryApiService =
      InventoryCategoryApiService();  

  final UnitApiService _unitApiService = UnitApiService();
  final InvSubCategoryApiService _subCategoryApiService =
      InvSubCategoryApiService();

  List<InventoryItemModel> _items = [];
  List<InventoryCategoryModel> _categories = [];
  List<UnitModel> _units = [];
  List<InvSubCategoryModel> _subCategories = [];

  String _statusFilter = 'All';
  int? _selectedCategoryFilter;
  int? _selectedSubCategoryFilter;

  bool _isLoading = true;
  String? _errorMessage;
  String? _message;
  bool _messageIsError = false;
  bool _messageIsWarning = false;
  int _messageVersion = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      // Inventory items are intentionally dummy/local data until the inventory
      // backend is implemented. Categories, units and subcategories still come
      // from their existing modules.
      final results = await Future.wait([
        _categoryApiService.getCategories(includeInactive: true),
        _unitApiService.getUnits(includeInactive: true),
        _subCategoryApiService.getSubCategories(includeInactive: true),
      ]);
      if (!mounted) return;
      final categories = results[0] as List<InventoryCategoryModel>;
      final units = results[1] as List<UnitModel>;
      final subCategories = results[2] as List<InvSubCategoryModel>;
      final activeCategories = categories.where((c) => c.status).toList();
      final activeUnits = units.where((u) => u.status).toList();
      final seeded = <InventoryItemModel>[];
      if (activeCategories.isNotEmpty && activeUnits.isNotEmpty) {
        final cat = activeCategories.first;
        final unit = activeUnits.first;
        final subs = subCategories.where((s) => s.status && s.categoryId == cat.id).toList();
        seeded.addAll([
          InventoryItemModel(id: 1, name: 'Basmati Rice', itemCode: 'INV-001', categoryId: cat.id, subCategoryId: subs.isEmpty ? null : subs.first.id, unitId: unit.id, minimumStockLevel: 5, tax: 5, hsnCode: '100630', openingStock: 25, isActive: true, isProduced: false),
          InventoryItemModel(id: 2, name: 'Cooking Oil', itemCode: 'INV-002', categoryId: cat.id, subCategoryId: subs.isEmpty ? null : subs.first.id, unitId: unit.id, minimumStockLevel: 3, tax: 5, hsnCode: '151219', openingStock: 12, isActive: true, isProduced: false),
          InventoryItemModel(id: 3, name: 'Spice Mix', itemCode: 'INV-003', categoryId: cat.id, subCategoryId: subs.isEmpty ? null : subs.first.id, unitId: unit.id, minimumStockLevel: 2, tax: 5, hsnCode: '091091', openingStock: 1, isActive: false, isProduced: true),
        ]);
      }
      setState(() { _categories = categories; _units = units; _subCategories = subCategories; _items = seeded; _isLoading = false; });
    } catch (error) {
      debugPrint('Failed to load inventory reference data: $error');
      if (!mounted) return;
      setState(() { _isLoading = false; _errorMessage = 'Could not load categories, units, or subcategories. Check those modules and retry.'; });
      _showMessage('Could not load inventory reference data', isError: true);
    }
  }

  // ============================================================
  // FILTER
  // ============================================================

  List<InventoryItemModel> get _filteredItems {
    final query = _searchController.text.trim().toLowerCase();

    return _items.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(query) ||
          (item.itemCode ?? '').toLowerCase().contains(query) ||
          item.hsnCode.toLowerCase().contains(query) ||
          _getCategoryName(item.categoryId).toLowerCase().contains(query) ||
          _getSubCategoryName(item.subCategoryId).toLowerCase().contains(query);
      final matchesStatus = _statusFilter == 'All' ||
          (_statusFilter == 'Active' && item.isActive) ||
          (_statusFilter == 'Inactive' && !item.isActive);
      final matchesCategory = _selectedCategoryFilter == null ||
          item.categoryId == _selectedCategoryFilter;
      final matchesSubCategory = _selectedSubCategoryFilter == null ||
          item.subCategoryId == _selectedSubCategoryFilter;
      return matchesSearch && matchesStatus && matchesCategory && matchesSubCategory;
    }).toList();
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _getCategoryName(int categoryId) {
    try {
      return _categories
          .firstWhere((category) => category.id == categoryId)
          .name;
    } catch (_) {
      return 'Unknown Category';
    }
  }

  String _getSubCategoryName(int? subCategoryId) {
    if (subCategoryId == null) return '—';
    for (final subCategory in _subCategories) {
      if (subCategory.id == subCategoryId) return subCategory.name;
    }
    return '—';
  }

  List<InvSubCategoryModel> get _availableSubCategories {
    if (_selectedCategoryFilter == null) return const [];
    return _subCategories.where((s) =>
      s.categoryId == _selectedCategoryFilter && s.status).toList();
  }

  void _onCategoryFilterChanged(int? categoryId) {
    setState(() {
      _selectedCategoryFilter = categoryId;
      _selectedSubCategoryFilter = null;
    });
  }

  String _getUnitName(int unitId) {
    try {
      return _units.firstWhere((unit) => unit.id == unitId).name;
    } catch (_) {
      return 'Unknown Unit';
    }
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toString();
  }

  void _showMessage(String message, {bool isError = false, bool isWarning = false}) {
    if (!mounted) return;
    setState(() { _message = message; _messageIsError = isError; _messageIsWarning = isWarning; _messageVersion++; });
    final version = _messageVersion;
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _messageVersion == version) setState(() => _message = null);
    });
  }

  Widget _buildTopMessage() {
    if (_message == null) return const SizedBox.shrink();
    final color = _messageIsError ? const Color(0xFFD32F2F) : _messageIsWarning ? const Color(0xFFB87900) : const Color(0xFF1E9E45);
    final background = _messageIsError ? const Color(0xFFFFE5E5) : _messageIsWarning ? const Color(0xFFFFF2D6) : const Color(0xFFE5F7E9);
    return Positioned(top: 70, right: 16, child: Material(color: Colors.transparent, child: Container(
      constraints: const BoxConstraints(maxWidth: 360), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .12), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(_messageIsError ? Icons.close_rounded : _messageIsWarning ? Icons.warning_amber_rounded : Icons.check_rounded, color: color, size: 22), const SizedBox(width: 10), Flexible(child: Text(_message!, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600))), const SizedBox(width: 6), InkWell(onTap: () => setState(() => _message = null), child: Icon(Icons.close, color: color, size: 17))]),
    )));
  }

  // ============================================================
  // ADD ITEM
  // ============================================================

  Future<void> _showAddItemDialog() async {
    final formKey = GlobalKey<FormState>();
    bool showValidation = false;
    final nameController = TextEditingController();
    final itemCodeController = TextEditingController();
    final minimumStockController =
        TextEditingController(text: '0');
    final hsnController = TextEditingController();
    final openingStockController =
        TextEditingController(text: '0');

    int? selectedCategoryId;
    int? selectedSubCategoryId;
    int? selectedUnitId;
    double selectedTax = 0;

    bool isActive = true;
    bool isProduced = false;
    bool isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final screen = MediaQuery.of(context).size;
            return AlertDialog(
              backgroundColor: AppColors.surface,
              surfaceTintColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 10),
              contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              title: const Text('Add Inventory Item', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              content: SizedBox(
                width: (screen.width - 96).clamp(280.0, 620.0),
                height: (screen.height * 0.66).clamp(360.0, 640.0),
                child: Form(
                  key: formKey,
                  autovalidateMode: showValidation ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
                  child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ITEM NAME
                      TextFormField(
                        controller: nameController,
                        textCapitalization:
                            TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Item Name *',
                          hintText: 'Enter item name',
                          errorMaxLines: 2,
                        ),
                        validator: (value) {
                          final name = (value ?? '').trim();
                          if (name.isEmpty) return 'Please enter item name';
                          if (name.length > 100) return 'Please enter up to 100 characters';
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // ITEM CODE
                      TextField(
                        controller: itemCodeController,
                        textCapitalization:
                            TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'Item Code',
                          hintText: 'Optional',
                        ),
                      ),

                      const SizedBox(height: 16),

                      // CATEGORY
                      DropdownButtonFormField<int>(
                        initialValue: selectedCategoryId,
                        decoration: const InputDecoration(labelText: 'Category *'),
                        validator: (value) => value == null ? 'Please select category' : null,
                        items: _categories
                            .where((category) => category.status)
                            .map(
                              (category) => DropdownMenuItem<int>(
                                value: category.id,
                                child: Text(category.name),
                              ),
                            )
                            .toList(),
                        onChanged: isSaving
                            ? null
                            : (value) {
                                setDialogState(() {
                                  selectedCategoryId = value;
                                  selectedSubCategoryId = null;
                                });
                              },
                      ),

                      const SizedBox(height: 16),

                      // SUB CATEGORY
                      DropdownButtonFormField<int>(
                        key: ValueKey('add-subcategory-$selectedCategoryId'),
                        initialValue: selectedSubCategoryId,
                        decoration: const InputDecoration(labelText: 'Sub Category', hintText: 'Select sub category'),
                        items: _subCategories.where((s) => s.status && s.categoryId == selectedCategoryId).map((s) => DropdownMenuItem<int>(value: s.id, child: Text(s.name, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: isSaving || selectedCategoryId == null ? null : (value) => setDialogState(() => selectedSubCategoryId = value),
                      ),

                      const SizedBox(height: 16),

                      // UNIT
                      DropdownButtonFormField<int>(
                        initialValue: selectedUnitId,
                        decoration: const InputDecoration(labelText: 'Unit *'),
                        validator: (value) => value == null ? 'Please select unit' : null,
                        items: _units
                            .where((unit) => unit.status)
                            .map(
                              (unit) => DropdownMenuItem<int>(
                                value: unit.id,
                                child: Text(unit.name),
                              ),
                            )
                            .toList(),
                        onChanged: isSaving
                            ? null
                            : (value) {
                                setDialogState(() {
                                  selectedUnitId = value;
                                });
                              },
                      ),

                      const SizedBox(height: 16),

                      // MINIMUM STOCK LEVEL
                      TextFormField(
                        controller: minimumStockController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Minimum Stock Level *',
                          hintText: 'Enter minimum stock',
                        ),
                        validator: (value) {
                          final number = double.tryParse((value ?? '').trim());
                          if ((value ?? '').trim().isEmpty) return 'Please enter minimum stock level';
                          if (number == null) return 'Please enter a valid number';
                          if (number < 0) return 'Stock level cannot be negative';
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // TAX
                      DropdownButtonFormField<double>(
                        initialValue: selectedTax,
                        decoration: const InputDecoration(
                          labelText: 'Tax / GST *',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 0,
                            child: Text('0%'),
                          ),
                          DropdownMenuItem(
                            value: 5,
                            child: Text('5%'),
                          ),
                          DropdownMenuItem(
                            value: 12,
                            child: Text('12%'),
                          ),
                          DropdownMenuItem(
                            value: 18,
                            child: Text('18%'),
                          ),
                          DropdownMenuItem(
                            value: 28,
                            child: Text('28%'),
                          ),
                        ],
                        onChanged: isSaving
                            ? null
                            : (value) {
                                if (value != null) {
                                  setDialogState(() {
                                    selectedTax = value;
                                  });
                                }
                              },
                      ),

                      const SizedBox(height: 16),

                      // HSN CODE
                      TextFormField(
                        controller: hsnController,
                        decoration: const InputDecoration(
                          labelText: 'HSN Code *',
                          hintText: 'Enter HSN code',
                        ),
                        validator: (value) {
                          final code = (value ?? '').trim();
                          if (code.isEmpty) return 'Please enter HSN code';
                          if (!RegExp(r'^[A-Za-z0-9-]{4,12}$').hasMatch(code)) return 'Enter a valid HSN code';
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // OPENING STOCK
                      TextFormField(
                        controller: openingStockController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Opening Stock *',
                          hintText: 'Enter opening stock',
                        ),
                        validator: (value) {
                          final number = double.tryParse((value ?? '').trim());
                          if ((value ?? '').trim().isEmpty) return 'Please enter opening stock';
                          if (number == null) return 'Please enter a valid number';
                          if (number < 0) return 'Opening stock cannot be negative';
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // ACTIVE
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Active'),
                        value: isActive,
                        onChanged: isSaving
                            ? null
                            : (value) {
                                setDialogState(() {
                                  isActive = value;
                                });
                              },
                      ),

                      // PRODUCED ITEM
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Is this a produced item?',
                        ),
                        value: isProduced,
                        onChanged: isSaving
                            ? null
                            : (value) {
                                setDialogState(() {
                                  isProduced = value;
                                });
                              },
                      ),
                    ],
                  ),
                ),
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: isSaving
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF776A61),
                    side: const BorderSide(color: Color(0xFFE8DAD0)),
                    minimumSize: const Size(115, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(115, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          final name =
                              nameController.text.trim();

                          final itemCode =
                              itemCodeController.text.trim();

                          final hsnCode =
                              hsnController.text.trim();

                          final minimumStock =
                              double.tryParse(
                            minimumStockController.text.trim(),
                          );

                          final openingStock =
                              double.tryParse(
                            openingStockController.text.trim(),
                          );

                          setDialogState(() { showValidation = true; });
                          if (!(formKey.currentState?.validate() ?? false)) return;

                          setDialogState(() {
                            isSaving = true;
                          });

                          try {
                            if (_items.any((i) => i.name.trim().toLowerCase() == name.toLowerCase())) {
                              setDialogState(() { isSaving = false; });
                              _showMessage('Inventory item already exists', isWarning: true);
                              return;
                            }
                            setState(() {
                              _items.add(InventoryItemModel(
                                id: _items.isEmpty ? 1 : _items.map((i) => i.id).reduce((a,b) => a > b ? a : b) + 1,
                                name: name, itemCode: itemCode.isEmpty ? null : itemCode,
                                categoryId: selectedCategoryId!, subCategoryId: selectedSubCategoryId,
                                unitId: selectedUnitId!, minimumStockLevel: minimumStock!,
                                tax: selectedTax, hsnCode: hsnCode, openingStock: openingStock!,
                                isActive: isActive, isProduced: isProduced,
                              ));
                            });
                            if (dialogContext.mounted) Navigator.pop(dialogContext);
                            _showMessage('Inventory item added successfully');
                          } catch (error) {
                            setDialogState(() {
                              isSaving = false;
                            });

                            _showMessage('Could not add inventory item', isError: true);
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

      // Wait for the dialog closing animation to finish.
    await Future<void>.delayed(const Duration(milliseconds: 300));

    nameController.dispose();
    itemCodeController.dispose();
    minimumStockController.dispose();
    hsnController.dispose();
    openingStockController.dispose();
  }

  // ============================================================
  // EDIT ITEM
  // ============================================================

  Future<void> _showEditItemDialog(
    InventoryItemModel item,
  ) async {
    final formKey = GlobalKey<FormState>();
    bool showValidation = false;
    final nameController =
        TextEditingController(text: item.name);

    final itemCodeController =
        TextEditingController(text: item.itemCode ?? '');

    final minimumStockController = TextEditingController(
      text: _formatNumber(item.minimumStockLevel),
    );

    final hsnController =
        TextEditingController(text: item.hsnCode);

    final openingStockController = TextEditingController(
      text: _formatNumber(item.openingStock),
    );

    int? selectedCategoryId = item.categoryId;
    int? selectedSubCategoryId = item.subCategoryId;
    int? selectedUnitId = item.unitId;

    double selectedTax = item.tax;

    bool isActive = item.isActive;
    bool isProduced = item.isProduced;

    bool isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final screen = MediaQuery.of(context).size;
            return AlertDialog(
              backgroundColor: AppColors.surface,
              surfaceTintColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 10),
              contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              title: const Text('Update Inventory Item', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              content: SizedBox(
                width: (screen.width - 96).clamp(280.0, 620.0),
                height: (screen.height * 0.66).clamp(360.0, 640.0),
                child: Form(
                  key: formKey,
                  autovalidateMode: showValidation ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
                  child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        textCapitalization:
                            TextCapitalization.words,
                        decoration: const InputDecoration(labelText: 'Item Name *'),
                        validator: (value) {
                          final name = (value ?? '').trim();
                          if (name.isEmpty) return 'Please enter item name';
                          if (name.length > 100) return 'Please enter up to 100 characters';
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: itemCodeController,
                        decoration: const InputDecoration(
                          labelText: 'Item Code',
                          hintText: 'Optional',
                        ),
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<int>(
                        initialValue: _categories.any(
                          (category) =>
                              category.id ==
                              selectedCategoryId,
                        )
                            ? selectedCategoryId
                            : null,
                        decoration: const InputDecoration(labelText: 'Category *'),
                        validator: (value) => value == null ? 'Please select category' : null,
                        items: _categories
                            .where((category) => category.status)
                            .map(
                              (category) => DropdownMenuItem<int>(
                                value: category.id,
                                child: Text(category.name),
                              ),
                            )
                            .toList(),
                        onChanged: isSaving
                            ? null
                            : (value) {
                                setDialogState(() {
                                  selectedCategoryId = value;
                                  selectedSubCategoryId = null;
                                });
                              },
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<int>(
                        key: ValueKey('edit-subcategory-$selectedCategoryId'),
                        initialValue: _subCategories.any((s) => s.id == selectedSubCategoryId && s.categoryId == selectedCategoryId) ? selectedSubCategoryId : null,
                        decoration: const InputDecoration(labelText: 'Sub Category', hintText: 'Select sub category'),
                        items: _subCategories.where((s) => s.status && s.categoryId == selectedCategoryId).map((s) => DropdownMenuItem<int>(value: s.id, child: Text(s.name, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: isSaving || selectedCategoryId == null ? null : (value) => setDialogState(() => selectedSubCategoryId = value),
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<int>(
                        initialValue: _units.any(
                          (unit) => unit.id == selectedUnitId,
                        )
                            ? selectedUnitId
                            : null,
                        decoration: const InputDecoration(labelText: 'Unit *'),
                        validator: (value) => value == null ? 'Please select unit' : null,
                        items: _units
                            .where((unit) => unit.status)
                            .map(
                              (unit) => DropdownMenuItem<int>(
                                value: unit.id,
                                child: Text(unit.name),
                              ),
                            )
                            .toList(),
                        onChanged: isSaving
                            ? null
                            : (value) {
                                setDialogState(() {
                                  selectedUnitId = value;
                                });
                              },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: minimumStockController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(labelText: 'Minimum Stock Level *'),
                        validator: (value) {
                          final number = double.tryParse((value ?? '').trim());
                          if ((value ?? '').trim().isEmpty) return 'Please enter minimum stock level';
                          if (number == null) return 'Please enter a valid number';
                          if (number < 0) return 'Stock level cannot be negative';
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<double>(
                        initialValue: selectedTax,
                        decoration: const InputDecoration(
                          labelText: 'Tax / GST *',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 0,
                            child: Text('0%'),
                          ),
                          DropdownMenuItem(
                            value: 5,
                            child: Text('5%'),
                          ),
                          DropdownMenuItem(
                            value: 12,
                            child: Text('12%'),
                          ),
                          DropdownMenuItem(
                            value: 18,
                            child: Text('18%'),
                          ),
                          DropdownMenuItem(
                            value: 28,
                            child: Text('28%'),
                          ),
                        ],
                        onChanged: isSaving
                            ? null
                            : (value) {
                                if (value != null) {
                                  setDialogState(() {
                                    selectedTax = value;
                                  });
                                }
                              },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: hsnController,
                        decoration: const InputDecoration(labelText: 'HSN Code *'),
                        validator: (value) {
                          final code = (value ?? '').trim();
                          if (code.isEmpty) return 'Please enter HSN code';
                          if (!RegExp(r'^[A-Za-z0-9-]{4,12}$').hasMatch(code)) return 'Enter a valid HSN code';
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: openingStockController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(labelText: 'Opening Stock *'),
                        validator: (value) {
                          final number = double.tryParse((value ?? '').trim());
                          if ((value ?? '').trim().isEmpty) return 'Please enter opening stock';
                          if (number == null) return 'Please enter a valid number';
                          if (number < 0) return 'Opening stock cannot be negative';
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Active'),
                        value: isActive,
                        onChanged: isSaving
                            ? null
                            : (value) {
                                setDialogState(() {
                                  isActive = value;
                                });
                              },
                      ),

                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Is this a produced item?',
                        ),
                        value: isProduced,
                        onChanged: isSaving
                            ? null
                            : (value) {
                                setDialogState(() {
                                  isProduced = value;
                                });
                              },
                      ),
                    ],
                  ),
                ),
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: isSaving
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF776A61),
                    side: const BorderSide(color: Color(0xFFE8DAD0)),
                    minimumSize: const Size(115, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(115, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          final name =
                              nameController.text.trim();

                          final itemCode =
                              itemCodeController.text.trim();

                          final hsnCode =
                              hsnController.text.trim();

                          final minimumStock =
                              double.tryParse(
                            minimumStockController.text.trim(),
                          );

                          final openingStock =
                              double.tryParse(
                            openingStockController.text.trim(),
                          );

                          setDialogState(() { showValidation = true; });
                          if (!(formKey.currentState?.validate() ?? false)) return;

                          setDialogState(() {
                            isSaving = true;
                          });

                          try {
                            if (_items.any((i) => i.id != item.id && i.name.trim().toLowerCase() == name.toLowerCase())) {
                              setDialogState(() { isSaving = false; });
                              _showMessage('Inventory item already exists', isWarning: true);
                              return;
                            }
                            setState(() {
                              final index = _items.indexWhere((i) => i.id == item.id);
                              if (index != -1) {
                                _items[index] = InventoryItemModel(
                                id: item.id, name: name, itemCode: itemCode.isEmpty ? null : itemCode,
                                categoryId: selectedCategoryId!, subCategoryId: selectedSubCategoryId,
                                unitId: selectedUnitId!, minimumStockLevel: minimumStock!,
                                tax: selectedTax, hsnCode: hsnCode, openingStock: openingStock!,
                                isActive: isActive, isProduced: isProduced,
                              );
                              }
                            });
                            if (dialogContext.mounted) Navigator.pop(dialogContext);
                            _showMessage('Inventory item updated successfully');
                          } catch (error) {
                            setDialogState(() {
                              isSaving = false;
                            });

                            _showMessage('Could not update inventory item', isError: true);
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );

       // Wait for the dialog closing animation to finish.
    await Future<void>.delayed(const Duration(milliseconds: 300));

    nameController.dispose();
    itemCodeController.dispose();
    minimumStockController.dispose();
    hsnController.dispose();
    openingStockController.dispose();
  }

  // ============================================================
  // UPDATE STATUS
  // ============================================================

  Future<void> _updateItemStatus(
    InventoryItemModel item,
    bool isActive,
  ) async {
    final action = isActive ? 'Activate' : 'Deactivate';
    final actionLower = isActive ? 'activate' : 'deactivate';
    final confirmed = await showDialog<bool>(
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFFEAF5E8) : const Color(0xFFFFF0E7),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    isActive ? Icons.check_rounded : Icons.priority_high_rounded,
                    size: 42,
                    color: isActive ? const Color(0xFF2E7D32) : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '$action Item?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF302923)),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to $actionLower "${item.name}"?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, height: 1.45, color: Color(0xFF776A61)),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF302923),
                          side: const BorderSide(color: Color(0xFFE8DAD0)),
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(action, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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
    if (confirmed != true || !mounted) return;

    final index = _items.indexWhere((current) => current.id == item.id);
    if (index == -1) return;
    setState(() {
      _items[index] = InventoryItemModel(
        id: item.id, name: item.name, itemCode: item.itemCode,
        categoryId: item.categoryId, subCategoryId: item.subCategoryId,
        unitId: item.unitId, minimumStockLevel: item.minimumStockLevel,
        tax: item.tax, hsnCode: item.hsnCode, openingStock: item.openingStock,
        isActive: isActive, isProduced: item.isProduced,
      );
    });
    _showMessage('Item ${isActive ? 'activated' : 'deactivated'} successfully');
  }

  // ============================================================
  // RESPONSIVE UI — styled to match the Items screen
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF302923)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Inventory Items',
          style: TextStyle(color: Color(0xFF302923), fontWeight: FontWeight.w700, fontSize: 20),
        ),
      ),
      body: Stack(
        children: [SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final mobile = width < 700;
            final tablet = width >= 700 && width < 1100;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(mobile ? 16 : tablet ? 20 : 30, mobile ? 18 : 28, mobile ? 16 : tablet ? 20 : 30, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPageHeader(mobile: mobile),
                  const SizedBox(height: 22),
                  _buildFilterCard(mobile: mobile, tablet: tablet),
                  const SizedBox(height: 22),
                  _buildInventoryList(mobile: mobile),
                ],
              ),
            );
          },
        ),
      ),
      _buildTopMessage(),
      ],
      ),
    );
  }

  Widget _buildPageHeader({required bool mobile}) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Manage your inventory items',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF776A61),
            ),
          ),
        ),
        if (!mobile) ...[
          const SizedBox(width: 12),
          _buildAddButton(compact: false),
        ],
      ],
    );
  }

  Widget _buildAddButton({required bool compact}) {
    return FilledButton(
      onPressed: _isLoading ? null : _showAddItemDialog,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 24,
          vertical: 14,
        ),
        minimumSize: Size(compact ? 0 : 120, 46),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_rounded, size: 20),
          SizedBox(width: 6),
          Text('Add', style: TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildFilterCard({required bool mobile, required bool tablet}) {
    const border = Color(0xFFE8DAD0);
    return Container(
      padding: EdgeInsets.all(mobile ? 14 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF302923),
            ),
          ),
          const SizedBox(height: 14),
          if (mobile) ...[
            // Mobile: keep Add beside Search, like the Categories screen.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildSearchField()),
                const SizedBox(width: 8),
                _buildAddButton(compact: true),
              ],
            ),
            const SizedBox(height: 12),
            _buildCategoryFilter(),
            const SizedBox(height: 12),
            _buildSubCategoryFilter(),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: _buildStatusChips(compact: true),
            ),
          ] else if (tablet) ...[
            // Tablet: match the Items page — search on its own row,
            // category filters side by side, and status chips underneath.
            _buildSearchField(),
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
              child: _buildStatusChips(compact: true),
            ),
          ] else ...[
            // Desktop/web: all filters fit on one line.
            Row(
              children: [
                Expanded(flex: 3, child: _buildSearchField()),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: _buildCategoryFilter()),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: _buildSubCategoryFilter()),
                const SizedBox(width: 12),
                _buildStatusChips(compact: true),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchField() => TextField(
    controller: _searchController, onChanged: (_) => setState(() {}),
    decoration: InputDecoration(hintText: 'Search item name or SKU', prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF776A61)),
      filled: true, fillColor: const Color(0xFFFCFAF8), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8DAD0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8DAD0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary, width: 1.4))),
  );

  Widget _buildCategoryFilter() => DropdownButtonFormField<int?>(
    value: _selectedCategoryFilter,
    decoration: _filterDecoration('Category'),
    items: [const DropdownMenuItem<int?>(value: null, child: Text('All Categories', overflow: TextOverflow.ellipsis)),
      ..._categories.map((c) => DropdownMenuItem<int?>(value: c.id, child: Text(c.name, overflow: TextOverflow.ellipsis)))],
    onChanged: _onCategoryFilterChanged,
  );

  Widget _buildSubCategoryFilter() => DropdownButtonFormField<int?>(
    value: _selectedSubCategoryFilter,
    decoration: _filterDecoration('Sub Category', hint: _selectedCategoryFilter == null ? 'Select category first' : 'All Sub Categories'),
    items: _selectedCategoryFilter == null ? const [] : <DropdownMenuItem<int?>>[
      const DropdownMenuItem<int?>(value: null, child: Text('All Sub Categories')),
      ..._availableSubCategories.map((s) => DropdownMenuItem<int?>(value: s.id, child: Text(s.name, overflow: TextOverflow.ellipsis))),
    ],
    onChanged: _selectedCategoryFilter == null ? null : (value) => setState(() => _selectedSubCategoryFilter = value),
  );

  InputDecoration _filterDecoration(String label, {String? hint}) => InputDecoration(
    labelText: label, hintText: hint, filled: true, fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8DAD0))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8DAD0))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary, width: 1.4)),
  );

  Widget _buildStatusChips({bool compact = false}) {
    const options = ['All', 'Active', 'Inactive'];
    return Container(height: 42, padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: const Color(0xFFFFFBF8), border: Border.all(color: const Color(0xFFE8DAD0)), borderRadius: BorderRadius.circular(24)),
      child: Row(mainAxisSize: MainAxisSize.min, children: options.map((option) {
        final selected = _statusFilter == option;
        return InkWell(borderRadius: BorderRadius.circular(20), onTap: () => setState(() => _statusFilter = option),
          child: AnimatedContainer(duration: const Duration(milliseconds: 160), width: compact ? 66 : 78, alignment: Alignment.center,
            decoration: BoxDecoration(color: selected ? const Color(0xFFF8E8DE) : Colors.transparent, borderRadius: BorderRadius.circular(20)),
            child: Text(option, style: TextStyle(fontSize: 13, fontWeight: selected ? FontWeight.w700 : FontWeight.w600, color: selected ? AppColors.primary : const Color(0xFF302923)))));
      }).toList()),
    );
  }

  Widget _buildInventoryList({required bool mobile}) {
    final items = _filteredItems;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Inventory Item List',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: Color(0xFF302923),
          ),
        ),
        const SizedBox(height: 14),
        if (_isLoading)
          const SizedBox(
            height: 260,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_errorMessage != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE8DAD0)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF776A61)),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _loadData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          )
        else if (items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE8DAD0)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'No inventory items found. Add an item or change your filters.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF776A61)),
            ),
          )
        else if (mobile)
          Column(
            children: [
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildMobileInventoryCard(item),
                ),
            ],
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              const minimumTableWidth = 1050.0;
              final tableWidth = constraints.maxWidth < minimumTableWidth
                  ? minimumTableWidth
                  : constraints.maxWidth;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    children: [
                      _buildInventoryColumnHeader(),
                      const SizedBox(height: 10),
                      ...items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildInventoryRow(item, mobile: false),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildMobileInventoryCard(InventoryItemModel item) {
    final stock = item.openingStock;
    final low = stock > 0 && stock <= item.minimumStockLevel;
    final out = stock <= 0;
    final stockLabel = out
        ? 'Out of Stock'
        : low
            ? 'Low Stock'
            : 'In Stock';
    final stockColor = out
        ? const Color(0xFFD32F2F)
        : low
            ? const Color(0xFFB87900)
            : const Color(0xFF16883B);
    final stockBg = out
        ? const Color(0xFFFDEBEC)
        : low
            ? const Color(0xFFFAF1E2)
            : const Color(0xFFE7F4EA);

    Widget detail(String label, String value) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF8D7D73),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF302923),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8DAD0)),
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
                        color: Color(0xFF302923),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'SKU: ${item.itemCode?.isNotEmpty == true ? item.itemCode : '—'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8D7D73),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFE8DAD0)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              detail('Category', _getCategoryName(item.categoryId)),
              const SizedBox(width: 12),
              detail('Sub Category', _getSubCategoryName(item.subCategoryId)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              detail('Unit', _getUnitName(item.unitId)),
              const SizedBox(width: 12),
              detail('Opening Stock', _formatNumber(stock)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              detail('Minimum Stock', _formatNumber(item.minimumStockLevel)),
              const SizedBox(width: 12),
              detail('Tax / GST', '${_formatNumber(item.tax)}%'),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFE8DAD0)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: stockBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      stockLabel,
                      style: TextStyle(
                        color: stockColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              _buildStatusSwitch(item),
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Edit item',
                onPressed: () => _showEditItemDialog(item),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Color(0xFF302923),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryColumnHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(color: const Color(0xFFF7E8DE), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE8DAD0))),
      child: const Row(children: [
        SizedBox(width: 38, child: Text('#', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF776A61)))),
        Expanded(flex: 3, child: Text('Item', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF776A61)))),
        Expanded(flex: 2, child: Text('Category', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF776A61)))),
        Expanded(flex: 2, child: Text('Sub Category', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF776A61)))),
        Expanded(flex: 2, child: Text('Unit', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF776A61)))),
        Expanded(flex: 1, child: Text('Opening Stock', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF776A61)))),
        Expanded(flex: 1, child: Text('Min. Stock', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF776A61)))),
        Expanded(flex: 1, child: Text('Tax', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF776A61)))),
        Expanded(flex: 1, child: Text('Status', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF776A61)))),
        SizedBox(width: 112, child: Text('Actions', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF776A61)))),
      ]),
    );
  }

  Widget _buildInventoryRow(InventoryItemModel item, {required bool mobile}) {
    final stock = item.openingStock;
    final low = stock > 0 && stock <= item.minimumStockLevel;
    final out = stock <= 0;
    final stockLabel = out ? 'Out of Stock' : low ? 'Low Stock' : 'In Stock';
    final stockColor = out ? const Color(0xFFD32F2F) : low ? const Color(0xFFB87900) : const Color(0xFF16883B);
    final stockBg = out ? const Color(0xFFFDEBEC) : low ? const Color(0xFFFAF1E2) : const Color(0xFFE7F4EA);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE8DAD0))),
      child: Row(children: [
        SizedBox(width: 38, child: Text('${_items.indexOf(item) + 1}', style: const TextStyle(color: Color(0xFF776A61)))),
        Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF776A61))), const SizedBox(height: 3), Text('SKU: ${item.itemCode?.isNotEmpty == true ? item.itemCode : '—'}', style: const TextStyle(fontSize: 12, color: Color(0xFF8D7D73))) ])),
        Expanded(flex: 2, child: Text(_getCategoryName(item.categoryId), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF776A61)))),
        Expanded(flex: 2, child: Text(_getSubCategoryName(item.subCategoryId), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF776A61)))),
        Expanded(flex: 2, child: Text(_getUnitName(item.unitId), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF776A61)))),
        Expanded(flex: 1, child: Text(_formatNumber(stock), style: TextStyle(fontWeight: FontWeight.w700, color: out ? const Color(0xFFD32F2F) : low ? const Color(0xFFB87900) : const Color(0xFF16883B)))),
        Expanded(flex: 1, child: Text(_formatNumber(item.minimumStockLevel), style: const TextStyle(color: Color(0xFF776A61)))),
        Expanded(flex: 1, child: Text('${_formatNumber(item.tax)}%', style: const TextStyle(color: Color(0xFF776A61)))),
        Expanded(flex: 1, child: Align(alignment: Alignment.centerLeft, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: stockBg, borderRadius: BorderRadius.circular(20)), child: Text(stockLabel, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: stockColor))))),
        SizedBox(width: 112, child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          _buildStatusSwitch(item),
          const SizedBox(width: 6),
          SizedBox(width: 36, height: 36, child: IconButton(tooltip: 'Edit item', onPressed: () => _showEditItemDialog(item), padding: EdgeInsets.zero, icon: const Icon(Icons.edit_outlined, size: 19, color: Colors.black))),
        ])),
      ]),
    );
  }

  Widget _buildStatusSwitch(InventoryItemModel item) {
    return Semantics(
      button: true,
      toggled: item.isActive,
      label: item.isActive ? 'Active' : 'Inactive',
      child: GestureDetector(
        onTap: () => _updateItemStatus(item, !item.isActive),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 48,
          height: 26,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(color: item.isActive ? AppColors.primary : const Color(0xFFBDBDBD), borderRadius: BorderRadius.circular(20)),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 160),
            alignment: item.isActive ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(width: 20, height: 20, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          ),
        ),
      ),
    );
  }
}
