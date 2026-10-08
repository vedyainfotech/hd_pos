import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

import 'package:flutter/services.dart';

class KotSettingsScreen extends StatefulWidget {
  const KotSettingsScreen({super.key});

  @override
  State<KotSettingsScreen> createState() => _KotSettingsScreenState();
}

class _KotSettingsScreenState extends State<KotSettingsScreen> {
  // ─────────────────────────────────────────────
  // Controllers
  // ─────────────────────────────────────────────

  final TextEditingController _sequenceTypeController =
    TextEditingController(text: 'BILL');

  final TextEditingController _prefixController = TextEditingController(
    text: 'BILL',
  );

  final TextEditingController _currentNoController = TextEditingController(
    text: '45',
  );

  final TextEditingController _digitsController = TextEditingController(
    text: '1',
  );

  final TextEditingController _suffixController = TextEditingController(
    text: '2025',
  );

  final GlobalKey _numberFormatKey = GlobalKey();

  // ─────────────────────────────────────────────
  // Dropdown values
  // ─────────────────────────────────────────────


  String _selectedResetType = 'Financial Year';
  int? _editingSequenceIndex;


  final List<String> _resetTypes = [
    'Financial Year',
    'Continuous',
    'Daily',
    'Monthly',
  ];

  // ─────────────────────────────────────────────
  // Existing frontend sequence data
  // Backend will replace this later.
  // ─────────────────────────────────────────────

  final List<Map<String, dynamic>> _existingSequences = [
    {
      'type': 'KOT',
      'prefix': 'KOT',
      'currentNo': 136,
      'digits': 1,
      'suffix': '',
      'resetType': 'Financial Year',
      'lastResetKey': '2026-27',
    },
    {
      'type': 'BILL',
      'prefix': 'BILL',
      'currentNo': 45,
      'digits': 1,
      'suffix': '',
      'resetType': 'Financial Year',
      'lastResetKey': '2026-27',
    },
    {
      'type': 'PARCEL',
      'prefix': 'PARCEL',
      'currentNo': 24,
      'digits': 1,
      'suffix': '',
      'resetType': 'Financial Year',
      'lastResetKey': '2026-27',
    },
  ];

  // ─────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _prefixController.addListener(_updatePreview);
    _currentNoController.addListener(_updatePreview);
    _digitsController.addListener(_updatePreview);
    _suffixController.addListener(_updatePreview);
  }

  @override
  void dispose() {
    _prefixController.dispose();
    _currentNoController.dispose();
    _digitsController.dispose();
    _suffixController.dispose();
    _sequenceTypeController.dispose();

    super.dispose();
  }

  // ─────────────────────────────────────────────
  // Preview
  // ─────────────────────────────────────────────

  void _updatePreview() {
    setState(() {});
  }

  String get _financialYear {
    final now = DateTime.now();

    final int startYear = now.month >= 4 ? now.year : now.year - 1;

    final int endYear = startYear + 1;

    return 'FY $startYear - ${endYear.toString().substring(2)}';
  }

  int get _currentNumber {
    return int.tryParse(_currentNoController.text) ?? 0;
  }

  int get _digits {
    final value = int.tryParse(_digitsController.text) ?? 1;

    if (value < 1) return 1;
    if (value > 10) return 10;

    return value;
  }

  String get _nextNumber {
    final next = _currentNumber + 1;

    return next.toString().padLeft(_digits, '0');
  }

  String get _preview {
    return '${_prefixController.text}'
        '$_nextNumber'
        '${_suffixController.text}';
  }

  // ─────────────────────────────────────────────
  // Type change
  // ─────────────────────────────────────────────


  // ─────────────────────────────────────────────
  // Save
  // ─────────────────────────────────────────────

void _saveSettings() {
  FocusScope.of(context).unfocus();

  final String type = _sequenceTypeController.text.trim();

  if (type.isEmpty) {
    _showSuccessAlert('Please enter a sequence type');
    return;
  }

  final bool duplicateType = _existingSequences.asMap().entries.any(
  (entry) =>
      entry.key != (_editingSequenceIndex ?? -1) &&
      entry.value['type']?.toString().trim().toLowerCase() ==
          type.toLowerCase(),
);

if (duplicateType) {
  _showSuccessAlert(
    '$type sequence already exists',
  );
  return;
}

final String prefix = _prefixController.text.trim();
final String currentNoText = _currentNoController.text.trim();
final String digitsText = _digitsController.text.trim();

if (prefix.isEmpty) {
  _showSuccessAlert('Please enter a prefix');
  return;
}

if (currentNoText.isEmpty || int.tryParse(currentNoText) == null) {
  _showSuccessAlert('Please enter a valid current number');
  return;
}

final int currentNo = int.parse(currentNoText);

if (currentNo < 0) {
  _showSuccessAlert('Current number cannot be negative');
  return;
}

if (digitsText.isEmpty || int.tryParse(digitsText) == null) {
  _showSuccessAlert('Please enter valid digits');
  return;
}

final int digits = int.parse(digitsText);

if (digits < 1 || digits > 10) {
  _showSuccessAlert('Digits must be between 1 and 10');
  return;
}

  final int? editingIndex = _editingSequenceIndex;

  final Map<String, dynamic> updatedSequence = {
    'type': type,
    'prefix': _prefixController.text.trim(),
    'currentNo': currentNo,
'digits': digits,
    'suffix': _suffixController.text.trim(),
    'resetType': _selectedResetType,
    'lastResetKey': '2026-27',
  };

setState(() {
  if (editingIndex != null) {
    _existingSequences[editingIndex] = updatedSequence;
    _editingSequenceIndex = null;

    _sequenceTypeController.text = 'BILL';
    _prefixController.text = 'BILL';
    _currentNoController.text = '45';
    _digitsController.text = '1';
    _suffixController.text = '';
    _selectedResetType = 'Financial Year';
  } else {
    _existingSequences.add(updatedSequence);
  }
});

  _showSuccessAlert(
    editingIndex != null
        ? '$type sequence updated successfully'
        : '$type sequence saved successfully',
  );
}

 void _editSequence(Map<String, dynamic> sequence) {
  final int index = _existingSequences.indexOf(sequence);

  if (index == -1) return;

  setState(() {
    _editingSequenceIndex = index;

    _sequenceTypeController.text =
        sequence['type']?.toString() ?? '';

    _prefixController.text =
        sequence['prefix']?.toString() ?? '';

    _currentNoController.text =
        sequence['currentNo']?.toString() ?? '0';

    _digitsController.text =
        sequence['digits']?.toString() ?? '1';

    _suffixController.text =
        sequence['suffix']?.toString() ?? '';

    _selectedResetType =
        sequence['resetType']?.toString() ?? 'Financial Year';
  });

  final targetContext = _numberFormatKey.currentContext;

if (targetContext != null) {
  Scrollable.ensureVisible(
    targetContext,
    duration: const Duration(milliseconds: 400),
    curve: Curves.easeOut,
  );
}
}

  // ─────────────────────────────────────────────
  // Reset
  // ────────────────────────────────────────────

void _resetSettings() {
  setState(() {
    _editingSequenceIndex = null;

    _sequenceTypeController.text = 'BILL';
    _selectedResetType = 'Financial Year';

    _prefixController.text = 'BILL';
    _currentNoController.text = '45';
    _digitsController.text = '1';
    _suffixController.text = '';
  });
}

  // ─────────────────────────────────────────────
  // Success Alert
  // ─────────────────────────────────────────────

void _showSuccessAlert(String message) {
  final overlay = Overlay.of(context);

  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) {
      final width = MediaQuery.of(context).size.width;
      final bool isMobile = width < 600;

      return Positioned(
        top: 16,
        right: isMobile ? 12 : 20,
        left: isMobile ? 12 : null,
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isMobile ? double.infinity : 380,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F7EC),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF2E9B4F),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    },
  );

  overlay.insert(overlayEntry);

  Future.delayed(const Duration(seconds: 3), () {
    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
  });
}

  // ─────────────────────────────────────────────
  // Existing Sequences
  // ─────────────────────────────────────────────

  Widget _buildExistingSequences() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Existing Sequences',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Currently configured numbering sequences.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),

          const SizedBox(height: 18),

          LayoutBuilder(
            builder: (context, constraints) {
              final bool isDesktop = constraints.maxWidth >= 900;

              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _existingSequences
                      .map(
                        (sequence) => Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: sequence == _existingSequences.last
                                  ? 0
                                  : 12,
                            ),
                            child: _buildSequenceCard(sequence),
                          ),
                        ),
                      )
                      .toList(),
                );
              }

              return Column(
                children: _existingSequences
                    .map(
                      (sequence) => Padding(
                        padding: EdgeInsets.only(
                          bottom: sequence == _existingSequences.last ? 0 : 12,
                        ),
                        child: _buildSequenceCard(sequence),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSequenceCard(Map<String, dynamic> sequence) {
    final String type = sequence['type'];
    final String prefix = sequence['prefix'];
    final int currentNo = sequence['currentNo'];
    final int digits = sequence['digits'];
    final String resetType = sequence['resetType'];
    final String lastResetKey = sequence['lastResetKey'];

    final String nextNumber = (currentNo + 1).toString().padLeft(digits, '0');

    final String preview = '$prefix$nextNumber';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─────────────────────────
          // TYPE
          // ─────────────────────────

          Text(
            type,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 14),

          _sequenceDetail('Prefix', prefix),

          const SizedBox(height: 9),

          _sequenceDetail('Current Number', currentNo.toString()),

          const SizedBox(height: 9),

          _sequenceDetail('Digits', digits.toString()),

          const SizedBox(height: 9),

          _sequenceDetail('Reset Type', resetType),

          const SizedBox(height: 9),

          _sequenceDetail('Reset Key', lastResetKey),

          const SizedBox(height: 14),

          // ─────────────────────────
          // NEXT NUMBER
          // ─────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              children: [
                const Text(
                  'Next Number',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const Spacer(),

                Text(
                  preview,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton(
              onPressed: () {
                _editSequence(sequence);
              },
              child: const Text(
                'Edit',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sequenceDetail(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),

        title: const Text(
          'Number Sequences',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          final bool isMobile = width < 600;

          

   final double horizontalPadding = isMobile ? 12 : 24;

   final double contentWidth = double.infinity;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              24,
              horizontalPadding,
              32,
            ),

            child: Center(
              child: SizedBox(
                width: contentWidth,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    _buildHeader(),

                    const SizedBox(height: 24),

                    _buildNumberingCard(),

                    const SizedBox(height: 24),

                    _buildExistingSequences(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Header
  // ─────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: const Text(
        'Configure numbering sequences for different documents and orders.',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Main Numbering Card
  // ─────────────────────────────────────────────

  Widget _buildNumberingCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 1000;

        if (!isDesktop) {
          return _buildNumberFormatContent(showPreviewBelow: true);
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─────────────────────────────
              // LEFT - NUMBER FORMAT
              // ─────────────────────────────

              Expanded(
                flex: 6,
                child: _buildNumberFormatContent(showPreviewBelow: false),
              ),

              const SizedBox(width: 20),

              // ─────────────────────────────
              // RIGHT - PREVIEW
              // ─────────────────────────────
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    _buildPreview(),

                    const SizedBox(height: 14),

                    _buildFinancialYear(),

                    const SizedBox(height: 14),

                    _buildInformationCard(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNumberFormatContent({required bool showPreviewBelow}) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      key: _numberFormatKey,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Number Format',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),

          if (_editingSequenceIndex != null) ...[
            const SizedBox(height: 8),
            Text(
              'Editing ${_sequenceTypeController.text}',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          const SizedBox(height: 6),

          const Text(
            'Set the format and sequence rules for the selected document type.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),

          const SizedBox(height: 22),

          // ─────────────────────────────
          // ROW 1
          // ─────────────────────────────
          if (isMobile) ...[
            _buildTypeField(),

            const SizedBox(height: 18),

            _buildTextField(
              label: 'Prefix',
              hint: 'Example: KOT',
              controller: _prefixController,
            ),
          ] else
            Row(
              children: [
                Expanded(child: _buildTypeField()),

                const SizedBox(width: 16),

                Expanded(
                  child: _buildTextField(
                    label: 'Prefix',
                    hint: 'Example: KOT',
                    controller: _prefixController,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 18),

          // ─────────────────────────────
          // ROW 2
          // ─────────────────────────────
          Row(
            children: [
              Expanded(
                child:_buildTextField(
                label: 'Current Number',
                hint: 'Example: 136',
                controller: _currentNoController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child:_buildTextField(
                      label: 'Digits',
                      hint: 'Example: 1',
                      controller: _digitsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ─────────────────────────────
          // ROW 3
          // ─────────────────────────────
          if (isMobile) ...[
            _buildTextField(
              label: 'Suffix',
              hint: 'Example: 2026',
              controller: _suffixController,
            ),

            const SizedBox(height: 18),

            _buildResetType(),
          ] else
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Suffix',
                    hint: 'Example: 2026',
                    controller: _suffixController,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(child: _buildResetType()),
              ],
            ),

          const SizedBox(height: 22),

          // ─────────────────────────────
          // BUTTONS
          // ─────────────────────────────
          if (isMobile) ...[
            _buildSaveButton(),

            const SizedBox(height: 10),

            _buildResetButton(),
          ] else
            Row(
              children: [
                Expanded(child: _buildSaveButton()),

                const SizedBox(width: 12),

                Expanded(child: _buildResetButton()),
              ],
            ),

          if (showPreviewBelow) ...[
            const SizedBox(height: 20),

            _buildPreview(),

            const SizedBox(height: 14),

            _buildFinancialYear(),

            const SizedBox(height: 14),

            _buildInformationCard(),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Sequence Type
  // ─────────────────────────────────────────────

Widget _buildTypeField() {
  return _buildTextField(
    label: 'Sequence Type',
    hint: 'Example: KOT',
    controller: _sequenceTypeController,
  );
}

  // ─────────────────────────────────────────────
  // Text Field
  // ─────────────────────────────────────────────

Widget _buildTextField({
  required String label,
  required String hint,
  required TextEditingController controller,
  TextInputType keyboardType = TextInputType.text,
  List<TextInputFormatter>? inputFormatters,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      const SizedBox(height: 8),

      TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textInputAction: TextInputAction.next,
        decoration: _inputDecoration(hint: hint),
      ),
    ],
  );
}

  // ─────────────────────────────────────────────
  // Input Decoration
  // ─────────────────────────────────────────────

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,

      hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),

      filled: true,

      fillColor: AppColors.inputBackground,

      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),

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

        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Reset Type
  // ─────────────────────────────────────────────

  Widget _buildResetType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Text(
          'Reset Type',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 8),

        DropdownButtonFormField<String>(
          value: _selectedResetType,

          isExpanded: true,

          decoration: _inputDecoration(),

          items: _resetTypes.map((type) {
            return DropdownMenuItem<String>(value: type, child: Text(type));
          }).toList(),

          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _selectedResetType = value;
            });
          },
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Financial Year
  // ─────────────────────────────────────────────

  Widget _buildFinancialYear() {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,

        borderRadius: BorderRadius.circular(10),

        border: Border.all(color: AppColors.border),
      ),

      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'Current Financial Year',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),

                SizedBox(height: 3),

                Text(
                  'Numbering sequence belongs to this financial year',
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
                ),
              ],
            ),
          ),

          Text(
            _financialYear,

            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Preview
  // ─────────────────────────────────────────────

  Widget _buildPreview() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),

        color: AppColors.primarySoft,

        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.35),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Next Number',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),

          const SizedBox(height: 8),

          Text(
            _preview,

            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Preview only — numbering will be handled automatically.',
            style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Information Card
  // ─────────────────────────────────────────────

  Widget _buildInformationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sequence Information',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 6),

          Text(
            'Numbers increase sequentially. When Financial Year reset '
            'is selected, the sequence starts again from 1 at the '
            'beginning of each financial year.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Save Button
  // ─────────────────────────────────────────────

  Widget _buildSaveButton() {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: _saveSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          _editingSequenceIndex != null ? 'Update Sequence' : 'Save Sequence',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: _resetSettings,
        child: const Text(
          'Reset',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
