
import 'package:flutter/material.dart';
import '../models/receita.dart';
import '../database/banco_dados.dart';

class AcompanhaReceitaPage extends StatefulWidget {

  final Receita? receitaSelecionada;

  const AcompanhaReceitaPage({
    super.key,
    this.receitaSelecionada,
  });

  @override
  State<AcompanhaReceitaPage> createState() =>
      _AcompanhaReceitaPageState();
}

class _AcompanhaReceitaPageState
    extends State<AcompanhaReceitaPage> {

  List<Receita> _receitas = [];

  List<Map<String, dynamic>> _ingredientes = [];

  int? _receitaId;

  // CARREGAR RECEITAS
  Future<void> _carregarReceitas() async {

    final linhas = await BancoDados.listarReceitas('', 0, false);

    setState(() {
      _receitas = linhas.map((m) => Receita.fromMap(m)).toList();

      if (widget.receitaSelecionada != null) {
        _receitaId = widget.receitaSelecionada!.id;
      } else if (_receitas.isNotEmpty) {
        _receitaId = null;
      }
    });

    if (_receitaId != null) {
      await _carregarIngredientes();
    }
  }

  // CARREGAR INGREDIENTES
  Future<void> _carregarIngredientes() async {

    if (_receitaId == null) {
      return;
    }

    final linhas = await BancoDados.listarIngredientes(
      _receitaId!,
    );

    setState(() {
      _ingredientes = linhas;
    });
  }

  // MARCAR INGREDIENTE COMO COMPRADO
  Future<void> _marcarComprado(
    int id,
    bool comprado,
  ) async {

    await BancoDados.atualizarIngrediente(
      id,
      comprado,
    );

    await _carregarIngredientes();
  }

  @override
  void initState() {
    super.initState();
    _carregarReceitas();
  }

  // ATUALIZAR RECEITA SELECIONADA
  @override
  void didUpdateWidget(covariant AcompanhaReceitaPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.receitaSelecionada?.id !=
        oldWidget.receitaSelecionada?.id &&
        widget.receitaSelecionada != null) {

      _receitaId = widget.receitaSelecionada!.id;
      _carregarIngredientes();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Acompanhar Receita'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            // SELECIONAR RECEITA
            DropdownButtonFormField<int>(
              value: _receitas.any((r) => r.id == _receitaId)
                  ? _receitaId
                  : null,

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

              onChanged: (valor) async {

                setState(() {
                  _receitaId = valor;
                  _ingredientes = [];
                });

                await _carregarIngredientes();
              },
            ),

            const SizedBox(height: 16),

            // LISTA DE INGREDIENTES
            Expanded(
              child: _ingredientes.isEmpty
                  ? const Center(
                      child: Text('Selecione uma receita'),
                    )
                  : ListView.builder(

                      itemCount: _ingredientes.length,

                      itemBuilder: (context, index) {

                        final ingrediente = _ingredientes[index];

                        return CheckboxListTile(

                          title: Text(ingrediente['nome']),

                          value: ingrediente['comprado'] == 1,

                          onChanged: (valor) {

                            _marcarComprado(
                              ingrediente['id'] as int,
                              valor!,
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
