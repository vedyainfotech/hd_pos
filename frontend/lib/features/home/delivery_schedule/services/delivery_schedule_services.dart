import '../../category/models/category_model.dart';
import '../../category/services/category_api_service.dart';
import '../../delivery_persons/models/delivery_person_model.dart';
import '../../delivery_persons/services/delivery_person_services.dart';
import '../models/delivery_schedule_model.dart';

class DeliveryScheduleService {
  final CategoryApiService _categoryService = CategoryApiService();
  final DeliveryPersonApiService _deliveryPersonService =
      DeliveryPersonApiService();

  final Map<String, DeliveryScheduleModel> _savedSchedules = {};

  Future<DeliveryScheduleResources> loadResources() async {
    final results = await Future.wait([
      _categoryService.getCategories(includeInactive: true),
      _deliveryPersonService.getDeliveryPersons(includeInactive: true),
    ]);

    final allCategories = results[0] as List<CategoryModel>;
    final allDeliveryPersons = results[1] as List<DeliveryPersonModel>;

    final activeCategories = allCategories
        .where((category) => category.isActive)
        .toList();

    final activeDeliveryPersons = allDeliveryPersons
        .where((person) => person.isActive)
        .toList();

    return DeliveryScheduleResources(
      categories: activeCategories,
      deliveryPersons: activeDeliveryPersons,
    );
  }

  Future<void> saveSchedule(DeliveryScheduleModel schedule) async {
    final normalizedDate = _normalizeDate(schedule.date);

    final copiedAssignments = <int, List<int>>{};

    for (final entry in schedule.assignments.entries) {
      copiedAssignments[entry.key] = List<int>.from(entry.value);
    }

    final savedSchedule = DeliveryScheduleModel(
      date: normalizedDate,
      assignments: copiedAssignments,
    );

    _savedSchedules[_dateKey(normalizedDate)] = savedSchedule;
  }

  DeliveryScheduleModel? getScheduleForDate(DateTime date) {
    final key = _dateKey(_normalizeDate(date));
    return _savedSchedules[key];
  }

  List<DeliveryScheduleModel> getHistory() {
    final history = _savedSchedules.values.toList();

    history.sort((a, b) => b.date.compareTo(a.date));

    return history;
  }

  DateTime? get earliestHistoryDate {
    if (_savedSchedules.isEmpty) {
      return null;
    }

    return _savedSchedules.values
        .map((schedule) => schedule.date)
        .reduce((a, b) => a.isBefore(b) ? a : b);
  }

  DateTime? get latestHistoryDate {
    if (_savedSchedules.isEmpty) {
      return null;
    }

    return _savedSchedules.values
        .map((schedule) => schedule.date)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _dateKey(DateTime date) {
    final normalized = _normalizeDate(date);

    return '${normalized.year.toString().padLeft(4, '0')}-'
        '${normalized.month.toString().padLeft(2, '0')}-'
        '${normalized.day.toString().padLeft(2, '0')}';
  }
}
