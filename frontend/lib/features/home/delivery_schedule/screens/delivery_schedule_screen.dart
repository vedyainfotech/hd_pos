import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

import '../../category/models/category_model.dart';

import '../../delivery_persons/models/delivery_person_model.dart';

import '../models/delivery_schedule_model.dart';

import '../services/delivery_schedule_services.dart';

class DeliveryScheduleScreen extends StatefulWidget {
  const DeliveryScheduleScreen({super.key});

  @override
  State<DeliveryScheduleScreen> createState() => _DeliveryScheduleScreenState();
}

class _DeliveryScheduleScreenState extends State<DeliveryScheduleScreen> {
  final DeliveryScheduleService _scheduleService = DeliveryScheduleService();

  final Map<int, Set<int>> _assignments = {};

  final Map<int, TextEditingController> _searchControllers = {};

  List<CategoryModel> _categories = [];

  List<DeliveryPersonModel> _deliveryPersons = [];

  DateTime _selectedDate = _dateOnly(DateTime.now());

  bool _loading = true;

  String? _errorMessage;

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime get _today => _dateOnly(DateTime.now());

  @override
  void initState() {
    super.initState();

    _loadResources();
  }

  @override
  void dispose() {
    for (final controller in _searchControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  // ============================================================

  // DATA

  // ============================================================

  Future<void> _loadResources() async {
    setState(() {
      _loading = true;

      _errorMessage = null;
    });

    try {
      final resources = await _scheduleService.loadResources();

      if (!mounted) {
        return;
      }

      final categories = resources.categories
          .whereType<CategoryModel>()
          .toList();

      final deliveryPersons = resources.deliveryPersons
          .whereType<DeliveryPersonModel>()
          .toList();

      final assignments = <int, Set<int>>{};

      for (final category in categories) {
        assignments[category.id] = <int>{};
      }

      setState(() {
        _categories = categories;

        _deliveryPersons = deliveryPersons;

        _assignments
          ..clear()
          ..addAll(assignments);

        _loading = false;
      });

      _loadScheduleForDate(_selectedDate);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;

        _errorMessage = error.toString();
      });
    }
  }

  void _loadScheduleForDate(DateTime date) {
    final schedule = _scheduleService.getScheduleForDate(date);

    final assignments = <int, Set<int>>{};

    for (final category in _categories) {
      assignments[category.id] = <int>{};
    }

    if (schedule != null) {
      for (final entry in schedule.assignments.entries) {
        assignments[entry.key] = Set<int>.from(entry.value);
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _assignments
        ..clear()
        ..addAll(assignments);
    });
  }

  // ============================================================

  // DATE

  // ============================================================

  void _goToPreviousDate() {
    if (_selectedDate == _today) {
      return;
    }

    final previousDate = _selectedDate.subtract(const Duration(days: 1));

    if (previousDate.isBefore(_today)) {
      return;
    }

    setState(() {
      _selectedDate = previousDate;
    });

    _loadScheduleForDate(previousDate);
  }

  void _goToNextDate() {
    final nextDate = _selectedDate.add(const Duration(days: 1));

    setState(() {
      _selectedDate = nextDate;
    });

    _loadScheduleForDate(nextDate);
  }

  Future<void> _selectDateFromCalendar() async {
    DateTime pickerDate = _selectedDate;

    final selected = await showDialog<DateTime>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 390,
                  maxHeight: 560,
                ),
                child: Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select date',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(pickerDate),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Flexible(
                          child: CalendarDatePicker(
                            initialDate: pickerDate,
                            firstDate: _today,
                            lastDate: _today.add(const Duration(days: 3650)),
                            onDateChanged: (date) {
                              setDialogState(() {
                                pickerDate = _dateOnly(date);
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, pickerDate),
                              child: const Text(
                                'OK',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
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
            );
          },
        );
      },
    );

    if (selected == null) {
      return;
    }

    final selectedDate = _dateOnly(selected);

    if (selectedDate.isBefore(_today)) {
      return;
    }

    setState(() {
      _selectedDate = selectedDate;
    });

    _loadScheduleForDate(selectedDate);
  }

  // ASSIGNMENTS

  // ============================================================

  void _togglePerson({
    required int categoryId,

    required int personId,

    required bool selected,
  }) {
    setState(() {
      final people = _assignments.putIfAbsent(categoryId, () => <int>{});

      if (selected) {
        people.add(personId);
      } else {
        people.remove(personId);
      }
    });
  }

  Future<void> _saveCategory(CategoryModel category) async {
    final assignments = <int, List<int>>{};

    for (final item in _categories) {
      assignments[item.id] = List<int>.from(_assignments[item.id] ?? <int>{});
    }

    final schedule = DeliveryScheduleModel(
      date: _selectedDate,

      assignments: assignments,
    );

    await _scheduleService.saveSchedule(schedule);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${category.name} schedule saved successfully.'),

        behavior: SnackBarBehavior.floating,

        backgroundColor: AppColors.textPrimary,

        margin: const EdgeInsets.all(16),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ============================================================

  // HISTORY

  // ============================================================

  Future<void> _openHistory() async {
    await showDialog<void>(
      context: context,

      builder: (_) => _HistoryDialog(
        history: _scheduleService.getHistory(),

        categories: _categories,

        deliveryPersons: _deliveryPersons,
      ),
    );
  }

  // ============================================================

  // MAIN

  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : _errorMessage != null
                  ? _buildErrorState()
                  : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================

  // HEADER

  // ============================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,

      color: AppColors.surface,

      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),

      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 600;

          return Row(
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),

                borderRadius: BorderRadius.circular(8),

                child: const Padding(
                  padding: EdgeInsets.all(6),

                  child: Icon(
                    Icons.arrow_back_rounded,

                    size: 21,

                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  'Delivery Schedule',

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    color: AppColors.textPrimary,

                    fontSize: compact ? 17 : 18,

                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              OutlinedButton.icon(
                onPressed: _openHistory,

                icon: const Icon(Icons.history_rounded, size: 16),

                label: Text(compact ? 'History' : 'View History'),

                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,

                  side: const BorderSide(color: AppColors.primary),

                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 10 : 16,

                    vertical: 9,
                  ),

                  minimumSize: Size.zero,

                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),

                  textStyle: TextStyle(
                    fontSize: compact ? 11 : 12,

                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================

  // CONTENT

  // ============================================================

  Widget _buildContent() {
    if (_categories.isEmpty) {
      return const Center(
        child: Text(
          'No active categories available.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 14 : 36,
            20,
            isMobile ? 14 : 36,
            20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopSection(constraints.maxWidth, isMobile),
              const SizedBox(height: 18),
              Expanded(
                child: _buildCategorySection(constraints.maxWidth, isMobile),
              ),
            ],
          ),
        );
      },
    );
  }

  // TOP SECTION

  // ============================================================

  Widget _buildTopSection(double width, bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Assign delivery persons for each delivery date.',

            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),

          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerRight,

            child: _buildDateSelector(availableWidth: width - 28),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [
        const Expanded(
          child: Text(
            'Assign delivery persons for each delivery date.',

            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ),

        const SizedBox(width: 24),

        _buildDateSelector(availableWidth: width - 72),
      ],
    );
  }

  // ============================================================

  // DATE SELECTOR

  // ============================================================

  Widget _buildDateSelector({required double availableWidth}) {
    final selectorWidth = availableWidth.clamp(230.0, 365.0);

    return Container(
      width: selectorWidth,

      height: 50,

      decoration: BoxDecoration(
        color: AppColors.surface,

        borderRadius: BorderRadius.circular(10),

        border: Border.all(color: AppColors.border),
      ),

      child: Row(
        children: [
          _dateNavigationButton(
            icon: Icons.chevron_left_rounded,

            enabled: _selectedDate != _today,

            onTap: _goToPreviousDate,
          ),

          Expanded(
            child: InkWell(
              onTap: _selectDateFromCalendar,

              child: Center(
                child: Text(
                  _formatDate(_selectedDate),

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: AppColors.textPrimary,

                    fontSize: 13,

                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),

          _dateNavigationButton(
            icon: Icons.chevron_right_rounded,

            enabled: true,

            onTap: _goToNextDate,
          ),

          Container(
            width: 44,

            height: 44,

            margin: const EdgeInsets.only(right: 3),

            decoration: BoxDecoration(
              color: AppColors.primarySoft,

              borderRadius: BorderRadius.circular(8),
            ),

            child: IconButton(
              onPressed: _selectDateFromCalendar,

              icon: const Icon(
                Icons.calendar_month_outlined,

                size: 19,

                color: AppColors.primary,
              ),

              tooltip: 'Select date',
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateNavigationButton({
    required IconData icon,

    required bool enabled,

    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 40,

      height: 48,

      child: IconButton(
        onPressed: enabled ? onTap : null,

        padding: EdgeInsets.zero,

        icon: Icon(
          icon,

          size: 20,

          color: enabled ? AppColors.textSecondary : AppColors.border,
        ),
      ),
    );
  }

  // ============================================================

  // CATEGORY HORIZONTAL SCROLL

  // ============================================================

  Widget _buildCategorySection(double width, bool isMobile) {
    final crossAxisCount = isMobile
        ? 1
        : width < 1100
        ? 2
        : 4;

    return GridView.builder(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: isMobile ? 500 : 440,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        return _buildCategoryCard(_categories[index]);
      },
    );
  }

  // CATEGORY CARD

  // ============================================================

  Widget _buildCategoryCard(CategoryModel category) {
    final controller = _searchControllers.putIfAbsent(
      category.id,

      () => TextEditingController(),
    );

    final search = controller.text.trim().toLowerCase();

    final people = _deliveryPersons.where((person) {
      if (search.isEmpty) {
        return true;
      }

      return person.name.toLowerCase().contains(search) ||
          person.contactNumber.toLowerCase().contains(search);
    }).toList();

    final selected = _assignments[category.id] ?? <int>{};

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,

        borderRadius: BorderRadius.circular(12),

        border: Border.all(color: AppColors.border),

        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.025),

            blurRadius: 12,

            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(15),

        child: Column(
          children: [
            // CATEGORY NAME

            Align(
              alignment: Alignment.centerLeft,

              child: Text(
                category.name,

                maxLines: 1,

                overflow: TextOverflow.ellipsis,

                style: const TextStyle(
                  color: AppColors.textPrimary,

                  fontSize: 16,

                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // SEARCH
            TextField(
              controller: controller,

              onChanged: (_) {
                setState(() {});
              },

              decoration: InputDecoration(
                hintText: 'Search Delivery Person...',

                hintStyle: const TextStyle(
                  color: AppColors.textTertiary,

                  fontSize: 12,
                ),

                prefixIcon: const Icon(
                  Icons.search_rounded,

                  size: 18,

                  color: AppColors.icon,
                ),

                filled: true,

                fillColor: AppColors.inputBackground,

                isDense: true,

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,

                  vertical: 12,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),

                  borderSide: const BorderSide(color: AppColors.border),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),

                  borderSide: const BorderSide(color: AppColors.border),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),

                  borderSide: const BorderSide(
                    color: AppColors.primary,

                    width: 1.2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // DELIVERY PERSON SCROLL AREA
            Expanded(
              child: Container(
                width: double.infinity,

                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,

                  borderRadius: BorderRadius.circular(8),

                  border: Border.all(color: AppColors.borderLight),
                ),

                child: people.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12),

                          child: Text(
                            'No delivery persons found.',

                            textAlign: TextAlign.center,

                            style: TextStyle(
                              color: AppColors.textSecondary,

                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: const ClampingScrollPhysics(),

                        padding: const EdgeInsets.symmetric(vertical: 4),

                        itemCount: people.length,

                        itemBuilder: (context, index) {
                          final person = people[index];

                          final isSelected = selected.contains(person.id);

                          return _buildPersonRow(
                            categoryId: category.id,

                            person: person,

                            selected: isSelected,
                          );
                        },
                      ),
              ),
            ),

            const SizedBox(height: 12),

            // SAVE BUTTON
            SizedBox(
              width: double.infinity,

              height: 40,

              child: ElevatedButton(
                onPressed: () => _saveCategory(category),

                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,

                  foregroundColor: Colors.white,

                  elevation: 0,

                  padding: EdgeInsets.zero,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),

                child: Text(
                  'Save ${category.name}',

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 12,

                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================

  // DELIVERY PERSON ROW

  // NO LIST TILE

  // ============================================================

  Widget _buildPersonRow({
    required int categoryId,

    required DeliveryPersonModel person,

    required bool selected,
  }) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: () {
          _togglePerson(
            categoryId: categoryId,

            personId: person.id,

            selected: !selected,
          );
        },

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),

          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 120),

                width: 20,

                height: 20,

                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,

                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,

                    width: 1.2,
                  ),

                  borderRadius: BorderRadius.circular(4),
                ),

                child: selected
                    ? const Icon(
                        Icons.check_rounded,

                        size: 14,

                        color: Colors.white,
                      )
                    : null,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  person.name,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: AppColors.textPrimary,

                    fontSize: 13,

                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================

  // ERROR

  // ============================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            const Text(
              'Unable to load delivery schedule',

              textAlign: TextAlign.center,

              style: TextStyle(
                color: AppColors.textPrimary,

                fontSize: 18,

                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _errorMessage ?? 'Unknown error',

              textAlign: TextAlign.center,

              style: const TextStyle(
                color: AppColors.textSecondary,

                fontSize: 12,
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _loadResources,

              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,

                foregroundColor: Colors.white,

                elevation: 0,
              ),

              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================

  // DATE FORMAT

  // ============================================================

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} '
        '${_monthName(date.month)} '
        '${date.year}';
  }
}

// ==================================================================

// HISTORY DIALOG

// ==================================================================

class _HistoryDialog extends StatefulWidget {
  final List<DeliveryScheduleModel> history;

  final List<CategoryModel> categories;

  final List<DeliveryPersonModel> deliveryPersons;

  const _HistoryDialog({
    required this.history,

    required this.categories,

    required this.deliveryPersons,
  });

  @override
  State<_HistoryDialog> createState() => _HistoryDialogState();
}

class _HistoryDialogState extends State<_HistoryDialog> {
  int? _monthFilter;

  int? _yearFilter;

  int? _categoryFilter;

  int? _deliveryPersonFilter;

  @override
  void initState() {
    super.initState();
  }

  List<DeliveryScheduleModel> get _filteredHistory {
    final result = widget.history.where((schedule) {
      if (_monthFilter != null && schedule.date.month != _monthFilter) {
        return false;
      }

      if (_yearFilter != null && schedule.date.year != _yearFilter) {
        return false;
      }

      if (_categoryFilter != null) {
        final assignments = schedule.assignments[_categoryFilter!];

        if (assignments == null || assignments.isEmpty) {
          return false;
        }
      }

      if (_deliveryPersonFilter != null) {
        final found = schedule.assignments.values.any(
          (ids) => ids.contains(_deliveryPersonFilter),
        );

        if (!found) {
          return false;
        }
      }

      return true;
    }).toList();

    result.sort((a, b) => b.date.compareTo(a.date));

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,

      insetPadding: const EdgeInsets.all(16),

      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 720),

        child: Material(
          color: AppColors.surface,

          borderRadius: BorderRadius.circular(14),

          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Delivery Schedule History',

                        style: TextStyle(
                          color: AppColors.textPrimary,

                          fontSize: 19,

                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () => Navigator.pop(context),

                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                _buildHistoryFilters(),

                const SizedBox(height: 16),

                Expanded(
                  child: _filteredHistory.isEmpty
                      ? const Center(
                          child: Text(
                            'No schedule history found.',

                            style: TextStyle(
                              color: AppColors.textSecondary,

                              fontSize: 13,
                            ),
                          ),
                        )
                      : ListView.separated(
                          physics: const ClampingScrollPhysics(),

                          itemCount: _filteredHistory.length,

                          separatorBuilder: (_, _) => const SizedBox(height: 8),

                          itemBuilder: (context, index) {
                            return _buildHistoryItem(_filteredHistory[index]);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================

  // HISTORY FILTERS

  // ============================================================

  Widget _buildHistoryFilters() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 650;

        final fields = [
          _buildMonthYearDropdown(),
          _buildCategoryDropdown(),
          _buildDeliveryPersonDropdown(),
        ];

        if (narrow) {
          return Column(
            children: [
              for (final field in fields) ...[
                SizedBox(width: double.infinity, child: field),
                const SizedBox(height: 10),
              ],
            ],
          );
        }

        return Wrap(spacing: 10, runSpacing: 10, children: fields);
      },
    );
  }

  Widget _buildMonthYearDropdown() {
    final current = DateTime.now();

    final availableKeys = <String>{};

    // Include every month/year that actually exists in history.
    for (final schedule in widget.history) {
      availableKeys.add('${schedule.date.year}-${schedule.date.month}');
    }

    // Also include the current month and the previous 11 months so the
    // selector remains useful even when there is no saved history yet.
    for (var offset = 0; offset < 12; offset++) {
      final monthDate = DateTime(current.year, current.month - offset);

      availableKeys.add('${monthDate.year}-${monthDate.month}');
    }

    final monthYearOptions = availableKeys.map((key) {
      final parts = key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);

      return DateTime(year, month);
    }).toList()..sort((a, b) => b.compareTo(a));

    final selectedKey = _monthFilter != null && _yearFilter != null
        ? '${_yearFilter!}-${_monthFilter!}'
        : null;

    return SizedBox(
      width: 250,
      child: DropdownButtonFormField<String>(
        initialValue: selectedKey,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Month',
          border: OutlineInputBorder(),
        ),
        items: [
          const DropdownMenuItem<String>(
            value: null,
            child: Text('All Months'),
          ),
          ...monthYearOptions.map(
            (monthDate) => DropdownMenuItem<String>(
              value: '${monthDate.year}-${monthDate.month}',
              child: Text(
                _formatMonthYear(monthDate),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
        onChanged: (value) {
          setState(() {
            if (value == null) {
              _monthFilter = null;
              _yearFilter = null;
              return;
            }

            final parts = value.split('-');

            _yearFilter = int.parse(parts[0]);
            _monthFilter = int.parse(parts[1]);
          });
        },
      ),
    );
  }

  String _formatMonthYear(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.year}';
  }

  Widget _buildCategoryDropdown() {
    return SizedBox(
      width: 205,

      child: DropdownButtonFormField<int>(
        initialValue: _categoryFilter,

        decoration: const InputDecoration(
          labelText: 'Food Type',

          border: OutlineInputBorder(),
        ),

        items: [
          const DropdownMenuItem<int>(
            value: null,

            child: Text('All Food Types'),
          ),

          ...widget.categories.map(
            (category) => DropdownMenuItem<int>(
              value: category.id,

              child: Text(category.name, overflow: TextOverflow.ellipsis),
            ),
          ),
        ],

        onChanged: (value) {
          setState(() {
            _categoryFilter = value;
          });
        },
      ),
    );
  }

  Widget _buildDeliveryPersonDropdown() {
    return SizedBox(
      width: 210,

      child: DropdownButtonFormField<int>(
        initialValue: _deliveryPersonFilter,

        decoration: const InputDecoration(
          labelText: 'Delivery Person',

          border: OutlineInputBorder(),
        ),

        items: [
          const DropdownMenuItem<int>(
            value: null,

            child: Text('All Delivery Persons'),
          ),

          ...widget.deliveryPersons.map(
            (person) => DropdownMenuItem<int>(
              value: person.id,

              child: Text(person.name, overflow: TextOverflow.ellipsis),
            ),
          ),
        ],

        onChanged: (value) {
          setState(() {
            _deliveryPersonFilter = value;
          });
        },
      ),
    );
  }

  // ============================================================

  // HISTORY ITEM

  // ============================================================

  Widget _buildHistoryItem(DeliveryScheduleModel schedule) {
    final assignments = schedule.assignments.entries
        .where((entry) => entry.value.isNotEmpty)
        .toList();

    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,

        borderRadius: BorderRadius.circular(9),

        border: Border.all(color: AppColors.borderLight),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            _formatHistoryDate(schedule.date),

            style: const TextStyle(
              color: AppColors.textPrimary,

              fontSize: 14,

              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          if (assignments.isEmpty)
            const Text(
              'No delivery persons assigned.',

              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            )
          else
            ...assignments.map((entry) {
              CategoryModel? category;

              for (final item in widget.categories) {
                if (item.id == entry.key) {
                  category = item;

                  break;
                }
              }

              final names = entry.value
                  .map((personId) {
                    DeliveryPersonModel? person;

                    for (final item in widget.deliveryPersons) {
                      if (item.id == personId) {
                        person = item;

                        break;
                      }
                    }

                    return person?.name ?? 'Unknown';
                  })
                  .join(', ');

              return Padding(
                padding: const EdgeInsets.only(bottom: 5),

                child: Text(
                  '${category?.name ?? 'Category'}: $names',

                  style: const TextStyle(
                    color: AppColors.textSecondary,

                    fontSize: 12,
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  String _formatHistoryDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} '
        '${_monthName(date.month)} '
        '${date.year}';
  }
}

// ==================================================================

// MONTH

// ==================================================================

String _monthName(int month) {
  const names = [
    'Jan',

    'Feb',

    'Mar',

    'Apr',

    'May',

    'Jun',

    'Jul',

    'Aug',

    'Sep',

    'Oct',

    'Nov',

    'Dec',
  ];

  return names[month - 1];
}
