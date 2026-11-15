import 'package:flutter/material.dart';

import '../database/banco_dados.dart';
import '../models/receita.dart';

class PesquisaReceitaPage extends StatefulWidget {
  final Function(Receita) onSelecionar;

  const PesquisaReceitaPage({
    super.key,
    required this.onSelecionar,
  });

  @override
  State<PesquisaReceitaPage> createState() => _PesquisaReceitaPageState();
}

class _PesquisaReceitaPageState extends State<PesquisaReceitaPage> {
  final List<Map<String, dynamic>> _receitas = [];
  final TextEditingController _buscaController = TextEditingController();

  int _filtroTempo = 0;
  bool _somenteEstoque = false;

  Future<void> _carregarReceitas() async {
    final linhas = await BancoDados.listarReceitas(
      _buscaController.text.trim(),
      _filtroTempo,
      _somenteEstoque,
    );

    if (!mounted) return;

    setState(() {
      _receitas
        ..clear()
        ..addAll(linhas);
    });
  }

  @override
  void initState() {
    super.initState();
    _carregarReceitas();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesquisar receitas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _buscaController,
              decoration: const InputDecoration(
                labelText: 'Pesquisar por receita ou ingrediente',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _carregarReceitas(),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _filtroTempo,
              decoration: const InputDecoration(
                labelText: 'Tempo de preparo',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 0, child: Text('Todos os tempos')),
                DropdownMenuItem(value: 1, child: Text('Até 30 minutos')),
                DropdownMenuItem(value: 2, child: Text('De 31 a 60 minutos')),
                DropdownMenuItem(value: 3, child: Text('Mais de 60 minutos')),
              ],
              onChanged: (valor) {
                setState(() {
                  _filtroTempo = valor ?? 0;
                });
                _carregarReceitas();
              },
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Mostrar receitas com pelo menos 3 ingredientes no estoque'),
              value: _somenteEstoque,
              onChanged: (valor) {
                setState(() {
                  _somenteEstoque = valor ?? false;
                });
                _carregarReceitas();
              },
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _receitas.isEmpty
                  ? const Center(
                      child: Text('Nenhuma receita encontrada.'),
                    )
                  : ListView.builder(
                      itemCount: _receitas.length,
                      itemBuilder: (context, index) {
                        final dados = _receitas[index];
                        final receita = Receita.fromMap(dados);
                        final disponiveis =
                            (dados['ingredientesDisponiveis'] as int?) ?? 0;
                        final faltantes =
                            (dados['ingredientesFaltantes'] as int?) ?? 0;

                        return ListTile(
                          title: Text(receita.nome),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${receita.tempoPreparo} minutos • '
                                '${receita.porcoes} porções',
                              ),
                              Text(
                                '$disponiveis ingredientes disponíveis • '
                                '$faltantes faltantes',
                                style: TextStyle(
                                  color: faltantes == 0
                                      ? Colors.green
                                      : Colors.deepOrange,
                                ),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          onTap: () => widget.onSelecionar(receita),
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
