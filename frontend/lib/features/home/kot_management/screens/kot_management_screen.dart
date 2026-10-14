
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

enum _KotView { cards, table }

enum _KotFilter {
  all,
  notAssigned,
  assigned,
  notPrinted,
  printed,
}

class KotManagementScreen extends StatefulWidget {
  const KotManagementScreen({super.key});

  @override
  State<KotManagementScreen> createState() =>
      _KotManagementScreenState();
}

class _KotManagementScreenState
    extends State<KotManagementScreen> {
  _KotView _view = _KotView.cards;
  _KotFilter _filter = _KotFilter.all;

  final TextEditingController _searchController =
      TextEditingController();

  late DateTime _selectedDate = DateTime.now();

  String _foodType = 'All Food Types';
  String _deliveryBoy = 'All Delivery Boys';
  String _sortBy = 'Name (A - Z)';

  final Set<int> _selectedIds = {};

  final List<String> _deliveryBoys = [
    'A V S Prasad',
    'A Ravi',
    'Prasad',
    'jagan',
  ];

  late final List<_KotOrder> _orders = [
    _KotOrder(
      id: 1,
      name: 'Dr N Uma Sundari',
      phone: '9848195506',
      address:
          'Crystal Dew Apartments, C4, 3rd floor, Harbour Park Road, Pandurangapuram',
      item: 'Pesarattu Upma',
      quantity: 1,
      deliveryBoy: 'A V S Prasad',
      deliveryContact: '9676770701',
      foodType: 'Breakfast',
      isPrinted: true,
    ),
    _KotOrder(
      id: 2,
      name: 'V K SARMA',
      phone: '9010355333, 9949482593',
      address:
          '303-SATYA APTS OLD C.B.I. ROAD, VIDYANAGAR 3RD BLDG FROM 900K BUS STOP',
      item: 'Pesarattu Upma',
      quantity: 2,
      deliveryBoy: 'A V S Prasad',
      deliveryContact: '9676770701',
      foodType: 'Breakfast',
      isPrinted: true,
    ),
    _KotOrder(
      id: 3,
      name: 'N SRIDEVI',
      phone: '9849575405',
      address:
          'Flat no:501, 5th floor, Vinayagar South Avenue, CBM Compound',
      item: 'Pesarattu Upma',
      quantity: 1,
      deliveryBoy: 'A V S Prasad',
      deliveryContact: '9676770701',
      foodType: 'Breakfast',
      isPrinted: false,
    ),
    _KotOrder(
      id: 4,
      name: 'Sri V Uma Maheswara Rao',
      phone: '9866338059',
      address:
          'Flat 401, 4th floor, Sai Nilayam Apartments, Doctors Colony, Seethammadhara',
      item: 'Pesarattu Upma',
      quantity: 1,
      deliveryBoy: 'Prasad',
      deliveryContact: '9030117162',
      foodType: 'Breakfast',
      isPrinted: true,
    ),
    _KotOrder(
      id: 5,
      name: 'Veera Lakshmi',
      phone: '9246618059',
      address: '104 Niharika Enclave, Abidnagar, MVP Colony',
      item: 'Pesarattu Upma',
      quantity: 1,
      deliveryBoy: 'jagan',
      deliveryContact: '8179650301',
      foodType: 'Breakfast',
      isPrinted: true,
    ),
    _KotOrder(
      id: 6,
      name: 'V Muralidhara Rao',
      phone: '9866886930',
      address:
          'Vijjabhas karn Residency, Flat No 402, Visalakshinagar',
      item: 'Curryset',
      quantity: 1,
      deliveryBoy: 'A Ravi',
      deliveryContact: '9755557070',
      foodType: 'Lunch',
      isPrinted: true,
    ),
    _KotOrder(
      id: 7,
      name: 'S Durga Devi',
      phone: '7075894735',
      address:
          'Sri Shirdi Sai Retirement Home, Veterinary Colony, Visalakshi Nagar',
      item: 'Curryset',
      quantity: 1,
      deliveryBoy: null,
      deliveryContact: '',
      foodType: 'Lunch',
      isPrinted: false,
    ),
    _KotOrder(
      id: 8,
      name: 'B S Suryanarayana',
      phone: '9866160348',
      address: '119/3, LIG, D/no-1-82-9/1, Sector 3, MVP Colony',
      item: 'Meals',
      quantity: 1,
      deliveryBoy: 'A Ravi',
      deliveryContact: '9755557070',
      foodType: 'Lunch',
      isPrinted: true,
    ),
    _KotOrder(
      id: 9,
      name: 'DR N Someswara Rao',
      phone: '9949041121, 8639551512',
      address:
          'D/no-55-43-41, 2nd lane Doctors Colony, Seethammadhara',
      item: 'Curryset',
      quantity: 1,
      deliveryBoy: 'jagan',
      deliveryContact: '8179650301',
      foodType: 'Lunch',
      isPrinted: false,
    ),
    _KotOrder(
      id: 10,
      name: 'B Madhuri Kishore',
      phone: '9493531611',
      address: 'MIG 21, 55-8-49, HB Colony',
      item: 'Curryset',
      quantity: 1,
      deliveryBoy: 'A Ravi',
      deliveryContact: '9755557070',
      foodType: 'Lunch',
      isPrinted: true,
    ),
    _KotOrder(
      id: 11,
      name: 'Nagamani',
      phone: '7331159345',
      address: 'Flat No 56, 3rd floor, Raghu Enclave, Lalitha Nagar',
      item: 'Meals/NC',
      quantity: 2,
      deliveryBoy: 'jagan',
      deliveryContact: '8179650301',
      foodType: 'Dinner',
      isPrinted: true,
    ),
    _KotOrder(
      id: 12,
      name: 'D V Ramana Rao',
      phone: '9177413050',
      address: 'Flat 501, Venkateswara Residency, Sector 8, MVP Colony',
      item: 'Curryset',
      quantity: 1,
      deliveryBoy: 'A Ravi',
      deliveryContact: '9755557070',
      foodType: 'Dinner',
      isPrinted: true,
    ),
  ];

  static const Color _borderColor = Color(0xFFE9DDD2);
  static const Color _mutedColor = Color(0xFF77716C);
  static const Color _green = Color(0xFF16803C);
  static const Color _greenBg = Color(0xFFE0F0DB);
  static const Color _orange = Color(0xFFC2410C);
  static const Color _orangeBg = Color(0xFFFFE8D8);

  List<_KotOrder> get _filteredOrders {
    final query = _searchController.text.trim().toLowerCase();

    final result = _orders.where((order) {
      final matchesSearch = query.isEmpty ||
          order.id.toString().contains(query) ||
          order.name.toLowerCase().contains(query) ||
          order.phone.toLowerCase().contains(query) ||
          order.address.toLowerCase().contains(query) ||
          order.item.toLowerCase().contains(query);

      final matchesFood = _foodType == 'All Food Types' ||
          order.foodType == _foodType;

      final matchesBoy = _deliveryBoy == 'All Delivery Boys' ||
          order.deliveryBoy == _deliveryBoy;

      final matchesStatus = switch (_filter) {
        _KotFilter.all => true,
        _KotFilter.notAssigned => order.deliveryBoy == null,
        _KotFilter.assigned => order.deliveryBoy != null,
        _KotFilter.notPrinted => !order.isPrinted,
        _KotFilter.printed => order.isPrinted,
      };

      return matchesSearch &&
          matchesFood &&
          matchesBoy &&
          matchesStatus;
    }).toList();

    switch (_sortBy) {
      case 'Name (A - Z)':
        result.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Name (Z - A)':
        result.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'Order ID':
        result.sort((a, b) => a.id.compareTo(b.id));
        break;
    }

    return result;
  }

  int get _selectedCount => _selectedIds.length;

  int get _notAssignedCount =>
      _orders.where((o) => o.deliveryBoy == null).length;

  int get _assignedCount =>
      _orders.where((o) => o.deliveryBoy != null).length;

  int get _notPrintedCount =>
      _orders.where((o) => !o.isPrinted).length;

  int get _printedCount =>
      _orders.where((o) => o.isPrinted).length;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleOrder(int id, bool? checked) {
    setState(() {
      if (checked == true) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  void _toggleAllVisible(bool? checked) {
    setState(() {
      if (checked == true) {
        _selectedIds.addAll(_filteredOrders.map((o) => o.id));
      } else {
        _selectedIds.removeAll(_filteredOrders.map((o) => o.id));
      }
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _assignOrders(List<_KotOrder> orders) async {
    if (orders.isEmpty) {
      _showMessage('Select at least one order first.');
      return;
    }

    String? selectedBoy;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.white,
              title: const Text('Assign Delivery Person'),
              content: SizedBox(
                width: 350,
                child: DropdownButtonFormField<String>(
                  initialValue: selectedBoy,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Delivery person',
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('Select delivery person'),
                  items: _deliveryBoys.map((boy) {
                    return DropdownMenuItem(
                      value: boy,
                      child: Text(boy),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedBoy = value);
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: () {
                    if (selectedBoy == null) return;

                    setState(() {
                      for (final order in orders) {
                        order.deliveryBoy = selectedBoy;
                        order.deliveryContact = _contactFor(selectedBoy!);
                      }
                      _selectedIds.clear();
                    });

                    Navigator.pop(dialogContext);
                    _showMessage(
                      'Delivery person assigned to ${orders.length} order(s).',
                    );
                  },
                  child: const Text('Assign'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _contactFor(String boy) {
    return switch (boy) {
      'A V S Prasad' => '9676770701',
      'A Ravi' => '9755557070',
      'Prasad' => '9030117162',
      'jagan' => '8179650301',
      _ => '',
    };
  }

  void _printOrders(List<_KotOrder> orders) {
    if (orders.isEmpty) {
      _showMessage('Select at least one order first.');
      return;
    }

    setState(() {
      for (final order in orders) {
        order.isPrinted = true;
      }
      _selectedIds.clear();
    });

    _showMessage(
      'Demo: ${orders.length} KOT order(s) marked as printed.',
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  String get _dateLabel =>
      '${_selectedDate.day.toString().padLeft(2, '0')}-'
      '${_selectedDate.month.toString().padLeft(2, '0')}-'
      '${_selectedDate.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
                child: Column(
                  children: [
                    _buildFilters(),
                    const SizedBox(height: 12),
                    _buildStatusAndViewBar(),
                    const SizedBox(height: 12),
                    Expanded(child: _buildOrderArea()),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }


Widget _buildHeader() {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 22,
      vertical: 13,
    ),
    decoration: BoxDecoration(
      color: AppColors.white,
      border: Border(
        bottom: BorderSide(
          color: _borderColor.withValues(alpha: 0.8),
        ),
      ),
    ),
    child: Row(
      children: [
        IconButton(
          tooltip: 'Back',
          onPressed: () {
            Navigator.of(context).maybePop();
          },
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppColors.textPrimary,
        ),
        const SizedBox(width: 6),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.receipt_long_outlined,
            color: AppColors.primary,
            size: 23,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KOT Management',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Manage daily home delivery orders',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Refresh',
          onPressed: () => setState(() {}),
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    ),
  );
}


  Widget _buildFilters() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 1050;

        final search = SizedBox(
          width: compact ? constraints.maxWidth : 240,
          height: 42,
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search ID, name, phone',
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: _borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: _borderColor),
              ),
            ),
          ),
        );

        final date = SizedBox(
          width: compact ? 190 : 205,
          height: 42,
          child: OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_month_outlined, size: 18),
            label: Text(_dateLabel),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              backgroundColor: AppColors.white,
              side: const BorderSide(color: _borderColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
        );

        final food = SizedBox(
          width: compact ? 190 : 175,
          height: 42,
          child: _dropdown<String>(
            value: _foodType,
            items: const [
              'All Food Types',
              'Breakfast',
              'Lunch',
              'Dinner',
            ],
            onChanged: (value) => setState(() => _foodType = value!),
          ),
        );

        final delivery = SizedBox(
          width: compact ? 210 : 190,
          height: 42,
          child: _dropdown<String>(
            value: _deliveryBoy,
            items: ['All Delivery Boys', ..._deliveryBoys],
            onChanged: (value) => setState(() => _deliveryBoy = value!),
          ),
        );

        final actions = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton(
              onPressed: () => _assignOrders(
                _orders.where((o) => _selectedIds.contains(o.id)).toList(),
              ),
              style: _outlinedButtonStyle(),
              child: const Text('Assign To'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: () => _printOrders(
                _orders.where((o) => _selectedIds.contains(o.id)).toList(),
              ),
              style: _filledButtonStyle(),
              icon: const Icon(Icons.print_outlined, size: 17),
              label: const Text('Print KOT'),
            ),
          ],
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              search,
              const SizedBox(height: 9),
              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: [date, food, delivery],
              ),
              const SizedBox(height: 9),
              actions,
            ],
          );
        }

        return Wrap(
          spacing: 12,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [search, date, food, delivery, actions],
        );
      },
    );
  }

  Widget _dropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 9,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: _borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: _borderColor),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            item.toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildStatusAndViewBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final statusTabs = [
          _statusTab('All Orders', _orders.length, _KotFilter.all),
          _statusTab(
            'Not Assigned',
            _notAssignedCount,
            _KotFilter.notAssigned,
          ),
          _statusTab('Assigned', _assignedCount, _KotFilter.assigned),
          _statusTab(
            'Not Printed',
            _notPrintedCount,
            _KotFilter.notPrinted,
          ),
          _statusTab('Printed', _printedCount, _KotFilter.printed),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < statusTabs.length; i++) ...[
                    statusTabs[i],
                    if (i != statusTabs.length - 1)
                      const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  'Sort by:',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 150,
                  height: 36,
                  child: _dropdown<String>(
                    value: _sortBy,
                    items: const [
                      'Name (A - Z)',
                      'Name (Z - A)',
                      'Order ID',
                    ],
                    onChanged: (value) =>
                        setState(() => _sortBy = value!),
                  ),
                ),
                const Spacer(),
                _viewButton(
                  icon: Icons.grid_view_rounded,
                  selected: _view == _KotView.cards,
                  tooltip: 'Card view',
                  onTap: () => setState(() => _view = _KotView.cards),
                ),
                const SizedBox(width: 6),
                _viewButton(
                  icon: Icons.view_list_rounded,
                  selected: _view == _KotView.table,
                  tooltip: 'Table view',
                  onTap: () => setState(() => _view = _KotView.table),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _statusTab(String label, int count, _KotFilter filter) {
    final selected = _filter == filter;

    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: () => setState(() => _filter = filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: selected ? AppColors.primary : _borderColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 9),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.18)
                    : AppColors.primarySoft,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _viewButton({
    required IconData icon,
    required bool selected,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: selected ? AppColors.primary : AppColors.white,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            width: 37,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? AppColors.primary : _borderColor,
              ),
            ),
            child: Icon(
              icon,
              size: 21,
              color: selected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderArea() {
    final orders = _filteredOrders;

    if (orders.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _borderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 42,
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 12),
              const Text(
                'No orders to display',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Try changing your search or filters.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_view == _KotView.cards) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 1250
              ? 3
              : constraints.maxWidth >= 780
                  ? 2
                  : 1;

          return GridView.builder(
            padding: const EdgeInsets.only(bottom: 8),
            itemCount: orders.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 230,
            ),
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderCard(order);
            },
          );
        },
      );
    }

    return _buildTable(orders);
  }

  Widget _buildOrderCard(_KotOrder order) {
    final selected = _selectedIds.contains(order.id);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? AppColors.primary : _borderColor,
          width: selected ? 1.4 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 30,
                  height: 30,
                  child: Checkbox(
                    value: selected,
                    activeColor: AppColors.primary,
                    onChanged: (value) => _toggleOrder(order.id, value),
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    '#${order.id.toString().padLeft(3, '0')}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.phone,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _mutedColor,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                _printStatus(order.isPrinted),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 145),
                  iconSize: 19,
                  onSelected: (value) {
                    if (value == 'assign') {
                      _assignOrders([order]);
                    } else if (value == 'print') {
                      _printOrders([order]);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'assign',
                      child: Text('Assign delivery person'),
                    ),
                    PopupMenuItem(
                      value: 'print',
                      child: Text('Print KOT'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 7),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: _borderColor.withValues(alpha: 0.8),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.restaurant_menu,
                    size: 17,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.item,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '× ${order.quantity}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: InkWell(
                onTap: () => _showAddress(order),
                borderRadius: BorderRadius.circular(7),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: _borderColor.withValues(alpha: 0.8),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 17,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          order.address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            height: 1.35,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.open_in_new,
                        size: 12,
                        color: _mutedColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.delivery_dining_outlined,
                  size: 17,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    order.deliveryBoy ?? 'Not assigned',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(
                  Icons.phone_outlined,
                  size: 15,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    order.deliveryContact.isEmpty
                        ? 'No contact'
                        : order.deliveryContact,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddress(_KotOrder order) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        title: Text(order.name),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Complete delivery address',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(order.address),
              const SizedBox(height: 12),
              Text('Customer phone: ${order.phone}'),
              Text('Item: ${order.item} × ${order.quantity}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _printStatus(bool printed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: printed ? _greenBg : _orangeBg,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        printed ? 'Printed' : 'Not Printed',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: printed ? _green : _orange,
        ),
      ),
    );
  }


Widget _buildTable(List<_KotOrder> orders) {
  final allSelected = orders.isNotEmpty &&
      orders.every((o) => _selectedIds.contains(o.id));

  return LayoutBuilder(
    builder: (context, constraints) {
      final tableWidth =
          constraints.maxWidth < 1380 ? 1380.0 : constraints.maxWidth;

      Widget headerCell(String label, double width) {
        return SizedBox(
          width: width,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }

      Widget cell(
        String value,
        double width, {
        int maxLines = 1,
        bool bold = false,
      }) {
        return SizedBox(
          width: width,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
            child: Text(
              value,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                height: 1.35,
                color: AppColors.textPrimary,
                fontWeight:
                    bold ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        );
      }

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: _borderColor),
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.antiAlias,
        child: Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: Column(
                children: [
                  Container(
                    height: 48,
                    color: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 42,
                          child: Checkbox(
                            value: allSelected,
                            activeColor: Colors.white,
                            checkColor: AppColors.primary,
                            side: const BorderSide(
                              color: Colors.white,
                            ),
                            onChanged: _toggleAllVisible,
                          ),
                        ),
                        headerCell('#', 65),
                        headerCell('Name', 180),
                        headerCell('Delivery Address', 330),
                        headerCell('Phone', 150),
                        headerCell('Item', 155),
                        headerCell('Qty', 65),
                        headerCell('Delivery Boy', 155),
                        headerCell('Print Status', 115),
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'Actions',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        final selected =
                            _selectedIds.contains(order.id);

                        return Container(
                          height: 66,
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primarySoft
                                : index.isEven
                                    ? AppColors.white
                                    : AppColors.background,
                            border: Border(
                              bottom: BorderSide(
                                color: _borderColor.withValues(
                                  alpha: 0.75,
                                ),
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 42,
                                child: Checkbox(
                                  value: selected,
                                  activeColor: AppColors.primary,
                                  onChanged: (value) =>
                                      _toggleOrder(order.id, value),
                                ),
                              ),
                              cell(
                                '#${order.id.toString().padLeft(3, '0')}',
                                65,
                                bold: true,
                              ),
                              cell(order.name, 180, maxLines: 2),
                              cell(
                                order.address,
                                330,
                                maxLines: 2,
                              ),
                              cell(order.phone, 150, maxLines: 2),
                              cell(order.item, 155, maxLines: 2),
                              cell('${order.quantity}', 65),
                              cell(
                                order.deliveryBoy ?? 'Not assigned',
                                155,
                                maxLines: 2,
                              ),
                              SizedBox(
                                width: 115,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: _printStatus(order.isPrinted),
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    IconButton(
                                      tooltip: 'Assign delivery person',
                                      onPressed: () =>
                                          _assignOrders([order]),
                                      icon: const Icon(
                                        Icons.person_add_alt_1_outlined,
                                        size: 20,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Print KOT',
                                      onPressed: () =>
                                          _printOrders([order]),
                                      icon: const Icon(
                                        Icons.print_outlined,
                                        size: 20,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
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



Widget _tableHeader(String label, double width) {
  return SizedBox(
    width: width,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

Widget _tableCell(
  String text,
  double width, {
  bool bold = false,
  int maxLines = 2,
}) {
  return SizedBox(
    width: width,
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      child: Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11.5,
          height: 1.35,
          color: AppColors.textPrimary,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    ),
  );
}


  Widget _buildBottomBar() {
    final visibleOrders = _filteredOrders;
    final allVisibleSelected = visibleOrders.isNotEmpty &&
        visibleOrders.every((o) => _selectedIds.contains(o.id));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: _borderColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: allVisibleSelected,
            activeColor: AppColors.primary,
            onChanged: _toggleAllVisible,
          ),
          const SizedBox(width: 5),
          Text(
            'Items Selected: $_selectedCount',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          OutlinedButton(
            onPressed: () => _assignOrders(
              _orders.where((o) => _selectedIds.contains(o.id)).toList(),
            ),
            style: _outlinedButtonStyle(),
            child: const Text('Assign To Selected'),
          ),
          const SizedBox(width: 9),
          FilledButton.icon(
            onPressed: () => _printOrders(
              _orders.where((o) => _selectedIds.contains(o.id)).toList(),
            ),
            style: _filledButtonStyle(),
            icon: const Icon(Icons.print_outlined, size: 17),
            label: const Text('Print Selected'),
          ),
        ],
      ),
    );
  }

  ButtonStyle _outlinedButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary),
      backgroundColor: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  ButtonStyle _filledButtonStyle() {
    return FilledButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _KotOrder {
  _KotOrder({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.item,
    required this.quantity,
    required this.deliveryContact,
    required this.foodType,
    required this.isPrinted,
    this.deliveryBoy,
  });

  final int id;
  final String name;
  final String phone;
  final String address;
  final String item;
  final int quantity;
  final String foodType;

  String? deliveryBoy;
  String deliveryContact;
  bool isPrinted;
}
