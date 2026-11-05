import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../models/customer_model.dart';
import '../services/customer_store.dart';
import '../services/customer_api_service.dart';
import 'customer_details_screen.dart';
import 'package:countrify/countrify.dart';
import '../services/location_service.dart';
import 'package:flutter/services.dart';

class AddCustomerScreen extends StatefulWidget {
  final Customer? customer;

  const AddCustomerScreen({super.key, this.customer});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final List<TextEditingController> _phoneControllers = [
    TextEditingController(),
  ];
  final List<_AddressFormData> _addresses = [];

  // Search and edit an existing customer from the same form.
  final TextEditingController _customerSearchController =
      TextEditingController();
  Customer? _editingCustomer;
  List<Customer> _matchingCustomers = [];
  bool _showCustomerResults = false;
  bool _isLoadingCustomers = false;
  String? _message;
  bool _messageIsError = false;
  bool _messageIsWarning = false;
  int _messageVersion = 0;

  static const double _addressInputHeight = 56;
static const double _addressLabelGap = 7;
static const double _addressFieldGap = 10;
static const double _addressErrorHeight = 18;

List<Country> _countries = [];



  @override
  void initState() {
    super.initState();
    _loadCountries();
    _loadCustomersFromApi();

    _editingCustomer = widget.customer;
    final customer = widget.customer;

    if (customer == null) {
      _addresses.add(_AddressFormData());
    } else {
      _nameController.text = customer.name;

      if (customer.phoneNumbers.isNotEmpty) {
        _phoneControllers.first.text = customer.phoneNumbers.first;

        for (int i = 1; i < customer.phoneNumbers.length; i++) {
          _phoneControllers.add(
            TextEditingController(text: customer.phoneNumbers[i]),
          );
        }
      }

      _emailController.text = customer.email;

      for (final address in customer.addresses) {
        final addressData = _AddressFormData.fromModel(address);
        // Keep the saved contact name independent from the customer name.
        // "Same as Customer Name" stays unchecked unless the user selects it.
        _addresses.add(addressData);
      }

      if (_addresses.isEmpty) {
        _addresses.add(_AddressFormData());
      }
    }

    _nameController.addListener(_syncCustomerNameToAddresses);

    for (final controller in _phoneControllers) {
      controller.addListener(_syncPhoneToAddresses);
    }
    
  }
  Future<void> _loadCustomersFromApi() async {
    if (mounted) {
      setState(() => _isLoadingCustomers = true);
    }

    try {
      final customers = await CustomerApiService.getCustomers();
      CustomerStore.customers.value = customers;

      if (!mounted) return;
      setState(() {
        _isLoadingCustomers = false;
        if (_customerSearchController.text.trim().isNotEmpty) {
          _filterCustomers(_customerSearchController.text);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingCustomers = false);
      _showMessage('Unable to load customers: $e');
    }
  }

  void _searchExistingCustomers(String value) {
    setState(() => _filterCustomers(value));
  }

  void _filterCustomers(String value) {
    final query = value.trim().toLowerCase();
    final normalizedQuery = query.replaceAll(RegExp(r'[^a-z0-9]'), '');
    final phoneQuery = query.replaceAll(RegExp(r'[^0-9]'), '');

    if (query.isEmpty) {
      _matchingCustomers = [];
      _showCustomerResults = false;
      return;
    }

    _matchingCustomers = CustomerStore.customers.value.where((customer) {
      final customerId = customer.id.trim().toLowerCase();
      final customerName = customer.name.trim().toLowerCase();
      final normalizedName = customerName.replaceAll(RegExp(r'[^a-z0-9]'), '');

      final idMatches = customerId.startsWith(query);
      final nameMatches = normalizedQuery.isNotEmpty &&
          normalizedName.contains(normalizedQuery);
      final phoneMatches = phoneQuery.isNotEmpty &&
          customer.phoneNumbers.any((phone) {
            final normalizedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
            return normalizedPhone.contains(phoneQuery);
          });

      return idMatches || nameMatches || phoneMatches;
    }).toList();
    _showCustomerResults = true;
  }

  Future<void> _openCustomerDetails(Customer customer) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerDetailsScreen(customer: customer),
      ),
    );

    if (!mounted) return;

    setState(() {
      _customerSearchController.clear();
      _matchingCustomers = [];
      _showCustomerResults = false;
    });
  }

  void _loadCountries() {
  setState(() {
    _countries = CountryUtils.getAllCountries();
  });
}









void _showDistrictPicker(_AddressFormData address) {
  final searchController = TextEditingController();
  List<String> filteredDistricts = List.from(address.districts);

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
                children: [
                  const Expanded(
                    child: Text('Select District'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                  ),
                ],
              ),
            content: SizedBox(
              width: 420,
              height: 420,
              child: Column(
                children: [
                  TextField(
                    controller: searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search district...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();

                                setDialogState(() {
                                  filteredDistricts =
                                      List.from(address.districts);
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      final query = value.trim().toLowerCase();

                      setDialogState(() {
                        filteredDistricts =
                            address.districts.where((district) {
                          return district
                              .toLowerCase()
                              .contains(query);
                        }).toList();
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: filteredDistricts.isEmpty
                        ? const Center(
                            child: Text('No districts found'),
                          )
                        : ListView.separated(
                            itemCount: filteredDistricts.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final district =
                                  filteredDistricts[index];

                              final isSelected =
                                  address.selectedDistrict ==
                                      district;

                              return ListTile(
                                dense: true,
                                title: Text(district),
                                trailing: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: AppColors.primary,
                                      )
                                    : null,
                                onTap: () {
                                  setState(() {
                                    address.selectedDistrict =
                                        district;

                                    // Area is manually entered, so keep its text
                                    // when the district selection changes.
                                    
                                
                                  });

                                  Navigator.pop(dialogContext);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  ).then((_) {
    searchController.dispose();
  });
}

void _showStatePicker(_AddressFormData address) {
  final searchController = TextEditingController();
  List<CountryState> filteredStates = List.from(address.states);

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                const Expanded(
                  child: Text('Select State'),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                ),
              ],
            ),
            content: SizedBox(
              width: 420,
              height: 420,
              child: Column(
                children: [
                  TextField(
                    controller: searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search state...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();

                                setDialogState(() {
                                  filteredStates =
                                      List.from(address.states);
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      final query = value.trim().toLowerCase();

                      setDialogState(() {
                        filteredStates = address.states.where((state) {
                          return state.name.toLowerCase().contains(query);
                        }).toList();
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: filteredStates.isEmpty
                        ? const Center(
                            child: Text('No states found'),
                          )
                        : ListView.separated(
                            itemCount: filteredStates.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final state = filteredStates[index];

                              final isSelected =
                                  address.selectedState == state.name;

                              return ListTile(
                                dense: true,
                                title: Text(state.name),
                                trailing: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: AppColors.primary,
                                      )
                                    : null,
                                onTap: () {
                                  setState(() {
                                    address.selectedState = state.name;
                                  });

                                  Navigator.pop(dialogContext);

                                  _loadDistrictsForAddress(
                                    address,
                                    state.name,
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  ).then((_) {
    searchController.dispose();
  });
}

void _showCountryPicker(_AddressFormData address) {
  final searchController = TextEditingController();
  List<Country> filteredCountries = List.from(_countries);

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
           title: Row(
                  children: [
                    const Expanded(
                      child: Text('Select Country'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                    ),
                  ],
                ),
             content: SizedBox(
              width: 420,
              height: 420,
              child: Column(
                children: [
                  TextField(
                    controller: searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search country...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();

                                setDialogState(() {
                                  filteredCountries = List.from(_countries);
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      final query = value.trim().toLowerCase();

                      setDialogState(() {
                        filteredCountries = _countries.where((country) {
                          return country.name.toLowerCase().contains(query);
                        }).toList();
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: filteredCountries.isEmpty
                        ? const Center(
                            child: Text('No countries found'),
                          )
                        : ListView.separated(
                            itemCount: filteredCountries.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final country = filteredCountries[index];

                              final isSelected =
                                  address.selectedCountry ==
                                      country.alpha2Code;

                              return ListTile(
                                dense: true,
                                title: Text(country.name),
                                trailing: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: AppColors.primary,
                                      )
                                    : null,
                                onTap: () {
                                  setState(() {
                                    address.selectedCountry =
                                        country.alpha2Code;
                                  });

                                  Navigator.pop(dialogContext);

                                  _loadStatesForAddress(
                                    address,
                                    country.alpha2Code,
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  ).then((_) {
    searchController.dispose();
  });
}

Future<void> _loadDistrictsForAddress(
  _AddressFormData address,
  String state,
) async {
  setState(() {
    address.loadingDistricts = true;
    address.districts = [];

    address.selectedDistrict = null;
  });

  try {
    // Convert state name into API slug.
    // Example:
    // Andhra Pradesh -> andhra-pradesh
    final stateSlug = state
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '-');

    final districts =
        await LocationApiService.getDistricts(stateSlug);

    if (!mounted) return;

    setState(() {
      address.districts = districts
          .map((district) => district.name)
          .toList();

      address.loadingDistricts = false;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      address.loadingDistricts = false;
      address.districts = [];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Failed to load districts: $e',
        ),
      ),
    );
  }
}

Future<void> _loadStatesForAddress(
  _AddressFormData address,
  String countryIso2,
) async {
  setState(() {
    address.loadingStates = true;
    address.states = [];
    address.selectedState = null;
    address.selectedDistrict = null;
  });

  final states = await GeoRepository.instance.statesOf(countryIso2);

  if (!mounted) return;

  setState(() {
    address.states = states;
    address.loadingStates = false;
  });
}

  @override
  void dispose() {
    _nameController.removeListener(_syncCustomerNameToAddresses);
    _nameController.dispose();

    _emailController.dispose();
    _customerSearchController.dispose();

    for (final controller in _phoneControllers) {
      controller.removeListener(_syncPhoneToAddresses);
      controller.dispose();
    }

    for (final address in _addresses) {
      address.dispose();
    }

    super.dispose();
  }

  void _addPhone() {
    final controller = TextEditingController();

    controller.addListener(_syncPhoneToAddresses);

    setState(() {
      _phoneControllers.add(controller);
    });
  }

  void _removePhone(int index) {
    if (_phoneControllers.length == 1) {
      return;
    }

    final controller = _phoneControllers.removeAt(index);
    controller.dispose();

    setState(() {});
  }

  void _syncCustomerNameToAddresses() {
    for (final address in _addresses) {
      if (address.sameAsCustomerName) {
        address.contactNameController.text = _nameController.text;
      }
    }
  }

  void _syncPhoneToAddresses() {
    final primaryPhone = _phoneControllers.isNotEmpty
        ? _phoneControllers.first.text
        : '';

    for (final address in _addresses) {
      if (address.sameAsPhoneNumber) {
        address.contactNumberController.text = primaryPhone;
      }
    }
  }

  void _addAddress() {
    final address = _AddressFormData();

    setState(() {
      _addresses.add(address);
    });
  }

  void _removeAddress(int index) {
    if (index <= 0 || index >= _addresses.length) return;

    final address = _addresses[index];

    // Remove address controllers from the touched-field set before disposal.
    _touchedControllers.removeAll({
      address.contactNameController,
      address.contactNumberController,
      address.houseNameController,
      address.houseController,
      address.streetController,
      address.areaController,
      address.landmarkController,
      address.pincodeController,
      address.locationController,
    });

    setState(() {
      _addresses.removeAt(index);
    });

    address.dispose();
  }

  void _editAddress(int index) {
    setState(() {
      _addresses[index].isSaved = false;
    });
  }


// ============================================================
// LIVE VALIDATION
// ============================================================

final Set<TextEditingController> _touchedControllers = {};

void _markTouched(TextEditingController controller) {
  if (!_touchedControllers.contains(controller)) {
    setState(() {
      _touchedControllers.add(controller);
    });
  }
}

String? _validateName(String value, {String fieldName = 'Name'}) {
  final text = value.trim();

  if (text.isEmpty) {
    return '$fieldName is required';
  }

  if (text.length < 2) {
    return '$fieldName must be at least 2 characters';
  }

  if (text.length > 50) {
    return '$fieldName cannot exceed 50 characters';
  }

  if (!RegExp(r"^[a-zA-Z\s.'-]+$").hasMatch(text)) {
    return '$fieldName can contain letters only';
  }

  return null;
}

String? _validateIndianPhone(String value) {
  final text = value.trim();

  if (text.isEmpty) {
    return 'Phone number is required';
  }

  // Remove spaces, hyphens and brackets for validation.
  final normalized = text.replaceAll(
    RegExp(r'[\s\-()]'),
    '',
  );

  // Indian mobile number: 10 digits starting with 6-9
  if (RegExp(r'^[6-9]\d{9}$').hasMatch(normalized)) {
    return null;
  }

  // Indian landline with STD code
  // Examples:
  // 0891 2567890
  // 040 23456789
  // 011 23456789
  // 08912567890
  // 04023456789
  if (RegExp(r'^(?:0\d{2,4})\d{6,8}$').hasMatch(normalized)) {
    return null;
  }

  return 'Enter a valid Indian mobile or landline number';
}

String? _validateEmail(String value) {
  final text = value.trim();

  // Email is optional
  if (text.isEmpty) {
    return null;
  }

  if (!RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@'
    r'[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
    r'(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$',
  ).hasMatch(text)) {
    return 'Enter a valid email address';
  }

  return null;
}

String? _validatePincode(String value) {
  final text = value.trim();

  if (text.isEmpty) {
    return 'Pincode is required';
  }

  if (!RegExp(r'^[1-9][0-9]{5}$').hasMatch(text)) {
    return 'Enter a valid 6-digit Indian pincode';
  }

  return null;
}

String? _validateUrl(String value) {
  final text = value.trim();

  // Location link is optional
  if (text.isEmpty) {
    return null;
  }

  final uri = Uri.tryParse(text);

  if (uri == null ||
      !uri.hasScheme ||
      !['http', 'https'].contains(uri.scheme.toLowerCase()) ||
      uri.host.isEmpty) {
    return 'Enter a valid location link';
  }

  return null;
}

String? _validateRequired(
  String value, {
  required String fieldName,
}) {
  if (value.trim().isEmpty) {
    return '$fieldName is required';
  }

  return null;
}

 
Future<void> _registerCustomer() async {
  // Ask for confirmation only when updating an existing customer.
  if (_editingCustomer != null) {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Update'),
        content: const Text(
          'Are you sure you want to update this customer?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;
  }

  final name = _nameController.text.trim();

  final phones = _phoneControllers
      .map((controller) => controller.text.trim())
      .where((phone) => phone.isNotEmpty)
      .toList();

  final nameError = _validateName(name, fieldName: 'Customer name');
  if (nameError != null) {
    _showMessage(nameError);
    return;
  }

  if (phones.isEmpty) {
    _showMessage('At least one phone number is required.');
    return;
  }

  for (var i = 0; i < phones.length; i++) {
    final phoneError = _validateIndianPhone(phones[i]);
    if (phoneError != null) {
      _showMessage('Phone ${i + 1}: $phoneError');
      return;
    }
  }

  final emailError = _validateEmail(_emailController.text);
  if (emailError != null) {
    _showMessage(emailError);
    return;
  }

  if (_addresses.isEmpty) {
    _showMessage('Please add at least one delivery address.');
    return;
  }

  // Validate every address before opening the preview or sending the API
  // request. The preview's Save Address button is a confirmation step only.
  for (var i = 0; i < _addresses.length; i++) {
    final address = _addresses[i];
    final label = 'Address ${i + 1}: ';
    final requiredChecks = <MapEntry<String, String>>[
      MapEntry('Delivery contact name', address.contactNameController.text),
      MapEntry('Delivery contact number', address.contactNumberController.text),
      MapEntry('House / Flat No.', address.houseController.text),
      MapEntry('Street', address.streetController.text),
      MapEntry('Pincode', address.pincodeController.text),
    ];
    for (final check in requiredChecks) {
      if (check.value.trim().isEmpty) {
        _showMessage('$label${check.key} is required.');
        return;
      }
    }

    final contactPhoneError = _validateIndianPhone(address.contactNumberController.text);
    if (contactPhoneError != null) {
      _showMessage('$label$contactPhoneError');
      return;
    }

    final pincodeError = _validatePincode(address.pincodeController.text);
    if (pincodeError != null) {
      _showMessage('$label$pincodeError');
      return;
    }

    if ((address.selectedCountry ?? '').trim().isEmpty) {
      _showMessage('${label}Please select a country.');
      return;
    }

    if ((address.selectedState ?? '').trim().isEmpty) {
      _showMessage('${label}Please select a state.');
      return;
    }

    if ((address.selectedDistrict ?? '').trim().isEmpty) {
      _showMessage('${label}Please select a district.');
      return;
    }

    if (address.areaController.text.trim().isEmpty) {
      _showMessage('${label}Please enter the area.');
      return;
    }

    final locationError = _validateUrl(address.locationController.text);
    if (locationError != null) {
      _showMessage('$label$locationError');
      return;
    }
  }

  // Open the address preview before saving the customer.
  // The customer is saved only after the user confirms all addresses.
  final firstUnsavedIndex = _addresses.indexWhere(
    (address) => !address.isSaved,
  );

  if (firstUnsavedIndex != -1) {
    _showAddressPreview(firstUnsavedIndex);
    return;
  }

  // All addresses have already been reviewed.
  await _saveCustomer();
}


Future<void> _saveCustomer() async {
  final name = _nameController.text.trim();

  final phones = _phoneControllers
      .map((controller) => controller.text.trim())
      .where((phone) => phone.isNotEmpty)
      .toList();

  final isEditing = _editingCustomer != null;

  final customer = Customer(
    id: _editingCustomer?.id ?? '',
    customerCode: _editingCustomer?.customerCode ?? '',
    name: name,
    phoneNumbers: phones,
    email: _emailController.text.trim(),
    addresses: _addresses.asMap().entries.map((entry) {
      final index = entry.key;
      final address = entry.value;

      // Generate once and retain the ID/code on this address form.
      final addressId = address.id ??
          '${DateTime.now().microsecondsSinceEpoch}-$index';
      final addressCode = address.addressCode ?? 'ADDR-$addressId';

      address.id = addressId;
      address.addressCode = addressCode;

      return CustomerAddress(
        id: addressId,
        addressCode: addressCode,
        contactName: address.contactNameController.text.trim(),
        contactNumber: address.contactNumberController.text.trim(),
        houseName: address.houseNameController.text.trim(),
        houseFlatNumber: address.houseController.text.trim(),
        addressType: address.addressType,
        country: address.selectedCountry ?? '',
        state: address.selectedState ?? '',
        district: address.selectedDistrict ?? '',
        street: address.streetController.text.trim(),
        area: address.areaController.text.trim(),
        landmark: address.landmarkController.text.trim(),
        pincode: address.pincodeController.text.trim(),
        locationLink: address.locationController.text.trim(),
        monthlyFoodOrder: address.monthlyFoodOrder,
      );
    }).toList(),
  );

  try {
    final Customer savedCustomer = isEditing
        ? await CustomerApiService.updateCustomer(customer)
        : await CustomerApiService.createCustomer(customer);

    final customers = List<Customer>.from(CustomerStore.customers.value);
    final existingIndex = customers.indexWhere(
      (item) => item.id == savedCustomer.id,
    );
    if (existingIndex >= 0) {
      customers[existingIndex] = savedCustomer;
    } else {
      customers.add(savedCustomer);
    }
    CustomerStore.customers.value = customers;

    if (!mounted) return;

    if (isEditing) {
      _editingCustomer = savedCustomer;
      _showMessage('Customer updated successfully!');
      Navigator.pop(context, savedCustomer);
      return;
    }

    _resetForNextCustomer(savedCustomer);
    _showMessage('Customer added successfully!');
  } catch (e) {
    if (!mounted) return;
    _showMessage('Failed to ${isEditing ? 'update' : 'save'} customer: $e');
  }
}

void _resetForNextCustomer(Customer savedCustomer) {
  // Dispose the previous address controllers before creating a fresh form.
  for (final address in _addresses) {
    address.dispose();
  }

  _addresses
    ..clear()
    ..add(_AddressFormData());

  // Keep one empty phone field for the next customer.
  for (final controller in _phoneControllers) {
    controller.removeListener(_syncPhoneToAddresses);
    controller.dispose();
  }

  _phoneControllers
    ..clear()
    ..add(TextEditingController());

  _phoneControllers.first.addListener(_syncPhoneToAddresses);

  _nameController.clear();
  _emailController.clear();
  _touchedControllers.clear();

  // Show the newly registered customer as a result on this same page.
 // Clear search after successful customer registration.
_customerSearchController.clear();
_matchingCustomers = [];
_showCustomerResults = false;
_editingCustomer = null;

  if (mounted) {
    setState(() {});
  }
}

  void _showMessage(String message) {
    if (!mounted) return;

    final lowerMessage = message.toLowerCase();

    final isSuccess = lowerMessage.contains('successfully');
    final isWarning = lowerMessage.contains('already exists') ||
        lowerMessage.contains('duplicate');

    final version = ++_messageVersion;

    setState(() {
      _message = message;
      _messageIsError = !isSuccess && !isWarning;
      _messageIsWarning = isWarning;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted || version != _messageVersion) return;

      setState(() {
        _message = null;
      });
    });
  }

  Widget _buildTopRightMessage() {
    final message = _message;

    if (message == null) {
      return const SizedBox.shrink();
    }

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

    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      right: 16,
      left: screenWidth < 600 ? 16 : null,
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.topRight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: screenWidth < 600 ? 340 : 320,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
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
                    size: 22,
                    color: iconColor,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      message,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: iconColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

    Widget _buildPreviewHeader({
    required String title,
    required _AddressFormData address,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 18, 18),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Review delivery address details',
                  style: TextStyle(
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

  Widget _buildAddressPreviewContent(
    _AddressFormData address, {
    required bool isMobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _previewSectionTitle(
          icon: Icons.person_outline,
          title: 'Contact Details',
        ),

        const SizedBox(height: 12),

        if (isMobile)
          Column(
            children: [
              _previewInfoCard(
                icon: Icons.person_outline,
                label: 'Contact Name',
                value: address.contactNameController.text,
              ),
              const SizedBox(height: 10),
              _previewInfoCard(
                icon: Icons.phone_outlined,
                label: 'Contact Number',
                value: address.contactNumberController.text,
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: _previewInfoCard(
                  icon: Icons.person_outline,
                  label: 'Contact Name',
                  value: address.contactNameController.text,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _previewInfoCard(
                  icon: Icons.phone_outlined,
                  label: 'Contact Number',
                  value: address.contactNumberController.text,
                ),
              ),
            ],
          ),

        const SizedBox(height: 22),

        _previewSectionTitle(
          icon: Icons.home_outlined,
          title: 'Address Details',
        ),

        const SizedBox(height: 12),

        if (isMobile)
          Column(
            children: [
              _previewInfoCard(
                icon: Icons.home_work_outlined,
                label: 'Address Type',
                value: address.addressType,
              ),
              const SizedBox(height: 10),
              _previewInfoCard(
                icon: Icons.badge_outlined,
                label: address.addressType == 'Office'
                    ? 'Office Name'
                    : address.addressType == 'Other'
                        ? 'Address Name'
                        : 'Home Name',
                value: address.houseNameController.text,
              ),
              const SizedBox(height: 10),
              _previewInfoCard(
                icon: Icons.home_outlined,
                label: 'House / Flat No.',
                value: address.houseController.text,
              ),
              const SizedBox(height: 10),
              _previewInfoCard(
                icon: Icons.signpost_outlined,
                label: 'Street',
                value: address.streetController.text,
              ),
              const SizedBox(height: 10),
              _previewInfoCard(
                icon: Icons.location_city_outlined,
                label: 'Area',
                value: address.areaController.text,
              ),
              const SizedBox(height: 10),
              _previewInfoCard(
                icon: Icons.place_outlined,
                label: 'Landmark',
                value: address.landmarkController.text,
              ),
              const SizedBox(height: 10),
              _previewInfoCard(
                icon: Icons.pin_drop_outlined,
                label: 'Pincode',
                value: address.pincodeController.text,
              ),
              const SizedBox(height: 10),
              _previewInfoCard(
                icon: Icons.link_outlined,
                label: 'Location Link',
                value: address.locationController.text,
              ),
            ],
          )
        else
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _previewInfoCard(
                      icon: Icons.home_work_outlined,
                      label: 'Address Type',
                      value: address.addressType,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _previewInfoCard(
                      icon: address.addressType == 'Office'
                          ? Icons.business_outlined
                          : Icons.badge_outlined,
                      label: address.addressType == 'Office'
                          ? 'Office Name'
                          : address.addressType == 'Other'
                              ? 'Address Name'
                              : 'Home Name',
                      value: address.houseNameController.text,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _previewInfoCard(
                      icon: Icons.home_outlined,
                      label: 'House / Flat No.',
                      value: address.houseController.text,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _previewInfoCard(
                      icon: Icons.signpost_outlined,
                      label: 'Street',
                      value: address.streetController.text,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _previewInfoCard(
                      icon: Icons.location_city_outlined,
                      label: 'Area',
                      value: address.areaController.text,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _previewInfoCard(
                      icon: Icons.place_outlined,
                      label: 'Landmark',
                      value: address.landmarkController.text,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _previewInfoCard(
                      icon: Icons.pin_drop_outlined,
                      label: 'Pincode',
                      value: address.pincodeController.text,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _previewInfoCard(
                      icon: Icons.link_outlined,
                      label: 'Location Link',
                      value: address.locationController.text,
                    ),
                  ),
                ],
              ),
            ],
          ),

        const SizedBox(height: 22),

        _previewSectionTitle(
          icon: Icons.restaurant_outlined,
          title: 'Order Preference',
        ),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_month_outlined,
                size: 19,
                color: AppColors.icon,
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Text(
                  'Monthly Food Order',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Text(
                address.monthlyFoodOrder ? 'Yes' : 'No',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _previewSectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 17),
        ),

        const SizedBox(width: 9),

        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _previewInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final displayValue = value.trim().isEmpty ? 'Not provided' : value.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  displayValue,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final isMobile = width < 600;
        final isTablet = width >= 600 && width < 1000;

        return Stack(
          children: [
            Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                title: Text(
                  _editingCustomer == null ? 'Add Customer' : 'Edit Customer',
                ),
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
                  child: _buildResponsiveContent(
                    isMobile: isMobile,
                    isTablet: isTablet,
                  ),
                ),
              ),
            ),
            if (_message != null) _buildTopRightMessage(),
          ],
        );
      },
    );
  }

  Widget _buildResponsiveContent({
    required bool isMobile,
    required bool isTablet,
  }) {
    // Stack the panels on mobile and tablet; keep desktop side-by-side.
    if (isMobile || isTablet) {
      return _buildMobileLayout();
    }

    return _buildLargeLayout(isTablet: false);
  }

  // ============================================================
  // MOBILE
  // ============================================================

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Both panels move together inside this single scroll area.
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCustomerInfoSection(isMobile: true),
                const SizedBox(height: 16),
                _buildAddressSection(isMobile: true),
              ],
            ),
          ),
        ),

        // Fixed footer: these buttons stay visible while the panels scroll.
        const SizedBox(height: 12),
        _buildBottomButtons(isMobile: true),
      ],
    );
  }
  // ============================================================
  // TABLET / DESKTOP
  // ============================================================

  Widget _buildLargeLayout({required bool isTablet}) {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: isTablet ? 5 : 4,
                child: _buildCustomerInfoSection(isMobile: false),
              ),

              const SizedBox(width: 16),

              Expanded(
                flex: isTablet ? 6 : 5,
                child: _buildAddressSection(isMobile: false),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        _buildBottomButtons(isMobile: false),
      ],
    );
  }

  // ============================================================
  // CUSTOMER INFO
  // ============================================================

Widget _buildCustomerInfoSection({required bool isMobile}) {
  final customerInfoContent = Padding(
    padding: const EdgeInsets.all(18),
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon: Icons.person_outline,
            title: 'Customer Info',
          ),

          const SizedBox(height: 16),

          
          TextField(
            controller: _customerSearchController,
            onChanged: _searchExistingCustomers,
            decoration: InputDecoration(
              hintText: 'Search by name, phone number or customer ID',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _customerSearchController.text.isNotEmpty
                  ? IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _customerSearchController.clear();
                        setState(() {
                          _matchingCustomers = [];
                          _showCustomerResults = false;
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
          ),
          if (_showCustomerResults) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 0.85,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 220),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _isLoadingCustomers && _matchingCustomers.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : _matchingCustomers.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: Text('No matching customers found.'),
                        )
                      : ListView.separated(
                      shrinkWrap: true,
                      itemCount: _matchingCustomers.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final customer = _matchingCustomers[index];
                        final phoneNumbers = customer.phoneNumbers
                            .map((phone) => phone.trim())
                            .where((phone) => phone.isNotEmpty)
                            .toSet()
                            .toList();

                        return InkWell(
                          onTap: () => _openCustomerDetails(customer),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const CircleAvatar(
                                  radius: 20,
                                  child: Icon(
                                    Icons.person_outline,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        customer.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          height: 1.05,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        phoneNumbers.isEmpty
                                            ? 'No phone number'
                                            : phoneNumbers.join(', '),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          height: 1.05,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'ID: ${customer.id}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          height: 1.1,
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          _fieldLabel('Full Name'),
          const SizedBox(height: 7),

          _buildFixedValidationField(
            controller: _nameController,
            hintText: 'Enter full name',
            keyboardType: TextInputType.name,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r"[a-zA-Z\s.'-]"),
              ),
            ],
            validator: () => _validateName(
              _nameController.text,
              fieldName: 'Customer name',
            ),
          ),

          const SizedBox(height: 18),

          _fieldLabel('Phone Numbers'),
          const SizedBox(height: 7),

          Column(
            children: [
              ..._phoneControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controller = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildFixedValidationField(
                          controller: controller,
                          hintText: index == 0
                              ? 'Primary phone number'
                              : 'Additional phone number',
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9\s()+-]'),
                            ),
                          ],
                          validator: () =>
                              _validateIndianPhone(controller.text),
                        ),
                      ),

                      if (_phoneControllers.length > 1) ...[
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: SizedBox(
                            width: 46,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () => _removePhone(index),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),

              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _addPhone,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Phone'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _fieldLabel('Email'),
          const SizedBox(height: 7),

          _buildFixedValidationField(
            controller: _emailController,
            hintText: 'Optional email',
            keyboardType: TextInputType.emailAddress,
            validator: () => _validateEmail(_emailController.text),
          ),

          const SizedBox(height: 28),
        ],
      ),
    );

  return _sectionContainer(
    child: isMobile
        ? customerInfoContent
        : SingleChildScrollView(child: customerInfoContent),
  );
}


Widget _buildFixedValidationField({
  required TextEditingController controller,
  required String hintText,
  required String? Function() validator,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
}) {
  final isTouched = _touchedControllers.contains(controller);
  final error = isTouched ? validator() : null;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        height: 56,
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: (_) {
            _markTouched(controller);
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: hintText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            constraints: const BoxConstraints(
              minHeight: 56,
              maxHeight: 56,
            ),
          ),
        ),
      ),

      // Fixed space for the validation message.
      SizedBox(
        height: 22,
        child: error == null
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.only(
                  left: 12,
                  top: 2,
                ),
                child: Text(
                  error,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
      ),
    ],
  );
}



  // ============================================================
  // ADDRESS SECTION
  // ============================================================

  Widget _buildAddressSection({required bool isMobile}) {
    return _sectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 700;

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(
                        icon: Icons.location_on_outlined,
                        title: 'Delivery Address',
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: ElevatedButton.icon(
                          onPressed: _addAddress,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Address'),
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: _sectionTitle(
                        icon: Icons.location_on_outlined,
                        title: 'Delivery Address',
                      ),
                    ),

                    const SizedBox(width: 12),

                    SizedBox(
                      height: 42,
                      child: ElevatedButton.icon(
                        onPressed: _addAddress,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Address'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const Divider(),

          if (isMobile)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
              child: Column(
                children: [
                  for (int index = 0; index < _addresses.length; index++) ...[
                    if (index > 0) const SizedBox(height: 12),
                    _buildAddressCard(index: index),
                  ],
                ],
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
                itemCount: _addresses.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildAddressCard(index: index);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddressCard({required int index}) {
    final address = _addresses[index];

    if (address.isSaved) {
      return _buildSavedAddressCard(index: index, address: address);
    }

    return _buildEditableAddressCard(index: index, address: address);
  }

  Widget _buildEditableAddressCard({
    required int index,
    required _AddressFormData address,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              if (index > 0)
                IconButton(
                  onPressed: () => _removeAddress(index),
                  tooltip: 'Remove address',
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(
                    minWidth: 30,
                    minHeight: 30,
                  ),
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 19,
                    color: AppColors.textPrimary,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          _addressField(
            label: 'Delivery Contact Name',
            controller: address.contactNameController,
            suffix: Row(
              children: [
                Checkbox(
                  value: address.sameAsCustomerName,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (value) {
                    setState(() {
                      address.sameAsCustomerName = value ?? false;

                      if (address.sameAsCustomerName) {
                        address.contactNameController.text =
                            _nameController.text;
                      }
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    'Same as Customer Name',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

         
_addressField(
  label: 'Delivery Contact Number',
  controller: address.contactNumberController,
  keyboardType: TextInputType.phone,
  validator: _validateIndianPhone,
  inputFormatters: [
    FilteringTextInputFormatter.allow(
      RegExp(r'[0-9\s()+-]'),
    ),
  ],
  suffix: Row(
    children: [
      Checkbox(
        value: address.sameAsPhoneNumber,
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onChanged: (value) {
          setState(() {
            address.sameAsPhoneNumber = value ?? false;

            if (address.sameAsPhoneNumber) {
              final primaryPhone = _phoneControllers.isNotEmpty
                  ? _phoneControllers.first.text
                  : '';

              address.contactNumberController.text = primaryPhone;
            }

            _markTouched(address.contactNumberController);
          });
        },
      ),
      Expanded(
        child: Text(
          'Same as Phone Number',
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    ],
  ),
),

          const SizedBox(height: 12),

       
DropdownButtonFormField<String>(
  initialValue: address.addressType,
  isExpanded: true,
  decoration: const InputDecoration(
    labelText: 'Address Type',
    prefixIcon: Icon(Icons.home_work_outlined),
    constraints: BoxConstraints(
      minHeight: _addressInputHeight,
      maxHeight: _addressInputHeight,
    ),
    contentPadding: EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 12,
    ),
  ),
  items: const [
    DropdownMenuItem(value: 'Home', child: Text('Home')),
    DropdownMenuItem(value: 'Office', child: Text('Office')),
    DropdownMenuItem(value: 'Other', child: Text('Other')),
  ],
  onChanged: (value) {
    setState(() {
      address.addressType = value ?? 'Home';
    });
  },
),

const SizedBox(height: _addressFieldGap),

_simpleAddressField(
  label: address.addressType == 'Office'
      ? 'Office Name'
      : address.addressType == 'Other'
          ? 'Address Name'
          : 'House Name',
  controller: address.houseNameController,
),

const SizedBox(height: _addressFieldGap),

_simpleAddressField(
  label: 'House / Flat No.',
  controller: address.houseController,
  validator: (value) => _validateRequired(
    value,
    fieldName: 'House / Flat No.',
  ),
),


const SizedBox(height: _addressFieldGap ),

_simpleAddressField(
  label: 'Street',
  controller: address.streetController,
  validator: (value) => _validateRequired(
    value,
    fieldName: 'Street',
  ),
),

const SizedBox(height: _addressFieldGap),

_simpleAddressField(
  label: 'Area',
  controller: address.areaController,
  validator: (value) => _validateRequired(
    value,
    fieldName: 'Area',
  ),
),

         const SizedBox(height: _addressFieldGap),

          _simpleAddressField(
            label: 'Landmark',
            controller: address.landmarkController,
          ),

         const SizedBox(height: _addressFieldGap),

          _simpleAddressField(
  label: 'Pincode',
  controller: address.pincodeController,
  keyboardType: TextInputType.number,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
  ],
  maxLength: 6,
  validator: _validatePincode,
),

         const SizedBox(height: _addressFieldGap),
_simpleAddressField(
  label: 'Location Link',
  controller: address.locationController,
  keyboardType: TextInputType.url,
  validator: _validateUrl,
),
const SizedBox(height: _addressFieldGap),

 InkWell(
  onTap: () {
    _showCountryPicker(address);
  },
  borderRadius: BorderRadius.circular(12),
  child: InputDecorator(
  
decoration: const InputDecoration(
  labelText: 'Country',
  prefixIcon: Icon(Icons.public_outlined),
  suffixIcon: Icon(Icons.keyboard_arrow_down),

  constraints: BoxConstraints(
    minHeight: 56,
    maxHeight: 56,
  ),

  contentPadding: EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 12,
  ),
),

    child: Text(
      address.selectedCountry == null ||
              address.selectedCountry!.isEmpty
          ? 'Select country'
          : _countries
              .firstWhere(
                (country) =>
                    country.alpha2Code == address.selectedCountry,
                orElse: () => _countries.first,
              )
              .name,
      style: TextStyle(
        color: address.selectedCountry == null ||
                address.selectedCountry!.isEmpty
            ? AppColors.textSecondary
            : AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),
),

const SizedBox(height: _addressFieldGap),

InkWell(
  onTap: address.loadingStates || address.states.isEmpty
      ? null
      : () {
          _showStatePicker(address);
        },
  borderRadius: BorderRadius.circular(12),

child: InputDecorator(
  decoration: InputDecoration(
    labelText: 'State',
    prefixIcon: const Icon(Icons.map_outlined),

    suffixIcon: address.loadingStates
        ? const SizedBox(
            width: 20,
            height: 20,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          )
        : const Icon(Icons.keyboard_arrow_down),

    // Keep these properties inside InputDecoration.
    constraints: const BoxConstraints(
      minHeight: 56,
      maxHeight: 56,
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 12,
    ),
  ),
  child: Text(
    address.selectedState == null ||
            address.selectedState!.isEmpty
        ? 'Select state'
        : address.selectedState!,
    style: TextStyle(
      color: address.selectedState == null ||
              address.selectedState!.isEmpty
          ? AppColors.textSecondary
          : AppColors.textPrimary,
      fontSize: 15,
      fontWeight: FontWeight.w500,
    ),
  ),
),

),
        const SizedBox(height: 14),
InkWell(
  onTap: address.loadingDistricts ||
          address.districts.isEmpty
      ? null
      : () {
          _showDistrictPicker(address);
        },
  borderRadius: BorderRadius.circular(12),
  child: InputDecorator(
    decoration: InputDecoration(
      labelText: 'District',
      prefixIcon: const Icon(
        Icons.location_city_outlined,
      ),
      suffixIcon: address.loadingDistricts
          ? const SizedBox(
              width: 20,
              height: 20,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            )
          : const Icon(
              Icons.keyboard_arrow_down,
            ),
    ),
    child: Text(
      address.selectedDistrict == null ||
              address.selectedDistrict!.isEmpty
          ? 'Select district'
          : address.selectedDistrict!,
      style: TextStyle(
        color: address.selectedDistrict == null ||
                address.selectedDistrict!.isEmpty
            ? AppColors.textSecondary
            : AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),
),
         const SizedBox(height: _addressFieldGap),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Checkbox(
                  value: address.monthlyFoodOrder,
                  onChanged: (value) {
                    setState(() {
                      address.monthlyFoodOrder = value ?? false;
                    });
                  },
                  visualDensity: VisualDensity.compact,
                ),

                const SizedBox(width: 4),

                const Expanded(
                  child: Text(
                    'Monthly Food Order',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedAddressCard({
    required int index,
    required _AddressFormData address,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              if (index > 0)
                IconButton(
                  onPressed: () => _removeAddress(index),
                  tooltip: 'Remove address',
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(
                    minWidth: 30,
                    minHeight: 30,
                  ),
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 19,
                    color: AppColors.textPrimary,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          _savedAddressRow(
            icon: Icons.person_outline,
            label: 'Contact',
            value: address.contactNameController.text,
          ),

          _savedAddressRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: address.contactNumberController.text,
          ),

          _savedAddressRow(
            icon: Icons.home_work_outlined,
            label: 'Address Type',
            value: address.addressType,
          ),

          if (address.houseNameController.text.trim().isNotEmpty)
            _savedAddressRow(
              icon: Icons.badge_outlined,
              label: address.addressType == 'Office'
                  ? 'Office Name'
                  : address.addressType == 'Other'
                      ? 'Address Name'
                      : 'Home Name',
              value: address.houseNameController.text,
            ),

          _savedAddressRow(
            icon: Icons.location_on_outlined,
            label: 'Address',
            value: _formattedAddress(address),
          ),

          if (address.landmarkController.text.trim().isNotEmpty)
            _savedAddressRow(
              icon: Icons.place_outlined,
              label: 'Landmark',
              value: address.landmarkController.text,
            ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _editAddress(index);
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit Address'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showAddressPreview(index);
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('Preview'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formattedAddress(_AddressFormData address) {
    final parts = <String>[];

    if (address.houseController.text.trim().isNotEmpty) {
      parts.add(address.houseController.text.trim());
    }

    if (address.streetController.text.trim().isNotEmpty) {
      parts.add(address.streetController.text.trim());
    }

    if (address.areaController.text.trim().isNotEmpty) {
      parts.add(address.areaController.text.trim());
    }

    if (address.pincodeController.text.trim().isNotEmpty) {
      parts.add(address.pincodeController.text.trim());
    }

    return parts.isEmpty ? 'Address not provided' : parts.join(', ');
  }

  Widget _savedAddressRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.icon),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value.trim().isEmpty ? 'Not provided' : value.trim(),
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

void _showAddressPreview(int index) {
  if (_addresses.isEmpty) return;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      final screenWidth = MediaQuery.of(dialogContext).size.width;
      final screenHeight = MediaQuery.of(dialogContext).size.height;
      final isMobile = screenWidth < 700;

      return Dialog(
        backgroundColor: AppColors.surface,
        insetPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 40,
          vertical: 24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 850,
            maxHeight: screenHeight * 0.88,
          ),
          child: Column(
            children: [
              _buildPreviewHeader(
                title: 'Delivery Addresses Preview',
                address: _addresses.first,
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  itemCount: _addresses.length,
                  separatorBuilder: (context, addressIndex) =>
                      const SizedBox(height: 20),
                  itemBuilder: (context, addressIndex) {
                    final address = _addresses[addressIndex];

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Address ${addressIndex + 1}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildAddressPreviewContent(
                            address,
                            isMobile: isMobile,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: EdgeInsets.all(isMobile ? 14 : 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      child: const Text('Back'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () async {
                        setState(() {
                          for (final address in _addresses) {
                            address.isSaved = true;
                          }
                        });

                        Navigator.pop(dialogContext);
                        await _saveCustomer();
                      },
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Confirm & Save All'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

  // ============================================================
  // ADDRESS FIELD
  // ============================================================
  Widget _addressField({
  required String label,
  required TextEditingController controller,
  TextInputType? keyboardType,
  Widget? suffix,
  String? Function(String)? validator,
  List<TextInputFormatter>? inputFormatters,
}) {
   return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    _fieldLabel(label),
    const SizedBox(height: 7),

    LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;

        Widget buildInput() {
          return SizedBox(
            height: 56,
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              onChanged: (_) {
                _markTouched(controller);
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Enter $label',
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
              ),
            ),
          );
        }

        Widget buildError() {
          final error = _touchedControllers.contains(controller)
              ? validator?.call(controller.text)
              : null;

          return SizedBox(
            height: 22,
            child: error == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(left: 12, top: 3),
                    child: Text(
                      error,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
          );
        }

        if (suffix == null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildInput(),
              buildError(),
            ],
          );
        }

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildInput(),
              buildError(),
              const SizedBox(height: 4),
              suffix,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: buildInput()),
                const SizedBox(width: 10),
                SizedBox(width: 245, child: suffix),
              ],
            ),
            buildError(),
          ],
        );
      },
    ),
  ],
);
  }

 

Widget _simpleAddressField({
  required String label,
  required TextEditingController controller,
  TextInputType? keyboardType,
  String? Function(String)? validator,
  List<TextInputFormatter>? inputFormatters,
  int? maxLength,
}) {
  final error = _touchedControllers.contains(controller)
      ? validator?.call(controller.text)
      : null;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _fieldLabel(label),
      const SizedBox(height: _addressLabelGap),

      SizedBox(
        height: _addressInputHeight,
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          onChanged: (_) {
            _markTouched(controller);
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: 'Enter $label',
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            constraints: const BoxConstraints(
              minHeight: _addressInputHeight,
              maxHeight: _addressInputHeight,
            ),
          ),
        ),
      ),

      if (validator != null)
        SizedBox(
          height: _addressErrorHeight,
          child: error == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(
                    left: 12,
                    top: 2,
                  ),
                  child: Text(
                    error,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 11,
                    ),
                  ),
                ),
        ),
    ],
  );
}




  // ============================================================
  // BOTTOM BUTTONS
  // ============================================================

  Widget _buildBottomButtons({required bool isMobile}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),

        const SizedBox(width: 12),

        ElevatedButton(
          onPressed: _registerCustomer,
          child: Text(_editingCustomer == null ? 'Register' : 'Update Customer'),
        ),
      ],
    );
  }

  // ============================================================
  // COMMON UI
  // ============================================================

  Widget _sectionContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  Widget _sectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 21),

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
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _AddressFormData {
  String? id;
  String? addressCode;

  _AddressFormData();

  _AddressFormData.fromModel(CustomerAddress address) {
    id = address.id;
    addressCode = address.addressCode;

    contactNameController.text = address.contactName;
    contactNumberController.text = address.contactNumber;

    houseNameController.text = address.houseName;
    houseController.text = address.houseFlatNumber;

    addressType = address.addressType;

    selectedCountry = address.country;
    selectedState = address.state;
    selectedDistrict = address.district;
    selectedArea = address.area;

    areaController.text = address.area;
    streetController.text = address.street;
    landmarkController.text = address.landmark;
    pincodeController.text = address.pincode;
    locationController.text = address.locationLink;

    monthlyFoodOrder = address.monthlyFoodOrder;

    isSaved = true;
  }

  final TextEditingController contactNameController = TextEditingController();

  final TextEditingController contactNumberController = TextEditingController();

  final TextEditingController houseNameController = TextEditingController();

  final TextEditingController houseController = TextEditingController();

  final TextEditingController streetController = TextEditingController();

  final TextEditingController areaController = TextEditingController();

  final TextEditingController landmarkController = TextEditingController();

  final TextEditingController pincodeController = TextEditingController();

  final TextEditingController locationController = TextEditingController();

  bool sameAsCustomerName = false;
  bool sameAsPhoneNumber = false;
  bool monthlyFoodOrder = false;

  String addressType = 'Home';

String? selectedCountry;
String? selectedState;
String? selectedDistrict;
String? selectedArea;

List<CountryState> states = [];
bool loadingStates = false;

List<String> districts = [];
List<String> areas = [];

bool loadingDistricts = false;
bool loadingAreas = false;

  bool isSaved = false;

  void dispose() {
    contactNameController.dispose();
    contactNumberController.dispose();
    houseNameController.dispose();
    houseController.dispose();
    streetController.dispose();
    areaController.dispose();
    landmarkController.dispose();
    pincodeController.dispose();
    locationController.dispose();
  }
}
