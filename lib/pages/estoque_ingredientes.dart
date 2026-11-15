
import 'package:flutter/material.dart';
import '../database/banco_dados.dart';

class EstoqueIngredientesPage extends StatefulWidget {

  const EstoqueIngredientesPage({super.key});

  @override
  State<EstoqueIngredientesPage> createState() =>
      _EstoqueIngredientesPageState();
}

class _EstoqueIngredientesPageState
    extends State<EstoqueIngredientesPage> {

  final List<Map<String, dynamic>> _ingredientes = [];

  final TextEditingController _nomeController =
      TextEditingController();

  // CARREGAR ESTOQUE
  Future<void> _carregarEstoque() async {
  final linhas = await BancoDados.listarEstoque();

  if (!mounted) return;

  setState(() {
    _ingredientes.clear();
    _ingredientes.addAll(linhas);
  });
}

  // ADICIONAR INGREDIENTE
  Future<void> _adicionarIngrediente() async {

    final nome = _nomeController.text.trim();

    if (nome.isEmpty) {
      return;
    }

    await BancoDados.adicionarEstoque(nome);

    _nomeController.clear();

    await _carregarEstoque();
  }

  // REMOVER INGREDIENTE
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

            // CAMPO DE NOME
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do ingrediente',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // ADICIONAR
            ElevatedButton(
              onPressed: _adicionarIngrediente,
              child: const Text('Adicionar ingrediente'),
            ),

            const SizedBox(height: 16),

            // LISTA
            Expanded(
              child: ListView.builder(

                itemCount: _ingredientes.length,

                itemBuilder: (context, index) {

                  final ingrediente = _ingredientes[index];

                  return ListTile(

                    title: Text(ingrediente['nome']),

                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        _removerIngrediente(ingrediente['id']);
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
