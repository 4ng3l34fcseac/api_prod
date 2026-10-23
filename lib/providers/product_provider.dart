// lib/providers/product_provider.dart
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository repository;

  ProductProvider(this.repository);

  List<Product> products = [];
  bool isLoading = false;
  String? error;

  Future<void> loadProducts() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      products = await repository.getProducts();
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('ClientException')) {
        error = 'No hay conexión a Internet. Verifica tu red.';
      } else {
        error = 'No se pudieron cargar los productos.';
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(Product product) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final newProduct = await repository.createProduct(product);
      products.add(newProduct);
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct(Product product) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final updatedProduct = await repository.updateProduct(product);
      final index = products.indexWhere((p) => p.id == updatedProduct.id);
      if (index != -1) {
        products[index] = updatedProduct;
      }
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeProduct(int id) async {
    try {
      await repository.deleteProduct(id);
      products.removeWhere((product) => product.id == id);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}