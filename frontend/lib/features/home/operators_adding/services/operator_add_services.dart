import '../models/operator_add_model.dart';

class OperatorAddService {
  OperatorAddService._();

  static final OperatorAddService instance = OperatorAddService._();

  final List<OperatorModel> _operators = [];

  List<OperatorModel> getOperators() {
    return List<OperatorModel>.from(_operators);
  }

  OperatorModel addOperator({
    required String name,
    required String phoneNumber,
    required String email,
    required String role,
    required String address,
    required String aadhaarNumber,
    required String panCardNumber,
    required String drivingLicense,
    String? identityProofFilename,
  }) {
    final nextId = _operators.isEmpty
        ? 1
        : _operators
                .map((operator) => operator.id)
                .reduce((a, b) => a > b ? a : b) +
            1;

    final operator = OperatorModel(
      id: nextId,
      name: name,
      phoneNumber: phoneNumber,
      email: email,
      role: role,
      address: address,
      aadhaarNumber: aadhaarNumber,
      panCardNumber: panCardNumber,
      drivingLicense: drivingLicense,
      identityProofFilename: identityProofFilename,
      isActive: true,
    );

    _operators.add(operator);

    return operator;
  }

  OperatorModel updateOperator({
    required int id,
    required String name,
    required String phoneNumber,
    required String email,
    required String role,
    required String address,
    required String aadhaarNumber,
    required String panCardNumber,
    required String drivingLicense,
    String? identityProofFilename,
  }) {
    final index = _operators.indexWhere(
      (operator) => operator.id == id,
    );

    if (index == -1) {
      throw Exception('Operator not found');
    }

    final current = _operators[index];

    final updatedOperator = current.copyWith(
      name: name,
      phoneNumber: phoneNumber,
      email: email,
      role: role,
      address: address,
      aadhaarNumber: aadhaarNumber,
      panCardNumber: panCardNumber,
      drivingLicense: drivingLicense,
      identityProofFilename:
          identityProofFilename ?? current.identityProofFilename,
    );

    _operators[index] = updatedOperator;

    return updatedOperator;
  }

  OperatorModel toggleStatus(int id) {
    final index = _operators.indexWhere(
      (operator) => operator.id == id,
    );

    if (index == -1) {
      throw Exception('Operator not found');
    }

    final updatedOperator = _operators[index].copyWith(
      isActive: !_operators[index].isActive,
    );

    _operators[index] = updatedOperator;

    return updatedOperator;
  }
}