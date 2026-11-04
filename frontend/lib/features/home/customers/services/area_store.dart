class AreaMaster {
  final String id;
  final String name;
  final String country;
  final String state;
  final String district;

  AreaMaster({
    required this.id,
    required this.name,
    required this.country,
    required this.state,
    required this.district,
  });
}

class AreaStore {
  static final List<AreaMaster> _areas = [];

  static List<AreaMaster> get areas => List.unmodifiable(_areas);

  /// Add a new area if it does not already exist
  static AreaMaster? addArea({
    required String name,
    required String country,
    required String state,
    required String district,
  }) {
    final cleanedName = name.trim();

    if (cleanedName.isEmpty) {
      return null;
    }

    // Prevent duplicate areas within the same location.
    final existingIndex = _areas.indexWhere(
      (area) =>
          area.name.trim().toLowerCase() ==
              cleanedName.toLowerCase() &&
          area.country.trim().toLowerCase() ==
              country.trim().toLowerCase() &&
          area.state.trim().toLowerCase() ==
              state.trim().toLowerCase() &&
          area.district.trim().toLowerCase() ==
              district.trim().toLowerCase(),
    );

    if (existingIndex != -1) {
      return _areas[existingIndex];
    }

    final area = AreaMaster(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: cleanedName,
      country: country,
      state: state,
      district: district,
    );

    _areas.add(area);

    return area;
  }

  /// Get areas belonging to a particular location
  static List<AreaMaster> getAreas({
    required String country,
    required String state,
    required String district,
  }) {
    return _areas.where((area) {
      return area.country.trim().toLowerCase() ==
              country.trim().toLowerCase() &&
          area.state.trim().toLowerCase() ==
              state.trim().toLowerCase() &&
          area.district.trim().toLowerCase() ==
              district.trim().toLowerCase();
    }).toList();
  }
}