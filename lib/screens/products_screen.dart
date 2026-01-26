import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'product_detail_screen.dart';
import '../services/mock_product_service.dart';
import '../services/mock_category_service.dart';
import '../models/product.dart';
import '../models/category.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late Future<List<Product>> _futureProducts;
  List<Category> _categories = [];
  Category? _selectedCategory;
  String? _searchText;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
      _loadProducts();
    });
  }

  void _loadProducts() {
    final productService = Provider.of<MockProductService>(context, listen: false);
    setState(() {
      _futureProducts = productService.getProducts(
        categoryId: _selectedCategory?.id,
        search: _searchText,
      );
    });
  }

  Future<void> _loadCategories() async {
    try {
      final service = Provider.of<MockCategoryService>(context, listen: false);
      final cats = await service.getCategories();
      setState(() => _categories = cats);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки категорий: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<MockProductService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Услуги клиники'),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchAndFilter(),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: _futureProducts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Ошибка: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Нет доступных услуг.'));
                  }

                  final products = snapshot.data!;
                  return _buildProductGrid(products, productService);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Поиск товара...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (text) {
              setState(() {
                _searchText = text.trim();
                _loadProducts();
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: DropdownButton<Category>(
            value: _selectedCategory,
            hint: const Text('Категория'),
            underline: SizedBox(),
            items: [
              const DropdownMenuItem<Category>(
                value: null,
                child: Text('Все'),
              ),
              ..._categories.map((c) => DropdownMenuItem<Category>(
                    value: c,
                    child: Text(c.name),
                  )),
            ],
            onChanged: (cat) {
              setState(() {
                _selectedCategory = cat;
                _loadProducts();
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductGrid(
      List<Product> products, MockProductService productService) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final imageUrl = product.imageUrls.isNotEmpty
            ? productService.getImageUrl(product.imageUrls.first)
            : productService.placeholderImageUrl;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(productId: product.id),
              ),
            );
          },
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: const Icon(
                    Icons.medical_services,
                    size: 60,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${product.price.toStringAsFixed(2)} ₸',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
