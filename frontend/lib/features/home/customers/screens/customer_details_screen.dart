import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../models/customer_model.dart';
import '../services/customer_store.dart';
import 'add_customer_screen.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final Customer customer;

  const CustomerDetailsScreen({
    super.key,
    required this.customer,
  });

   @override
  State<CustomerDetailsScreen> createState() =>
      _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState
    extends State<CustomerDetailsScreen> {
  late Customer _customer;

  @override
  void initState() {
    super.initState();
    _customer = widget.customer;
  }

Future<void> _editCustomer() async {
  final result = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => AddCustomerScreen(
        customer: _customer,
      ),
    ),
  );

  if (!mounted) return;

  // Refresh customer details after returning.
  final updatedCustomer =
      CustomerStore.getCustomerById(_customer.id);

  if (updatedCustomer != null) {
    setState(() {
      _customer = updatedCustomer;
    });
  }

  // Show success only after a successful update.
  if (result == true) {
    _showSuccessToast('Customer updated successfully');
  }
}

void _showSuccessToast(String message) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (overlayContext) {
      return Positioned(
        top: MediaQuery.of(overlayContext).padding.top + 12,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
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
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF1B5E20),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
                centerTitle: false,
                titleSpacing: 0,
                title: Builder(
                  builder: (context) {
                    final width = MediaQuery.of(context).size.width;

                    return Text(
                      width < 420
                          ? 'Customer'
                          : 'Customer Details',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
                actions: [
                  IconButton(
                    onPressed: _editCustomer,
                    icon: const Icon(
                      Icons.edit_outlined,
                    ),
                    tooltip: 'Edit Customer',
                  ),
                ],
              ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(
                isMobile
                    ? 14
                    : isTablet
                        ? 20
                        : 28,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1100,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      _buildCustomerHeader(
                        isMobile: isMobile,
                      ),

                      const SizedBox(height: 18),

                      _buildCustomerInformation(),

                      const SizedBox(height: 18),

    

                      const SizedBox(height: 18),

                      _buildAddresses(
                        isMobile: isMobile,
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _editCustomer,
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 19,
                          ),
                          label: const Text('Edit Customer'),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _buildCustomerHeader({
    required bool isMobile,
  }) {
    final initial = _customer.name.trim().isEmpty
        ? '?'
        : _customer.name.trim()[0].toUpperCase();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        isMobile ? 18 : 22,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: isMobile ? 52 : 64,
            height: isMobile ? 52 : 64,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                initial,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: isMobile ? 22 : 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _customer.name,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Customer ID: ${_customer.id}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInformation() {
    return _sectionCard(
      title: 'Customer Information',
      icon: Icons.person_outline,
      child: Column(
        children: [
          _detailRow(
            icon: Icons.person_outline,
            label: 'Full Name',
            value: _customer.name,
          ),

          _detailRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: _customer.phoneNumbers.isEmpty
                ? 'Not provided'
                : _customer.phoneNumbers.join(', '),
          ),

          _detailRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: _customer.email.isEmpty
                ? 'Not provided'
                : _customer.email,
          ),
        ],
      ),
    );
  }

 

  Widget _buildAddresses({
    required bool isMobile,
  }) {
    return _sectionCard(
      title: 'Delivery Addresses',
      icon: Icons.location_on_outlined,
      child: _customer.addresses.isEmpty
          ? _emptyAddress()
          : Column(
              children: List.generate(
                _customer.addresses.length,
                (index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom:
                          index == _customer.addresses.length - 1
                              ? 0
                              : 12,
                    ),
                    child: _buildAddressCard(
                      _customer.addresses[index],
                      index,
                      isMobile,
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildAddressCard(
    CustomerAddress address,
    int index,
    bool isMobile,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
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
              Expanded(
                child: Text(
                  'Address ${index + 1}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

            ],
          ),

          const SizedBox(height: 14),

          _detailRow(
            icon: Icons.person_outline,
            label: 'Contact Name',
            value: _valueOrNotProvided(
              address.contactName,
            ),
          ),

          _detailRow(
            icon: Icons.phone_outlined,
            label: 'Contact Number',
            value: _valueOrNotProvided(
              address.contactNumber,
            ),
          ),

          _detailRow(
            icon: Icons.home_outlined,
            label: 'House / Flat No.',
            value: _valueOrNotProvided(
              address.houseFlatNumber,
            ),
          ),

          _detailRow(
            icon: Icons.signpost_outlined,
            label: 'Street',
            value: _valueOrNotProvided(
              address.street,
            ),
          ),

          _detailRow(
            icon: Icons.location_city_outlined,
            label: 'Area',
            value: _valueOrNotProvided(
              address.area,
            ),
          ),

          _detailRow(
            icon: Icons.place_outlined,
            label: 'Landmark',
            value: _valueOrNotProvided(
              address.landmark,
            ),
          ),

          _detailRow(
            icon: Icons.pin_drop_outlined,
            label: 'Pincode',
            value: _valueOrNotProvided(
              address.pincode,
            ),
          ),

          _detailRow(
            icon: Icons.link_outlined,
            label: 'Location Link',
            value: _valueOrNotProvided(
              address.locationLink,
            ),
          ),

          _detailRow(
            icon: Icons.calendar_month_outlined,
            label: 'Monthly Food Order',
            value: address.monthlyFoodOrder
                ? 'Yes'
                : 'No',
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
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
              Icon(
                icon,
                color: AppColors.primary,
                size: 21,
              ),

              const SizedBox(width: 8),

              Text(
                title,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          child,
        ],
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors.icon,
          ),

          const SizedBox(width: 9),

          SizedBox(
            width: 145,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyAddress() {
    return const Padding(
      padding: EdgeInsets.symmetric(
        vertical: 12,
      ),
      child: Text(
        'No delivery addresses found.',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
    );
  }

  String _valueOrNotProvided(String value) {
    return value.trim().isEmpty
        ? 'Not provided'
        : value.trim();
  }
}