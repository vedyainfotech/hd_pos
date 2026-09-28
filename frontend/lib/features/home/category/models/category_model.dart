class CategoryModel {
  final int id;
  final String name;
  final String allotmentTime;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.name,
    required this.allotmentTime,
    required this.isActive,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      allotmentTime: json['allotment_time'] as String,
      isActive: json['status'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'allotment_time': allotmentTime,
      'status': isActive,
    };
  }
}