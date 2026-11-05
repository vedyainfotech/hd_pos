import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hd_pos/core/theme/theme.dart';

import '../../category/models/category_model.dart';
import '../../category/services/category_api_service.dart';
import '../../sub_categories/models/sub_category_model.dart';
import '../../sub_categories/services/sub_category_services.dart';
import '../../item/models/item_model.dart';
import '../../item/services/item_service.dart';

import '../services/menu_schedule_service.dart';

class MenuSchedulingScreen extends StatefulWidget {
  const MenuSchedulingScreen({super.key});

  @override
  State<MenuSchedulingScreen> createState() => _MenuSchedulingScreenState();
}

class _MenuSchedulingScreenState extends State<MenuSchedulingScreen> {
  final CategoryApiService _categoryService = CategoryApiService();
  final SubCategoryService _subCategoryService = SubCategoryService();
  final ItemApiService _itemService = ItemApiService();
  final MenuScheduleApiService _scheduleService = MenuScheduleApiService();

  DateTime selectedDate = DateUtils.dateOnly(DateTime.now());
  Timer? _dateRefreshTimer;
  late DateTime _lastObservedToday;

  List<CategoryModel> _categories = [];
  final Map<int, List<_MenuGroup>> _menusByCategory = {};
  bool _isLoading = true;
  String? _loadError;
  bool _isSaving = false;

  String? _message;
  bool _messageIsError = false;
  bool _messageIsWarning = false;
  int _messageVersion = 0;

  @override
  void initState() {
    super.initState();
    _lastObservedToday = DateUtils.dateOnly(DateTime.now());
    _loadScreenData();
    _dateRefreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      final today = DateUtils.dateOnly(DateTime.now());
      if (!mounted || DateUtils.isSameDay(_lastObservedToday, today)) return;
      _lastObservedToday = today;
      setState(() => selectedDate = today);
      _loadScreenData();
    });
  }
  @override
  void dispose() {
    _dateRefreshTimer?.cancel();
    super.dispose();
  }

  void _showMessage(
    String message, {
    bool isError = false,
    bool isWarning = false,
  }) {
    if (!mounted) return;
    final version = ++_messageVersion;
    setState(() {
      _message = message;
      _messageIsError = isError;
      _messageIsWarning = isWarning;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted || version != _messageVersion) return;
      setState(() => _message = null);
    });
  }

  Future<void> _loadScreenData({bool showLoading = true}) async {
  if (mounted && showLoading) {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
  }

  try {
    final categories =
        await _categoryService.getCategories(includeInactive: false);

    final scheduleResponse =
        await _scheduleService.getMenuByDate(deliveryDate: selectedDate);

    final Map<int, List<_MenuGroup>> loadedMenus = {
      for (final category in categories) category.id: <_MenuGroup>[],
    };

    for (final schedule in scheduleResponse.schedules) {
      if (!loadedMenus.containsKey(schedule.categoryId)) continue;

      final Map<int, List<_ScheduledItem>> groupedItems = {};
      final Map<int, String> groupNames = {};

      for (final scheduledItem in schedule.items) {
        final subCategoryId = scheduledItem.subCategoryId ?? -1;

        groupedItems.putIfAbsent(subCategoryId, () => []);

        groupNames[subCategoryId] =
            scheduledItem.subCategoryName ?? 'Other';

        groupedItems[subCategoryId]!.add(
          _ScheduledItem(
            id: scheduledItem.itemId,
            name: scheduledItem.itemName,
            price: scheduledItem.price,
          ),
        );
      }

      loadedMenus[schedule.categoryId] = groupedItems.entries
          .map(
            (entry) => _MenuGroup(
              id: entry.key,
              name: groupNames[entry.key] ?? 'Other',
              items: entry.value,
            ),
          )
          .toList();
    }

    if (!mounted) return;

    setState(() {
      _categories = categories;

      _menusByCategory
        ..clear()
        ..addAll(loadedMenus);

      _isLoading = false;
      _loadError = null;
    });
  } catch (error) {
    if (!mounted) return;

    if (showLoading) {
      setState(() {
        _isLoading = false;
        _loadError = error.toString();
      });
    }

    _showMessage(
      showLoading
          ? 'Failed to load menu: $error'
          : 'Failed to refresh menu: $error',
      isError: true,
    );
  }
}

  Future<List<_MenuGroup>> _loadAvailableGroups(int categoryId) async {
    final subCategories = await _subCategoryService.getSubCategories(
      includeInactive: false,
      categoryId: categoryId,
    );

    final groups = <_MenuGroup>[];
    for (final SubCategoryModel subCategory in subCategories) {
      final List<ItemModel> items = await _itemService.getItems(
        includeInactive: false,
        categoryId: categoryId,
        subCategoryId: subCategory.id,
      );

      groups.add(
        _MenuGroup(
          id: subCategory.id,
          name: subCategory.name,
          items: items
              .map(
                (item) => _ScheduledItem(
                  id: item.id,
                  name: item.name,
                  price: item.price,
                ),
              )
              .toList(),
        ),
      );
    }
    return groups;
  }

  Future<bool> _confirmRemoveItem(String itemName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Item'),
        content: Text(
          'Are you sure you want to remove "$itemName" from this menu?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Remove'),
          ),
        ],
      ),
    );
    return result == true;
  }

  int _itemCount(int categoryId) {
    return (_menusByCategory[categoryId] ?? [])
        .fold(0, (sum, group) => sum + group.items.length);
  }

  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${selectedDate.day} ${months[selectedDate.month - 1]} ${selectedDate.year}';
  }

  String _weekday(DateTime date) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    return days[date.weekday - 1];
  }

  void _changeDate(int amount) {
    setState(() {
      selectedDate = DateUtils.dateOnly(
        selectedDate.add(Duration(days: amount)),
      );
    });
    _loadScreenData();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (!mounted || pickedDate == null) return;
    setState(() => selectedDate = DateUtils.dateOnly(pickedDate));
    _loadScreenData();
  }

  Future<void> _editCategory(CategoryModel category) async {
    await _openCategoryEditor(category);
  }

  Future<void> _addItems(CategoryModel category) async {
    await _openCategoryEditor(category);
  }

  Future<void> _openCategoryEditor(CategoryModel category) async {
    final originalGroups = _menusByCategory[category.id] ?? [];
    List<_MenuGroup> availableGroups;

    try {
      availableGroups = await _loadAvailableGroups(category.id);
    } catch (error) {
      _showMessage('Failed to load items: $error', isError: true);
      return;
    }
    if (!mounted) return;

    var workingGroups = originalGroups
        .map((group) => group.copy())
        .toList();

    while (mounted) {
      final editedGroups = await showDialog<List<_MenuGroup>>(
        context: context,
        builder: (_) => _AddEditItemsDialog(
          categoryName: category.name,
          availableGroups: availableGroups,
          selectedGroups: workingGroups,
          onConfirmRemove: _confirmRemoveItem,
        ),
      );

      if (!mounted || editedGroups == null) return;
      workingGroups = editedGroups;

      final submit = await showDialog<bool>(
        context: context,
        builder: (_) => _CategoryPreviewDialog(
          date: selectedDate,
          categoryName: category.name,
          groups: workingGroups,
          weekday: _weekday,
        ),
      );

      if (!mounted) return;
      if (submit == true) {
        await _saveCategorySchedule(category, workingGroups);
        return;
      }
      // Preview Back: reopen the editor with the same temporary selection.
    }
  }

  Future<void> _saveCategorySchedule(
    CategoryModel category,
    List<_MenuGroup> groups,
  ) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final itemIds = groups
          .expand((group) => group.items)
          .map((item) => item.id)
          .toSet()
          .toList();

      await _scheduleService.saveMenuSchedule(
        deliveryDate: selectedDate,
        categoryId: category.id,
        itemIds: itemIds,
      );

      if (!mounted) return;

_showMessage(
  itemIds.isEmpty
      ? 'Menu schedule updated successfully'
      : 'Menu schedule saved successfully',
);

await _loadScreenData(showLoading: false);
    } catch (error) {
      if (!mounted) return;
      _showMessage('Failed to save menu schedule: $error', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

 Widget _buildTopRightMessage() {
  final message = _message;
  if (message == null) return const SizedBox.shrink();

  final screenWidth = MediaQuery.of(context).size.width;

  final backgroundColor = _messageIsError
      ? const Color(0xFFFFE5E5)
      : _messageIsWarning
          ? const Color(0xFFFFF3CD)
          : const Color(0xFFE5F7E9);

  final iconColor = _messageIsError
      ? const Color(0xFFD32F2F)
      : _messageIsWarning
          ? const Color(0xFFE59A00)
          : const Color(0xFF1E9E45);

  final icon = _messageIsError
      ? Icons.close_rounded
      : _messageIsWarning
          ? Icons.warning_amber_rounded
          : Icons.check_rounded;

  return Material(
    color: Colors.transparent,
    child: Container(
      constraints: BoxConstraints(
        maxWidth: screenWidth < 600
            ? 190
            : screenWidth < 1024
                ? 270
                : 320,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth < 600 ? 8: 14,
         vertical: screenWidth < 600 ? 7 : 10,
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
         Icon(
  icon,
  size: screenWidth < 600 ? 18 : 21,
  color: iconColor,
),
          const SizedBox(width: 8),
          Flexible(
          child: Text(
  message,
  maxLines: 1,
  softWrap: false,
  overflow: TextOverflow.ellipsis,
  style: TextStyle(
    fontSize: screenWidth < 600 ? 10 : 13,
    fontWeight: FontWeight.w600,
    color: iconColor,
  ),
),
          ),
        ],
      ),
    ),
  );
}
  double _horizontalPadding(double width) =>
      width < 600 ? 16 : width < 1024 ? 24 : 32;
  double _verticalPadding(double width) =>
      width < 600 ? 12 : width < 1024 ? 20 : 24;
  double _spacing(double width) =>
      width < 600 ? 12 : width < 900 ? 16 : 20;
  int _gridColumns(double width) =>
      width < 600 ? 1 : width < 900 ? 2 : width < 1200 ? 3 : 4;
  double _cardHeight(double cardWidth) =>
      cardWidth < 240 ? 300 : cardWidth < 340 ? 320 : 340;

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text('Menu Scheduling'),
        actions: [
          if (_message != null)
            Padding(
              padding: const EdgeInsets.only(
                right: 12,
                top: 5,
                bottom: 5,
              ),
              child: Center(
                child: _buildTopRightMessage(),
              ),
            ),
        ],
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final horizontalPadding = _horizontalPadding(width);
          final verticalPadding = _verticalPadding(width);
          final gap = _spacing(width);

          if (_isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (_loadError != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Unable to load menu scheduling data',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _loadError!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadScreenData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              verticalPadding,
              horizontalPadding,
              verticalPadding + 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPageHeader(width),
                SizedBox(height: width < 600 ? 14 : 16),

                if (_categories.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No active categories found'),
                    ),
                  )
                else
                  LayoutBuilder(
                    builder: (context, gridConstraints) {
                      final columns =
                          _gridColumns(gridConstraints.maxWidth);

                      final cardWidth =
                          (gridConstraints.maxWidth -
                                  gap * (columns - 1)) /
                              columns;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        itemCount: _categories.length,
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: gap,
                          mainAxisSpacing: gap,
                          mainAxisExtent: _cardHeight(cardWidth),
                        ),
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final groups =
                              _menusByCategory[category.id] ?? [];

                          return _MealCard(
                            categoryName: category.name,
                            groups: groups,
                            itemCount: _itemCount(category.id),
                            onEdit: () => _editCategory(category),
                            onAddItems: () => _addItems(category),
                          );
                        },
                      );
                    },
                  ),

                if (_isSaving)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageHeader(double width) {
    final dateSelector = _buildDateSelector();
    if (width < 600) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manage the menu for each delivery date.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          dateSelector,
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            'Manage the menu for each delivery date.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(width: 20),
        dateSelector,
      ],
    );
  }

  Widget _buildDateSelector() {
    return Container(
      width: 300,
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _changeDate(-1),
            icon: const Icon(Icons.chevron_left, size: 21),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 34,
              minHeight: 34,
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(6),
              child: Center(
                child: Text(
                  formattedDate,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => _changeDate(1),
            icon: const Icon(Icons.chevron_right, size: 21),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 34,
              minHeight: 34,
            ),
          ),
          InkWell(
            onTap: _selectDate,
            borderRadius: BorderRadius.circular(7),
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(
                Icons.calendar_month_outlined,
                size: 18,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MealCard extends StatefulWidget {
  final String categoryName;
  final List<_MenuGroup> groups;
  final int itemCount;
  final VoidCallback onEdit;
  final VoidCallback onAddItems;

  const _MealCard({
    required this.categoryName,
    required this.groups,
    required this.itemCount,
    required this.onEdit,
    required this.onAddItems,
  });

  @override
  State<_MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<_MealCard> {
  late final ScrollController _groupsScrollController;

  @override
  void initState() {
    super.initState();
    _groupsScrollController = ScrollController();
  }

  @override
  void dispose() {
    _groupsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.categoryName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.itemCount} Items',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: widget.groups.isEmpty
                  ? Center(
                      child: Text(
                        'No items scheduled',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    )
                  : Scrollbar(
                      controller: _groupsScrollController,
                      thumbVisibility: true,
                      child: ListView.separated(
                        controller: _groupsScrollController,
                        primary: false,
                        padding: const EdgeInsets.only(right: 6, bottom: 4),
                        itemCount: widget.groups.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) =>
                            _GroupPreview(group: widget.groups[index]),
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onEdit,
                    child: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onAddItems,
                    child: const Text('+ Add Items'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupPreview extends StatelessWidget {
  final _MenuGroup group;

  const _GroupPreview({required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${group.name} (${group.items.length})',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 5),
          ...group.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Text(
                    '₹${item.price.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddEditItemsDialog extends StatefulWidget {
  final String categoryName;
  final List<_MenuGroup> availableGroups;
  final List<_MenuGroup> selectedGroups;
  final Future<bool> Function(String itemName) onConfirmRemove;

  const _AddEditItemsDialog({
    required this.categoryName,
    required this.availableGroups,
    required this.selectedGroups,
    required this.onConfirmRemove,
  });

  @override
  State<_AddEditItemsDialog> createState() => _AddEditItemsDialogState();
}

class _AddEditItemsDialogState extends State<_AddEditItemsDialog> {
  late int selectedSubCategoryId;
  late Set<int> selectedItemIds;
  late Set<int> _originalSelectedItemIds;
  String search = '';

  @override
  void initState() {
    super.initState();
    final selectableGroups = widget.availableGroups
        .where((group) => group.items.isNotEmpty)
        .toList();
    selectedSubCategoryId =
        selectableGroups.isEmpty ? -1 : selectableGroups.first.id;
    selectedItemIds = widget.selectedGroups
        .expand((group) => group.items)
        .map((item) => item.id)
        .toSet();
    _originalSelectedItemIds = Set<int>.from(selectedItemIds);
  }

  List<_MenuGroup> get _nonEmptyAvailableGroups =>
      widget.availableGroups.where((group) => group.items.isNotEmpty).toList();

  List<_ScheduledItem> get filteredItems {
    _MenuGroup? group;
    for (final candidate in widget.availableGroups) {
      if (candidate.id == selectedSubCategoryId) {
        group = candidate;
        break;
      }
    }
    final items = group?.items ?? [];
    if (search.trim().isEmpty) return items;
    return items
        .where((item) => item.name.toLowerCase().contains(search.toLowerCase()))
        .toList();
  }

  List<_MenuGroup> _buildSelectedGroups() {
    return widget.availableGroups
        .map(
          (group) => _MenuGroup(
            id: group.id,
            name: group.name,
            items: group.items
                .where((item) => selectedItemIds.contains(item.id))
                .map((item) => item.copy())
                .toList(),
          ),
        )
        .where((group) => group.items.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 600;

    return AlertDialog(
      title: Row(
        children: [
          Expanded(child: Text('Add Items - ${widget.categoryName}')),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            tooltip: 'Close',
          ),
        ],
      ),
      content: SizedBox(
        width: mobile ? width - 32 : 560,
        child: widget.availableGroups.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(20),
                child: Text('No active subcategories or items found.'),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) => setState(() => search = value),
                    decoration: const InputDecoration(
                      hintText: 'Search items...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (mobile) _buildMobile() else _buildDesktop(),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _buildSelectedGroups()),
          child: const Text('Preview'),
        ),
      ],
    );
  }

  Widget _buildMobile() {
    return Column(
      children: [
        DropdownButtonFormField<int>(
          initialValue: selectedSubCategoryId,
          decoration: const InputDecoration(labelText: 'Subcategory'),
          items: _nonEmptyAvailableGroups
              .map(
                (group) => DropdownMenuItem<int>(
                  value: group.id,
                  child: Text(group.name),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) setState(() => selectedSubCategoryId = value);
          },
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 300,
          child: ListView(
            padding: EdgeInsets.zero,
            children: filteredItems.map(_buildCheckItem).toList(),
          ),
        ),
      ],
    );
  }

  
Widget _buildDesktop() {
  return SizedBox(
    height: 300,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Subcategory sidebar with a complete outer box.
        SizedBox(
          width: 175,
          child: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.border,
                width: 1.3,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 2, 4, 10),
                  child: Text(
                    'Subcategories',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 1,
                      vertical: 2,
                    ),
                    itemCount: _nonEmptyAvailableGroups.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: 9),
                    itemBuilder: (context, index) {
                      final group = _nonEmptyAvailableGroups[index];
                      final selected =
                          group.id == selectedSubCategoryId;

                      return Material(
                        color: selected
                            ? AppColors.primarySoft
                            : AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            setState(() {
                              selectedSubCategoryId = group.id;
                              search = '';
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.borderLight,
                                width: selected ? 1.4 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    group.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: selected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: selected
                                          ? AppColors.primary
                                          : null,
                                    ),
                                  ),
                                ),
                                if (selected)
                                  Icon(
                                    Icons.check_circle,
                                    size: 17,
                                    color: AppColors.primary,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Items list with its own complete border.
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.border,
                width: 1.2,
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: filteredItems.isEmpty
                  ? [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: Text('No items found'),
                        ),
                      ),
                    ]
                  : filteredItems.map(_buildCheckItem).toList(),
            ),
          ),
        ),
      ],
    ),
  );
}


  Widget _buildCheckItem(_ScheduledItem item) {
    final selected = selectedItemIds.contains(item.id);
    return InkWell(
      onTap: () async {
        if (selected && _originalSelectedItemIds.contains(item.id)) {
          final confirmed = await widget.onConfirmRemove(item.name);
          if (!confirmed || !mounted) return;
        }
        if (!mounted) return;
        setState(() {
          if (selected) {
            selectedItemIds.remove(item.id);
          } else {
            selectedItemIds.add(item.id);
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    '₹${item.price.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : AppColors.borderLight,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: selected
                  ? Icon(Icons.check, size: 20, color: AppColors.primary)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPreviewDialog extends StatelessWidget {
  final DateTime date;
  final String categoryName;
  final List<_MenuGroup> groups;
  final String Function(DateTime) weekday;

  const _CategoryPreviewDialog({
    required this.date,
    required this.categoryName,
    required this.groups,
    required this.weekday,
  });

  int get _itemCount =>
      groups.fold(0, (sum, group) => sum + group.items.length);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: width < 600 ? width - 24 : 700,
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preview - $categoryName',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${date.day.toString().padLeft(2, '0')}/'
                          '${date.month.toString().padLeft(2, '0')}/'
                          '${date.year} • ${weekday(date)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '$categoryName • $_itemCount Items',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: groups.isEmpty
                    ? const Center(child: Text('No items selected'))
                    : ListView.separated(
                        itemCount: groups.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final group = groups[index];
                          return Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSoft,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.borderLight,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySoft,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    '${group.name} (${group.items.length})',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                                ...group.items.map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 7,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.name,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          '₹${item.price.toStringAsFixed(0)}',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuGroup {
  final int id;
  final String name;
  final List<_ScheduledItem> items;

  _MenuGroup({
    required this.id,
    required this.name,
    required this.items,
  });

  _MenuGroup copy() => _MenuGroup(
        id: id,
        name: name,
        items: items.map((item) => item.copy()).toList(),
      );
}

class _ScheduledItem {
  final int id;
  final String name;
  final double price;

  _ScheduledItem({
    required this.id,
    required this.name,
    required this.price,
  });

  _ScheduledItem copy() => _ScheduledItem(
        id: id,
        name: name,
        price: price,
      );
}
