import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/business_profile_models.dart';
import '../services/business_profile_services.dart';

class _FirstDigitInputFormatter extends TextInputFormatter {
  _FirstDigitInputFormatter(this.allowedFirstDigits);
  final String allowedFirstDigits;
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    if (!allowedFirstDigits.contains(newValue.text[0])) return oldValue;
    return newValue;
  }
}

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _formScrollController = ScrollController();

  final _restaurant = TextEditingController();
  final _owner = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _telephone = TextEditingController();
  final _address = TextEditingController();
  final _stateText = TextEditingController();
  final _city = TextEditingController();
  final _pin = TextEditingController();
  final _fssai = TextEditingController();
  final _gstin = TextEditingController();
  final _pan = TextEditingController();

  static const _primary = Color(0xFF9A3F0B);
  static const _primaryDark = Color(0xFF7A2F08);
  static const _canvas = Color(0xFFFAF8F5);
  static const _soft = Color(0xFFF7E8DE);
  static const _border = Color(0xFFE3D9D1);
  static const _ink = Color(0xFF2D241F);
  static const _muted = Color(0xFF6F625A);
  static const _danger = Color(0xFFB42318);
  static const _success = Color(0xFF247443);

  static const _businessTypes = [
    'Restaurant', 'Cloud Kitchen', 'Home Kitchen',
    'Catering', 'Food Delivery', 'Other',
  ];

  static const _countries = [
    'India', 'United States', 'United Kingdom',
    'United Arab Emirates', 'Australia', 'Canada',
    'Singapore', 'Other',
  ];

  static const _indianStates = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar',
    'Chhattisgarh', 'Goa', 'Gujarat', 'Haryana',
    'Himachal Pradesh', 'Jharkhand', 'Karnataka', 'Kerala',
    'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya',
    'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan',
    'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura',
    'Uttar Pradesh', 'Uttarakhand', 'West Bengal', 'Delhi',
    'Jammu and Kashmir', 'Ladakh', 'Puducherry',
  ];

  String _businessType = '';
  String _country = 'India';
  String _openingTime = '';
  String _closingTime = '';
  DateTime? _fssaiExpiry;

  bool _hasBranches = false;
  bool _gstRegistered = false;
  bool _loading = false;
  bool _saving = false;
  bool _branchLoading = false;

  String? _statusMessage;
  bool _statusIsError = false;
  String? _branchError;
  OverlayEntry? _toastEntry;
  Timer? _toastTimer;

  int? _branchId;
  List<BusinessBranchModel> _branches = [];

  PlatformFile? _logo;
  PlatformFile? _fssaiDocument;
  PlatformFile? _gstDocument;
  PlatformFile? _panDocument;

  String? _existingLogoName;
  String? _existingFssaiName;
  String? _existingGstName;
  String? _existingPanName;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _restaurant.dispose();
    _owner.dispose();
    _email.dispose();
    _phone.dispose();
    _telephone.dispose();
    _address.dispose();
    _stateText.dispose();
    _city.dispose();
    _pin.dispose();
    _fssai.dispose();
    _gstin.dispose();
    _pan.dispose();
    _toastTimer?.cancel();
    _toastEntry?.remove();
    _formScrollController.dispose();
    super.dispose();
  }

  void _status(String message, {bool error = false}) {
    if (!mounted) return;
    _toastTimer?.cancel();
    _toastEntry?.remove();
    final overlay = Overlay.of(context);
    _toastEntry = OverlayEntry(builder: (context) {
      final color = error ? _danger : _success;
      return Positioned(
        top: 16, right: 20,
        child: Material(
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: error ? const Color(0xFFFFEFEE) : const Color(0xFFEAF7EE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(.35)),
                boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 16)],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(error ? Icons.error_outline : Icons.check_circle_outline, color: color),
                const SizedBox(width: 10),
                Flexible(child: Text(message, style: TextStyle(color: color, fontWeight: FontWeight.w600))),
                IconButton(onPressed: () { _toastTimer?.cancel(); _toastEntry?.remove(); _toastEntry = null; }, icon: Icon(Icons.close, color: color, size: 18)),
              ]),
            ),
          ),
        ),
      );
    });
    overlay.insert(_toastEntry!);
    _toastTimer = Timer(const Duration(seconds: 4), () {
      _toastEntry?.remove();
      _toastEntry = null;
    });
  }

  Future<void> _loadProfile() async {
    if (mounted) setState(() => _loading = true);
    try {
      final profile = await BusinessProfileService.getProfile();
      if (!mounted) return;

      if (profile != null) {
        setState(() {
          _restaurant.text = profile.restaurantName;
          _owner.text = profile.ownerFullName;
          _email.text = profile.email;
          _phone.text = profile.phoneNumber;
          _telephone.text = profile.telephoneNumber;
          _address.text = profile.address;
          _stateText.text = profile.state;
          _city.text = profile.city;
          _pin.text = profile.pinCode;
          _fssai.text = profile.fssaiNumber;
          _gstin.text = profile.gstin;
          _pan.text = profile.panNumber;
          _businessType = profile.businessType;
          _country = _countries.contains(profile.country)
              ? profile.country : 'Other';
          _hasBranches = profile.hasBranches;
          _branchId = profile.selectedBranchId;
          _openingTime = profile.openingTime;
          _closingTime = profile.closingTime;
          _gstRegistered = profile.gstRegistered;
          _fssaiExpiry = DateTime.tryParse(profile.fssaiExpiryDate);
          _existingLogoName = profile.logoFileName;
          _existingFssaiName = profile.fssaiDocumentName;
          _existingGstName = profile.gstDocumentName;
          _existingPanName = profile.panDocumentName;
        });
        if (_hasBranches) await _loadBranches(showError: false);
      }
    } catch (e) {
      // A missing/unavailable profile API must never hide the blank form.
      if (mounted) {
        _status(
          'Saved profile could not be loaded. You can still fill in the form. '
          'Backend: $e',
          error: true,
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadBranches({bool showError = true}) async {
    if (!mounted) return;
    setState(() {
      _branchLoading = true;
      _branchError = null;
    });
    try {
      final branches = await BusinessProfileService.getBranches();
      if (!mounted) return;
      setState(() {
        _branches = branches;
        if (!_branches.any((b) => b.id == _branchId)) _branchId = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _branches = [];
        _branchId = null;
        _branchError = 'No registered branches are available. Register a branch first, or choose No.';
      });
      if (showError) _status('Registered branches are currently unavailable. You can continue without selecting a branch.', error: true);
    } finally {
      if (mounted) setState(() => _branchLoading = false);
    }
  }

  String? _required(String? value, String label) =>
      value == null || value.trim().isEmpty ? '$label is required.' : null;

  String? _businessNameValidator(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Business name is required.';
    if (v.length > 50) return 'Maximum 50 characters allowed.';
    return null;
  }

  String? _cityValidator(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'City is required.';
    if (!RegExp(r'^[A-Za-z0-9]').hasMatch(v)) {
      return 'City must start with a letter or number.';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email address is required.';
    return RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
            .hasMatch(v)
        ? null : 'Enter a valid email address.';
  }

  String? _phoneValidator(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Mobile number is required.';
    return RegExp(r'^[6-9]\d{9}$').hasMatch(v)
        ? null : 'Enter a valid 10-digit Indian mobile number.';
  }

  String? _telephoneValidator(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    return RegExp(r'^[06789][0-9]{10}$').hasMatch(v)
        ? null : 'Enter exactly 11 digits starting with 0, 6, 7, 8 or 9.';
  }

  String? _pinValidator(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Postal code is required.';
    if (_country == 'India' && !RegExp(r'^\d{6}$').hasMatch(v)) {
      return 'Enter a valid 6-digit Indian PIN code.';
    }
    return null;
  }

  String? _gstinValidator(String? value) {
    if (!_gstRegistered) return null;
    final v = value?.trim().toUpperCase() ?? '';
    if (v.isEmpty) return 'GSTIN is required.';
    return RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$')
            .hasMatch(v)
        ? null : 'Enter a valid 15-character GSTIN.';
  }

  String? _panValidator(String? value) {
    final v = value?.trim().toUpperCase() ?? '';
    if (v.isEmpty) return null;
    return RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(v)
        ? null : 'Enter a valid PAN number.';
  }

  String? _identityError() {
    if (_pan.text.trim().isEmpty) {
      return 'PAN number is required.';
    }
    if (_panValidator(_pan.text) != null) return 'Correct the PAN number.';
    return null;
  }

  Future<void> _pickFile(String type) async {
    try {
     final result = await FilePicker.pickFiles(
  type: type == 'logo' ? FileType.image : FileType.custom,
  allowedExtensions: type == 'logo'
      ? null
      : ['pdf', 'jpg', 'jpeg', 'png'],
);
      if (!mounted || result.isEmpty) return;
      final file = result.first;
      setState(() {
        switch (type) {
          case 'logo': _logo = file; break;
          case 'fssai': _fssaiDocument = file; break;
          case 'gst': _gstDocument = file; break;
          case 'pan': _panDocument = file; break;
        }
        _statusMessage = null;
      });
      _formKey.currentState?.validate();
    } catch (e) {
      _status('Unable to select file: $e', error: true);
    }
  }

  void _removeFile(String type) {
    setState(() {
      switch (type) {
        case 'logo': _logo = null; _existingLogoName = null; break;
        case 'fssai': _fssaiDocument = null; _existingFssaiName = null; break;
        case 'gst': _gstDocument = null; _existingGstName = null; break;
        case 'pan': _panDocument = null; _existingPanName = null; break;
      }
    });
  }

  TimeOfDay _parseTime(String value) {
    final p = value.split(':');
    if (p.length != 2) return const TimeOfDay(hour: 9, minute: 0);
    final h = int.tryParse(p[0]) ?? 9;
    final m = int.tryParse(p[1]) ?? 0;
    if (h < 0 || h > 23 || m < 0 || m > 59) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
    return TimeOfDay(hour: h, minute: m);
  }

  Future<void> _chooseTime(bool opening) async {
    final current = opening ? _openingTime : _closingTime;
    final selected = await showTimePicker(
      context: context,
      initialTime: _parseTime(current),
    );
    if (!mounted || selected == null) return;
    final value = '${selected.hour.toString().padLeft(2, '0')}:'
        '${selected.minute.toString().padLeft(2, '0')}';
    setState(() {
      if (opening) {
        _openingTime = value;
      } else {
        _closingTime = value;
      }
      _statusMessage = null;
    });
  }

  Future<void> _chooseExpiry() async {
    final today = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _fssaiExpiry != null &&
              !_fssaiExpiry!.isBefore(DateTime(today.year, today.month, today.day))
          ? _fssaiExpiry! : today,
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: DateTime(today.year + 30),
      helpText: 'Select FSSAI expiry date',
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      
    );
    if (!mounted || selected == null) return;
    setState(() {
      _fssaiExpiry = selected;
      _statusMessage = null;
    });
  }

  String _apiDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  String _displayDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';

  bool _validateExtra() {
    if (_businessType.isEmpty) {
      _status('Please select a business type.', error: true); return false;
    }
    if (_stateText.text.trim().isEmpty) {
      _status('Please select or enter your state.', error: true); return false;
    }
    if (_openingTime.isEmpty || _closingTime.isEmpty) {
      _status('Please select opening and closing times.', error: true);
      return false;
    }
    if (_openingTime == _closingTime) {
      _status('Opening and closing times cannot be identical.', error: true);
      return false;
    }
    if (_fssaiExpiry == null) {
      _status('Please select the FSSAI expiry date.', error: true);
      return false;
    }
    if (_hasBranches) {
      if (_branchLoading) {
        _status('Please wait while branches are loading.', error: true);
        return false;
      }
      if (_branches.isEmpty || _branchId == null ||
          !_branches.any((b) => b.id == _branchId)) {
        _status('Please select a registered branch.', error: true);
        return false;
      }
    }
    final identityError = _identityError();
    if (identityError != null) {
      _status(identityError, error: true); return false;
    }
    if (_fssaiDocument == null &&
        (_existingFssaiName == null || _existingFssaiName!.isEmpty)) {
      _status('Please attach the FSSAI license document.', error: true);
      return false;
    }
    if (_gstRegistered && _gstDocument == null &&
        (_existingGstName == null || _existingGstName!.isEmpty)) {
      _status('Please attach the GST registration document.', error: true);
      return false;
    }
    if (_pan.text.trim().isNotEmpty && _panDocument == null &&
        (_existingPanName == null || _existingPanName!.isEmpty)) {
      _status('Please attach the PAN document.', error: true); return false;
    }
    return true;
  }

  Future<void> _submitProfile() async {
    if (_saving) return;
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      _status('Please correct the highlighted fields.', error: true);
      return;
    }
    if (!_validateExtra()) return;

    final expiry = _fssaiExpiry!;
    final profile = BusinessProfileModel(
      restaurantName: _restaurant.text.trim(),
      businessType: _businessType,
      email: _email.text.trim(),
      phoneNumber: _phone.text.trim(),
      telephoneNumber: _telephone.text.trim(),
      ownerFullName: _owner.text.trim(),
      address: _address.text.trim(),
      country: _country,
      state: _stateText.text.trim(),
      city: _city.text.trim(),
      pinCode: _pin.text.trim(),
      hasBranches: _hasBranches,
      selectedBranchId: _hasBranches ? _branchId : null,
      openingTime: _openingTime,
      closingTime: _closingTime,
      fssaiNumber: _fssai.text.trim(),
      fssaiExpiryDate: _apiDate(expiry),
      gstRegistered: _gstRegistered,
      gstin: _gstRegistered ? _gstin.text.trim().toUpperCase() : '',
      panNumber: _pan.text.trim().toUpperCase(),
      aadhaarNumber: '',
      logoFileName: _logo?.name ?? _existingLogoName,
      fssaiDocumentName: _fssaiDocument?.name ?? _existingFssaiName,
      gstDocumentName: _gstDocument?.name ?? _existingGstName,
      panDocumentName: _panDocument?.name ?? _existingPanName,
      aadhaarDocumentName: null,
    );

    setState(() {
      _saving = true;
      _statusMessage = 'Saving Business Profile...';
      _statusIsError = false;
    });
    try {
      final saved = await BusinessProfileService.saveProfile(
        profile,
        logo: _logo,
        fssaiDocument: _fssaiDocument,
        gstDocument: _gstDocument,
        panDocument: _panDocument,
      );
      if (!mounted) return;
      setState(() {
        _existingLogoName = saved.logoFileName ?? profile.logoFileName;
        _existingFssaiName =
            saved.fssaiDocumentName ?? profile.fssaiDocumentName;
        _existingGstName = saved.gstDocumentName ?? profile.gstDocumentName;
        _existingPanName = saved.panDocumentName ?? profile.panDocumentName;
        _logo = null;
        _fssaiDocument = null;
        _gstDocument = null;
        _panDocument = null;
        _statusMessage = 'Business Profile saved successfully.';
        _statusIsError = false;
      });
      _status('Business Profile saved successfully.');
    } catch (e) {
      if (mounted) _status('Could not save Business Profile: $e', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveProfile() async {
    if (_saving) return;
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      _status('Please correct the highlighted fields.', error: true);
      _focusFirstInvalidField();
      return;
    }
    if (!_validateExtra()) {
      _focusFirstInvalidField();
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Preview Business Profile'),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _previewRow('Business', _restaurant.text),
              _previewRow('Business type', _businessType),
              _previewRow('Owner', _owner.text),
              _previewRow('Email', _email.text),
              _previewRow('Mobile', _phone.text),
              _previewRow('Telephone', _telephone.text.isEmpty ? '—' : _telephone.text),
              _previewRow('Address', '${_address.text}, ${_city.text}, ${_stateText.text}, $_country - ${_pin.text}'),
              _previewRow('Branch', !_hasBranches ? 'No branch selected' : (_branchNameForPreview())),
              _previewRow('Timings', '$_openingTime - $_closingTime'),
              _previewRow('FSSAI', _fssai.text),
              _previewRow('FSSAI expiry', _fssaiExpiry == null ? '—' : _displayDate(_fssaiExpiry!)),
              _previewRow('GST', _gstRegistered ? _gstin.text : 'Not registered'),
              _previewRow('PAN', _pan.text),
              _previewRow('Logo', _logo?.name ?? _existingLogoName ?? 'Not attached'),
              _previewRow('FSSAI document', _fssaiDocument?.name ?? _existingFssaiName ?? 'Not attached'),
            ],
          )),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Submit Profile')),
        ],
      ),
    );
    if (confirmed == true && mounted) await _submitProfile();
  }

  String _branchNameForPreview() {
    for (final branch in _branches) {
      if (branch.id == _branchId) return branch.name;
    }
    return 'Not selected';
  }

  Widget _previewRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 125, child: Text(label, style: const TextStyle(color: _muted, fontWeight: FontWeight.w600))),
      Expanded(child: Text(value.isEmpty ? '—' : value)),
    ]),
  );

  void _focusFirstInvalidField() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_formScrollController.hasClients) return;
      _formScrollController.animateTo(
        _formScrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 250), curve: Curves.easeOut,
      );
    });
  }

  InputDecoration _decoration(String label, {bool required = false,
      String? hint, Widget? prefix}) {
    return InputDecoration(
      labelText: required ? '$label *' : label,
      hintText: hint,
      prefixIcon: prefix,
      filled: true,
      fillColor: _canvas,
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _danger, width: 1.5),
      ),
    );
  }

  Widget _textField(TextEditingController controller, String label, {
    bool required = false,
    String? hint,
    TextInputType? keyboard,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
    TextCapitalization capitalization = TextCapitalization.words,
    List<TextInputFormatter>? formatters,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      maxLength: maxLength,
      textCapitalization: capitalization,
      inputFormatters: formatters,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      onChanged: onChanged,
      decoration: _decoration(label, required: required, hint: hint),
    );
  }

  Widget _dropdown(String label, String? value, List<String> options,
      ValueChanged<String?> onChanged, {bool required = false}) {
    return DropdownButtonFormField<String>(
      key: ValueKey('$label-$value-${options.length}'),
      initialValue: options.contains(value) ? value : null,
      isExpanded: true,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: _decoration(label, required: required),
      items: options.map((v) =>
          DropdownMenuItem<String>(value: v, child: Text(v,
              overflow: TextOverflow.ellipsis))).toList(),
      validator: required
          ? (v) => v == null ? 'Select $label.' : null
          : null,
      onChanged: onChanged,
    );
  }

  Widget _yesNo(String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _canvas,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: LayoutBuilder(builder: (context, c) {
        final selector = SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('Yes')),
            ButtonSegment(value: false, label: Text('No')),
          ],
          selected: {value},
          onSelectionChanged: (s) => onChanged(s.first),
          showSelectedIcon: false,
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
        );
        if (c.maxWidth < 340) {
          return Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(title), const SizedBox(height: 10), selector]);
        }
        return Row(children: [
          Expanded(child: Text(title,
              style: const TextStyle(color: _ink, fontWeight: FontWeight.w500))),
          selector,
        ]);
      }),
    );
  }

  Widget _fileField(String label, String type, PlatformFile? selected,
      String? existing, {bool required = false}) {
    final name = selected?.name ??
        ((existing?.isNotEmpty ?? false) ? existing : null);
    return InkWell(
      onTap: () => _pickFile(type),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 68),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _canvas,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: Row(children: [
          Icon(name == null ? Icons.attach_file : Icons.check_circle_outline,
              color: name == null ? _muted : _success),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(required ? '$label *' : label,
                  style: const TextStyle(color: _muted, fontSize: 12)),
              const SizedBox(height: 3),
              Text(name ?? 'No file selected',
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _ink, fontSize: 13)),
            ],
          )),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => _pickFile(type),
            child: Text(name == null ? 'Choose' : 'Change'),
          ),
          if (name != null)
            TextButton(
              onPressed: () => _removeFile(type),
              style: TextButton.styleFrom(foregroundColor: _danger),
              child: const Text('Remove'),
            ),
        ]),
      ),
    );
  }

  Widget _timeField(String label, bool opening) {
    final value = opening ? _openingTime : _closingTime;
    return InkWell(
      onTap: () => _chooseTime(opening),
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: _decoration(label, required: true),
        child: Row(children: [
          Expanded(child: Text(value.isEmpty ? 'Select time' : value,
              style: TextStyle(color: value.isEmpty ? _muted : _ink))),
          const Icon(Icons.access_time, color: _primary),
        ]),
      ),
    );
  }

  Widget _expiryField() {
    return InkWell(
      onTap: _chooseExpiry,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: _decoration('FSSAI Expiry Date', required: true),
        child: Row(children: [
          Expanded(child: Text(
            _fssaiExpiry == null
                ? 'Select expiry date' : _displayDate(_fssaiExpiry!),
            style: TextStyle(color: _fssaiExpiry == null ? _muted : _ink),
          )),
          const Icon(Icons.calendar_month_outlined, color: _primary),
        ]),
      ),
    );
  }

  Widget _branchField() {
    return DropdownButtonFormField<int>(
      key: ValueKey('branch-$_branchId-${_branches.length}'),
      initialValue: _branches.any((b) => b.id == _branchId) ? _branchId : null,
      isExpanded: true,
      decoration: _decoration('Select Registered Branch', required: true),
      items: _branches.map((b) {
        final address = b.address?.trim() ?? '';
        return DropdownMenuItem<int>(
          value: b.id,
          child: Text(address.isEmpty ? b.name : '${b.name} — $address',
              overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      validator: (v) => _hasBranches && v == null
          ? 'Select a registered branch.' : null,
      onChanged: (v) => setState(() => _branchId = v),
    );
  }

  Widget _section({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> fields,
    required bool desktop,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000),
              blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
                color: _soft, borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, color: _primary),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: _ink)),
              const SizedBox(height: 3),
              Text(subtitle, style: const TextStyle(
                  fontSize: 12, color: _muted)),
            ],
          )),
        ]),
        const SizedBox(height: 14),
        LayoutBuilder(builder: (context, c) {
          final twoColumns = desktop && c.maxWidth >= 650;
          final gap = 12.0;
          final width = twoColumns ? (c.maxWidth - gap) / 2 : c.maxWidth;
          return Wrap(
            spacing: gap,
            runSpacing: 12,
            children: fields.map((f) => SizedBox(width: width, child: f))
                .toList(),
          );
        }),
      ]),
    );
  }

  Widget _intro() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          color: _soft, borderRadius: BorderRadius.circular(18)),
      child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.business_outlined, color: _primary, size: 26),
        SizedBox(width: 11),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Set up your business profile', style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: _ink)),
            SizedBox(height: 3),
            Text(
              'Complete your restaurant details, contact information, address, '
              'operating hours and registration details. Fields marked * are required.',
              style: TextStyle(fontSize: 12, height: 1.35, color: _muted),
            ),
          ],
        )),
      ]),
    );
  }

  Widget _formContent(bool desktop) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_loading) const LinearProgressIndicator(minHeight: 3),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _border), boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 3))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _section(
            title: 'Business Information',
            subtitle: 'Restaurant identity and ownership details',
            icon: Icons.storefront_outlined,
            desktop: desktop,
            fields: [
              _textField(_restaurant, 'Restaurant / Business Name',
                  required: true, hint: 'e.g. Vedya Home Kitchen',
                  maxLength: 50,
                  validator: _businessNameValidator),
              _fileField('Business Logo', 'logo', _logo, _existingLogoName),
              _dropdown('Business Type',
                  _businessType.isEmpty ? null : _businessType,
                  _businessTypes, (v) => setState(() => _businessType = v ?? ''),
                  required: true),
              _textField(_owner, 'Owner Full Name', required: true,
                  hint: 'e.g. Shyam Kumar', validator: (v) => _required(v, 'Owner name')),
            ],
          ),
          const SizedBox(height: 12),
          _section(
            title: 'Contact Information',
            subtitle: 'Contact details for your business',
            icon: Icons.contact_phone_outlined,
            desktop: desktop,
            fields: [
              _textField(_email, 'Email Address', required: true, hint: 'e.g. name@example.com',
                  keyboard: TextInputType.emailAddress,
                  capitalization: TextCapitalization.none,
                  validator: _emailValidator),
              _textField(_phone, 'Primary Mobile Number', required: true, hint: 'e.g. 9876543210',
                  keyboard: TextInputType.phone, maxLength: 10,
                  formatters: [FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                    _FirstDigitInputFormatter('6789')],
                  validator: _phoneValidator),
              _textField(_telephone, 'Telephone Number', hint: 'e.g. 08912345678',
                  keyboard: TextInputType.phone, maxLength: 11,
                  formatters: [FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11)],
                  validator: _telephoneValidator),
            ],
          ),
          const SizedBox(height: 12),
          _section(
            title: 'Business Address',
            subtitle: 'Registered location of your business',
            icon: Icons.location_on_outlined,
            desktop: desktop,
            fields: [
              _textField(_address, 'Complete Address', required: true,
                  hint: 'e.g. Door No. 12-34, MVP Colony', maxLines: 2, validator: (v) => _required(v, 'Address')),
              _dropdown('Country', _country, _countries, (v) {
                setState(() {
                  _country = v ?? 'India';
                  _stateText.clear();
                });
              }, required: true),
              if (_country == 'India')
                _dropdown('State', _stateText.text.isEmpty ? null : _stateText.text,
                    _indianStates,
                    (v) => setState(() => _stateText.text = v ?? ''),
                    required: true)
              else
                _textField(_stateText, 'State / Province', required: true,
                    hint: 'e.g. Andhra Pradesh', validator: (v) => _required(v, 'State')),
              _textField(_city, 'City', required: true, hint: 'e.g. Visakhapatnam',
                  validator: _cityValidator),
              _textField(_pin, 'PIN / Postal Code', required: true,
                  hint: _country == 'India' ? 'e.g. 530016' : 'Enter postal code',
                  keyboard: TextInputType.number,
                  maxLength: _country == 'India' ? 6 : 12,
                  formatters: [FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(_country == 'India' ? 6 : 12)],
                  validator: _pinValidator),
            ],
          ),
          const SizedBox(height: 12),
          _section(
            title: 'Branch Configuration',
            subtitle: 'Connect this profile to a registered branch',
            icon: Icons.account_tree_outlined,
            desktop: desktop,
            fields: [
              _yesNo('Do you have an existing branch?', _hasBranches, (v) {
                setState(() {
                  _hasBranches = v;
                  _branchId = null;
                  _branchError = null;
                });
                if (v) _loadBranches();
              }),
              if (_hasBranches)
                if (_branchLoading)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: LinearProgressIndicator(),
                  )
                else if (_branches.isNotEmpty)
                  _branchField()
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF5E8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(_branchError ??
                        'No registered branches found. Please register a branch first.',
                        style: const TextStyle(color: _ink, fontSize: 12)),
                  ),
            ],
          ),
          const SizedBox(height: 12),
          _section(
            title: 'Business Timings',
            subtitle: 'Set your regular operating hours',
            icon: Icons.schedule_outlined,
            desktop: desktop,
            fields: [
              _timeField('Opening Time', true),
              _timeField('Closing Time', false),
            ],
          ),
          const SizedBox(height: 12),
          _section(
            title: 'Food Safety & Tax Registration',
            subtitle: 'FSSAI and GST registration information',
            icon: Icons.verified_user_outlined,
            desktop: desktop,
            fields: [
              _textField(_fssai, 'FSSAI License Number', required: true, hint: 'e.g. 10012345678901',
                  capitalization: TextCapitalization.characters,
                  maxLength: 50,
                  validator: (v) {
                    final e = _required(v, 'FSSAI number');
                    if (e != null) return e;
                    return (v ?? '').trim().length > 50
                        ? 'Maximum 50 characters allowed.' : null;
                  }),
              _expiryField(),
              _yesNo('Is your business GST registered?', _gstRegistered, (v) {
                setState(() {
                  _gstRegistered = v;
                  if (!v) _gstin.clear();
                });
              }),
              if (_gstRegistered) ...[
                _textField(_gstin, 'GSTIN', required: true,
                    hint: 'e.g. 37ABCDE1234F1Z5',
                    capitalization: TextCapitalization.characters,
                    validator: _gstinValidator),
                _fileField('GST Registration Document', 'gst', _gstDocument,
                    _existingGstName, required: true),
              ],
              _fileField('FSSAI License Document', 'fssai', _fssaiDocument,   
              
                  _existingFssaiName, required: true),
            ],
          ),

          const SizedBox(height: 12),
          _section(
            title: 'Identity Verification',
            subtitle: 'Enter your PAN details for identity verification.',
            icon: Icons.badge_outlined,
            desktop: desktop,
            fields: [
              _textField(_pan, 'PAN Number', required: true, hint: 'e.g. ABCDE1234F',
                  capitalization: TextCapitalization.characters,
                  validator: _panValidator, onChanged: (_) => setState(() {})),
              _fileField('PAN Document', 'pan', _panDocument, _existingPanName),
              Builder(builder: (context) {
                final error = _identityError();
                return Text(error ??
                    'At least one identity number must be provided.',
                    style: TextStyle(
                        color: error == null ? _muted : _danger, fontSize: 12));
              }),
            ],
          ),
            ]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        toolbarHeight: 52,
        titleSpacing: 2,
        leadingWidth: 48,
        title: const Text('Business Profile',
            style: TextStyle(fontSize: 17, color: _ink, fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: _ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),

      // Keep the scrollable form and bottom actions as siblings in a Column.
      // This makes the available height explicit and avoids a loose body layout.
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 2),
              child: Center(

                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1560),
                  child: _intro(),
                ),
              ),
            ),
            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                final desktop = constraints.maxWidth >= 900;
                final horizontal = constraints.maxWidth < 600 ? 12.0 : 18.0;
               return Scrollbar(
  controller: _formScrollController,
  thumbVisibility: true,
  child: SingleChildScrollView(
    controller: _formScrollController,
    keyboardDismissBehavior:
        ScrollViewKeyboardDismissBehavior.onDrag,
    padding: EdgeInsets.fromLTRB(horizontal, 10, horizontal, 18),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1560),
        child: _formContent(desktop),
      ),
    ),
  ),
);
              }),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
              decoration: const BoxDecoration(
                color: _canvas,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1560),
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: _saving
                            ? null : () => Navigator.maybePop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _primary,
                          side: const BorderSide(color: _primary),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        child: const Text('Cancel'),
                      ),
                      FilledButton.icon(
                        onPressed: _saving ? null : _saveProfile,
                        icon: _saving
                            ? const SizedBox(
                                width: 17, height: 17,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(_saving ? 'Saving...' : 'Save Profile'),
                        style: FilledButton.styleFrom(
                          backgroundColor: _primaryDark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
