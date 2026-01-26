import '../models/category.dart';

/// Mock сервис для категорий услуг клиники
class MockCategoryService {
  // Mock данные категорий
  static final List<Category> _mockCategories = [
    Category(id: 1, name: 'Консультации врачей'),
    Category(id: 2, name: 'Диагностика'),
    Category(id: 3, name: 'Анализы'),
    Category(id: 4, name: 'Процедуры'),
  ];

  Future<List<Category>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List<Category>.from(_mockCategories);
  }
}
