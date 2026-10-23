// lib/screens/product_form_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageController = TextEditingController();

  String? selectedCategory;
  List<String> categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductProvider>();
      
      // Extraer categorías únicas
      final uniqueCategories = provider.products
          .map((p) => p.category)
          .where((c) => c.isNotEmpty)
          .toSet()
          .toList();

      // Si no hay productos cargados, usamos unas por defecto
      if (uniqueCategories.isEmpty) {
        uniqueCategories.addAll(['electronics', 'jewelery', "men's clothing", "women's clothing"]);
      }

      setState(() {
        categories = uniqueCategories;

        if (widget.product != null) {
          _titleController.text = widget.product!.title;
          _priceController.text = widget.product!.price.toString();
          _descriptionController.text = widget.product!.description;
          _imageController.text = widget.product!.image;

          if (!categories.contains(widget.product!.category)) {
            categories.add(widget.product!.category);
          }
          selectedCategory = widget.product!.category;
        } else {
          selectedCategory = categories.first;
        }
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (_isLoading) return; 
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final price = double.tryParse(_priceController.text.trim());
      if (price == null) return;

      final product = Product(
        id: widget.product?.id ?? 0,
        title: _titleController.text.trim(),
        price: price,
        description: _descriptionController.text.trim(),
        category: selectedCategory ?? 'Otros',
        image: _imageController.text.trim().isNotEmpty
            ? _imageController.text.trim()
            : 'https://via.placeholder.com/150',
      );

      final provider = context.read<ProductProvider>();

      if (widget.product == null) {
        await provider.addProduct(product);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Producto creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await provider.updateProduct(product);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Producto actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
      
    } catch (e) {
      if (!mounted) return;
      
      // ✅ Captura de error de red
      String mensajeError = '❌ No se pudo guardar el producto. Intente nuevamente.';
      if (e.toString().contains('SocketException') || 
          e.toString().contains('ClientException') || 
          e.toString().contains('Failed host lookup')) {
        mensajeError = '❌ No hay conexión a Internet. Verifica tu red.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensajeError),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Producto' : 'Nuevo Producto'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Ingrese el título';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Ingrese la descripción';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Ingrese el precio';
                  final price = double.tryParse(value.trim());
                  if (price == null) return 'Ingrese un valor numérico válido';
                  if (price <= 0) return 'El precio debe ser mayor que cero';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedCategory = value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Seleccione una categoría';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(
                  labelText: 'URL de la imagen (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(isEditing ? 'Actualizar' : 'Guardar'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}