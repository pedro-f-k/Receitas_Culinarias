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
  State<AcompanhaReceitaPage> createState() => _AcompanhaReceitaPageState();
}

class _AcompanhaReceitaPageState extends State<AcompanhaReceitaPage> {
  List<Receita> _receitas = [];

  List<Map<String, dynamic>> _ingredientes = [];

  int? _receitaId;

  bool _carregando = false;

  // CARREGAR RECEITAS
  Future<void> _carregarReceitas() async {
    final linhas = await BancoDados.listarReceitas('', 0, false);

    if (!mounted) return;

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
    if (_receitaId == null) return;

    setState(() {
      _carregando = true;
    });

    final linhas = await BancoDados.listarIngredientes(_receitaId!);

    if (!mounted) return;

    setState(() {
      _ingredientes = linhas;
      _carregando = false;
    });
  }

  // MARCAR INGREDIENTE COMO COMPRADO
  Future<void> _marcarComprado(
    int id,
    bool comprado,
  ) async {
    await BancoDados.atualizarIngrediente(id, comprado);

    if (!mounted) return;

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

    if (widget.receitaSelecionada?.id != oldWidget.receitaSelecionada?.id &&
        widget.receitaSelecionada != null) {
      _receitaId = widget.receitaSelecionada!.id;
      _carregarIngredientes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    final corPrincipal = cores.primary;
    final corTexto = cores.onSurface;
    final corSecundaria = cores.onSurfaceVariant;

    // LOCALIZAR RECEITA SELECIONADA
    Receita? receitaAtual;

    for (final receita in _receitas) {
      if (receita.id == _receitaId) {
        receitaAtual = receita;
        break;
      }
    }

    final comprados = _ingredientes
        .where(
          (i) => i['comprado'] == 1,
        )
        .length;

    final total = _ingredientes.length;

    final progresso = total > 0 ? comprados / total : 0.0;

    final todosComprados = total > 0 && comprados == total;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Acompanhar receita',
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
            Text(
              'Prepare sua receita',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: corTexto,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              'Marque os ingredientes conforme for comprando.',
              style: TextStyle(
                fontSize: 14,
                color: corSecundaria,
              ),
            ),

            const SizedBox(height: 20),

            // SELECIONAR RECEITA
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cores.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: cores.outlineVariant,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        color: corPrincipal,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Receita selecionada',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: corTexto,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<int>(
                    value: _receitas.any((r) => r.id == _receitaId)
                        ? _receitaId
                        : null,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      hintText: 'Selecione uma receita',
                      prefixIcon: Icon(Icons.menu_book_outlined),
                    ),
                    items: _receitas.map((receita) {
                      return DropdownMenuItem<int>(
                        value: receita.id,
                        child: Text(
                          receita.nome,
                          overflow: TextOverflow.ellipsis,
                        ),
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
                ],
              ),
            ),

            const SizedBox(height: 18),

            // PROGRESSO DA RECEITA
            if (receitaAtual != null && total > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cores.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progresso da compra',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: cores.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          '${(progresso * 100).round()}%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: cores.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progresso,
                        minHeight: 9,
                        backgroundColor: cores.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(corPrincipal),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$comprados de $total ingredientes comprados',
                      style: TextStyle(
                        fontSize: 13,
                        color: cores.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // TÍTULO DA LISTA
            if (_receitaId != null)
              Text(
                'Lista de ingredientes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: corTexto,
                ),
              ),

            const SizedBox(height: 12),

            // LISTA DE INGREDIENTES
            Expanded(
              child: _carregando
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _receitaId == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.menu_book_outlined,
                                size: 65,
                                color: corSecundaria,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Selecione uma receita',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: corTexto,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Escolha uma receita para acompanhar seus ingredientes.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: corSecundaria,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        )
                      : _ingredientes.isEmpty
                          ? Center(
                              child: Text(
                                'Nenhum ingrediente cadastrado.',
                                style: TextStyle(
                                  color: corSecundaria,
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                // MENSAGEM DE CONCLUSÃO
                                if (todosComprados)
                                  Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(
                                      bottom: 12,
                                    ),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: cores.primaryContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: cores.onPrimaryContainer,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'Tudo pronto! Você já possui todos os ingredientes.',
                                            style: TextStyle(
                                              color: cores.onPrimaryContainer,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                // LISTA
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: _ingredientes.length,
                                    itemBuilder: (context, index) {
                                      final ingrediente = _ingredientes[index];

                                      final comprado =
                                          ingrediente['comprado'] == 1;

                                      return Card(
                                        color: comprado
                                            ? cores.primaryContainer
                                            : cores.surface,
                                        elevation: 1,
                                        margin: const EdgeInsets.only(
                                          bottom: 10,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          side: BorderSide(
                                            color: cores.outlineVariant,
                                          ),
                                        ),
                                        child: CheckboxListTile(
                                          activeColor: corPrincipal,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 4,
                                          ),
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                          title: Text(
                                            ingrediente['nome'],
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: corTexto,
                                              decoration: comprado
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                            ),
                                          ),
                                          subtitle: Text(
                                            comprado
                                                ? 'Ingrediente comprado'
                                                : 'Pendente',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: comprado
                                                  ? corPrincipal
                                                  : corSecundaria,
                                            ),
                                          ),
                                          value: comprado,
                                          onChanged: (valor) {
                                            _marcarComprado(
                                              ingrediente['id'] as int,
                                              valor ?? false,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
