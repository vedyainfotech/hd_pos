import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../models/customer_model.dart';
import '../services/customer_store.dart';
import 'add_customer_screen.dart';
import 'customer_details_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String _searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }




Future<void> _openAddCustomer() async {
  final result = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => const AddCustomerScreen(),
    ),
  );

  if (!mounted) return;

  if (result == true) {
    _showSuccessToast('Customer added successfully');
  }
}






  List<Customer> _filterCustomers(
    List<Customer> customers,
  ) {
    final query = _searchText.trim().toLowerCase();

    if (query.isEmpty) {
      return customers;
    }

    return customers.where((customer) {
      final id = customer.id.toLowerCase();
      final name = customer.name.toLowerCase();

      final phoneMatches = customer.phoneNumbers.any(
        (phone) => phone.toLowerCase().contains(query),
      );

      return id.contains(query) ||
          name.contains(query) ||
          phoneMatches;
    }).toList();
  }


void _showSuccessToast(String message) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

 
overlayEntry = OverlayEntry(
  builder: (overlayContext) {
    final screenWidth = MediaQuery.of(overlayContext).size.width;
    final isMobile = screenWidth < 600;

    return Positioned(
      top: MediaQuery.of(overlayContext).padding.top + 12,
      right: isMobile ? 12 : 16,
      left: screenWidth < 380 ? 12 : null,
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isMobile ? screenWidth - 24 : 320,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFC8E6C9),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF2E7D32),
                size: 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF1B5E20),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  },
);


  overlay.insert(overlayEntry);

  Future.delayed(const Duration(seconds: 3), () {
    overlayEntry.remove();
    overlayEntry.dispose();
  });
}


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final isMobile = width < 600;
        final isTablet = width >= 600 && width < 1000;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Customers'),
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(
                isMobile
                    ? 14
                    : isTablet
                        ? 20
                        : 28,
              ),
              child: ValueListenableBuilder<List<Customer>>(
                valueListenable: CustomerStore.customers,
                builder: (context, customers, _) {
                  final filteredCustomers =
                      _filterCustomers(customers);

                  return Column(
                    children: [
                      _buildSearchAndAdd(
                        isMobile: isMobile,
                      ),

                      const SizedBox(height: 18),

                      Expanded(
                        child: filteredCustomers.isEmpty
                            ? _buildEmptyState(
                                hasCustomers:
                                    customers.isNotEmpty,
                                isMobile: isMobile,
                              )
                            : _buildCustomerList(
                                filteredCustomers,
                                isMobile: isMobile,
                                isTablet: isTablet,
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchAndAdd({
    required bool isMobile,
  }) {
    final searchField = TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchText = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Enter Here (Id/Name/PhoneNumber)',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchText.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchText = '';
                  });
                },
                icon: const Icon(Icons.close),
              )
            : null,
      ),
    );

    final addButton = SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _openAddCustomer,
        icon: const Icon(
          Icons.person_add_outlined,
          size: 19,
        ),
        label: const Text('Add Customer'),
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          searchField,
          const SizedBox(height: 12),
          addButton,
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: searchField,
        ),
        const SizedBox(width: 14),
        addButton,
      ],
    );
  }

 
Widget _buildCustomerList(
  List<Customer> customers, {
  required bool isMobile,
  required bool isTablet,
}) {

if (isMobile) {
  return GridView.builder(
    padding: const EdgeInsets.only(bottom: 20),
    gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.35,
    ),
    itemCount: customers.length,
    itemBuilder: (context, index) {
      return _buildCustomerCard(customers[index]);
    },
  );
}



return GridView.builder(
  padding: const EdgeInsets.only(bottom: 20),
  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: isTablet ? 320 : 280,
    crossAxisSpacing: 12,
    mainAxisSpacing: 10,
    childAspectRatio: 3.0,
  ),
  itemCount: customers.length,
  itemBuilder: (context, index) {
    return _buildCustomerCard(customers[index]);
  },
);

}



Widget _buildCustomerCard(Customer customer) {
  final phone = customer.phoneNumbers.isNotEmpty
      ? customer.phoneNumbers.first
      : 'No phone number';

  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CustomerDetailsScreen(
              customer: customer,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  customer.name.trim().isEmpty
                      ? '?'
                      : customer.name.trim()[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    customer.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 15,
                        color: AppColors.icon,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          phone,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 21,
            ),
          ],
        ),
      ),
    ),
  );
}


  Widget _customerInfoRow(
    IconData icon,
    String text,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 17,
          color: AppColors.icon,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  String _formatAddress(
    CustomerAddress address,
  ) {
    final parts = <String>[];

    if (address.houseFlatNumber
        .trim()
        .isNotEmpty) {
      parts.add(
        address.houseFlatNumber.trim(),
      );
    }

    if (address.street.trim().isNotEmpty) {
      parts.add(address.street.trim());
    }

    if (address.area.trim().isNotEmpty) {
      parts.add(address.area.trim());
    }

    if (address.pincode.trim().isNotEmpty) {
      parts.add(address.pincode.trim());
    }

    if (parts.isEmpty) {
      return 'Address not provided';
    }

    return parts.join(', ');
  }

  Widget _buildEmptyState({
    required bool hasCustomers,
    required bool isMobile,
  }) {
    final bool isSearchEmpty =
        hasCustomers && _searchText.isNotEmpty;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isMobile ? 72 : 84,
            height: isMobile ? 72 : 84,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSearchEmpty
                  ? Icons.search_off_outlined
                  : Icons.people_outline,
              size: isMobile ? 34 : 40,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            isSearchEmpty
                ? 'No Matching Customers'
                : 'No Customers Found',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            isSearchEmpty
                ? 'Try another name, ID or phone number.'
                : 'Add your first customer to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: isMobile ? 13 : 14,
            ),
          ),
        ],
      ),
    );
  }
}