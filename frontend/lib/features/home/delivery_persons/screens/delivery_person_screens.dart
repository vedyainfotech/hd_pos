import 'package:flutter/material.dart';



import 'package:flutter/services.dart';

import 'package:file_picker/file_picker.dart';



import '../../../../core/theme/theme.dart';



import '../models/delivery_person_model.dart';



import '../services/delivery_person_services.dart';



class DeliveryPersonsScreen extends StatefulWidget {

  const DeliveryPersonsScreen({super.key});



  @override

  State<DeliveryPersonsScreen> createState() => _DeliveryPersonsScreenState();

}



class _DeliveryPersonsScreenState extends State<DeliveryPersonsScreen> {

  final DeliveryPersonApiService _service = DeliveryPersonApiService();



  final TextEditingController _searchController = TextEditingController();



  List<DeliveryPersonModel> _deliveryPersons = [];



  bool _isLoading = true;



  String _statusFilter = 'All';



  @override

  void initState() {

    super.initState();



    _loadDeliveryPersons();



    _searchController.addListener(_applyFilters);

  }



  @override

  void dispose() {

    _searchController.dispose();



    super.dispose();

  }



  Future<void> _loadDeliveryPersons() async {

    setState(() {

      _isLoading = true;

    });



    try {

      final data = await _service.getDeliveryPersons(includeInactive: true);



      if (!mounted) return;



      setState(() {

        _deliveryPersons = data;



        _isLoading = false;

      });

    } catch (e) {

      if (!mounted) return;



      setState(() {

        _isLoading = false;

      });



      _showMessage(e.toString().replaceFirst('Exception: ', ''));

    }

  }



  List<DeliveryPersonModel> get _filteredPersons {

    final search = _searchController.text.trim().toLowerCase();



    return _deliveryPersons.where((person) {

      final matchesSearch =

          search.isEmpty ||

          person.name.toLowerCase().contains(search) ||

          person.contactNumber.contains(search);



      final matchesStatus =

          _statusFilter == 'All' ||

          (_statusFilter == 'Active' && person.isActive) ||

          (_statusFilter == 'Inactive' && !person.isActive);



      return matchesSearch && matchesStatus;

    }).toList();

  }



  void _applyFilters() {

    if (mounted) {

      setState(() {});

    }

  }



  Future<void> _openAddDialog() async {

    final result = await showDialog<_DeliveryPersonFormResult>(

      context: context,



      barrierDismissible: false,



      builder: (_) => const _DeliveryPersonFormDialog(),

    );



    if (result == null) return;



    try {

      await _service.createDeliveryPerson(
  name: result.name,
  contactNumber: result.contactNumber,
  bankName: result.bankName,
  accountNumber: result.accountNumber,
  ifscCode: result.ifscCode,
  aadhaarNumber: result.aadhaarNumber,
  panCardNumber: result.panCardNumber,
  drivingLicense: result.drivingLicense,
  identityProofFile: result.identityProofFile!,
);



      if (!mounted) return;



      _showMessage('Delivery person added successfully.');



      await _loadDeliveryPersons();

    } catch (e) {

      if (!mounted) return;



      _showMessage(e.toString().replaceFirst('Exception: ', ''));

    }

  }



  Future<void> _openEditDialog(DeliveryPersonModel person) async {

    final result = await showDialog<_DeliveryPersonFormResult>(

      context: context,



      barrierDismissible: false,



      builder: (_) => _DeliveryPersonFormDialog(person: person),

    );



    if (result == null) return;



    try {

      await _service.updateDeliveryPerson(

        id: person.id,



        name: result.name,



        contactNumber: result.contactNumber,



        bankName: result.bankName,



        accountNumber: result.accountNumber,



        ifscCode: result.ifscCode,



        aadhaarNumber: result.aadhaarNumber,



        panCardNumber: result.panCardNumber,



        drivingLicense: result.drivingLicense,



        status: person.isActive,

      );



      if (!mounted) return;



      _showMessage('Delivery person updated successfully.');



      await _loadDeliveryPersons();

    } catch (e) {

      if (!mounted) return;



      _showMessage(e.toString().replaceFirst('Exception: ', ''));

    }

  }



  Future<void> _toggleStatus(DeliveryPersonModel person) async {

    try {

      final updated = await _service.updateDeliveryPersonStatus(

        person.id,



        !person.isActive,

      );



      if (!mounted) return;



      setState(() {

        final index = _deliveryPersons.indexWhere(

          (item) => item.id == person.id,

        );



        if (index != -1) {

          _deliveryPersons[index] = updated;

        }

      });

    } catch (e) {

      if (!mounted) return;



      _showMessage(e.toString().replaceFirst('Exception: ', ''));

    }

  }



  void _showMessage(String message) {

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),

    );

  }



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: AppColors.background,



      appBar: AppBar(

        backgroundColor: AppColors.surface,



        elevation: 0,



        surfaceTintColor: Colors.transparent,



        title: const Text(

          'Delivery Persons',



          style: TextStyle(

            color: AppColors.textPrimary,



            fontSize: 16,



            fontWeight: FontWeight.w700,

          ),

        ),



        leading: IconButton(

          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),



          onPressed: () => Navigator.pop(context),

        ),

      ),



      body: SafeArea(

        top: false,



        child: LayoutBuilder(

          builder: (context, constraints) {

            final horizontalPadding = constraints.maxWidth >= 1100

                ? 32.0

                : constraints.maxWidth >= 700

                ? 24.0

                : 16.0;



            return SingleChildScrollView(

              padding: EdgeInsets.fromLTRB(

                horizontalPadding,



                28,



                horizontalPadding,



                40,

              ),



              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,



                children: [

                  _buildHeader(constraints.maxWidth),



                  const SizedBox(height: 24),



                  _buildFilters(constraints.maxWidth),



                  const SizedBox(height: 18),



                  _buildDeliveryPersonsCard(constraints.maxWidth),

                ],

              ),

            );

          },

        ),

      ),

    );

  }



  Widget _buildHeader(double width) {

    return Row(

      children: [

        const Expanded(

          child: Text(

            'Manage your delivery persons',



            style: TextStyle(

              color: AppColors.textPrimary,



              fontSize: 22,



              fontWeight: FontWeight.w700,

            ),

          ),

        ),



        const SizedBox(width: 16),



        SizedBox(

          height: 44,



          child: ElevatedButton(

            onPressed: _openAddDialog,



            style: ElevatedButton.styleFrom(

              backgroundColor: AppColors.primary,



              foregroundColor: Colors.white,



              elevation: 0,



              padding: const EdgeInsets.symmetric(horizontal: 20),



              shape: RoundedRectangleBorder(

                borderRadius: BorderRadius.circular(12),

              ),

            ),



            child: const Text(

              '+  Add Delivery Person',



              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),

            ),

          ),

        ),

      ],

    );

  }



  Widget _buildFilters(double width) {

    final isCompact = width < 850;



    final search = SizedBox(

      height: 48,



      child: TextField(

        controller: _searchController,



        decoration: InputDecoration(

          hintText: 'Search by name or phone number',



          hintStyle: const TextStyle(

            color: AppColors.textTertiary,



            fontSize: 13,

          ),



          filled: true,



          fillColor: AppColors.surface,



          border: OutlineInputBorder(

            borderRadius: BorderRadius.circular(12),



            borderSide: const BorderSide(color: AppColors.border),

          ),



          enabledBorder: OutlineInputBorder(

            borderRadius: BorderRadius.circular(12),



            borderSide: const BorderSide(color: AppColors.border),

          ),



          focusedBorder: OutlineInputBorder(

            borderRadius: BorderRadius.circular(12),



            borderSide: const BorderSide(color: AppColors.primary, width: 1.2),

          ),



          contentPadding: const EdgeInsets.symmetric(horizontal: 14),

        ),

      ),

    );



    final status = _buildStatusFilter();



    return _CardContainer(

      child: Padding(

        padding: const EdgeInsets.all(16),



        child: isCompact

            ? Column(

                children: [

                  search,



                  const SizedBox(height: 12),



                  Align(alignment: Alignment.centerRight, child: status),

                ],

              )

            : Row(

                children: [

                  Expanded(child: search),



                  const SizedBox(width: 14),



                  status,

                ],

              ),

      ),

    );

  }



  Widget _buildStatusFilter() {

    const options = ['All', 'Active', 'Inactive'];



    return Container(

      height: 44,



      padding: const EdgeInsets.all(3),



      decoration: BoxDecoration(

        color: AppColors.surfaceSoft,



        border: Border.all(color: AppColors.border),



        borderRadius: BorderRadius.circular(24),

      ),



      child: Row(

        children: options.map((option) {

          final selected = _statusFilter == option;



          return SizedBox(

            width: 70,



            child: InkWell(

              borderRadius: BorderRadius.circular(20),



              onTap: () {

                setState(() {

                  _statusFilter = option;

                });

              },



              child: AnimatedContainer(

                duration: const Duration(milliseconds: 160),



                alignment: Alignment.center,



                decoration: BoxDecoration(

                  color: selected ? AppColors.primarySoft : Colors.transparent,



                  borderRadius: BorderRadius.circular(20),

                ),



                child: Text(

                  option,



                  style: TextStyle(

                    color: selected ? AppColors.primary : AppColors.textPrimary,



                    fontSize: 12,



                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,

                  ),

                ),

              ),

            ),

          );

        }).toList(),

      ),

    );

  }



  Widget _buildDeliveryPersonsCard(double width) {

    final persons = _filteredPersons;



    return _CardContainer(

      child: Padding(

        padding: const EdgeInsets.all(18),



        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,



          children: [

            const Text(

              'Delivery Persons',



              style: TextStyle(

                color: AppColors.textPrimary,



                fontSize: 17,



                fontWeight: FontWeight.w700,

              ),

            ),



            const SizedBox(height: 14),



            if (_isLoading)

              const Padding(

                padding: EdgeInsets.symmetric(vertical: 50),



                child: Center(

                  child: CircularProgressIndicator(color: AppColors.primary),

                ),

              )

            else if (persons.isEmpty)

              _buildEmptyState()

            else if (width >= 800)

              _buildDesktopList(persons)

            else

              _buildMobileList(persons),

          ],

        ),

      ),

    );

  }



  Widget _buildDesktopList(List<DeliveryPersonModel> persons) {

    return Column(

      children: [

        Container(

          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),



          decoration: BoxDecoration(

            color: AppColors.primarySoft,



            borderRadius: BorderRadius.circular(10),

          ),



          child: const Row(

            children: [

              Expanded(flex: 3, child: Text('Name', style: _headerStyle)),



              Expanded(

                flex: 3,



                child: Text('Phone Number', style: _headerStyle),

              ),



              SizedBox(

                width: 150,



                child: Center(child: Text('Actions', style: _headerStyle)),

              ),

            ],

          ),

        ),



        const SizedBox(height: 6),



        ...persons.map(_buildDesktopPersonRow),

      ],

    );

  }



  Widget _buildDesktopPersonRow(DeliveryPersonModel person) {

    return Container(

      margin: const EdgeInsets.only(bottom: 6),



      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),



      decoration: BoxDecoration(

        color: AppColors.surface,



        borderRadius: BorderRadius.circular(10),



        border: Border.all(color: AppColors.borderLight),

      ),



      child: Row(

        children: [

          Expanded(flex: 3, child: Text(person.name, style: _valueStyle)),



          Expanded(

            flex: 3,



            child: Text(person.contactNumber, style: _valueStyle),

          ),



          SizedBox(

            width: 150,



            child: Row(

              mainAxisAlignment: MainAxisAlignment.center,



              children: [

                _StatusSwitch(

                  value: person.isActive,



                  onChanged: (_) => _toggleStatus(person),

                ),



                const SizedBox(width: 16),



                _EditButton(onPressed: () => _openEditDialog(person)),

              ],

            ),

          ),

        ],

      ),

    );

  }



  Widget _buildMobileList(List<DeliveryPersonModel> persons) {

    return Column(

      children: persons.map((person) {

        return Container(

          margin: const EdgeInsets.only(bottom: 10),



          padding: const EdgeInsets.all(14),



          decoration: BoxDecoration(

            color: AppColors.surface,



            borderRadius: BorderRadius.circular(14),



            border: Border.all(color: AppColors.borderLight),

          ),



          child: Row(

            children: [

              Expanded(

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,



                  children: [

                    Text(person.name, style: _valueStyle),



                    const SizedBox(height: 5),



                    Text(

                      person.contactNumber,



                      style: const TextStyle(

                        color: AppColors.textSecondary,



                        fontSize: 13,

                      ),

                    ),

                  ],

                ),

              ),



              _StatusSwitch(

                value: person.isActive,



                onChanged: (_) => _toggleStatus(person),

              ),



              const SizedBox(width: 10),



              _EditButton(onPressed: () => _openEditDialog(person)),

            ],

          ),

        );

      }).toList(),

    );

  }



  Widget _buildEmptyState() {

    return Container(

      width: double.infinity,



      padding: const EdgeInsets.symmetric(vertical: 45),



      child: const Center(

        child: Text(

          'No delivery persons found.',



          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),

        ),

      ),

    );

  }



  static const TextStyle _headerStyle = TextStyle(

    color: AppColors.textPrimary,



    fontSize: 12,



    fontWeight: FontWeight.w700,

  );



  static const TextStyle _valueStyle = TextStyle(

    color: AppColors.textPrimary,



    fontSize: 14,



    fontWeight: FontWeight.w600,

  );

}



class _DeliveryPersonFormResult {

  final String name;



  final String contactNumber;



  final String? bankName;



  final String? accountNumber;



  final String? ifscCode;



  final String? aadhaarNumber;



  final String? panCardNumber;



  final String? drivingLicense;



  final PlatformFile? identityProofFile;

  const _DeliveryPersonFormResult({

    required this.name,



    required this.contactNumber,



    this.bankName,



    this.accountNumber,



    this.ifscCode,



    this.aadhaarNumber,



    this.panCardNumber,



    this.drivingLicense,



    this.identityProofFile,

  });

}



class _DeliveryPersonFormDialog extends StatefulWidget {

  final DeliveryPersonModel? person;



  const _DeliveryPersonFormDialog({this.person});



  @override

  State<_DeliveryPersonFormDialog> createState() =>

      _DeliveryPersonFormDialogState();

}



class _DeliveryPersonFormDialogState extends State<_DeliveryPersonFormDialog> {

  final _formKey = GlobalKey<FormState>();



  late final TextEditingController _nameController;



  late final TextEditingController _contactController;



  late final TextEditingController _bankController;



  late final TextEditingController _accountController;



  late final TextEditingController _ifscController;



  late final TextEditingController _aadhaarController;



  late final TextEditingController _panController;



  late final TextEditingController _licenseController;



  PlatformFile? _identityProofFile;

  String? _identityProofError;

  bool get isEdit => widget.person != null;



  @override

  void initState() {

    super.initState();



    final person = widget.person;



    _nameController = TextEditingController(text: person?.name ?? '');



    _contactController = TextEditingController(

      text: person?.contactNumber ?? '',

    );



    _bankController = TextEditingController(text: person?.bankName ?? '');



    _accountController = TextEditingController(

      text: person?.accountNumber ?? '',

    );



    _ifscController = TextEditingController(text: person?.ifscCode ?? '');



    _aadhaarController = TextEditingController(

      text: person?.aadhaarNumber ?? '',

    );



    _panController = TextEditingController(text: person?.panCardNumber ?? '');



    _licenseController = TextEditingController(

      text: person?.drivingLicense ?? '',

    );

  }



  @override

  void dispose() {

    _nameController.dispose();



    _contactController.dispose();



    _bankController.dispose();



    _accountController.dispose();



    _ifscController.dispose();



    _aadhaarController.dispose();



    _panController.dispose();



    _licenseController.dispose();



    super.dispose();

  }



  Future<void> _pickIdentityProof() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (file == null || !mounted) {
      return;
    }

    const maxFileSize = 10 * 1024 * 1024;
    final fileSize = file.lengthSync() ?? await file.length();

    if (fileSize != null && fileSize > maxFileSize) {
      setState(() {
        _identityProofError = 'File size must not exceed 10 MB.';
      });
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _identityProofFile = file;
      _identityProofError = null;
    });
  }

  void _removeIdentityProof() {

    setState(() {

      _identityProofFile = null;

      _identityProofError = !isEdit ? 'Identity Proof is required' : null;

    });

  }



  void _submit() {

    if (!_formKey.currentState!.validate()) {

      return;

    }



    if (!isEdit && _identityProofFile == null) {

      setState(() {

        _identityProofError = 'Identity Proof is required';

      });

      return;

    }



    Navigator.pop(

      context,



      _DeliveryPersonFormResult(

        name: _nameController.text.trim(),



        contactNumber: _contactController.text.trim(),



        bankName: _bankController.text.trim(),



        accountNumber: _accountController.text.trim(),



        ifscCode: _ifscController.text.trim(),



        aadhaarNumber: _aadhaarController.text.trim(),



        panCardNumber: _panController.text.trim(),



        drivingLicense: _licenseController.text.trim(),



        identityProofFile: _identityProofFile,

      ),

    );

  }



  @override

  Widget build(BuildContext context) {

    return Dialog(

      backgroundColor: Colors.transparent,



      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),



      child: ConstrainedBox(

        constraints: const BoxConstraints(maxWidth: 820),



        child: Material(

          color: AppColors.surface,



          borderRadius: BorderRadius.circular(20),



          child: Padding(

            padding: const EdgeInsets.fromLTRB(28, 24, 28, 22),



            child: Form(

              key: _formKey,



              child: Column(

                mainAxisSize: MainAxisSize.min,



                children: [

                  Row(

                    children: [

                      Expanded(

                        child: Column(

                          crossAxisAlignment: CrossAxisAlignment.start,



                          children: [

                            Text(

                              isEdit

                                  ? 'Edit Delivery Person'

                                  : 'Add Delivery Person',



                              style: const TextStyle(

                                color: AppColors.textPrimary,



                                fontSize: 20,



                                fontWeight: FontWeight.w700,

                              ),

                            ),



                            const SizedBox(height: 4),



                            Text(

                              isEdit

                                  ? 'Update delivery person details'

                                  : 'Add a new delivery person',



                              style: const TextStyle(

                                color: AppColors.textSecondary,



                                fontSize: 12,

                              ),

                            ),

                          ],

                        ),

                      ),



                      IconButton(

                        onPressed: () => Navigator.pop(context),



                        icon: const Icon(

                          Icons.close,



                          color: AppColors.textSecondary,

                        ),

                      ),

                    ],

                  ),



                  const SizedBox(height: 20),



                  Flexible(

                    child: SingleChildScrollView(

                      child: LayoutBuilder(

                        builder: (context, constraints) {

                          final twoColumns = constraints.maxWidth >= 620;



                          if (!twoColumns) {

                            return Column(

                              children: [

                                ..._buildFields(oneColumn: true),

                                const SizedBox(height: 18),

                                _buildIdentityProofSection(),

                              ],

                            );

                          }



                          final fields = _buildFields(oneColumn: false);



                          return Column(

                            children: [

                              GridView.count(

                                shrinkWrap: true,

                                physics: const NeverScrollableScrollPhysics(),

                                crossAxisCount: 2,

                                crossAxisSpacing: 20,

                                mainAxisSpacing: 12,

                                childAspectRatio: 4.8,

                                children: fields,

                              ),

                              const SizedBox(height: 18),

                              _buildIdentityProofSection(),

                            ],

                          );

                        },

                      ),

                    ),

                  ),



                  const SizedBox(height: 20),



                  Row(

                    children: [

                      Expanded(

                        child: OutlinedButton(

                          onPressed: () => Navigator.pop(context),



                          style: OutlinedButton.styleFrom(

                            minimumSize: const Size.fromHeight(46),



                            foregroundColor: AppColors.textPrimary,



                            side: const BorderSide(color: AppColors.border),



                            shape: RoundedRectangleBorder(

                              borderRadius: BorderRadius.circular(10),

                            ),

                          ),



                          child: const Text(

                            'Cancel',



                            style: TextStyle(fontWeight: FontWeight.w600),

                          ),

                        ),

                      ),



                      const SizedBox(width: 12),



                      Expanded(

                        child: ElevatedButton(

                          onPressed: _submit,



                          style: ElevatedButton.styleFrom(

                            minimumSize: const Size.fromHeight(46),



                            backgroundColor: AppColors.primary,



                            foregroundColor: Colors.white,



                            elevation: 0,



                            shape: RoundedRectangleBorder(

                              borderRadius: BorderRadius.circular(10),

                            ),

                          ),



                          child: Text(

                            isEdit ? 'Update' : 'Save',



                            style: const TextStyle(fontWeight: FontWeight.w700),

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

      ),

    );

  }



  List<Widget> _buildFields({required bool oneColumn}) {

    final fields = [

      _formField(

        label: 'Name',



        controller: _nameController,



        requiredField: true,



        hint: 'Enter Name',

      ),



      _formField(

        label: 'Contact Number',



        controller: _contactController,



        requiredField: true,



        hint: 'Enter Contact Number',



        keyboardType: TextInputType.phone,



        inputFormatters: [

          FilteringTextInputFormatter.digitsOnly,



          LengthLimitingTextInputFormatter(10),

        ],

      ),



      _formField(

        label: 'Bank Name',



        controller: _bankController,



        hint: 'Enter Bank Name',

      ),



      _formField(

        label: 'Account Number',



        controller: _accountController,



        hint: 'Enter Account Number',



        keyboardType: TextInputType.number,



        inputFormatters: [

          FilteringTextInputFormatter.digitsOnly,



          LengthLimitingTextInputFormatter(18),

        ],

      ),



      _formField(

        label: 'IFSC Code',



        controller: _ifscController,



        hint: 'Enter IFSC Code',



        inputFormatters: [

          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),



          LengthLimitingTextInputFormatter(11),



          _UpperCaseTextFormatter(),

        ],

      ),



      _formField(

        label: 'Aadhaar Number',



        controller: _aadhaarController,



        hint: 'Enter Aadhaar Number',



        keyboardType: TextInputType.number,



        inputFormatters: [

          FilteringTextInputFormatter.digitsOnly,



          LengthLimitingTextInputFormatter(12),

        ],

      ),



      _formField(

        label: 'PAN Card Number',



        controller: _panController,



        hint: 'Enter PAN Card Number',



        inputFormatters: [

          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),



          LengthLimitingTextInputFormatter(10),



          _UpperCaseTextFormatter(),

        ],

      ),



      _formField(

        label: 'Driving License',



        controller: _licenseController,



        hint: 'Enter Driving License Number',



        inputFormatters: [

          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9/-]')),



          LengthLimitingTextInputFormatter(20),



          _UpperCaseTextFormatter(),

        ],

      ),

    ];



    if (oneColumn) {

      return fields

          .map(

            (field) => Padding(

              padding: const EdgeInsets.only(bottom: 12),



              child: field,

            ),

          )

          .toList();

    }



    return fields;

  }



  Widget _buildIdentityProofSection() {

    final file = _identityProofFile;



    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(

        color: AppColors.surfaceSoft,

        borderRadius: BorderRadius.circular(12),

        border: Border.all(

          color: _identityProofError != null

              ? AppColors.error

              : AppColors.border,

        ),

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          const Text(

            'Identity Proof',

            style: TextStyle(

              color: AppColors.textPrimary,

              fontSize: 14,

              fontWeight: FontWeight.w700,

            ),

          ),

          const SizedBox(height: 5),

          const Text(

            'Upload one identity proof document.',

            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),

          ),

          const SizedBox(height: 12),

          Row(

            children: [

              OutlinedButton(

                onPressed: _pickIdentityProof,

                style: OutlinedButton.styleFrom(

                  minimumSize: const Size(0, 42),

                  padding: const EdgeInsets.symmetric(horizontal: 16),

                  foregroundColor: AppColors.primary,

                  side: const BorderSide(color: AppColors.primary),

                  shape: RoundedRectangleBorder(

                    borderRadius: BorderRadius.circular(10),

                  ),

                ),

                child: Text(

                  file == null ? 'Choose Document' : 'Change Document',

                ),

              ),

              if (file != null) ...[

                const SizedBox(width: 12),

                Expanded(

                  child: Text(

                    file.name,

                    maxLines: 2,

                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(

                      color: AppColors.textPrimary,

                      fontSize: 12,

                      fontWeight: FontWeight.w500,

                    ),

                  ),

                ),

                const SizedBox(width: 8),

                TextButton(

                  onPressed: _removeIdentityProof,

                  style: TextButton.styleFrom(foregroundColor: AppColors.error),

                  child: const Text('Remove'),

                ),

              ],

            ],

          ),

          const SizedBox(height: 8),

          const Text(

            'PDF, JPG, JPEG, PNG • Maximum file size: 10 MB',

            style: TextStyle(color: AppColors.textTertiary, fontSize: 11),

          ),

          if (_identityProofError != null) ...[

            const SizedBox(height: 6),

            Text(

              _identityProofError!,

              style: const TextStyle(color: AppColors.error, fontSize: 11),

            ),

          ],

        ],

      ),

    );

  }



  Widget _formField({

    required String label,



    required TextEditingController controller,



    required String hint,



    bool requiredField = false,



    TextInputType? keyboardType,



    List<TextInputFormatter>? inputFormatters,

  }) {

    return TextFormField(

      controller: controller,



      keyboardType: keyboardType,



      inputFormatters: inputFormatters,



      textInputAction: TextInputAction.next,



      autovalidateMode: AutovalidateMode.onUserInteraction,



      decoration: InputDecoration(

        labelText: requiredField ? '$label *' : label,



        hintText: hint,



        labelStyle: const TextStyle(

          color: AppColors.textPrimary,



          fontSize: 12,



          fontWeight: FontWeight.w600,

        ),



        hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 12),



        filled: true,



        fillColor: AppColors.inputBackground,



        contentPadding: const EdgeInsets.symmetric(

          horizontal: 14,



          vertical: 12,

        ),



        border: OutlineInputBorder(

          borderRadius: BorderRadius.circular(10),



          borderSide: const BorderSide(color: AppColors.border),

        ),



        enabledBorder: OutlineInputBorder(

          borderRadius: BorderRadius.circular(10),



          borderSide: const BorderSide(color: AppColors.border),

        ),



        focusedBorder: OutlineInputBorder(

          borderRadius: BorderRadius.circular(10),



          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),

        ),

      ),



      validator: (value) {

        final text = value?.trim() ?? '';



        if (requiredField && text.isEmpty) {

          return '$label is required';

        }



        if (text.isEmpty) {

          return null;

        }



        switch (label) {

          case 'Contact Number':

            if (!RegExp(r'^[06789][0-9]{9}$').hasMatch(text)) {

              return 'Enter exactly 10 digits starting with 0, 6, 7, 8 or 9';

            }



            break;



          case 'Account Number':

            if (!RegExp(r'^[0-9]{6,18}$').hasMatch(text)) {

              return 'Enter 6 to 18 digits';

            }



            break;



          case 'IFSC Code':

            if (!RegExp(

              r'^[A-Z]{4}0[A-Z0-9]{6}$',

            ).hasMatch(text.toUpperCase())) {

              return 'Enter a valid 11-character IFSC code';

            }



            break;



          case 'Aadhaar Number':

            if (!RegExp(r'^[0-9]{12}$').hasMatch(text)) {

              return 'Enter exactly 12 digits';

            }



            break;



          case 'PAN Card Number':

            if (!RegExp(

              r'^[A-Z]{5}[0-9]{4}[A-Z]$',

            ).hasMatch(text.toUpperCase())) {

              return 'Enter a valid PAN (e.g. ABCDE1234F)';

            }



            break;



          case 'Driving License':

            if (!RegExp(r'^[A-Z0-9/-]{5,20}$').hasMatch(text.toUpperCase())) {

              return 'Enter a valid driving licence number';

            }



            break;

        }



        return null;

      },

    );

  }

}



class _UpperCaseTextFormatter extends TextInputFormatter {

  @override

  TextEditingValue formatEditUpdate(

    TextEditingValue oldValue,



    TextEditingValue newValue,

  ) {

    return TextEditingValue(

      text: newValue.text.toUpperCase(),



      selection: newValue.selection,



      composing: newValue.composing,

    );

  }

}



class _StatusSwitch extends StatelessWidget {

  final bool value;



  final ValueChanged<bool> onChanged;



  const _StatusSwitch({required this.value, required this.onChanged});



  @override

  Widget build(BuildContext context) {

    return Switch(

      value: value,



      onChanged: onChanged,



      activeTrackColor: AppColors.primary,



      activeThumbColor: Colors.white,



      inactiveTrackColor: Colors.white,



      inactiveThumbColor: AppColors.textTertiary,



      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,

    );

  }

}



class _EditButton extends StatelessWidget {

  final VoidCallback onPressed;



  const _EditButton({required this.onPressed});



  @override

  Widget build(BuildContext context) {

    return SizedBox(

      width: 42,



      height: 38,



      child: OutlinedButton(

        onPressed: onPressed,



        style: OutlinedButton.styleFrom(

          foregroundColor: AppColors.primary,



          backgroundColor: AppColors.primarySoft,



          side: BorderSide.none,



          padding: EdgeInsets.zero,



          shape: RoundedRectangleBorder(

            borderRadius: BorderRadius.circular(10),

          ),

        ),



        child: const Text(

          'Edit',



          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),

        ),

      ),

    );

  }

}



class _CardContainer extends StatelessWidget {

  final Widget child;



  const _CardContainer({required this.child});



  @override

  Widget build(BuildContext context) {

    return Container(

      width: double.infinity,



      decoration: BoxDecoration(

        color: AppColors.surface,



        borderRadius: BorderRadius.circular(18),



        border: Border.all(color: AppColors.borderLight),



        boxShadow: [

          BoxShadow(

            color: AppColors.textSecondary.withValues(alpha: 0.035),



            blurRadius: 18,



            offset: const Offset(0, 5),

          ),

        ],

      ),



      child: child,

    );

  }

}
