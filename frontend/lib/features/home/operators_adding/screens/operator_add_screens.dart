import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import '../../../../core/theme/theme.dart';

import '../models/operator_add_model.dart';

import '../services/operator_add_services.dart';

class OperatorAddScreen extends StatefulWidget {
  const OperatorAddScreen({super.key});

  @override
  State<OperatorAddScreen> createState() => _OperatorAddScreenState();
}

class _OperatorAddScreenState extends State<OperatorAddScreen> {
  final OperatorAddService _service = OperatorAddService.instance;

  String _selectedRoleFilter = 'All Roles';

  String _searchQuery = '';

  List<OperatorModel> get _filteredOperators {
    final query = _searchQuery.trim().toLowerCase();

    return _service.getOperators().where((operator) {
      final matchesSearch =
          query.isEmpty ||
          operator.name.toLowerCase().contains(query) ||
          operator.phoneNumber.contains(query) ||
          operator.email.toLowerCase().contains(query);

      final matchesRole =
          _selectedRoleFilter == 'All Roles' ||
          operator.role == _selectedRoleFilter;

      return matchesSearch && matchesRole;
    }).toList();
  }

  Future<void> _openAddDialog() async {
    final result = await showDialog<_OperatorFormResult>(
      context: context,

      barrierDismissible: false,

      builder: (_) => const _OperatorFormDialog(),
    );

    if (result == null) {
      return;
    }

    try {
      _service.addOperator(
        name: result.name,

        phoneNumber: result.phoneNumber,

        email: result.email,

        role: result.role,

        address: result.address,

        aadhaarNumber: result.aadhaarNumber,

        panCardNumber: result.panCardNumber,

        drivingLicense: result.drivingLicense,

        identityProofFilename: result.identityProofFile?.name,
      );

      if (!mounted) {
        return;
      }

      setState(() {});

      _showMessage('Operator added successfully.');
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _openEditDialog(OperatorModel operator) async {
    final result = await showDialog<_OperatorFormResult>(
      context: context,

      barrierDismissible: false,

      builder: (_) => _OperatorFormDialog(operator: operator),
    );

    if (result == null) {
      return;
    }

    try {
      _service.updateOperator(
        id: operator.id,

        name: result.name,

        phoneNumber: result.phoneNumber,

        email: result.email,

        role: result.role,

        address: result.address,

        aadhaarNumber: result.aadhaarNumber,

        panCardNumber: result.panCardNumber,

        drivingLicense: result.drivingLicense,

        identityProofFilename: result.identityProofFile?.name,
      );

      if (!mounted) {
        return;
      }

      setState(() {});

      _showMessage('Operator updated successfully.');
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _openPreviewDialog(OperatorModel operator) {
    showDialog<void>(
      context: context,
      builder: (_) => _OperatorPreviewDialog(operator: operator),
    );
  }

  void _toggleStatus(OperatorModel operator) {
    try {
      _service.toggleStatus(operator.id);

      setState(() {});

      _showMessage(
        operator.isActive ? 'Operator deactivated.' : 'Operator activated.',
      );
    } catch (e) {
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),

          behavior: SnackBarBehavior.floating,

          backgroundColor: AppColors.primaryDark,
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

            if (width < 700) {
              return _buildMobileLayout();
            }

            if (width < 1100) {
              return _buildTabletLayout();
            }

            return _buildDesktopLayout();
          },
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 20, 26, 22),
      child: SizedBox.expand(child: _buildOperatorsCard()),
    );
  }

  Widget _buildTabletLayout() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: SizedBox.expand(child: _buildOperatorsCard()),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: _buildOperatorsCard(),
    );
  }

  Widget _buildOperatorsCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fillHeight =
            constraints.hasBoundedHeight &&
            constraints.maxHeight.isFinite &&
            constraints.maxHeight > 650;

        return _CardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAddOperatorSection(),
              const SizedBox(height: 20),
              if (fillHeight)
                Expanded(child: _buildOperatorsListSection(expandList: true))
              else
                _buildOperatorsListSection(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddOperatorSection() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: AppColors.primarySoft.withValues(alpha: 0.7),

        borderRadius: BorderRadius.circular(14),
      ),

      child: Row(
        children: [
          Container(
            width: 46,

            height: 46,

            decoration: BoxDecoration(
              color: AppColors.surface,

              borderRadius: BorderRadius.circular(12),
            ),

            child: const Icon(
              Icons.person_add_alt_1_outlined,

              color: AppColors.primary,

              size: 23,
            ),
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'Add Operator',

                  style: TextStyle(
                    fontSize: 18,

                    fontWeight: FontWeight.w700,

                    color: AppColors.textPrimary,
                  ),
                ),

                SizedBox(height: 3),

                Text(
                  'Create a new admin or operator account',

                  style: TextStyle(
                    fontSize: 12,

                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          ElevatedButton.icon(
            onPressed: _openAddDialog,

            icon: const Icon(Icons.add, size: 19),

            label: const Text('Add Operator'),

            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,

              foregroundColor: Colors.white,

              elevation: 0,

              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperatorsListSection({bool expandList = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 850) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  _buildListTitle(),

                  const SizedBox(height: 14),

                  _buildSearchAndRoleFilter(compact: true),
                ],
              );
            }

            return Row(
              children: [
                _buildListTitle(),

                const Spacer(),

                _buildSearchAndRoleFilter(),
              ],
            );
          },
        ),

        const SizedBox(height: 14),

        if (expandList)
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 850) {
                  return _buildMobileOperatorsList();
                }

                return _buildDesktopOperatorsList(expandList: true);
              },
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 850) {
                return _buildMobileOperatorsList();
              }

              return _buildDesktopOperatorsList();
            },
          ),
      ],
    );
  }

  Widget _buildListTitle() {
    return Row(
      children: [
        Container(
          width: 42,

          height: 42,

          decoration: BoxDecoration(
            color: AppColors.primarySoft,

            borderRadius: BorderRadius.circular(11),
          ),

          child: const Icon(
            Icons.groups_outlined,

            color: AppColors.primary,

            size: 22,
          ),
        ),

        const SizedBox(width: 12),

        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              'Operators List',

              style: TextStyle(
                fontSize: 18,

                fontWeight: FontWeight.w700,

                color: AppColors.textPrimary,
              ),
            ),

            SizedBox(height: 3),

            Text(
              'View and manage all system users and operators',

              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAndRoleFilter({bool compact = false}) {
    final search = SizedBox(
      width: compact ? double.infinity : 280,

      height: 42,

      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },

        decoration: InputDecoration(
          hintText: 'Search by name, email or phone...',

          prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.icon),

          filled: true,

          fillColor: AppColors.surface,

          contentPadding: const EdgeInsets.symmetric(horizontal: 12),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),

            borderSide: const BorderSide(color: AppColors.border),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),

            borderSide: const BorderSide(color: AppColors.border),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),

            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );

    final roleFilter = SizedBox(
      width: compact ? double.infinity : 140,

      height: 42,

      child: DropdownButtonFormField<String>(
        value: _selectedRoleFilter,

        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),

          filled: true,

          fillColor: AppColors.surface,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),

            borderSide: const BorderSide(color: AppColors.border),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),

            borderSide: const BorderSide(color: AppColors.border),
          ),
        ),

        items: const [
          DropdownMenuItem(value: 'All Roles', child: Text('All Roles')),

          DropdownMenuItem(value: 'Operator', child: Text('Operator')),

          DropdownMenuItem(value: 'Admin', child: Text('Admin')),

          DropdownMenuItem(value: 'Manager', child: Text('Manager')),
        ],

        onChanged: (value) {
          if (value == null) {
            return;
          }

          setState(() {
            _selectedRoleFilter = value;
          });
        },
      ),
    );

    if (compact) {
      return Column(children: [search, const SizedBox(height: 10), roleFilter]);
    }

    return Row(children: [search, const SizedBox(width: 10), roleFilter]);
  }

  Widget _buildDesktopOperatorsList({bool expandList = false}) {
    final operators = _filteredOperators;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLight),

        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        children: [
          _buildDesktopHeader(),

          if (expandList)
            Expanded(
              child: operators.isEmpty
                  ? _buildEmptyState()
                  : Scrollbar(
                      thumbVisibility: true,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(8),
                        itemCount: operators.length,
                        separatorBuilder: (_, __) {
                          return const SizedBox(height: 6);
                        },
                        itemBuilder: (context, index) {
                          return _buildDesktopRow(operators[index]);
                        },
                      ),
                    ),
            )
          else
            SizedBox(
              height: 360,
              child: operators.isEmpty
                  ? _buildEmptyState()
                  : Scrollbar(
                      thumbVisibility: true,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(8),
                        itemCount: operators.length,
                        separatorBuilder: (_, __) {
                          return const SizedBox(height: 6);
                        },
                        itemBuilder: (context, index) {
                          return _buildDesktopRow(operators[index]);
                        },
                      ),
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildDesktopHeader() {
    return Container(
      height: 50,

      padding: const EdgeInsets.symmetric(horizontal: 14),

      decoration: BoxDecoration(
        color: AppColors.primarySoft,

        borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
      ),

      child: const Row(
        children: [
          SizedBox(width: 60, child: Text('ID', style: _headerStyle)),

          Expanded(flex: 2, child: Text('Name', style: _headerStyle)),

          Expanded(flex: 2, child: Text('Phone Number', style: _headerStyle)),

          Expanded(flex: 2, child: Text('Email', style: _headerStyle)),

          SizedBox(width: 110, child: Text('Role', style: _headerStyle)),

          SizedBox(width: 170, child: Text('Actions', style: _headerStyle)),
        ],
      ),
    );
  }

  Widget _buildDesktopRow(OperatorModel operator) {
    return Container(
      height: 58,

      padding: const EdgeInsets.symmetric(horizontal: 14),

      decoration: BoxDecoration(
        color: AppColors.surface,

        borderRadius: BorderRadius.circular(9),

        border: Border.all(color: AppColors.borderLight),
      ),

      child: Row(
        children: [
          SizedBox(
            width: 60,

            child: Text(operator.id.toString(), style: _bodyStyle),
          ),

          Expanded(
            flex: 2,

            child: Text(
              operator.name,

              style: _bodyStyle,

              overflow: TextOverflow.ellipsis,
            ),
          ),

          Expanded(
            flex: 2,

            child: Text(operator.phoneNumber, style: _bodyStyle),
          ),

          Expanded(
            flex: 2,

            child: Text(
              operator.email,

              style: _bodyStyle,

              overflow: TextOverflow.ellipsis,
            ),
          ),

          SizedBox(
            width: 110,

            child: Text(
              operator.role,

              style: const TextStyle(
                fontSize: 13,

                color: AppColors.textPrimary,

                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          SizedBox(
            width: 170,

            child: Row(
              children: [
                _StatusSwitch(
                  value: operator.isActive,

                  onChanged: (_) {
                    _toggleStatus(operator);
                  },
                ),

                const SizedBox(width: 12),

                _PreviewActionButton(
                  onPressed: () {
                    _openPreviewDialog(operator);
                  },
                ),

                const SizedBox(width: 10),

                _IconActionButton(
                  icon: Icons.edit_outlined,

                  tooltip: 'Edit',

                  onPressed: () {
                    _openEditDialog(operator);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileOperatorsList() {
    final operators = _filteredOperators;

    return SizedBox(
      height: 500,

      child: operators.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              itemCount: operators.length,

              separatorBuilder: (_, __) {
                return const SizedBox(height: 10);
              },

              itemBuilder: (context, index) {
                return _buildMobileOperatorCard(operators[index]);
              },
            ),
    );
  }

  Widget _buildMobileOperatorCard(OperatorModel operator) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: AppColors.surface,

        borderRadius: BorderRadius.circular(13),

        border: Border.all(color: AppColors.borderLight),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          _MobileDetailRow(label: 'ID', value: operator.id.toString()),

          const SizedBox(height: 7),

          Text(
            operator.name,

            style: const TextStyle(
              fontSize: 16,

              fontWeight: FontWeight.w700,

              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          _MobileDetailRow(label: 'Phone', value: operator.phoneNumber),

          const SizedBox(height: 7),

          _MobileDetailRow(label: 'Email', value: operator.email),

          const SizedBox(height: 7),

          _MobileDetailRow(label: 'Role', value: operator.role),

          const SizedBox(height: 12),

          Row(
            children: [
              const Spacer(),

              _StatusSwitch(
                value: operator.isActive,

                onChanged: (_) {
                  _toggleStatus(operator);
                },
              ),

              const SizedBox(width: 12),

              _PreviewActionButton(
                onPressed: () {
                  _openPreviewDialog(operator);
                },
              ),

              const SizedBox(width: 10),

              _IconActionButton(
                icon: Icons.edit_outlined,

                tooltip: 'Edit',

                onPressed: () {
                  _openEditDialog(operator);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(Icons.people_outline, size: 42, color: AppColors.textTertiary),

          SizedBox(height: 10),

          Text(
            'No operators found',

            style: TextStyle(
              fontSize: 15,

              fontWeight: FontWeight.w600,

              color: AppColors.textSecondary,
            ),
          ),

          SizedBox(height: 4),

          Text(
            'Add an operator to see them here.',

            style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _OperatorFormResult {
  final String name;

  final String phoneNumber;

  final String email;

  final String role;

  final String address;

  final String aadhaarNumber;

  final String panCardNumber;

  final String drivingLicense;

  final PlatformFile? identityProofFile;

  const _OperatorFormResult({
    required this.name,

    required this.phoneNumber,

    required this.email,

    required this.role,

    required this.address,

    required this.aadhaarNumber,

    required this.panCardNumber,

    required this.drivingLicense,

    required this.identityProofFile,
  });
}

class _OperatorFormDialog extends StatefulWidget {
  final OperatorModel? operator;

  const _OperatorFormDialog({this.operator});

  @override
  State<_OperatorFormDialog> createState() => _OperatorFormDialogState();
}

class _OperatorFormDialogState extends State<_OperatorFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;

  late final TextEditingController _phoneController;

  late final TextEditingController _emailController;

  late final TextEditingController _addressController;

  late final TextEditingController _aadhaarController;

  late final TextEditingController _panController;

  late final TextEditingController _licenseController;

  PlatformFile? _identityProofFile;

  String? _identityProofError;

  String? _selectedRole;

  bool get isEdit => widget.operator != null;

  static const List<String> _roles = ['Operator', 'Admin', 'Manager'];

  @override
  void initState() {
    super.initState();

    final operator = widget.operator;

    _nameController = TextEditingController(text: operator?.name ?? '');

    _phoneController = TextEditingController(text: operator?.phoneNumber ?? '');

    _emailController = TextEditingController(text: operator?.email ?? '');

    _addressController = TextEditingController(text: operator?.address ?? '');

    _aadhaarController = TextEditingController(
      text: operator?.aadhaarNumber ?? '',
    );

    _panController = TextEditingController(text: operator?.panCardNumber ?? '');

    _licenseController = TextEditingController(
      text: operator?.drivingLicense ?? '',
    );

    _selectedRole = operator?.role;
  }

  @override
  void dispose() {
    _nameController.dispose();

    _phoneController.dispose();

    _emailController.dispose();

    _addressController.dispose();

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

    setState(() {
      _identityProofFile = file;

      _identityProofError = null;
    });
  }

  void _removeIdentityProof() {
    setState(() {
      _identityProofFile = null;

      _identityProofError = null;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRole == null) {
      setState(() {
        _identityProofError = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a role.'),

          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    // Identity proof is optional. If selected, file type and size are validated.

    Navigator.pop(
      context,

      _OperatorFormResult(
        name: _nameController.text.trim(),

        phoneNumber: _phoneController.text.trim(),

        email: _emailController.text.trim(),

        role: _selectedRole!,

        address: _addressController.text.trim(),

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
        constraints: const BoxConstraints(maxWidth: 820, maxHeight: 760),

        child: Material(
          color: AppColors.surface,

          borderRadius: BorderRadius.circular(20),

          clipBehavior: Clip.antiAlias,

          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 22),

            child: Form(
              key: _formKey,

              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              isEdit ? 'Edit Operator' : 'Add Operator',

                              style: const TextStyle(
                                color: AppColors.textPrimary,

                                fontSize: 20,

                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              isEdit
                                  ? 'Update operator details'
                                  : 'Add a new system operator',

                              style: const TextStyle(
                                color: AppColors.textSecondary,

                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },

                        icon: const Icon(
                          Icons.close,

                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(top: 10, bottom: 4),

                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final twoColumns = constraints.maxWidth >= 620;

                          if (!twoColumns) {
                            return Column(
                              children: [
                                _buildNameField(),

                                const SizedBox(height: 12),

                                _buildPhoneField(),

                                const SizedBox(height: 12),

                                _buildEmailField(),

                                const SizedBox(height: 12),

                                _buildRoleField(),

                                const SizedBox(height: 12),

                                _buildAddressField(),

                                const SizedBox(height: 12),

                                _buildAadhaarField(),

                                const SizedBox(height: 12),

                                _buildPanField(),

                                const SizedBox(height: 12),

                                _buildLicenseField(),

                                const SizedBox(height: 18),

                                _buildIdentityProofSection(),
                              ],
                            );
                          }

                          return Column(
                            children: [
                              GridView.count(
                                shrinkWrap: true,

                                physics: const NeverScrollableScrollPhysics(),

                                crossAxisCount: 2,

                                crossAxisSpacing: 20,

                                mainAxisSpacing: 12,

                                childAspectRatio: 4.8,

                                children: [
                                  _buildNameField(),

                                  _buildPhoneField(),

                                  _buildEmailField(),

                                  _buildRoleField(),

                                  _buildAadhaarField(),

                                  _buildPanField(),

                                  _buildLicenseField(),

                                  const SizedBox.shrink(),
                                ],
                              ),

                              const SizedBox(height: 12),

                              _buildAddressField(),

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
                          onPressed: () {
                            Navigator.pop(context);
                          },

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

  Widget _buildNameField() {
    return _formField(
      label: 'Name',

      controller: _nameController,

      hint: 'Enter Name',

      requiredField: true,
    );
  }

  Widget _buildPhoneField() {
    return _formField(
      label: 'Phone Number',

      controller: _phoneController,

      hint: 'Enter Phone Number',

      requiredField: true,

      keyboardType: TextInputType.phone,

      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,

        LengthLimitingTextInputFormatter(10),
      ],
    );
  }

  Widget _buildEmailField() {
    return _formField(
      label: 'Email',

      controller: _emailController,

      hint: 'Enter Email',

      requiredField: true,

      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildRoleField() {
    return DropdownButtonFormField<String>(
      value: _selectedRole,

      decoration: _inputDecoration(label: 'Role', hint: 'Select Role'),

      items: _roles.map((role) {
        return DropdownMenuItem<String>(value: role, child: Text(role));
      }).toList(),

      onChanged: (value) {
        setState(() {
          _selectedRole = value;
        });
      },

      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Role is required';
        }

        return null;
      },
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: _addressController,

      minLines: 3,

      maxLines: 4,

      textInputAction: TextInputAction.newline,

      decoration: _inputDecoration(
        label: 'Address',

        hint: 'Enter complete address',
      ),
    );
  }

  Widget _buildAadhaarField() {
    return _formField(
      label: 'Aadhaar Number',

      controller: _aadhaarController,

      hint: 'e.g. 123456789012',

      requiredField: false,

      keyboardType: TextInputType.number,

      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,

        LengthLimitingTextInputFormatter(12),
      ],
    );
  }

  Widget _buildPanField() {
    return _formField(
      label: 'PAN Card Number',

      controller: _panController,

      hint: 'e.g. ABCDE1234F',

      requiredField: false,

      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),

        LengthLimitingTextInputFormatter(10),

        _UpperCaseTextFormatter(),
      ],
    );
  }

  Widget _buildLicenseField() {
    return _formField(
      label: 'Driving License',

      controller: _licenseController,

      hint: 'e.g. AP0120230012345',

      requiredField: false,

      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9/-]')),

        LengthLimitingTextInputFormatter(20),

        _UpperCaseTextFormatter(),
      ],
    );
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
            'Upload an identity proof document (optional).',

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

      decoration: _inputDecoration(
        label: requiredField ? '$label *' : label,

        hint: hint,
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
          case 'Phone Number':
            if (!RegExp(r'^[06789][0-9]{9}$').hasMatch(text)) {
              return 'Enter 10 digits and start with 0, 6, 7, 8 or 9';
            }

            break;

          case 'Email':
            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
              return 'Enter a valid email';
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
              return 'Enter a valid PAN number';
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

  InputDecoration _inputDecoration({
    required String label,

    required String hint,
  }) {
    return InputDecoration(
      labelText: label,

      hintText: hint,

      labelStyle: const TextStyle(
        color: AppColors.textPrimary,

        fontSize: 12,

        fontWeight: FontWeight.w600,
      ),

      hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 12),

      filled: true,

      fillColor: AppColors.inputBackground,

      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),

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

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),

        borderSide: const BorderSide(color: AppColors.error),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),

        borderSide: const BorderSide(color: AppColors.error, width: 1.2),
      ),
    );
  }
}

class _OperatorPreviewDialog extends StatelessWidget {
  final OperatorModel operator;

  const _OperatorPreviewDialog({required this.operator});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 720),
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 22),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Operator Details',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'View operator information',
                            style: TextStyle(
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
                const SizedBox(height: 18),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 6, bottom: 4),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final fields = <Widget>[
                          _PreviewField(
                            label: 'ID',
                            value: operator.id.toString(),
                          ),
                          _PreviewField(label: 'Name', value: operator.name),
                          _PreviewField(
                            label: 'Phone Number',
                            value: operator.phoneNumber,
                          ),
                          _PreviewField(label: 'Email', value: operator.email),
                          _PreviewField(label: 'Role', value: operator.role),
                          _PreviewField(
                            label: 'Status',
                            value: operator.isActive ? 'Active' : 'Inactive',
                          ),
                          _PreviewField(
                            label: 'Address',
                            value: _previewValue(operator.address),
                          ),
                          _PreviewField(
                            label: 'Aadhaar Number',
                            value: _previewValue(operator.aadhaarNumber),
                          ),
                          _PreviewField(
                            label: 'PAN Card Number',
                            value: _previewValue(operator.panCardNumber),
                          ),
                          _PreviewField(
                            label: 'Driving License',
                            value: _previewValue(operator.drivingLicense),
                          ),
                          _PreviewField(
                            label: 'Identity Proof',
                            value: _previewValue(
                              operator.identityProofFilename,
                            ),
                          ),
                        ];
                        if (constraints.maxWidth < 560) {
                          return Column(children: _withSpacing(fields, 12));
                        }
                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 12,
                          childAspectRatio: 4.6,
                          children: fields,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
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
                      'Close',
                      style: TextStyle(fontWeight: FontWeight.w600),
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

  String _previewValue(String? value) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? 'Not provided' : text;
  }

  List<Widget> _withSpacing(List<Widget> widgets, double spacing) {
    final result = <Widget>[];
    for (var i = 0; i < widgets.length; i++) {
      result.add(widgets[i]);
      if (i != widgets.length - 1) result.add(SizedBox(height: spacing));
    }
    return result;
  }
}

class _PreviewField extends StatelessWidget {
  final String label;
  final String value;

  const _PreviewField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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

class _PreviewActionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _PreviewActionButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Preview',
      child: IconButton(
        onPressed: onPressed,
        icon: const Icon(
          Icons.visibility_outlined,
          size: 19,
          color: Colors.black,
        ),
        style: IconButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  final IconData icon;

  final String tooltip;

  final VoidCallback onPressed;

  const _IconActionButton({
    required this.icon,

    required this.tooltip,

    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,

      child: IconButton(
        onPressed: onPressed,

        icon: Icon(icon, size: 19, color: Colors.black),

        style: IconButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
          hoverColor: AppColors.primarySoft.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
      ),
    );
  }
}

class _MobileDetailRow extends StatelessWidget {
  final String label;

  final String value;

  const _MobileDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        SizedBox(
          width: 65,

          child: Text(
            label,

            style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),
        ),

        Expanded(
          child: Text(
            value,

            style: const TextStyle(
              fontSize: 13,

              color: AppColors.textPrimary,

              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
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

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: AppColors.surface,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: AppColors.borderLight),

        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),

            blurRadius: 18,

            offset: Offset(0, 6),
          ),
        ],
      ),

      child: child,
    );
  }
}

const TextStyle _headerStyle = TextStyle(
  fontSize: 12,

  fontWeight: FontWeight.w700,

  color: AppColors.textPrimary,
);

const TextStyle _bodyStyle = TextStyle(
  fontSize: 13,

  color: AppColors.textPrimary,

  fontWeight: FontWeight.w500,
);
