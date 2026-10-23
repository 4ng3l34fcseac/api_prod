import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/counter_provider.dart';

class StateDemoScreen extends StatelessWidget {
  const StateDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final counter = context.watch<CounterProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Gestión del estado')),
      body: Center(
        child: Text('${counter.contador}', style: const TextStyle(fontSize: 40)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<CounterProvider>().incrementar();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}