import 'package:flutter/material.dart';

import '../database/banco_dados.dart';

class EstoqueIngredientesPage extends StatefulWidget {
  const EstoqueIngredientesPage({super.key});

  @override
  State<EstoqueIngredientesPage> createState() =>
      _EstoqueIngredientesPageState();
}

class _EstoqueIngredientesPageState extends State<EstoqueIngredientesPage> {
  final List<Map<String, dynamic>> _ingredientes = [];
  final TextEditingController _nomeController = TextEditingController();

  Future<void> _carregarEstoque() async {
    final linhas = await BancoDados.listarEstoque();

    if (!mounted) return;

    setState(() {
      _ingredientes
        ..clear()
        ..addAll(linhas);
    });
  }

  Future<void> _adicionarIngrediente() async {
    final nome = _nomeController.text.trim();

    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite o nome do ingrediente.'),
        ),
      );
      return;
    }

    await BancoDados.adicionarEstoque(nome);

    if (!mounted) return;

    _nomeController.clear();
    await _carregarEstoque();
  }

  Future<void> _removerIngrediente(int id) async {
    await BancoDados.removerEstoque(id);
    await _carregarEstoque();
  }

  @override
  void initState() {
    super.initState();
    _carregarEstoque();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estoque de Ingredientes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do ingrediente',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _adicionarIngrediente,
              child: const Text('Adicionar ingrediente'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _ingredientes.isEmpty
                  ? const Center(
                      child: Text('Nenhum ingrediente no estoque.'),
                    )
                  : ListView.builder(
                      itemCount: _ingredientes.length,
                      itemBuilder: (context, index) {
                        final ingrediente = _ingredientes[index];

                        return ListTile(
                          title: Text(ingrediente['nome'] as String),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              _removerIngrediente(ingrediente['id'] as int);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
