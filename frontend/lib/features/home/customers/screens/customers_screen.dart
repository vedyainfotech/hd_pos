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

  void _openAddCustomer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddCustomerScreen(),
      ),
    );
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
      return ListView.separated(
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: customers.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildCustomerCard(
            customers[index],
          );
        },
      );
    }

    final columns = isTablet ? 2 : 3;

    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.8,
      ),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        return _buildCustomerCard(
          customers[index],
        );
      },
    );
  }

  Widget _buildCustomerCard(
    Customer customer,
  ) {
    final phone = customer.phoneNumbers.isNotEmpty
        ? customer.phoneNumbers.first
        : 'No phone number';

    final address = customer.addresses.isNotEmpty
        ? customer.addresses.first
        : null;

    final addressText = address == null
        ? 'No address'
        : _formatAddress(address);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        customer.name.isEmpty
                            ? '?'
                            : customer.name[0]
                                .toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      customer.name,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              _customerInfoRow(
                Icons.phone_outlined,
                phone,
              ),

              const SizedBox(height: 8),

              _customerInfoRow(
                Icons.location_on_outlined,
                addressText,
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