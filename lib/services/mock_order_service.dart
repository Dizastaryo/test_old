/// Mock сервис для записей на прием (вместо заказов)
class MockOrderService {
  Future<Map<String, dynamic>> createOrder(
    List<Map<String, int>> items,
    String shippingAddress,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return {
      'id': DateTime.now().millisecondsSinceEpoch,
      'items': items,
      'shipping_address': shippingAddress,
      'status': 'pending',
      'total': 0.0,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  Future<Map<String, dynamic>> getOrderById(int orderId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'id': orderId,
      'items': [],
      'shipping_address': 'Адрес клиники',
      'status': 'confirmed',
      'total': 5000.0,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  Future<List<dynamic>> getMyOrders() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {
        'id': 1,
        'items': [
          {'product_id': 1, 'quantity': 1, 'price': 5000.0}
        ],
        'status': 'confirmed',
        'total': 5000.0,
        'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      },
      {
        'id': 2,
        'items': [
          {'product_id': 4, 'quantity': 1, 'price': 6000.0}
        ],
        'status': 'completed',
        'total': 6000.0,
        'created_at': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      },
    ];
  }

  Future<void> cancelOrder(int orderId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock - всегда успешно
  }

  Future<Map<String, dynamic>> createPayment(int orderId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'payment_id': 'payment_${DateTime.now().millisecondsSinceEpoch}',
      'order_id': orderId,
      'status': 'pending',
      'amount': 5000.0,
    };
  }

  Future<Map<String, dynamic>> getPaymentStatus(int orderId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'order_id': orderId,
      'status': 'completed',
      'payment_date': DateTime.now().toIso8601String(),
    };
  }

  Future<Map<String, dynamic>> updateOrderStatus(
    int orderId,
    String newStatus,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'id': orderId,
      'status': newStatus,
    };
  }

  Future<List<String>> getOrderStatuses() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return ['pending', 'confirmed', 'in_progress', 'completed', 'cancelled'];
  }

  Future<List<dynamic>> getAllOrders() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return await getMyOrders();
  }
}
