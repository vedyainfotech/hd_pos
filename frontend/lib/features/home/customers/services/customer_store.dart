import 'package:flutter/foundation.dart';

import '../models/customer_model.dart';

class CustomerStore {
  CustomerStore._();

  static final ValueNotifier<List<Customer>> customers =
      ValueNotifier<List<Customer>>([]);

  static void addCustomer(Customer customer) {
    customers.value = [
      ...customers.value,
      customer,
    ];
  }

  static void updateCustomer(Customer customer) {
    customers.value = customers.value.map((item) {
      return item.id == customer.id ? customer : item;
    }).toList();
  }

  static Customer? getCustomerById(String id) {
    for (final customer in customers.value) {
      if (customer.id == id) {
        return customer;
      }
    }

    return null;
  }

  static void clear() {
    customers.value = [];
  }
}