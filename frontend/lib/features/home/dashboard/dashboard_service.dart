import '../category/models/category_model.dart';
import '../category/services/category_api_service.dart';
import 'dashboard_models.dart';
class HomeDeliveryDashboardService {
  final CategoryApiService _categoryService = CategoryApiService();

  Future<List<CategoryModel>> loadActiveCategories() async {
    final categories = await _categoryService.getCategories(
      includeInactive: true,
    );

    return categories.where((category) => category.isActive).toList();
  }

  DashboardOrderDraft createDraft({
    required DashboardCustomer customer,
    required DateTime fromDate,
    required DateTime toDate,
    required String meal,
    required List<DashboardOrderLine> lines,
    String remarks = '',
  }) {
    if (customer.name.trim().isEmpty) {
      throw ArgumentError('Enter the customer name.');
    }

    if (customer.phone.trim().isEmpty) {
      throw ArgumentError('Enter the customer phone number.');
    }

    if (toDate.isBefore(fromDate)) {
      throw ArgumentError('The end date cannot be before the start date.');
    }

    if (lines.isEmpty) {
      throw ArgumentError('Add at least one order item.');
    }

    for (final line in lines) {
      if (line.itemName.trim().isEmpty) {
        throw ArgumentError('Every order item needs a name.');
      }

      if (line.price < 0 || line.quantity <= 0) {
        throw ArgumentError('Check the price and quantity of each item.');
      }
    }

    return DashboardOrderDraft(
      customer: customer,
      fromDate: DateTime(fromDate.year, fromDate.month, fromDate.day),
      toDate: DateTime(toDate.year, toDate.month, toDate.day),
      meal: meal,
      lines: List.unmodifiable(lines),
      remarks: remarks.trim(),
    );
  }

  // Order persistence will be added when the order API is implemented.
  Future<void> placeOrder(DashboardOrderDraft draft) async {
    throw UnsupportedError(
      'Order saving is not connected yet. '
      'Your draft has not been saved.',
    );
  }
}
