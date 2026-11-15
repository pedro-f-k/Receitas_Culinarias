
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

  bool _carregando = true;
  bool _adicionando = false;

  // CARREGAR ESTOQUE
  Future<void> _carregarEstoque() async {
    final linhas = await BancoDados.listarEstoque();

    if (!mounted) return;

    setState(() {
      _ingredientes.clear();
      _ingredientes.addAll(linhas);
      _carregando = false;
    });
  }

  // ADICIONAR INGREDIENTE
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

    setState(() {
      _adicionando = true;
    });

    try {
      await BancoDados.adicionarEstoque(nome);

      if (!mounted) return;

      _nomeController.clear();

      await _carregarEstoque();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingrediente adicionado ao estoque!'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _adicionando = false;
        });
      }
    }
  }

  // REMOVER INGREDIENTE
  Future<void> _removerIngrediente(int id) async {
    await BancoDados.removerEstoque(id);

    await _carregarEstoque();
  }

  // CONFIRMAR REMOÇÃO
  void _confirmarRemocao(Map<String, dynamic> ingrediente) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remover ingrediente?'),
          content: Text(
            'Deseja remover "${ingrediente['nome']}" do seu estoque?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _removerIngrediente(ingrediente['id']);
              },
              child: const Text('Remover'),
            ),
          ],
        );
      },
    );
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
    final corPrincipal = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estoque de Ingredientes'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // CABEÇALHO
            const Text(
              'Seus ingredientes',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF26352D),
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Cadastre os ingredientes que você já tem em casa.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 20),

            // CAMPO DE CADASTRO
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    'Adicionar ingrediente',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF26352D),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: _nomeController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Nome do ingrediente',
                      hintText: 'Ex: Ovos, leite, farinha...',
                      prefixIcon: Icon(Icons.restaurant_outlined),
                    ),
                    onSubmitted: (_) => _adicionarIngrediente(),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          _adicionando ? null : _adicionarIngrediente,
                      icon: const Icon(Icons.add),
                      label: Text(
                        _adicionando
                            ? 'Adicionando...'
                            : 'Adicionar ingrediente',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // TÍTULO DA LISTA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ingredientes cadastrados',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF26352D),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F3EC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_ingredientes.length} itens',
                    style: TextStyle(
                      color: corPrincipal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // LISTA DE INGREDIENTES
            Expanded(
              child: _carregando
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _ingredientes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),

                              const SizedBox(height: 12),

                              const Text(
                                'Seu estoque está vazio',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF26352D),
                                ),
                              ),

                              const SizedBox(height: 6),

                              const Text(
                                'Adicione ingredientes para começar.',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _ingredientes.length,
                          itemBuilder: (context, index) {
                            final ingrediente = _ingredientes[index];

                            return Card(
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F3EC),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.eco_outlined,
                                    color: corPrincipal,
                                  ),
                                ),

                                title: Text(
                                  ingrediente['nome'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF26352D),
                                  ),
                                ),

                                subtitle: const Text(
                                  'Disponível no estoque',
                                ),

                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () {
                                    _confirmarRemocao(ingrediente);
                                  },
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
