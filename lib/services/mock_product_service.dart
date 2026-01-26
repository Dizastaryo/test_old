import '../models/product.dart';
import '../models/review.dart';

/// Mock сервис для услуг клиники (вместо продуктов)
class MockProductService {
  // Mock данные услуг клиники
  static final List<Product> _mockServices = [
    Product(
      id: 1,
      name: 'Консультация терапевта',
      description: 'Первичная консультация врача-терапевта с осмотром и назначением лечения',
      price: 5000.0,
      categoryId: 1,
      imageUrls: [],
    ),
    Product(
      id: 2,
      name: 'Консультация кардиолога',
      description: 'Консультация врача-кардиолога, ЭКГ, назначение лечения',
      price: 8000.0,
      categoryId: 1,
      imageUrls: [],
    ),
    Product(
      id: 3,
      name: 'Консультация невролога',
      description: 'Осмотр невролога, диагностика, назначение лечения',
      price: 7000.0,
      categoryId: 1,
      imageUrls: [],
    ),
    Product(
      id: 4,
      name: 'УЗИ брюшной полости',
      description: 'Ультразвуковое исследование органов брюшной полости',
      price: 6000.0,
      categoryId: 2,
      imageUrls: [],
    ),
    Product(
      id: 5,
      name: 'УЗИ сердца',
      description: 'Эхокардиография (УЗИ сердца)',
      price: 7000.0,
      categoryId: 2,
      imageUrls: [],
    ),
    Product(
      id: 6,
      name: 'Общий анализ крови',
      description: 'Лабораторное исследование общего анализа крови',
      price: 2500.0,
      categoryId: 3,
      imageUrls: [],
    ),
    Product(
      id: 7,
      name: 'Биохимический анализ',
      description: 'Полный биохимический анализ крови',
      price: 4500.0,
      categoryId: 3,
      imageUrls: [],
    ),
    Product(
      id: 8,
      name: 'Массаж лечебный',
      description: 'Сеанс лечебного массажа (60 минут)',
      price: 5000.0,
      categoryId: 4,
      imageUrls: [],
    ),
  ];

  String get placeholderImageUrl => 'https://via.placeholder.com/300';

  Future<List<Product>> getProducts({int? categoryId, String? search}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    var filtered = List<Product>.from(_mockServices);
    
    if (categoryId != null) {
      filtered = filtered.where((p) => p.categoryId == categoryId).toList();
    }
    
    if (search != null && search.isNotEmpty) {
      final searchLower = search.toLowerCase();
      filtered = filtered.where((p) =>
        p.name.toLowerCase().contains(searchLower) ||
        p.description.toLowerCase().contains(searchLower)
      ).toList();
    }
    
    return filtered;
  }

  Future<Product> getProductById(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockServices.firstWhere((p) => p.id == id);
  }

  Future<Product> addProduct({
    required ProductCreate product,
    required List<dynamic> images,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newProduct = Product(
      id: _mockServices.length + 1,
      name: product.name,
      description: product.description,
      price: product.price,
      categoryId: product.categoryId,
      imageUrls: [],
    );
    _mockServices.add(newProduct);
    return newProduct;
  }

  Future<Product> updateProduct({
    required int id,
    required ProductCreate product,
    required List<dynamic> images,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockServices.indexWhere((p) => p.id == id);
    if (index != -1) {
      _mockServices[index] = Product(
        id: id,
        name: product.name,
        description: product.description,
        price: product.price,
        categoryId: product.categoryId,
        imageUrls: _mockServices[index].imageUrls,
      );
      return _mockServices[index];
    }
    throw Exception('Услуга не найдена');
  }

  Future<void> deleteProduct(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockServices.removeWhere((p) => p.id == id);
  }

  Future<Map<String, dynamic>> getCart() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'items': [],
      'total': 0.0,
    };
  }

  Future<void> addToCart(int productId, {int quantity = 1}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock - ничего не делаем
  }

  Future<void> updateCart(int productId, int quantity) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock - ничего не делаем
  }

  Future<void> removeFromCart(int productId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock - ничего не делаем
  }

  Future<void> clearCart() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock - ничего не делаем
  }

  String getImageUrl(String imagePath) {
    return imagePath.startsWith('http') ? imagePath : placeholderImageUrl;
  }

  // Mock методы для отзывов
  Future<Review> addReview({
    required int productId,
    required int rating,
    String? comment,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Review(
      id: DateTime.now().millisecondsSinceEpoch,
      productId: productId,
      userId: 1,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );
  }

  Future<List<Review>> getReviewsForProduct(int productId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Возвращаем пустой список отзывов для mock
    return [];
  }
}
