// lib/services/product_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final String baseUrl = 'https://fakestoreapi.com';
  String? _token;

  void setToken(String token) {
    _token = token;
    print('✅ Token guardado en ProductService: $_token');
  }

  void clearToken() {
    _token = null;
    print('🗑️ Token eliminado');
  }

  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
      print('🔑 Authorization: Bearer $_token');
    } else {
      print('⚠️ No hay token - Solicitud sin autenticación');
    }
    
    return headers;
  }

  Future<List<Product>> getProducts() async {
    try {
      print('📡 Haciendo solicitud GET a: $baseUrl/products');
      
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 5)); // ✅ Timeout GET

      print('✅ Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('✅ Productos obtenidos: ${data.length}');
        return data.map((json) => Product.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Inicie sesión nuevamente.');
      } else {
        throw Exception('Error al obtener productos: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR: $e');
      if (e.toString().contains('SocketException') || e.toString().contains('TimeoutException')) {
        throw Exception('No hay conexión a Internet. Verifica tu red.');
      }
      rethrow;
    }
  }

  Future<Product> createProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: _getHeaders(),
        body: jsonEncode(product.toJson()),
      ).timeout(const Duration(seconds: 4)); // ✅ Timeout POST

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Product.fromJson(data);
      } else {
        throw Exception('No se pudo crear el producto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Product> updateProduct(Product product) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/products/${product.id}'),
        headers: _getHeaders(),
        body: jsonEncode(product.toJson()),
      ).timeout(const Duration(seconds: 4)); // ✅ Timeout PUT

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Product.fromJson(data);
      } else {
        throw Exception('No se pudo actualizar el producto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/products/$id'),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 4)); // ✅ Timeout DELETE

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else {
        throw Exception('No se pudo eliminar el producto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}