import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = 'https://reqres.in/api';

  Future<String> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String token = data['token'] ?? 'token_simulado_123';
        return token;
      } else if (response.statusCode == 400) {
        throw Exception('Usuario o contraseña incorrectos');
      } else {
        throw Exception('Error al iniciar sesión (${response.statusCode})');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('No se pudo conectar al servidor. Verifique su conexión.');
      }
      rethrow;
    }
  }

  void logout() {
    
  }
}