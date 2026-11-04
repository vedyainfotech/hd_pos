class UnitModel {
  final int id;
  final String name;
  final bool status;

  const UnitModel({
    required this.id,
    required this.name,
    required this.status,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'] as int,
      name: json['name'] as String,
      status: json['status'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
    };
  }
}