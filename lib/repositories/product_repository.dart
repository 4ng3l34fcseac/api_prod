// lib/repositories/product_repository.dart
import '../models/product.dart';
import '../services/api_client.dart';

class ProductRepository {
  final ApiClient apiClient;

  ProductRepository(this.apiClient);

  Future<List<Product>> getProducts() async {
    final data = await apiClient.get('/products');
    if (data is! List) {
      throw Exception('La respuesta no contiene una lista de productos');
    }
    return data.map((item) => Product.fromJson(Map<String, dynamic>.from(item))).toList();
  }

  Future<Product> createProduct(Product product) async {
    final data = await apiClient.post('/products', product.toJson());
    return Product.fromJson(Map<String, dynamic>.from(data));
  }

  Future<Product> updateProduct(Product product) async {
    final data = await apiClient.put('/products/${product.id}', product.toJson());
    return Product.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> deleteProduct(int id) async {
    await apiClient.delete('/products/$id');
  }
}