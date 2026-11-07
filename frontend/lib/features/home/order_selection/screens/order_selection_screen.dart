import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../models/order_selection_model.dart';
import '../services/order_selection_service.dart';

class OrderSelectionScreen extends StatefulWidget {
  const OrderSelectionScreen({super.key});

  @override
  State<OrderSelectionScreen> createState() => _OrderSelectionScreenState();
}

class _OrderSelectionScreenState extends State<OrderSelectionScreen> {
  final OrderSelectionService _service = OrderSelectionService();
  final TextEditingController _searchController = TextEditingController();

  DateTime _selectedDate = DateTime(2026, 11, 7);
  int _currentPage = 0;

  PendingOrderAssignmentModel? _selectedAssignment;
  OrderCustomerModel? _selectedCustomer;
  OrderAddressModel? _selectedAddress;
  String? _selectedSubCategory;
  int? _selectedItemId;

  Color get _brown => AppColors.primary;

  List<PendingOrderAssignmentModel> get _dateAssignments =>
      _service.getPendingAssignments(_selectedDate);

  List<PendingOrderAssignmentModel> get _filteredAssignments {
    final query = _searchController.text.trim().toLowerCase();
    return _dateAssignments.where((assignment) {
      final customer = _service.getCustomer(assignment.customerId);
      if (customer == null) return false;
      return query.isEmpty ||
          customer.name.toLowerCase().contains(query) ||
          customer.mobileNumber.toLowerCase().contains(query);
    }).toList();
  }

  List<OrderItemModel> get _availableItems {
    if (_selectedAssignment == null || _selectedSubCategory == null) {
      return [];
    }
    return _service.getItems(
      _selectedAssignment!.mealCategory,
      _selectedSubCategory!,
    );
  }

  String get _displayDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${_selectedDate.day} ${months[_selectedDate.month - 1]} ${_selectedDate.year}';
  }

  String get _formattedDate =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _selectAssignment(PendingOrderAssignmentModel assignment) {
    final customer = _service.getCustomer(assignment.customerId);
    if (customer == null) return;

    final address = _service.getAddress(customer, assignment.addressId);
    if (address == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The subscription delivery address was not found.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _selectedAssignment = assignment;
      _selectedCustomer = customer;
      _selectedAddress = address;
      _selectedSubCategory = assignment.subCategory;
      _selectedItemId = null;
      _currentPage = 1;
    });
  }

  void _changeSubCategory(String? value) {
    setState(() {
      _selectedSubCategory = value;
      _selectedItemId = null;
    });
  }

  void _selectItem(int itemId) {
    setState(() {
      _selectedItemId = _selectedItemId == itemId ? null : itemId;
    });
  }

  void _cancelAssignment() {
    setState(() {
      _currentPage = 0;
      _selectedAssignment = null;
      _selectedCustomer = null;
      _selectedAddress = null;
      _selectedSubCategory = null;
      _selectedItemId = null;
    });
  }

  void _showOrderPreview() {
    if (_selectedAssignment == null ||
        _selectedCustomer == null ||
        _selectedAddress == null ||
        _selectedSubCategory == null ||
        _selectedItemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a subcategory and one item.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final selectedItem = _availableItems.firstWhere(
      (item) => item.id == _selectedItemId,
    );

    final orderItem = OrderItemQuantityModel(
      itemId: selectedItem.id,
      itemName: selectedItem.name,
      quantity: _selectedAssignment!.quantity,
    );

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _OrderPreviewDialog(
        customer: _selectedCustomer!,
        address: _selectedAddress!,
        mealCategory: _selectedAssignment!.mealCategory,
        subCategory: _selectedSubCategory!,
        items: [orderItem],
        onBack: () => Navigator.pop(dialogContext),
        onSave: () {
          final order = OrderSelectionModel(
            assignmentId: _selectedAssignment!.id,
            customerId: _selectedCustomer!.id,
            customerName: _selectedCustomer!.name,
            mobileNumber: _selectedCustomer!.mobileNumber,
            address: _selectedAddress!.address,
            deliveryDate: _formattedDate,
            mealCategory: _selectedAssignment!.mealCategory,
            subCategory: _selectedSubCategory!,
            items: [orderItem],
          );

          _service.saveOrder(order);
          Navigator.pop(dialogContext);

          _cancelAssignment();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order saved successfully!'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Color(0xFF287A50),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _currentPage == 0
                  ? _buildCustomerSelection()
                  : _buildAssignItems(),
            ),
            if (_currentPage == 1) _buildAssignBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (_currentPage == 1) {
                _cancelAssignment();
              } else {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _currentPage == 0
                  ? Icons.receipt_long_outlined
                  : Icons.restaurant_menu,
              color: _brown,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentPage == 0
                      ? 'Orders Selection'
                      : 'Assign Items to Order',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: _brown,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _currentPage == 0
                      ? 'Select a customer to assign items'
                      : 'Select meal category and items',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerSelection() {
    final assignments = _filteredAssignments;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // Mobile and tablet: one assignment per row.
        // Wide web: three columns, matching the existing web layout.
        final columns = width < 1024 ? 1 : 3;
        final horizontalPadding = width < 600 ? 14.0 : 30.0;
        const spacing = 14.0;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            width < 600 ? 14 : 22,
            horizontalPadding,
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dateSelector(),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search customer (name or number)',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.75),
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.textPrimary,
                    size: 21,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.close, size: 18),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide:
                        BorderSide(color: AppColors.primary, width: 1.4),
                  ),
                ),
              ),
             const SizedBox(height: 18),
              if (assignments.isEmpty)
                _emptyState('No pending assignments for this date')
              else
                LayoutBuilder(
                  builder: (context, gridConstraints) {
                    final cardWidth = columns == 1
                        ? gridConstraints.maxWidth
                        : (gridConstraints.maxWidth -
                                spacing * (columns - 1)) /
                            columns;
                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: assignments.map((assignment) {
                        final customer =
                            _service.getCustomer(assignment.customerId);
                        if (customer == null) return const SizedBox.shrink();
                        return SizedBox(
                          width: cardWidth,
                          child: _customerCard(customer, assignment),
                        );
                      }).toList(),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _dateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => _changeDate(-1),
            icon: const Icon(Icons.chevron_left, size: 22),
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: 4),
          Text(
            _displayDate,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => _changeDate(1),
            icon: const Icon(Icons.chevron_right, size: 22),
            color: AppColors.textPrimary,
          ),
          Container(
            width: 1,
            height: 27,
            color: AppColors.border,
            margin: const EdgeInsets.symmetric(horizontal: 5),
          ),
          IconButton(
            tooltip: 'Choose date',
            visualDensity: VisualDensity.compact,
            onPressed: _selectDate,
            icon: const Icon(Icons.calendar_month_outlined, size: 20),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _customerCard(
    OrderCustomerModel customer,
    PendingOrderAssignmentModel assignment,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _selectAssignment(assignment),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primarySoft,
                child: Icon(Icons.person,
                    color: AppColors.primaryDark, size: 25),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone,
                            color: Colors.red.shade700, size: 13),
                        const SizedBox(width: 5),
                        Text(
                          customer.mobileNumber,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _service
                              .getAddress(customer, assignment.addressId)
                              ?.address ??
                          '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  assignment.mealCategory,
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Icon(Icons.chevron_right,
                  color: AppColors.textSecondary, size: 21),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssignItems() {
    final customer = _selectedCustomer;
    final assignment = _selectedAssignment;
    final address = _selectedAddress;

    if (customer == null || assignment == null || address == null) {
      return Center(child: _emptyState('Please select a customer first'));
    }

    final compact = MediaQuery.of(context).size.width < 900;

    return SingleChildScrollView(
      key: const ValueKey('assign_items'),
      padding: EdgeInsets.fromLTRB(
        compact ? 14 : 26,
        compact ? 12 : 22,
        compact ? 14 : 26,
        12,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _customerSummary(customer),
                const SizedBox(height: 18),
                _assignSectionTitle(
                    'Delivery Address', Icons.location_on_outlined),
                const SizedBox(height: 9),
                _singleAddressCard(address),
                const SizedBox(height: 17),
                _assignSectionTitle(
                    'Meal Category', Icons.restaurant_menu),
                const SizedBox(height: 9),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Text(
                      assignment.mealCategory,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 17),
                _assignSectionTitle('Sub Category', Icons.layers_outlined),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedSubCategory,
                  isExpanded: true,
                  decoration: InputDecoration(
                    hintText: 'Select subcategory',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                  ),
                  items: _service
                      .getSubCategories(assignment.mealCategory)
                      .map((subcategory) => DropdownMenuItem(
                            value: subcategory,
                            child: Text(subcategory),
                          ))
                      .toList(),
                  onChanged: _changeSubCategory,
                ),
                const SizedBox(height: 17),
                _assignSectionTitle('Select Curry',
                    Icons.shopping_basket_outlined),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: _selectedSubCategory == null
                      ? _itemsMessage('Select a subcategory to view items')
                      : _availableItems.isEmpty
                          ? _itemsMessage('No scheduled items available')
                          : Column(
                              children: _availableItems.map((item) {
                                final selected = _selectedItemId == item.id;
                                return InkWell(
                                  onTap: () => _selectItem(item.id),
                                  borderRadius: BorderRadius.circular(9),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 5),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 9, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? AppColors.primarySoft
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: selected,
                                          activeColor: AppColors.primary,
                                          visualDensity:
                                              VisualDensity.compact,
                                          onChanged: (_) =>
                                              _selectItem(item.id),
                                        ),
                                        Expanded(
                                          child: Text(
                                            item.name,
                                            style: TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _customerSummary(OrderCustomerModel customer) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primarySoft,
            child: Icon(Icons.person,
                color: AppColors.primaryDark, size: 25),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.phone,
                        size: 13, color: AppColors.primaryDark),
                    const SizedBox(width: 5),
                    Text(
                      customer.mobileNumber,
                      style: TextStyle(
                          color: AppColors.textPrimary, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _singleAddressCard(OrderAddressModel address) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.primary, width: 1.2),
      ),
      child: Row(
        children: [
          Icon(Icons.radio_button_checked,
              color: AppColors.primary, size: 20),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.label,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  address.address,
                  style: TextStyle(
                      color: AppColors.textPrimary, fontSize: 12),
                ),
              ],
            ),
          ),
          if (address.isDefault)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Default',
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _itemsMessage(String message) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _assignSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryDark, size: 20),
        const SizedBox(width: 9),
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildAssignBottomBar() {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Center(
          child: SizedBox(
            width: 470,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _cancelAssignment,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryDark,
                      side: BorderSide(color: AppColors.primary),
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showOrderPreview,
                    icon: const Icon(Icons.check, size: 17),
                    label: const Text('Create Orders'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

class _OrderPreviewDialog extends StatelessWidget {
  final OrderCustomerModel customer;
  final OrderAddressModel address;
  final String mealCategory;
  final String subCategory;
  final List<OrderItemQuantityModel> items;
  final VoidCallback onBack;
  final VoidCallback onSave;

  const _OrderPreviewDialog({
    required this.customer,
    required this.address,
    required this.mealCategory,
    required this.subCategory,
    required this.items,
    required this.onBack,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final brown = AppColors.primary;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(Icons.receipt_long_outlined, color: brown),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        'Order Preview',
                        style: TextStyle(
                          color: brown,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onBack,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(height: 25),
                _previewRow('Customer Name', customer.name),
                _previewRow('Mobile Number', customer.mobileNumber),
                _previewRow('Delivery Address', address.address),
                _previewRow('Meal Category', mealCategory),
                _previewRow('Subcategory', subCategory),
                const SizedBox(height: 12),
                Text(
                  'Selected Items',
                  style: TextStyle(
                    color: brown,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          Expanded(
                            child: Text(
                              'Item Name',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Text(
                            'Quantity',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 18),
                      ...items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.itemName,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              SizedBox(
                                width: 65,
                                child: Text(
                                  '${item.quantity}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onBack,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: brown,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: brown),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onSave,
                        icon: const Icon(Icons.save_outlined, size: 18),
                        label: const Text('Save Order'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brown,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
  }

  Widget _previewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
          ),
          const Text(':  '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
