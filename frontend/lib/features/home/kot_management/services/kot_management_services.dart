import '../models/kot_management_model.dart';

/// Temporary local data for frontend development.
///
/// Replace these methods with API calls after the KOT backend is finalized.
class KotManagementService {
  static List<KotManagementModel> getDemoKots() {
    return const [
      KotManagementModel(
        id: 1,
        kotNumber: 'KOT-1001',
        customerName: 'Ravi Kumar',
        customerPhone: '9876543210',
        deliveryAddress: 'MVP Colony, Sector 5, Visakhapatnam',
        foodType: 'Lunch',
        items: [
          KotItem(name: 'Meals', quantity: 2),
          KotItem(name: 'Potato Curry', quantity: 1),
          KotItem(name: 'Curd', quantity: 1),
        ],
        deliveryPerson: 'Prasad',
        deliveryPersonContact: '9030117162',
        isPrinted: true,
      ),
      KotManagementModel(
        id: 2,
        kotNumber: 'KOT-1002',
        customerName: 'Sita Devi',
        customerPhone: '9441755336',
        deliveryAddress: 'Madhurawada, Visakhapatnam',
        foodType: 'Breakfast',
        items: [
          KotItem(name: 'Masala Dosa', quantity: 2),
          KotItem(name: 'Idli', quantity: 4),
        ],
      ),
      KotManagementModel(
        id: 3,
        kotNumber: 'KOT-1003',
        customerName: 'Arun Kumar',
        customerPhone: '9949726278',
        deliveryAddress: 'MVP Colony, near Sai Chaitanya School',
        foodType: 'Dinner',
        items: [
          KotItem(name: 'Chapati', quantity: 4),
          KotItem(name: 'Paneer Curry', quantity: 1),
        ],
        deliveryPerson: 'Jagan',
        deliveryPersonContact: '8179650301',
      ),
      KotManagementModel(
        id: 4,
        kotNumber: 'KOT-1004',
        customerName: 'Lakshmi',
        customerPhone: '6304994745',
        deliveryAddress: 'Akkayyapalem, Visakhapatnam',
        foodType: 'Lunch',
        items: [
          KotItem(name: 'Rice', quantity: 1),
          KotItem(name: 'Sambar', quantity: 1),
        ],
      ),
    ];
  }

  static const List<String> deliveryPeople = [
    'Prasad',
    'A V S Prasad',
    'Jagan',
    'P Bharath Kumar',
  ];

  static const Map<String, String> deliveryContacts = {
    'Prasad': '9030117162',
    'A V S Prasad': '9676770701',
    'Jagan': '8179650301',
    'P Bharath Kumar': '8985868876',
  };
}
