
import 'package:flutter/material.dart';
import '../database/banco_dados.dart';

class AdicionaReceitaPage extends StatefulWidget {
  final VoidCallback onSalvou;

  const AdicionaReceitaPage({
    super.key,
    required this.onSalvou,
  });

  @override
  State<AdicionaReceitaPage> createState() =>
      _AdicionaReceitaPageState();
}

class _AdicionaReceitaPageState extends State<AdicionaReceitaPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _tempoController = TextEditingController();
  final TextEditingController _porcoesController = TextEditingController();
  final TextEditingController _ingredientesController =
      TextEditingController();

  bool _salvando = false;

  // ADICIONAR RECEITA
  Future<void> _adicionarReceita() async {
    if (_salvando) return;

    final nome = _nomeController.text.trim();

    final tempo = int.tryParse(_tempoController.text) ?? 0;

    final porcoes = int.tryParse(_porcoesController.text) ?? 0;

    final ingredientes = _ingredientesController.text
        .split(',')
        .map((i) => i.trim())
        .where((i) => i.isNotEmpty)
        .toSet()
        .toList();

    if (nome.isEmpty ||
        tempo <= 0 ||
        porcoes <= 0 ||
        ingredientes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos corretamente!'),
          backgroundColor: Colors.deepOrange,
        ),
      );

      return;
    }

    setState(() {
      _salvando = true;
    });

    try {
      await BancoDados.adicionarReceita(
        nome,
        tempo,
        porcoes,
        ingredientes,
      );

      if (!mounted) return;

      _nomeController.clear();
      _tempoController.clear();
      _porcoesController.clear();
      _ingredientesController.clear();

      widget.onSalvou();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Receita cadastrada com sucesso!'),
          backgroundColor: Color(0xFF2E7D5B),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível cadastrar a receita.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _tempoController.dispose();
    _porcoesController.dispose();
    _ingredientesController.dispose();

    super.dispose();
  }

  // CAMPO PERSONALIZADO
  Widget _campo({
    required String titulo,
    required String dica,
    required IconData icone,
    required TextEditingController controller,
    TextInputType teclado = TextInputType.text,
    int linhas = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF26352D),
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          keyboardType: teclado,
          maxLines: linhas,
          decoration: InputDecoration(
            hintText: dica,
            prefixIcon: Icon(icone),
            alignLabelWithHint: linhas > 1,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final corPrincipal = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nova receita',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // CABEÇALHO
            const Text(
              'Compartilhe uma receita!',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Color(0xFF26352D),
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Cadastre os detalhes para encontrar e preparar sua receita depois.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 22),

            // INFORMAÇÕES DA RECEITA
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),

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
                        Icons.restaurant_menu,
                        color: Color(0xFF2E7D5B),
                      ),

                      SizedBox(width: 8),

                      Text(
                        'Informações da receita',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF26352D),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  _campo(
                    titulo: 'Nome da receita',
                    dica: 'Ex: Bolo de cenoura',
                    icone: Icons.restaurant,
                    controller: _nomeController,
                  ),

                  const SizedBox(height: 18),

                  _campo(
                    titulo: 'Tempo de preparo',
                    dica: 'Ex: 40',
                    icone: Icons.access_time,
                    controller: _tempoController,
                    teclado: TextInputType.number,
                  ),

                  const SizedBox(height: 18),

                  _campo(
                    titulo: 'Quantidade de porções',
                    dica: 'Ex: 4',
                    icone: Icons.people_outline,
                    controller: _porcoesController,
                    teclado: TextInputType.number,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // INGREDIENTES
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),

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
                        Icons.shopping_basket_outlined,
                        color: Color(0xFF2E7D5B),
                      ),

                      SizedBox(width: 8),

                      Text(
                        'Ingredientes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF26352D),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Informe todos os ingredientes necessários para preparar a receita.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 16),

                  _campo(
                    titulo: 'Lista de ingredientes',
                    dica: 'Ex: farinha, ovos, leite, açúcar',
                    icone: Icons.list_alt,
                    controller: _ingredientesController,
                    linhas: 4,
                  ),

                  const SizedBox(height: 10),

                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Color(0xFF2E7D5B),
                      ),

                      SizedBox(width: 6),

                      Expanded(
                        child: Text(
                          'Separe cada ingrediente utilizando uma vírgula.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // BOTÃO CADASTRAR
            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton.icon(
                onPressed: _salvando ? null : _adicionarReceita,

                icon: _salvando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),

                label: Text(
                  _salvando
                      ? 'Salvando receita...'
                      : 'Cadastrar receita',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
