// lib/services/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<dynamic> get(String path, {Map<String, String>? headers}) async {
    final uri = Uri.parse('${AppConfig.baseUrl}$path');
    final response = await _client.get(uri, headers: headers);
    return _processResponse(response);
  }

  Future<dynamic> post(String path, dynamic body, {Map<String, String>? headers}) async {
    final uri = Uri.parse('${AppConfig.baseUrl}$path');
    final response = await _client.post(
      uri,
      headers: headers ?? {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _processResponse(response);
  }

  Future<dynamic> put(String path, dynamic body, {Map<String, String>? headers}) async {
    final uri = Uri.parse('${AppConfig.baseUrl}$path');
    final response = await _client.put(
      uri,
      headers: headers ?? {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _processResponse(response);
  }

  Future<dynamic> delete(String path, {Map<String, String>? headers}) async {
    final uri = Uri.parse('${AppConfig.baseUrl}$path');
    final response = await _client.delete(uri, headers: headers);
    return _processResponse(response);
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      throw Exception('Error HTTP ${response.statusCode}');
    }
  }

  void close() => _client.close();
}