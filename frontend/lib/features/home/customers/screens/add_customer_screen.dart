import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../models/customer_model.dart';
import '../services/customer_store.dart';
import 'package:countrify/countrify.dart';
import '../services/location_service.dart';
import '../services/area_store.dart';

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

List<Country> _countries = [];



  @override
  void initState() {
    super.initState();
    _loadCountries();

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
        _addresses.add(_AddressFormData.fromModel(address));
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
  void _loadCountries() {
  setState(() {
    _countries = CountryUtils.getAllCountries();
  });
}

void _showAddAreaDialog(_AddressFormData address) {
  final controller = TextEditingController();

  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Add New Area'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Area Name',
            hintText: 'Enter area name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final area = controller.text.trim();

              if (area.isEmpty) return;

          final addedArea = AreaStore.addArea(
                name: area,
                country: address.selectedCountry ?? '',
                state: address.selectedState ?? '',
                district: address.selectedDistrict ?? '',
              );

              if (addedArea == null) {
                return;
              }

              setState(() {
                if (!address.areas.contains(addedArea.name)) {
                  address.areas.add(addedArea.name);
                }

                address.selectedArea = addedArea.name;
                address.areaController.text = addedArea.name;
              });

              Navigator.pop(dialogContext);
            },
            child: const Text('Add Area'),
          ),
        ],
      );
    },
  ).then((_) {
    controller.dispose();
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
            title: const Text('Select Country'),
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
                            separatorBuilder: (_, __) =>
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

void _showStatePicker(_AddressFormData address) {
  final searchController = TextEditingController();
  List<CountryState> filteredStates = List.from(address.states);

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Select State'),
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
                            separatorBuilder: (_, __) =>
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

void _showDistrictPicker(_AddressFormData address) {
  final searchController = TextEditingController();
  List<String> filteredDistricts = List.from(address.districts);

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Select District'),
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
                            separatorBuilder: (_, __) =>
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

                                    // Clear area because the
                                    // district has changed.
                                    address.selectedArea = null;
                                    address.areas = [];
                                    address.areaController.clear();
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

void _showAreaPicker(_AddressFormData address) {
  final searchController = TextEditingController();


  final allAreas = _getAvailableAreas(address);

 

   List<String> filteredAreas = List.from(allAreas);

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Select Area'),
            content: SizedBox(
              width: 420,
              height: 420,
              child: Column(
                children: [
                  TextField(
                    controller: searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search area...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon:
                          searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    searchController.clear();

                                    setDialogState(() {
                                      filteredAreas =
                                          List.from(allAreas);
                                    });
                                  },
                                )
                              : null,
                    ),
                    onChanged: (value) {
                      final query =
                          value.trim().toLowerCase();

                      setDialogState(() {
                        filteredAreas = allAreas.where((area) {
                          return area
                              .toLowerCase()
                              .contains(query);
                        }).toList();
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: filteredAreas.isEmpty
                        ? const Center(
                            child: Text('No areas found'),
                          )
                        : ListView.separated(
                            itemCount: filteredAreas.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final area =
                                  filteredAreas[index];

                              final isSelected =
                                  address.selectedArea ==
                                      area;

                              return ListTile(
                                dense: true,
                                title: Text(area),
                                trailing: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color:
                                            AppColors.primary,
                                      )
                                    : null,
                                onTap: () {
                                  setState(() {
                                    address.selectedArea =
                                        area;
                                    address.areaController
                                        .text = area;
                                  });

                                  Navigator.pop(
                                    dialogContext,
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

List<String> _getAvailableAreas(_AddressFormData address) {
  final customAreas = AreaStore.getAreas(
    country: address.selectedCountry ?? '',
    state: address.selectedState ?? '',
    district: address.selectedDistrict ?? '',
  ).map((area) => area.name);

  return {
    ...address.areas,
    ...customAreas,
  }.toList();
}

Future<void> _loadDistrictsForAddress(
  _AddressFormData address,
  String state,
) async {
  setState(() {
    address.loadingDistricts = true;
    address.districts = [];
    address.areas = [];

    address.selectedDistrict = null;
    address.selectedArea = null;
    address.areaController.clear();
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
    address.selectedArea = null;
    address.areaController.clear();
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
    setState(() {
      _addresses.add(_AddressFormData());
    });
  }

  void _editAddress(int index) {
    setState(() {
      _addresses[index].isSaved = false;
    });
  }

  void _registerCustomer() {
    final name = _nameController.text.trim();

    final phones = _phoneControllers
        .map((controller) => controller.text.trim())
        .where((phone) => phone.isNotEmpty)
        .toList();

    if (name.isEmpty) {
      _showMessage('Customer name is required.');
      return;
    }

    if (phones.isEmpty) {
      _showMessage('Phone number is required.');
      return;
    }

    if (_addresses.isEmpty || !_addresses.every((address) => address.isSaved)) {
      _showMessage('Please preview and save all addresses before registering.');
      return;
    }

    final customer = Customer(
      id: widget.customer?.id ??
    DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      phoneNumbers: phones,
      email: _emailController.text.trim(),
      addresses: _addresses.map((address) {
        return CustomerAddress(
          id: address.id ?? DateTime.now().microsecondsSinceEpoch.toString(),

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

    if (widget.customer == null) {
      CustomerStore.addCustomer(customer);
    } else {
      CustomerStore.updateCustomer(customer);
    }

    Navigator.pop(context, true);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _previewAddress(int index) {
    final address = _addresses[index];

    showDialog(
      context: context,
      builder: (dialogContext) {
        final screenWidth = MediaQuery.of(dialogContext).size.width;
        final screenHeight = MediaQuery.of(dialogContext).size.height;

        final isMobile = screenWidth < 600;

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
              maxWidth: 700,
              maxHeight: screenHeight * 0.88,
            ),
            child: Column(
              children: [
                _buildPreviewHeader(
                  title: 'Address ${index + 1} Preview',
                  address: address,
                ),

                const Divider(height: 1),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMobile ? 18 : 24),
                    child: _buildAddressPreviewContent(
                      address,
                      isMobile: isMobile,
                    ),
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
                        child: const Text('Edit Address'),
                      ),

                      const SizedBox(width: 10),

                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            address.isSaved = true;
                          });

                          Navigator.pop(dialogContext);
                        },
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Save Address'),
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

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              widget.customer == null ? 'Add Customer' : 'Edit Customer',
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
        );
      },
    );
  }

  Widget _buildResponsiveContent({
    required bool isMobile,
    required bool isTablet,
  }) {
    if (isMobile) {
      return _buildMobileLayout();
    }

    return _buildLargeLayout(isTablet: isTablet);
  }

  // ============================================================
  // MOBILE
  // ============================================================

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCustomerInfoSection(isMobile: true),

          const SizedBox(height: 16),

          SizedBox(height: 560, child: _buildAddressSection(isMobile: true)),

          const SizedBox(height: 20),

          _buildBottomButtons(isMobile: true),

          const SizedBox(height: 20),
        ],
      ),
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
    return _sectionContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(icon: Icons.person_outline, title: 'Customer Info'),

            const SizedBox(height: 20),

            _fieldLabel('Full Name'),

            const SizedBox(height: 7),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Enter full name'),
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
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: index == 0
                                  ? 'Primary phone number'
                                  : 'Additional phone number',
                            ),
                          ),
                        ),

                        if (_phoneControllers.length > 1) ...[
                          const SizedBox(width: 8),

                          SizedBox(
                            width: 46,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () => _removePhone(index),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                              child: const Icon(Icons.close, size: 18),
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

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'Optional email'),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
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

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
              itemCount: _addresses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
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
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    'Same as Phone Number',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: address.addressType,
            decoration: const InputDecoration(
              labelText: 'Address Type',
              prefixIcon: Icon(Icons.home_work_outlined),
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
          _simpleAddressField(
            label: 'House Name',
            controller: address.houseNameController,
          ),

          const SizedBox(height: 12),

          _simpleAddressField(
            label: 'House / Flat No.',
            controller: address.houseController,
          ),

          

         const SizedBox(height: 16),

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

          const SizedBox(height: 16),

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

          const SizedBox(height: 16),

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

          const SizedBox(height: 16),
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
   InkWell(
  onTap: address.selectedDistrict == null ||
          address.selectedDistrict!.isEmpty
      ? null
      : () {
          _showAreaPicker(address);
        },
  borderRadius: BorderRadius.circular(12),
  child: InputDecorator(
    decoration: InputDecoration(
      labelText: 'Area',
      prefixIcon: const Icon(
        Icons.location_on_outlined,
      ),
      suffixIcon: const Icon(
        Icons.keyboard_arrow_down,
      ),
    ),
    child: Text(
      address.selectedArea == null ||
              address.selectedArea!.isEmpty
          ? 'Select area'
          : address.selectedArea!,
      style: TextStyle(
        color: address.selectedArea == null ||
                address.selectedArea!.isEmpty
            ? AppColors.textSecondary
            : AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),
),

    const SizedBox(height: 16),

 Align(
  alignment: Alignment.centerRight,
  child: TextButton.icon(
    onPressed: () {
      _showAddAreaDialog(address);
    },
    icon: const Icon(Icons.add, size: 17),
    label: const Text('Add New Area'),
  ),
),
  ],
),
          const SizedBox(height: 16),

          _simpleAddressField(
            label: 'Street',
            controller: address.streetController,
          ),

          const SizedBox(height: 16),

          _simpleAddressField(
            label: 'Landmark',
            controller: address.landmarkController,
          ),

          const SizedBox(height: 16),

          _simpleAddressField(
            label: 'Pincode',
            controller: address.pincodeController,
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 16),

          _simpleAddressField(
            label: 'Location Link',
            controller: address.locationController,
          ),

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

          const SizedBox(height: 8),

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _previewAddress(index);
              },
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('Preview Address'),
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
    final address = _addresses[index];

    showDialog(
      context: context,
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
              maxWidth: 700,
              maxHeight: screenHeight * 0.88,
            ),
            child: Column(
              children: [
                _buildPreviewHeader(
                  title: 'Address ${index + 1} Preview',
                  address: address,
                ),

                const Divider(height: 1),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMobile ? 18 : 24),
                    child: _buildAddressPreviewContent(
                      address,
                      isMobile: isMobile,
                    ),
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
                          _editAddress(index);
                        },
                        child: const Text('Edit Address'),
                      ),

                      const SizedBox(width: 10),

                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        child: const Text('Close'),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),

        const SizedBox(height: 7),

        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 600;

            if (suffix == null) {
              return TextField(
                controller: controller,
                keyboardType: keyboardType,
                decoration: InputDecoration(hintText: 'Enter $label'),
              );
            }

            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    decoration: InputDecoration(hintText: 'Enter $label'),
                  ),

                  const SizedBox(height: 4),

                  suffix,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    decoration: InputDecoration(hintText: 'Enter $label'),
                  ),
                ),

                const SizedBox(width: 10),

                SizedBox(width: 245, child: suffix),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),

        const SizedBox(height: 7),

        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(hintText: 'Enter $label'),
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
          child: Text(widget.customer == null ? 'Register' : 'Update Customer'),
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

  _AddressFormData();

  _AddressFormData.fromModel(CustomerAddress address) {
    id = address.id;

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
