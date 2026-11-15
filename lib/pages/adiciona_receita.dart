import 'package:flutter/material.dart';
import '../database/banco_dados.dart';

class AdicionaReceitaPage extends StatefulWidget {
  final VoidCallback onSalvou;

  const AdicionaReceitaPage({
    super.key,
    required this.onSalvou,
  });

  @override
  State<AdicionaReceitaPage> createState() => _AdicionaReceitaPageState();
}

class _AdicionaReceitaPageState extends State<AdicionaReceitaPage> {
  final TextEditingController _nomeController = TextEditingController();

  final TextEditingController _tempoController = TextEditingController();

  final TextEditingController _porcoesController = TextEditingController();

  final TextEditingController _ingredientesController = TextEditingController();

  // ADICIONAR RECEITA
  Future<void> _adicionarReceita() async {
    final nome = _nomeController.text.trim();

    final tempo = int.tryParse(_tempoController.text) ?? 0;

    final porcoes = int.tryParse(_porcoesController.text) ?? 0;

    final ingredientes = _ingredientesController.text
        .split(',')
        .map((i) => i.trim())
        .where((i) => i.isNotEmpty)
        .toSet()
        .toList();

    if (nome.isEmpty || tempo <= 0 || porcoes <= 0 || ingredientes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos corretamente!'),
        ),
      );

      return;
    }

    await BancoDados.adicionarReceita(
      nome,
      tempo,
      porcoes,
      ingredientes,
    );

    _nomeController.clear();
    _tempoController.clear();
    _porcoesController.clear();
    _ingredientesController.clear();

    widget.onSalvou();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Receita cadastrada!'),
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _tempoController.dispose();
    _porcoesController.dispose();
    _ingredientesController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Receita'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome da receita',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tempoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tempo de preparo (minutos)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _porcoesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Porções',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ingredientesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Ingredientes (separados por vírgula)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _adicionarReceita,
              child: const Text('Cadastrar receita'),
            ),
          ],
        ),
      ),
    );
  }
}
