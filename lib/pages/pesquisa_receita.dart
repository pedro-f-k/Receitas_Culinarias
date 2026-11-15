
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
  State<PesquisaReceitaPage> createState() =>
      _PesquisaReceitaPageState();
}

class _PesquisaReceitaPageState extends State<PesquisaReceitaPage> {
  final List<Map<String, dynamic>> _receitas = [];

  final TextEditingController _buscaController =
      TextEditingController();

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
    final corPrincipal = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Minhas receitas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // CABEÇALHO
            const Text(
              'O que vamos cozinhar hoje?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF26352D),
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Encontre uma receita para preparar.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            // CAMPO DE PESQUISA
            TextField(
              controller: _buscaController,
              decoration: const InputDecoration(
                hintText: 'Buscar receita ou ingrediente...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) {
                _carregarReceitas();
              },
            ),

            const SizedBox(height: 16),

            // FILTROS
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE0E7E1),
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Row(
                    children: [
                      Icon(
                        Icons.tune,
                        color: Color(0xFF2E7D5B),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Filtros',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  DropdownButtonFormField<int>(
                    value: _filtroTempo,
                    decoration: const InputDecoration(
                      labelText: 'Tempo de preparo',
                      prefixIcon: Icon(Icons.access_time),
                    ),

                    items: const [
                      DropdownMenuItem(
                        value: 0,
                        child: Text('Todos os tempos'),
                      ),
                      DropdownMenuItem(
                        value: 1,
                        child: Text('Até 30 minutos'),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text('De 31 a 60 minutos'),
                      ),
                      DropdownMenuItem(
                        value: 3,
                        child: Text('Mais de 60 minutos'),
                      ),
                    ],

                    onChanged: (valor) {
                      setState(() {
                        _filtroTempo = valor ?? 0;
                      });

                      _carregarReceitas();
                    },
                  ),

                  const SizedBox(height: 6),

                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: corPrincipal,
                    controlAffinity:
                        ListTileControlAffinity.leading,

                    title: const Text(
                      'Somente receitas com pelo menos 3 ingredientes no estoque',
                      style: TextStyle(fontSize: 13),
                    ),

                    value: _somenteEstoque,

                    onChanged: (valor) {
                      setState(() {
                        _somenteEstoque = valor ?? false;
                      });

                      _carregarReceitas();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // TÍTULO DA LISTA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Receitas disponíveis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF26352D),
                  ),
                ),

                Text(
                  '${_receitas.length} receitas',
                  style: TextStyle(
                    color: corPrincipal,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // LISTA DE RECEITAS
            Expanded(
              child: _receitas.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.menu_book_outlined,
                            size: 65,
                            color: Colors.grey.shade400,
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            'Nenhuma receita encontrada',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF26352D),
                            ),
                          ),

                          const SizedBox(height: 5),

                          const Text(
                            'Tente alterar sua pesquisa ou filtros.',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
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

                        final total =
                            (dados['totalIngredientes'] as int?) ?? 0;

                        return Card(
                          color: Colors.white,
                          elevation: 1,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(
                              color: Color(0xFFE8EEE9),
                            ),
                          ),

                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),

                            onTap: () {
                              widget.onSelecionar(receita);
                            },

                            child: Padding(
                              padding: const EdgeInsets.all(16),

                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [

                                  // NOME DA RECEITA
                                  Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8F3EC),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),

                                        child: const Icon(
                                          Icons.restaurant,
                                          color: Color(0xFF2E7D5B),
                                          size: 24,
                                        ),
                                      ),

                                      const SizedBox(width: 12),

                                      Expanded(
                                        child: Text(
                                          receita.nome,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF26352D),
                                          ),
                                        ),
                                      ),

                                      Icon(
                                        Icons.chevron_right,
                                        color: Colors.grey.shade500,
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // TEMPO E PORÇÕES
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 17,
                                        color: Colors.grey.shade600,
                                      ),

                                      const SizedBox(width: 5),

                                      Text(
                                        '${receita.tempoPreparo} minutos',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 13,
                                        ),
                                      ),

                                      const SizedBox(width: 20),

                                      Icon(
                                        Icons.people_outline,
                                        size: 17,
                                        color: Colors.grey.shade600,
                                      ),

                                      const SizedBox(width: 5),

                                      Text(
                                        '${receita.porcoes} porções',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 14),

                                  // INGREDIENTES DISPONÍVEIS
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Ingredientes no estoque',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      Text(
                                        '$disponiveis de $total',
                                        style: TextStyle(
                                          color: corPrincipal,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  // BARRA DE PROGRESSO
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),

                                    child: LinearProgressIndicator(
                                      value: total > 0
                                          ? disponiveis / total
                                          : 0,

                                      minHeight: 8,

                                      backgroundColor:
                                          const Color(0xFFE8EEE9),

                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                        corPrincipal,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // INGREDIENTES FALTANTES
                                  Row(
                                    children: [
                                      Icon(
                                        faltantes > 0
                                            ? Icons.shopping_cart_outlined
                                            : Icons.check_circle_outline,

                                        size: 17,

                                        color: faltantes > 0
                                            ? Colors.deepOrange
                                            : corPrincipal,
                                      ),

                                      const SizedBox(width: 6),

                                      Text(
                                        faltantes > 0
                                            ? '$faltantes ingredientes faltantes'
                                            : 'Todos os ingredientes disponíveis',

                                        style: TextStyle(
                                          fontSize: 12,
                                          color: faltantes > 0
                                              ? Colors.deepOrange
                                              : corPrincipal,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
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
