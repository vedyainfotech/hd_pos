class DeliveryScheduleModel {
  final DateTime date;

  /// Key = category ID
  /// Value = delivery person IDs assigned to that category.
  final Map<int, List<int>> assignments;

  const DeliveryScheduleModel({required this.date, required this.assignments});

  DeliveryScheduleModel copyWith({
    DateTime? date,
    Map<int, List<int>>? assignments,
  }) {
    return DeliveryScheduleModel(
      date: date ?? this.date,
      assignments: assignments ?? _copyAssignments(this.assignments),
    );
  }

  static Map<int, List<int>> _copyAssignments(Map<int, List<int>> source) {
    return source.map((key, value) => MapEntry(key, List<int>.from(value)));
  }
}

class DeliveryScheduleResources {
  final List<dynamic> categories;
  final List<dynamic> deliveryPersons;

  const DeliveryScheduleResources({
    required this.categories,
    required this.deliveryPersons,
  });
}
