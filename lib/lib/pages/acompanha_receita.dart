import 'package:flutter/material.dart';

import '../database/banco_dados.dart';
import '../models/receita.dart';

class AcompanhaReceitaPage extends StatefulWidget {
  final Receita? receitaSelecionada;

  const AcompanhaReceitaPage({
    super.key,
    this.receitaSelecionada,
  });

  @override
  State<AcompanhaReceitaPage> createState() => _AcompanhaReceitaPageState();
}

class _AcompanhaReceitaPageState extends State<AcompanhaReceitaPage> {
  List<Receita> _receitas = [];
  List<Map<String, dynamic>> _ingredientes = [];
  int? _receitaId;

  Future<void> _carregarReceitas() async {
    final linhas = await BancoDados.listarReceitas('', 0, false);

    if (!mounted) return;

    setState(() {
      _receitas = linhas.map((linha) => Receita.fromMap(linha)).toList();
    });

    final selecionada = widget.receitaSelecionada;
    if (selecionada != null && _receitas.any((r) => r.id == selecionada.id)) {
      await _selecionarReceita(selecionada.id);
    } else if (_receitas.isNotEmpty && _receitaId == null) {
      await _selecionarReceita(_receitas.first.id);
    }
  }

  Future<void> _selecionarReceita(int? id) async {
    if (id == null) return;

    setState(() {
      _receitaId = id;
      _ingredientes = [];
    });

    await _carregarIngredientes();
  }

  Future<void> _carregarIngredientes() async {
    if (_receitaId == null) return;

    final linhas = await BancoDados.listarIngredientes(_receitaId!);

    if (!mounted) return;

    setState(() {
      _ingredientes = linhas;
    });
  }

  Future<void> _marcarComprado(int id, bool comprado) async {
    await BancoDados.atualizarIngrediente(id, comprado);
    await _carregarIngredientes();
  }

  @override
  void initState() {
    super.initState();
    _carregarReceitas();
  }

  @override
  void didUpdateWidget(covariant AcompanhaReceitaPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.receitaSelecionada?.id != oldWidget.receitaSelecionada?.id) {
      final id = widget.receitaSelecionada?.id;
      if (id != null) {
        _selecionarReceita(id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final receitaAtual = _receitas.where((r) => r.id == _receitaId).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Acompanhar receita'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              value: receitaAtual.isEmpty ? null : _receitaId,
              decoration: const InputDecoration(
                labelText: 'Selecione uma receita',
                border: OutlineInputBorder(),
              ),
              items: _receitas.map((receita) {
                return DropdownMenuItem<int>(
                  value: receita.id,
                  child: Text(receita.nome),
                );
              }).toList(),
              onChanged: _selecionarReceita,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _ingredientes.isEmpty
                  ? const Center(
                      child: Text('Selecione uma receita para ver os ingredientes.'),
                    )
                  : ListView.builder(
                      itemCount: _ingredientes.length,
                      itemBuilder: (context, index) {
                        final ingrediente = _ingredientes[index];
                        final comprado = ingrediente['comprado'] == 1;

                        return CheckboxListTile(
                          title: Text(ingrediente['nome'] as String),
                          value: comprado,
                          onChanged: (valor) {
                            _marcarComprado(
                              ingrediente['id'] as int,
                              valor ?? false,
                            );
                          },
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
