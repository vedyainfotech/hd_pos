import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../settings/screens/home_delivery_settings_screen.dart';

class HomeDeliveryDashboardScreen extends StatefulWidget {
  const HomeDeliveryDashboardScreen({super.key});

  @override
  State<HomeDeliveryDashboardScreen> createState() =>
      _HomeDeliveryDashboardScreenState();
}

class _HomeDeliveryDashboardScreenState
    extends State<HomeDeliveryDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  // Local demo customers. Replace this list with the customer-search API later.
  final List<_CustomerOption> _customers = const [
    _CustomerOption(
      id: '16',
      name: 'Manjula Sample',
      phone: '9000000016',
      address: 'Annapurna Apartments, Seethammadhara, Visakhapatnam',
    ),
    _CustomerOption(
      id: '57',
      name: 'Pradeep Sample',
      phone: '9000000057',
      address: 'MVP Colony, Visakhapatnam',
    ),
    _CustomerOption(
      id: '101',
      name: 'Sample Customer One',
      phone: '9000000101',
      address: 'Visakhapatnam',
    ),
    _CustomerOption(
      id: '102',
      name: 'Sample Customer Two',
      phone: '9000000102',
      address: 'MVP Colony, Visakhapatnam',
    ),
    _CustomerOption(
      id: '103',
      name: 'Sample Customer Three',
      phone: '9000000103',
      address: 'Dwaraka Nagar, Visakhapatnam',
    ),
    _CustomerOption(
      id: '205',
      name: 'Priya Sample',
      phone: '9000000205',
      address: 'Maddilapalem, Visakhapatnam',
    ),
    _CustomerOption(
      id: '310',
      name: 'Kiran Sample',
      phone: '9000000310',
      address: 'Gajuwaka, Visakhapatnam',
    ),
  ];

  static const List<String> _meals = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Special Dishes',
  ];

  static const Map<String, List<_MenuItem>> _catalog = {
    'Breakfast': [
      _MenuItem('Idly', 30, 'Breakfast'),
      _MenuItem('Upma', 35, 'Breakfast'),
      _MenuItem('Pesarattu Upma', 60, 'Breakfast'),
      _MenuItem('Dosa', 45, 'Breakfast'),
    ],
    'Lunch': [
      _MenuItem('Curryset', 160, 'Lunch'),
      _MenuItem('Meals', 210, 'Lunch'),
      _MenuItem('Meals/NC', 200, 'Lunch'),
      _MenuItem('Curry', 50, 'Lunch'),
      _MenuItem('Senagapappu pachadi', 25, 'Lunch'),
      _MenuItem('Goruchikkudu kura', 50, 'Lunch'),
      _MenuItem('Birakaya Pachadi', 25, 'Lunch'),
    ],
    'Dinner': [
      _MenuItem('Idly', 30, 'Dinner'),
      _MenuItem('Puri', 45, 'Dinner'),
      _MenuItem('Tomato Bath', 60, 'Dinner'),
    ],
    'Special Dishes': [
      _MenuItem('Special Item', 100, 'Special Dishes'),
    ],
  };

  // Demo-only order counts displayed in the left panel until the API is ready.
  static const Map<String, List<_SummaryMetric>> _demoOrderSummary = {
    'Breakfast': [
      _SummaryMetric('Tiffins', 42),
      _SummaryMetric('Special Packing', 1),
      _SummaryMetric('Total Customers', 34),
    ],
    'Lunch': [
      _SummaryMetric('Curd', 0),
      _SummaryMetric('Curry', 0),
      _SummaryMetric('Curryset', 56),
      _SummaryMetric('Fry', 0),
      _SummaryMetric('Meals', 6),
      _SummaryMetric('Meals/NC', 2),
      _SummaryMetric('Pachadi', 0),
      _SummaryMetric('Pappu', 0),
      _SummaryMetric('Pulusu', 0),
      _SummaryMetric('Rice', 0),
      _SummaryMetric('Single Meal', 1),
      _SummaryMetric('Special Packing', 4),
      _SummaryMetric('Total Customers', 64),
    ],
    'Dinner': [
      _SummaryMetric('Tiffins', 0),
      _SummaryMetric('Special Packing', 0),
      _SummaryMetric('Total Customers', 0),
    ],
    'Special Dishes': [
      _SummaryMetric('Special Dishes', 3),
      _SummaryMetric('Special Packing', 0),
      _SummaryMetric('Total Customers', 3),
    ],
  };


  _CustomerOption? _selectedCustomer;
  String _searchText = '';
  String _selectedMeal = 'Breakfast';
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  int _compactTab = 1;
  bool _saving = false;

  // Quantities are retained independently for every meal when switching tabs.
  final Map<String, int> _quantities = {};

  @override
  void dispose() {
    _searchController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  String _key(String meal, String item) => '$meal::$item';

  int _quantity(String meal, String item) => _quantities[_key(meal, item)] ?? 0;

  void _setQuantity(String meal, String item, int value) {
    setState(() {
      _quantities[_key(meal, item)] = value < 0 ? 0 : value;
    });
  }

  int get _daysInRange => _toDate.difference(_fromDate).inDays + 1;

  double get _foodAmount {
    var total = 0.0;
    for (final meal in _meals) {
      for (final item in _catalog[meal] ?? const <_MenuItem>[]) {
        total += item.price * _quantity(meal, item.name);
      }
    }
    return total * (_daysInRange < 1 ? 1 : _daysInRange);
  }

  int get _totalQuantity {
    var total = 0;
    for (final value in _quantities.values) {
      total += value;
    }
    return total;
  }

  String _money(double amount) => amount.toStringAsFixed(2);

  String _dateLabel(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-${date.year}';

  String _dateTitle(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${weekdays[date.weekday - 1]}, ${date.day} '
        '${months[date.month - 1]}, ${date.year}';
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate({
    required DateTime initial,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      onSelected(DateTime(picked.year, picked.month, picked.day));
    }
  }

  void _selectCustomer(_CustomerOption customer) {
    setState(() {
      _selectedCustomer = customer;
      _searchText = '';
      _searchController.clear();
      _quantities.clear();
      _remarksController.clear();
      _selectedMeal = 'Breakfast';
    });
  }

  void _clearCustomer() {
    setState(() {
      _selectedCustomer = null;
      _searchText = '';
      _searchController.clear();
      _remarksController.clear();
      _quantities.clear();
    });
  }

  void _placeOrder() {
    if (_saving) return;
    if (_selectedCustomer == null) {
      _showMessage('Search for and select a customer first.', error: true);
      return;
    }
    if (_totalQuantity == 0) {
      _showMessage('Choose a quantity for at least one menu item.', error: true);
      return;
    }
    if (_toDate.isBefore(_fromDate)) {
      _showMessage('To Date must be the same as or later than From Date.',
          error: true);
      return;
    }

    setState(() => _saving = true);
    // Intentionally frontend-only. No API or database persistence is claimed.
    setState(() => _saving = false);
    _showMessage(
      'Order draft is ready for ${_selectedCustomer!.name}. '
      'Saving will be connected when the backend is implemented.',
    );
  }

  void _showMessage(String message, {bool error = false}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: error ? AppColors.error : AppColors.success,
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return Column(
              children: [
                _buildBackBar(),
                Expanded(
                  child: width >= 1200
                      ? _buildDesktop()
                      : _buildCompactWorkspace(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Keep the top area intentionally short: only the back arrow.
  Widget _buildBackBar() {
    return SizedBox(
      height: 38,
      child: Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          tooltip: 'Back to Settings',
          visualDensity: VisualDensity.compact,
          onPressed: () {
            final navigator = Navigator.of(context);
            if (navigator.canPop()) {
              navigator.pop();
            } else {
              navigator.pushReplacement(
                PageRouteBuilder<void>(
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                  pageBuilder: (_, __, ___) =>
                      const HomeDeliverySettingsScreen(),
                  transitionsBuilder: (_, __, ___, child) => child,
                ),
              );
            }
          },
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildDesktop() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 23, child: _panel(_buildOrderCountPanel())),
          const SizedBox(width: 8),
          Expanded(flex: 54, child: _panel(_buildCustomerOrderPanel(compact: false))),
          const SizedBox(width: 8),
          Expanded(flex: 23, child: _panel(_buildMenuSchedulePanel(showOrderAction: true))),
        ],
      ),
    );
  }

  Widget _buildCompactWorkspace() {
    final pages = <Widget>[
      Padding(
        padding: const EdgeInsets.all(7),
        child: _panel(_buildOrderCountPanel()),
      ),
      Padding(
        padding: const EdgeInsets.all(7),
        child: _panel(_buildCustomerOrderPanel(compact: true)),
      ),
      Padding(
        padding: const EdgeInsets.all(7),
        child: _panel(_buildMenuSchedulePanel()),
      ),
    ];

    return Column(
      children: [
        Expanded(
          child: IndexedStack(index: _compactTab, children: pages),
        ),
        _buildBottomTabs(),
      ],
    );
  }

  Widget _buildBottomTabs() {
    const labels = ['Order Count', 'Place Order', 'Menu Schedule'];
    const icons = [
      Icons.bar_chart_rounded,
      Icons.receipt_long_outlined,
      Icons.menu_book_outlined,
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 5, 6, 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final selected = _compactTab == index;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Material(
                color: selected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
                child: InkWell(
                  onTap: () => setState(() => _compactTab = index),
                  borderRadius: BorderRadius.circular(9),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icons[index], size: 21,
                            color: selected ? Colors.white : AppColors.textSecondary),
                        const SizedBox(height: 3),
                        Text(
                          labels[index],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            color: selected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _panel(Widget child) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(13),
      ),
      child: child,
    );
  }

  Widget _panelHeader(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: child,
    );
  }

  Widget _buildOrderCountPanel() {
    return Column(
      children: [
        _panelHeader(
          Row(
            children: [
              _smallArrow(
                Icons.chevron_left,
                () => setState(() {
                  _focusedDate = _focusedDate.subtract(const Duration(days: 1));
                }),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: InkWell(
                  onTap: () => _pickDate(
                    initial: _focusedDate,
                    onSelected: (date) => setState(() => _focusedDate = date),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.calendar_month,
                          size: 19, color: AppColors.primary),
                      const SizedBox(height: 3),
                      Text(
                        _dateTitle(_focusedDate),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 5),
              _smallArrow(
                Icons.chevron_right,
                () => setState(() {
                  _focusedDate = _focusedDate.add(const Duration(days: 1));
                }),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: [
              for (final meal in _meals) _buildMealSummary(meal),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMealSummary(String meal) {
    final metrics = _demoSummaryForDate(meal, _focusedDate);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: .7)),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Text(
              meal,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                for (final metric in metrics)
                  _summaryRow(metric.label, '${metric.value}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<_SummaryMetric> _demoSummaryForDate(String meal, DateTime date) {
    final base = _demoOrderSummary[meal] ?? const <_SummaryMetric>[];
    // Alternate sample totals on even dates to demonstrate date navigation.
    if (date.day.isOdd) return base;
    return base.map((metric) {
      if (metric.value == 0) return metric;
      final value = metric.label == 'Total Customers'
          ? (metric.value / 2).round()
          : (metric.value / 2).ceil();
      return _SummaryMetric(metric.label, value);
    }).toList(growable: false);
  }

  Widget _summaryRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 11),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerOrderPanel({required bool compact}) {
    return Column(
      children: [
        // In the reference layout this is the only content before a customer
        // is searched. The search suggestions occupy the body below it.
        Container(
          height: 48,
          color: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchText = value.trim();
                      if (_selectedCustomer != null && value.trim().isNotEmpty) {
                        _selectedCustomer = null;
                        _quantities.clear();
                        _remarksController.clear();
                      }
                    });
                  },
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Enter ID / Name / Phone Number',
                    hintStyle: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _selectedCustomer == null
              ? _buildCustomerSearchResults()
              : _buildSelectedCustomerOrder(compact: compact),
        ),
      ],
    );
  }

  Widget _buildCustomerSearchResults() {
    final query = _searchText.toLowerCase();
    if (query.isEmpty) return const SizedBox.expand();

    final matches = _customers.where((customer) {
      return customer.id.toLowerCase().contains(query) ||
          customer.name.toLowerCase().contains(query) ||
          customer.phone.toLowerCase().contains(query);
    }).toList();

    if (matches.isEmpty) {
      return const Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            'No matching customer in the local UI preview. Customer search will use the API later.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(6),
      itemCount: matches.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.border),
      itemBuilder: (context, index) {
        final customer = matches[index];
        return InkWell(
          onTap: () => _selectCustomer(customer),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Text(
              '${customer.id} - ${customer.name} (${customer.phone})',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedCustomerOrder({required bool compact}) {
    final customer = _selectedCustomer!;
    final mealItems = _catalog[_selectedMeal] ?? const <_MenuItem>[];

    return Column(
      children: [
        // Compact selected-customer card, matching the reference mini card.
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 7, 8, 6),
          child: Row(
            children: [
              Container(
                width: compact ? 48 : 62,
                height: compact ? 54 : 68,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(Icons.person_outline,
                    color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E8),
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('Selected', style: TextStyle(
                              color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700,
                            )),
                          ),
                          const Spacer(),
                          Text('ID: ${customer.id}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                          IconButton(
                            tooltip: 'Change customer',
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints.tightFor(width: 28, height: 28),
                            onPressed: _clearCustomer,
                            icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                          ),
                        ],
                      ),
                      Text(customer.name,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      Text(customer.phone, style: const TextStyle(fontSize: 11)),
                      Text(customer.address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Category tabs remain visible together on desktop and in the middle
        // Place Order tab on tablet/mobile.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          child: Row(
            children: [
              for (var i = 0; i < _meals.length; i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i == _meals.length - 1 ? 0 : 6),
                    child: _mealButton(_meals[i], compact: compact),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 5, 8, 6),
          child: Row(
            children: [
              Expanded(
                child: _dateField(
                  label: 'From',
                  date: _fromDate,
                  onTap: () => _pickDate(
                    initial: _fromDate,
                    onSelected: (date) => setState(() {
                      _fromDate = date;
                      if (_toDate.isBefore(date)) _toDate = date;
                      if (_focusedDate.isBefore(_fromDate) || _focusedDate.isAfter(_toDate)) {
                        _focusedDate = date;
                      }
                    }),
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _dateField(
                  label: 'To',
                  date: _toDate,
                  onTap: () => _pickDate(
                    initial: _toDate,
                    onSelected: (date) => setState(() {
                      _toDate = date.isBefore(_fromDate) ? _fromDate : date;
                      if (_focusedDate.isBefore(_fromDate) || _focusedDate.isAfter(_toDate)) {
                        _focusedDate = _fromDate;
                      }
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            children: [
              _buildBookingDateStrip(),
              const SizedBox(height: 7),
              Row(
                children: [
                  const Expanded(
                    child: Text('ITEM', style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    )),
                  ),
                  Text('₹ ${_money(_mealAmount(_selectedMeal))}',
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      )),
                ],
              ),
              const SizedBox(height: 5),
              _buildMenuItemsTable(mealItems),
              if (compact) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _remarksController,
                  decoration: const InputDecoration(
                    labelText: 'Remarks',
                    hintText: 'Enter remarks here...',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),
                _buildAmountAndPlaceOrder(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _mealButton(String meal, {required bool compact}) {
    final selected = _selectedMeal == meal;
    return SizedBox(
      height: compact ? 38 : 40,
      child: OutlinedButton(
        onPressed: () => setState(() => _selectedMeal = meal),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          backgroundColor: selected ? AppColors.primaryDark : const Color(0xFFFFF7E8),
          foregroundColor: selected ? Colors.white : AppColors.primaryDark,
          side: BorderSide(color: selected ? AppColors.primaryDark : AppColors.primaryLight),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(
          meal,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: compact ? 11 : 12, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  double _mealAmount(String meal) {
    final items = _catalog[meal] ?? const <_MenuItem>[];
    return items.fold<double>(
          0,
          (sum, item) => sum + item.price * _quantity(meal, item.name),
        ) *
        (_daysInRange < 1 ? 1 : _daysInRange);
  }

  Widget _buildBookingDateStrip() {
    final count = _daysInRange.clamp(1, 370).toInt();
    return SizedBox(
      height: 72,
      child: Row(
        children: [
          _smallArrow(
            Icons.chevron_left,
            () => setState(() {
              if (_focusedDate.isAfter(_fromDate)) {
                _focusedDate = _focusedDate.subtract(const Duration(days: 1));
              }
            }),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: count,
              separatorBuilder: (_, __) => const SizedBox(width: 7),
              itemBuilder: (context, index) {
                final date = _fromDate.add(Duration(days: index));
                final selected = _dateKey(date) == _dateKey(_focusedDate);
                final bookedItems = _demoBookedItems(date, _selectedMeal);
                return InkWell(
                  onTap: () => setState(() => _focusedDate = date),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 112,
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFFFFF4DE) : AppColors.surface,
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_dateKey(date),
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 3),
                        Expanded(
                          child: Text(
                            bookedItems.isEmpty
                                ? 'No bookings'
                                : bookedItems
                                    .map((item) => '${item.name}: ${item.quantity}')
                                    .join('\n'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 5),
          _smallArrow(
            Icons.chevron_right,
            () => setState(() {
              if (_focusedDate.isBefore(_toDate)) {
                _focusedDate = _focusedDate.add(const Duration(days: 1));
              }
            }),
          ),
        ],
      ),
    );
  }

  List<_BookedItem> _demoBookedItems(DateTime date, String meal) {
    // Local sample bookings let the date/category flow be tested before APIs exist.
    final alternateDay = date.day.isEven;
    switch (meal) {
      case 'Breakfast':
        return alternateDay
            ? const [_BookedItem('Pesarattu Upma', 1)]
            : const [_BookedItem('Idly', 3), _BookedItem('Upma', 1)];
      case 'Lunch':
        return alternateDay
            ? const [_BookedItem('Curryset', 1), _BookedItem('Meals/NC', 1)]
            : const [_BookedItem('Curryset', 1), _BookedItem('Meals', 2)];
      case 'Dinner':
        return alternateDay
            ? const [_BookedItem('Tomato Bath', 1)]
            : const [_BookedItem('Puri', 2)];
      case 'Special Dishes':
        return date.weekday == DateTime.friday
            ? const [_BookedItem('Special Item', 1)]
            : const <_BookedItem>[];
      default:
        return const <_BookedItem>[];
    }
  }

  Widget _buildMenuItemsTable(List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(7),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            color: AppColors.primaryDark,
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
            child: const Row(
              children: [
                Expanded(flex: 5, child: Text('ITEM NAME', style: _tableHeaderStyle)),
                Expanded(flex: 2, child: Text('PRICE', textAlign: TextAlign.center, style: _tableHeaderStyle)),
                Expanded(flex: 3, child: Text('QUANTITY', textAlign: TextAlign.center, style: _tableHeaderStyle)),
              ],
            ),
          ),
          for (final item in items)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.borderLight)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(item.name,
                        style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(_money(item.price),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                  ),
                  Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _quantityButton(
                          Icons.remove,
                          () => _setQuantity(
                            item.meal,
                            item.name,
                            _quantity(item.meal, item.name) - 1,
                          ),
                        ),
                        SizedBox(
                          width: 34,
                          child: Text(
                            '${_quantity(item.meal, item.name)}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ),
                        _quantityButton(
                          Icons.add,
                          () => _setQuantity(
                            item.meal,
                            item.name,
                            _quantity(item.meal, item.name) + 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static const TextStyle _tableHeaderStyle = TextStyle(
    color: Colors.white,
    fontSize: 11,
    fontWeight: FontWeight.w800,
  );

  Widget _quantityButton(IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: 27,
      height: 28,
      child: IconButton(
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }

  Widget _buildAmountAndPlaceOrder() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              'Estimated Amount: ₹ ${_money(_foodAmount)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _saving ? null : _placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
              ),
              child: const Text('PLACE ORDER',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSchedulePanel({bool showOrderAction = false}) {
    final secondDate = _focusedDate.add(const Duration(days: 1));
    return Column(
      children: [
        _panelHeader(
          Row(
            children: [
              _smallArrow(
                Icons.chevron_left,
                () => setState(() => _focusedDate = _focusedDate.subtract(const Duration(days: 1))),
              ),
              const Expanded(
                child: Text(
                  'Menu Schedule',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ),
              _smallArrow(
                Icons.chevron_right,
                () => setState(() => _focusedDate = _focusedDate.add(const Duration(days: 1))),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _menuDayColumn(_focusedDate)),
                const SizedBox(width: 7),
                Expanded(child: _menuDayColumn(secondDate)),
              ],
            ),
          ),
        ),
        if (showOrderAction)
          Padding(
            padding: const EdgeInsets.all(8),
            child: _buildAmountAndPlaceOrder(),
          ),
      ],
    );
  }

  Widget _menuDayColumn(DateTime date) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 3),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${date.weekday == 1 ? 'Mon' : date.weekday == 2 ? 'Tue' : date.weekday == 3 ? 'Wed' : date.weekday == 4 ? 'Thu' : date.weekday == 5 ? 'Fri' : date.weekday == 6 ? 'Sat' : 'Sun'}, ${date.day} ${_month(date.month)}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppColors.primaryDark, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 7),
        for (final meal in _meals)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 7),
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderLight),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    meal.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF0788BD),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Divider(height: 12),
                ..._scheduledMenuItems(date, meal).map(
                  (itemName) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: Color(0xFF0788BD))),
                        Expanded(
                          child: Text(
                            itemName,
                            style: const TextStyle(
                              color: Color(0xFF0788BD),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_scheduledMenuItems(date, meal).isEmpty)
                  const Text(
                    'Not scheduled',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  List<String> _scheduledMenuItems(DateTime date, String meal) {
    // Static preview data alternates by date so date navigation can be tested.
    final alternateDay = date.day.isEven;
    switch (meal) {
      case 'Breakfast':
        return alternateDay ? const ['Pesarattu Upma'] : const ['Idly', 'Upma'];
      case 'Lunch':
        return alternateDay
            ? const ['Curryset', 'Meals/NC', 'Goruchikkudu kura']
            : const ['Curryset', 'Meals', 'Meals/NC', 'Curry', 'Senagapappu pachadi'];
      case 'Dinner':
        return alternateDay ? const ['Tomato Bath'] : const ['Idly', 'Puri'];
      case 'Special Dishes':
        return date.weekday == DateTime.friday
            ? const ['Special Item']
            : const <String>[];
      default:
        return const <String>[];
    }
  }

  String _month(int month) => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ][month - 1];

  Widget _dateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_month, size: 18),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
        child: Text(
          _dateLabel(date),
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
        ),
      ),
    );
  }

  Widget _smallArrow(IconData icon, VoidCallback onPressed) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(7),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(7),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, color: Colors.white, size: 23),
        ),
      ),
    );
  }
}

class _CustomerOption {
  const _CustomerOption({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
  });

  final String id;
  final String name;
  final String phone;
  final String address;
}

class _MenuItem {
  const _MenuItem(this.name, this.price, this.meal);

  final String name;
  final double price;
  final String meal;
}

class _SummaryMetric {
  const _SummaryMetric(this.label, this.value);

  final String label;
  final int value;
}

class _BookedItem {
  const _BookedItem(this.name, this.quantity);

  final String name;
  final int quantity;
}
