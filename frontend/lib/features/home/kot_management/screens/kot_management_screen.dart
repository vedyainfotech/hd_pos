import 'package:flutter/material.dart';

/// Responsive KOT Management screen.
///
/// UI-first implementation with local demo data. Connect the callbacks and
/// data loading to KotManagementService when the backend endpoints are ready.
class KotManagementScreen extends StatefulWidget {
  const KotManagementScreen({super.key});

  @override
  State<KotManagementScreen> createState() => _KotManagementScreenState();
}

class _KotManagementScreenState extends State<KotManagementScreen> {
  static const Color _brand = Color(0xFF963D08);
  static const Color _brandDark = Color(0xFF7D3107);
  static const Color _brandLight = Color(0xFFFFF3EA);
  static const Color _page = Color(0xFFF8F7F5);
  static const Color _line = Color(0xFFE7E1DC);
  static const Color _text = Color(0xFF302923);
  static const Color _muted = Color(0xFF786D65);
  static const double _mobileBreakpoint = 760;
  static const double _wideTableMinimum = 1360;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _tableVerticalController = ScrollController();
  final ScrollController _tableHorizontalController = ScrollController();
  final ScrollController _mobileListController = ScrollController();

  final List<_KotEntry> _entries = [
    _KotEntry(
      customer: 'K Radha Krishna',
      address: 'E 1. Sairam apartments, Sector 1, MVP Colony, Vsp 17.',
      landmark: 'Besides Sri Chaitanya school',
      phone: '9849122946',
      item: 'Masala Dosa',
      quantity: 1,
      deliveryPerson: 'Prasad',
      contact: '9030117162',
      isPrinted: true,
      foodType: 'Breakfast',
    ),
    _KotEntry(
      customer: 'DB Venkatadri',
      address: '8-28-8/1 Tamil street, Old CBI down street, opposite Kanakamma Temple Arch',
      landmark: 'Old CBI down street, opposite Kanakamma Temple Arch',
      phone: '9441755336',
      item: 'Masala Dosa',
      quantity: 2,
      deliveryPerson: 'A V S Prasad',
      contact: '9676770701',
      isPrinted: true,
      foodType: 'Breakfast',
    ),
    _KotEntry(
      customer: 'DR R MADHURI DEVI',
      address: 'Vijaya Vipanchi, D.No. 2-65, Plot No. 6, Srinivas Nagar, Yendada',
      landmark: 'Durga Devi temple opposite lane',
      phone: '9949796278',
      item: 'Masala Dosa',
      quantity: 1,
      deliveryPerson: 'Prasad',
      contact: '9030117162',
      isPrinted: true,
      foodType: 'Breakfast',
    ),
    _KotEntry(
      customer: 'P ARUNA',
      address: 'Flat No. 16, Punarvasu Apartments, Pandurangapuram',
      landmark: '',
      phone: '6304994745',
      item: 'Masala Dosa',
      quantity: 1,
      deliveryPerson: 'P Bharath Kumar',
      contact: '8985868876',
      isPrinted: true,
      foodType: 'Breakfast',
    ),
    _KotEntry(
      customer: 'N SRIDEVI',
      address: 'Flat No. 501, 5th floor, Vinayagar South Avenue, CBM compound',
      landmark: 'Near CMR Jewellery',
      phone: '9849575405',
      item: 'Masala Dosa',
      quantity: 1,
      deliveryPerson: 'jagan',
      contact: '8179650301',
      isPrinted: true,
      foodType: 'Breakfast',
    ),
    _KotEntry(
      customer: 'Veera Lakshmi',
      address: '104 Niharika Enclave, Abidnagar, Akkayapalem',
      landmark: '',
      phone: '9246618059',
      item: 'Masala Dosa',
      quantity: 1,
      deliveryPerson: 'jagan',
      contact: '8179650301',
      isPrinted: true,
      foodType: 'Breakfast',
    ),
    _KotEntry(
      customer: 'B S Pradeep',
      address: 'Pragathi Park Lane Residency, B Block 2-B, East Point Colony',
      landmark: 'Opposite GCC, Vuda Park',
      phone: '7483208743',
      item: 'Masala Dosa',
      quantity: 2,
      deliveryPerson: 'A V S Prasad',
      contact: '9676770701',
      isPrinted: true,
      foodType: 'Breakfast',
    ),
    _KotEntry(
      customer: 'V Bangaraju',
      address: 'Flat 50-53-11/5, NE Layout, Leela Enclaves, Seethammadhara',
      landmark: 'Near Abhaya Anjaneya Temple',
      phone: '9542241155',
      item: 'Masala Dosa',
      quantity: 2,
      deliveryPerson: 'P Bharath Kumar',
      contact: '8985868876',
      isPrinted: true,
      foodType: 'Breakfast',
    ),
    _KotEntry(
      customer: 'Ravisankar',
      address: '45-46-21/A, Srinivasa Nagar, 80 Feet Road',
      landmark: '',
      phone: '9849242618',
      item: 'Masala Dosa',
      quantity: 1,
      deliveryPerson: 'jagan',
      contact: '8179650301',
      isPrinted: true,
      foodType: 'Breakfast',
    ),
  ];

  static const List<String> _foodTypes = [
    'All Food Types',
    'Breakfast',
    'Lunch',
    'Dinner',
  ];

  static const List<String> _menuItems = [
    'Masala Dosa',
    'Idli',
    'Puri',
    'Curd Rice',
    'Meals',
    'Potato Curry',
    'Chapati',
    'Paneer Curry',
    'Sambar',
  ];

  static const List<String> _deliveryPeople = [
    'Not assigned',
    'Prasad',
    'A V S Prasad',
    'P Bharath Kumar',
    'jagan',
    'A Ravi',
  ];

  DateTime _selectedDate = DateTime.now();
  String _selectedFoodType = 'All Food Types';
  bool _selectAllFiltered = false;
  String? _bulkItem;
  int? _bulkQuantity;
  String? _bulkDeliveryPerson;

  List<_KotEntry> get _filteredEntries {
    final query = _searchController.text.trim().toLowerCase();
    return _entries.where((entry) {
      final matchesQuery = query.isEmpty ||
          entry.customer.toLowerCase().contains(query) ||
          entry.phone.toLowerCase().contains(query) ||
          entry.address.toLowerCase().contains(query) ||
          entry.landmark.toLowerCase().contains(query);
      final matchesFoodType = _selectedFoodType == 'All Food Types' ||
          entry.foodType == _selectedFoodType;
      return matchesQuery && matchesFoodType;
    }).toList();
  }

  int get _selectedCount => _entries.where((entry) => entry.isSelected).length;
  int get _assignedCount => _entries
      .where((entry) => entry.deliveryPerson != 'Not assigned')
      .length;
  int get _unassignedCount => _entries.length - _assignedCount;
  int get _printedCount =>
      _entries.where((entry) => entry.isPrinted).length;

  @override
  void dispose() {
    _searchController.dispose();
    _tableVerticalController.dispose();
    _tableHorizontalController.dispose();
    _mobileListController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _page,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < _mobileBreakpoint;
            final horizontalPadding = isMobile
                ? 12.0
                : constraints.maxWidth < 1100
                    ? 18.0
                    : 28.0;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                isMobile ? 12 : 18,
                horizontalPadding,
                12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTitleBar(isMobile),
                  SizedBox(height: isMobile ? 14 : 18),
                  _buildFilterPanel(isMobile),
                  const SizedBox(height: 14),
                  Expanded(
                    child: isMobile
                        ? _buildMobileList()
                        : _buildResponsiveTable(),
                  ),
                  const SizedBox(height: 12),
                  _buildSummary(isMobile),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTitleBar(bool isMobile) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Go back',
          onPressed: () => Navigator.maybePop(context),
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.arrow_back, color: _text),
        ),
        const SizedBox(width: 7),
        Container(
          height: isMobile ? 42 : 46,
          width: isMobile ? 42 : 46,
          decoration: BoxDecoration(
            color: const Color(0xFFF1E5DC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.receipt_long_outlined,
            color: _brand,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KOT Management',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _text,
                  fontSize: isMobile ? 19 : 23,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (!isMobile)
                const Text(
                  'View, assign and print kitchen order tickets',
                  style: TextStyle(color: _muted, fontSize: 12),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: _printSelected,
          icon: const Icon(Icons.print_outlined, size: 18),
          label: Text(isMobile ? 'Print' : 'Print KOT'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _brand,
            side: const BorderSide(color: _brand),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 10 : 17,
              vertical: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterPanel(bool isMobile) {
    final searchField = TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {
        _selectAllFiltered = _filteredEntries.isNotEmpty &&
            _filteredEntries.every((entry) => entry.isSelected);
      }),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search ID, Name, Phone',
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9A8D84)),
        prefixIcon: const Icon(Icons.search, color: _muted),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                onPressed: () {
                  _searchController.clear();
                  setState(() => _selectAllFiltered = false);
                },
                icon: const Icon(Icons.close, size: 18),
              ),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: _line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: _line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: _brand, width: 1.3),
        ),
      ),
    );

    final dateButton = OutlinedButton.icon(
      onPressed: _pickDate,
      icon: const Icon(Icons.calendar_today_outlined, size: 16),
      label: Text(_formatDate(_selectedDate)),
      style: OutlinedButton.styleFrom(
        foregroundColor: _brand,
        side: const BorderSide(color: _brand),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      ),
    );

    final foodDropdown = DropdownButtonFormField<String>(
      initialValue: _selectedFoodType,
      isExpanded: true,
      decoration: _filterDecoration('Food type'),
      items: _foodTypes
          .map((type) =>
              DropdownMenuItem(value: type, child: Text(type, overflow: TextOverflow.ellipsis)))
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          _selectedFoodType = value;
          _selectAllFiltered = _filteredEntries.isNotEmpty &&
              _filteredEntries.every((entry) => entry.isSelected);
        });
      },
    );

    final assignButton = FilledButton.icon(
      onPressed: _assignSelected,
      icon: const Icon(Icons.assignment_ind_outlined, size: 18),
      label: const Text('Assign To'),
      style: FilledButton.styleFrom(
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          searchField,
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(child: dateButton),
              const SizedBox(width: 9),
              Expanded(child: foodDropdown),
            ],
          ),
          const SizedBox(height: 9),
          SizedBox(width: double.infinity, child: assignButton),
        ],
      );
    }

    return Row(
      children: [
        Expanded(flex: 5, child: searchField),
        const SizedBox(width: 10),
        dateButton,
        const SizedBox(width: 10),
        SizedBox(width: 195, child: foodDropdown),
        const SizedBox(width: 10),
        assignButton,
      ],
    );
  }

  InputDecoration _filterDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12, color: _muted),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: _line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: _line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: _brand, width: 1.3),
      ),
    );
  }

  Widget _buildResponsiveTable() {
    final rows = _filteredEntries;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(13),
      ),
      clipBehavior: Clip.antiAlias,
      child: rows.isEmpty
          ? _buildEmptyState()
          : LayoutBuilder(
              builder: (context, constraints) {
                final tableWidth = constraints.maxWidth < _wideTableMinimum
                    ? _wideTableMinimum
                    : constraints.maxWidth;
                final widths = _calculateColumnWidths(tableWidth);

                return Scrollbar(
                  controller: _tableHorizontalController,
                  thumbVisibility: tableWidth > constraints.maxWidth,
                  notificationPredicate: (notification) =>
                      notification.metrics.axis == Axis.horizontal,
                  child: SingleChildScrollView(
                    controller: _tableHorizontalController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: tableWidth,
                      child: Column(
                        children: [
                          _buildTableHeader(widths),
                          Expanded(
                            child: Scrollbar(
                              controller: _tableVerticalController,
                              thumbVisibility: true,
                              child: ListView.separated(
                                controller: _tableVerticalController,
                                padding: EdgeInsets.zero,
                                itemCount: rows.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1, color: _line),
                                itemBuilder: (context, index) =>
                                    _buildDesktopRow(rows[index], widths, index),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  List<double> _calculateColumnWidths(double width) {
    // Ratios preserve the reference's column hierarchy while using all
    // available desktop width. A minimum table width enables clean tablet
    // horizontal scrolling instead of squeezing controls until they break.
    const ratios = [0.035, 0.155, 0.205, 0.105, 0.135, 0.09, 0.145, 0.075, 0.055];
    return ratios.map((ratio) => width * ratio).toList();
  }

  Widget _buildTableHeader(List<double> widths) {
    return Container(
      height: 58,
      color: _brand,
      child: Row(
        children: [
          SizedBox(
            width: widths[0],
            child: Center(
              child: Checkbox(
                value: _selectAllFiltered && _filteredEntries.isNotEmpty,
                onChanged: _toggleSelectAll,
                side: const BorderSide(color: Colors.white, width: 1.4),
                checkColor: _brand,
                activeColor: Colors.white,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          _headerLabel(widths[1], 'Name'),
          _headerLabel(widths[2], 'Delivery Address'),
          _headerLabel(widths[3], 'Delivery PH NO'),
          SizedBox(
            width: widths[4],
            child: _headerDropdown<String>(
              hint: 'Select Item',
              value: _bulkItem,
              items: _menuItems,
              onChanged: (value) {
                if (value == null) return;
                final selected = _entries.where((entry) => entry.isSelected);
                if (selected.isEmpty) {
                  _showMessage('Select customer rows first to apply an item.');
                  setState(() => _bulkItem = null);
                  return;
                }
                setState(() {
                  for (final entry in selected) {
                    entry.item = value;
                  }
                  _bulkItem = null;
                });
              },
            ),
          ),
          SizedBox(
            width: widths[5],
            child: _headerDropdown<int>(
              hint: 'Select Qty',
              value: _bulkQuantity,
              items: List.generate(10, (index) => index + 1),
              itemLabel: (value) => '$value',
              onChanged: (value) {
                if (value == null) return;
                final selected = _entries.where((entry) => entry.isSelected);
                if (selected.isEmpty) {
                  _showMessage('Select customer rows first to apply quantity.');
                  setState(() => _bulkQuantity = null);
                  return;
                }
                setState(() {
                  for (final entry in selected) {
                    entry.quantity = value;
                  }
                  _bulkQuantity = null;
                });
              },
            ),
          ),
          SizedBox(
            width: widths[6],
            child: _headerDropdown<String>(
              hint: 'Select Delivery Boy',
              value: _bulkDeliveryPerson,
              items: _deliveryPeople.where((person) => person != 'Not assigned').toList(),
              onChanged: (value) {
                if (value == null) return;
                final selected = _entries.where((entry) => entry.isSelected);
                if (selected.isEmpty) {
                  _showMessage('Select customer rows first to assign a delivery person.');
                  setState(() => _bulkDeliveryPerson = null);
                  return;
                }
                setState(() {
                  for (final entry in selected) {
                    entry.deliveryPerson = value;
                    entry.contact = _contactFor(value);
                  }
                  _bulkDeliveryPerson = null;
                });
              },
            ),
          ),
          _headerLabel(widths[7], 'Contact'),
          _headerLabel(widths[8], 'Print Status'),
        ],
      ),
    );
  }

  Widget _headerLabel(double width, String label) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerDropdown<T>({
    required String hint,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    String Function(T value)? itemLabel,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down, size: 17, color: _text),
        style: const TextStyle(fontSize: 11.5, color: _text),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 11.5, color: _text),
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide.none,
          ),
        ),
        items: items.map((item) => DropdownMenuItem<T>(
          value: item,
          child: Text(
            itemLabel == null ? '$item' : itemLabel(item),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        )).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDesktopRow(_KotEntry entry, List<double> widths, int index) {
    return Container(
      constraints: const BoxConstraints(minHeight: 62),
      color: index.isEven ? Colors.white : const Color(0xFFFCFBFA),
      child: Row(
        children: [
          SizedBox(
            width: widths[0],
            child: Center(
              child: Checkbox(
                value: entry.isSelected,
                onChanged: (value) => _setEntrySelected(entry, value ?? false),
                activeColor: _brand,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          SizedBox(
            width: widths[1],
            child: _tableCell(
              Text(entry.customer,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5, color: _text)),
            ),
          ),
          SizedBox(
            width: widths[2],
            child: _tableCell(
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11.5, height: 1.3)),
                  if (entry.landmark.isNotEmpty)
                    Text(
                      'Landmark: ${entry.landmark}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: widths[3],
            child: _tableCell(
              Text(entry.phone,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 12)),
            ),
          ),
          SizedBox(
            width: widths[4],
            child: _tableCell(Text(entry.item,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12))),
          ),
          SizedBox(
            width: widths[5],
            child: _tableCell(Text('${entry.quantity}',
                style: const TextStyle(fontSize: 12))),
          ),
          SizedBox(
            width: widths[6],
            child: _tableCell(Text(entry.deliveryPerson == 'Not assigned'
                ? '—'
                : entry.deliveryPerson,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12))),
          ),
          SizedBox(
            width: widths[7],
            child: _tableCell(
              Text(entry.contact,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 11.5)),
            ),
          ),
          SizedBox(
            width: widths[8],
            child: _tableCell(_printStatus(entry)),
          ),
        ],
      ),
    );
  }

  Widget _tableCell(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
      child: Align(alignment: Alignment.centerLeft, child: child),
    );
  }


  Widget _buildMobileList() {
    final rows = _filteredEntries;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(13),
      ),
      clipBehavior: Clip.antiAlias,
      child: rows.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  color: _brand,
                  child: Row(
                    children: [
                      Checkbox(
                        value: _selectAllFiltered && rows.isNotEmpty,
                        onChanged: _toggleSelectAll,
                        side: const BorderSide(color: Colors.white),
                        activeColor: Colors.white,
                        checkColor: _brand,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const SizedBox(width: 5),
                      const Expanded(
                        child: Text('CUSTOMER KOT DETAILS',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12)),
                      ),
                      Text('${rows.length} records',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
                Expanded(
                  child: Scrollbar(
                    controller: _mobileListController,
                    thumbVisibility: true,
                    child: ListView.separated(
                      controller: _mobileListController,
                      padding: const EdgeInsets.all(10),
                      itemCount: rows.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 9),
                      itemBuilder: (context, index) =>
                          _buildMobileCard(rows[index], index),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMobileCard(_KotEntry entry, int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: index.isEven ? Colors.white : const Color(0xFFFFFDFC),
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: entry.isSelected,
                onChanged: (value) => _setEntrySelected(entry, value ?? false),
                activeColor: _brand,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.customer,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _text)),
                    const SizedBox(height: 3),
                    Text(entry.phone,
                        style:
                            const TextStyle(fontSize: 12, color: _muted)),
                  ],
                ),
              ),
              _printStatus(entry),
            ],
          ),
          const Divider(height: 18, color: _line),
          _mobileDetail('Delivery address', entry.address),
          if (entry.landmark.isNotEmpty)
            _mobileDetail('Landmark', entry.landmark),
          const SizedBox(height: 10),
          _mobileDropdownRow<String>(
            label: 'Select item',
            value: entry.item,
            items: _menuItems,
            onChanged: (value) {
              if (value != null) setState(() => entry.item = value);
            },
          ),
          const SizedBox(height: 8),
          _mobileDropdownRow<int>(
            label: 'Select quantity',
            value: entry.quantity,
            items: List.generate(10, (index) => index + 1),
            itemLabel: (value) => '$value',
            onChanged: (value) {
              if (value != null) setState(() => entry.quantity = value);
            },
          ),
          const SizedBox(height: 8),
          _mobileDropdownRow<String>(
            label: 'Delivery person',
            value: entry.deliveryPerson,
            items: _deliveryPeople,
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                entry.deliveryPerson = value;
                entry.contact = _contactFor(value);
              });
            },
          ),
          const SizedBox(height: 8),
          _mobileDetail('Delivery person contact', entry.contact),
        ],
      ),
    );
  }

  Widget _mobileDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(label,
                style: const TextStyle(fontSize: 11, color: _muted)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 12, color: _text, height: 1.3)),
          ),
        ],
      ),
    );
  }

  Widget _mobileDropdownRow<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    String Function(T value)? itemLabel,
  }) {
    final safeValue = items.contains(value) ? value : items.first;
    return Row(
      children: [
        SizedBox(
          width: 112,
          child: Text(label,
              style: const TextStyle(fontSize: 11, color: _muted)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButtonFormField<T>(
            initialValue: safeValue,
            isExpanded: true,
            isDense: true,
            style: const TextStyle(fontSize: 12, color: _text),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: const BorderSide(color: _line)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: const BorderSide(color: _line)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: const BorderSide(color: _brand)),
            ),
            items: items
                .map((item) => DropdownMenuItem<T>(
                      value: item,
                      child: Text(
                        itemLabel == null ? '$item' : itemLabel(item),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _printStatus(_KotEntry entry) {
    final printed = entry.isPrinted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: printed ? const Color(0xFFE8F5EC) : _brandLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        printed ? 'Printed' : 'Not printed',
        maxLines: 1,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: printed ? const Color(0xFF168044) : _brand,
        ),
      ),
    );
  }

  Widget _buildSummary(bool isMobile) {
    final stats = [
      _SummaryData(Icons.check_circle_outline, 'Items Selected', '$_selectedCount'),
      _SummaryData(Icons.receipt_long_outlined, 'Total Customers', '${_entries.length}'),
      _SummaryData(Icons.delivery_dining_outlined, 'Assigned Count', '$_assignedCount'),
      _SummaryData(Icons.person_off_outlined, 'Un-assigned Count', '$_unassignedCount'),
      _SummaryData(Icons.print_outlined, 'Printed KOTs Count', '$_printedCount'),
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 11 : 14,
        vertical: isMobile ? 10 : 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: isMobile
          ? Wrap(
              spacing: 14,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              children: stats.map(_buildSummaryItem).toList(),
            )
          : Row(
              children: stats
                  .map((stat) => Expanded(child: _buildSummaryItem(stat)))
                  .toList(),
            ),
    );
  }

  Widget _buildSummaryItem(_SummaryData stat) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(stat.icon, color: _brand, size: 17),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            '${stat.label}: ',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11.5, color: _muted),
          ),
        ),
        Text(
          stat.value,
          style: const TextStyle(
              fontSize: 12.5, fontWeight: FontWeight.w700, color: _text),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 38, color: Color(0xFFB7AAA0)),
            SizedBox(height: 9),
            Text('No KOT records found',
                style: TextStyle(
                    color: _text, fontWeight: FontWeight.w600, fontSize: 14)),
            SizedBox(height: 4),
            Text('Try changing the search or food type filter.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _toggleSelectAll(bool? value) {
    final shouldSelect = value ?? false;
    setState(() {
      _selectAllFiltered = shouldSelect;
      for (final entry in _filteredEntries) {
        entry.isSelected = shouldSelect;
      }
    });
  }

  void _setEntrySelected(_KotEntry entry, bool selected) {
    setState(() {
      entry.isSelected = selected;
      _selectAllFiltered = _filteredEntries.isNotEmpty &&
          _filteredEntries.every((item) => item.isSelected);
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: _brand,
                onPrimary: Colors.white,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';

  void _assignSelected() {
    final selected = _entries.where((entry) => entry.isSelected).toList();
    if (selected.isEmpty) {
      _showMessage('Select at least one customer before assigning.');
      return;
    }
    _openAssignDialog(selected);
  }

  Future<void> _openAssignDialog(List<_KotEntry> selected) async {
    String selectedPerson = _deliveryPeople[1];
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Assign delivery person'),
          content: SizedBox(
            width: 340,
            child: DropdownButtonFormField<String>(
              initialValue: selectedPerson,
              isExpanded: true,
              decoration: _filterDecoration('Delivery person'),
              items: _deliveryPeople
                  .where((person) => person != 'Not assigned')
                  .map((person) => DropdownMenuItem(
                        value: person,
                        child: Text(person),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setDialogState(() => selectedPerson = value);
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _brand),
              onPressed: () => Navigator.pop(dialogContext, selectedPerson),
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );

    if (!mounted || result == null) return;
    setState(() {
      for (final entry in selected) {
        entry.deliveryPerson = result;
        entry.contact = _contactFor(result);
      }
    });
    _showMessage('Assigned ${selected.length} selected customer(s).');
  }

  String _contactFor(String person) {
    switch (person) {
      case 'Prasad':
        return '9030117162';
      case 'A V S Prasad':
        return '9676770701';
      case 'P Bharath Kumar':
        return '8985868876';
      case 'jagan':
        return '8179650301';
      case 'A Ravi':
        return '9755557070';
      default:
        return '—';
    }
  }

  void _printSelected() {
    final selected = _entries.where((entry) => entry.isSelected).toList();
    if (selected.isEmpty) {
      _showMessage('Select at least one KOT before printing.');
      return;
    }
    setState(() {
      for (final entry in selected) {
        entry.isPrinted = true;
      }
    });
    _showMessage(
      'Selected KOTs marked as printed. Connect the printer service for physical printing.',
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _KotEntry {
  _KotEntry({
    required this.customer,
    required this.address,
    required this.landmark,
    required this.phone,
    required this.item,
    required this.quantity,
    required this.deliveryPerson,
    required this.contact,
    required this.isPrinted,
    required this.foodType,
  });

  final String customer;
  final String address;
  final String landmark;
  final String phone;
  String item;
  int quantity;
  String deliveryPerson;
  String contact;
  bool isPrinted;
  final String foodType;
  bool isSelected = false;
}

class _SummaryData {
  const _SummaryData(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;
}
