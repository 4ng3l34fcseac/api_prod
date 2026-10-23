// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PreferencesService _prefs = PreferencesService();

  final TextEditingController _usernameController = TextEditingController();

  bool _darkMode = false;
  bool _notifications = false;
  String _language = 'es';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Cargar preferencias guardadas
  Future<void> _loadPreferences() async {
    final darkMode = await _prefs.getDarkMode();
    final notifications = await _prefs.getNotifications();
    final language = await _prefs.getLanguage();
    final username = await _prefs.getUsername();

    setState(() {
      _darkMode = darkMode;
      _notifications = notifications;
      _language = language ?? 'es';
      _usernameController.text = username ?? '';
    });
  }

  // Guardar todas las preferencias
  Future<void> _savePreferences() async {
    await _prefs.saveDarkMode(_darkMode);
    await _prefs.saveNotifications(_notifications);
    await _prefs.saveLanguage(_language);
    await _prefs.saveUsername(_usernameController.text);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Preferencias guardadas'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Eliminar todas las preferencias
  Future<void> _clearPreferences() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar preferencias'),
        content: const Text('¿Está seguro de eliminar todas las preferencias?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _prefs.clearAll();

    setState(() {
      _darkMode = false;
      _notifications = false;
      _language = 'es';
      _usernameController.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🗑️ Preferencias eliminadas'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Nombre de usuario
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de usuario',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),

            // Idioma
            DropdownButtonFormField<String>(
              initialValue: _language,
              decoration: const InputDecoration(
                labelText: 'Idioma',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.language),
              ),
              items: const [
                DropdownMenuItem(value: 'es', child: Text('Español')),
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'pt', child: Text('Português')),
              ],
              onChanged: (value) {
                setState(() {
                  _language = value ?? 'es';
                });
              },
            ),
            const SizedBox(height: 16),

            // Modo oscuro
            SwitchListTile(
              title: const Text('Modo oscuro'),
              subtitle: const Text('Activar tema oscuro'),
              secondary: const Icon(Icons.dark_mode),
              value: _darkMode,
              onChanged: (value) {
                setState(() {
                  _darkMode = value;
                });
              },
            ),

            // Notificaciones
            SwitchListTile(
              title: const Text('Notificaciones'),
              subtitle: const Text('Recibir notificaciones'),
              secondary: const Icon(Icons.notifications),
              value: _notifications,
              onChanged: (value) {
                setState(() {
                  _notifications = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // Botón guardar
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _savePreferences,
                icon: const Icon(Icons.save),
                label: const Text('Guardar preferencias'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Botón eliminar
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _clearPreferences,
                icon: const Icon(Icons.delete),
                label: const Text('Eliminar preferencias'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}