import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'database/banco_dados.dart';
import 'models/receita.dart';
import 'pages/pesquisa_receita.dart';
import 'pages/adiciona_receita.dart';
import 'pages/acompanha_receita.dart';
import 'pages/estoque_ingredientes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await BancoDados.abrirBanco();

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PaginaPrincipal(),
    ),
  );
}

class PaginaPrincipal extends StatefulWidget {
  const PaginaPrincipal({super.key});

  @override
  State<PaginaPrincipal> createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {
  int _paginaAtual = 0;
  int _atualizacao = 0;
  Receita? _receitaSelecionada;

  @override
  Widget build(BuildContext context) {
    final paginas = [
      PesquisaReceitaPage(
        key: ValueKey(_atualizacao),
        onSelecionar: (receita) {
          setState(() {
            _receitaSelecionada = receita;
            _paginaAtual = 2;
          });
        },
      ),
      AdicionaReceitaPage(
        onSalvou: () {
          setState(() {
            _atualizacao++;
          });
        },
      ),
      AcompanhaReceitaPage(
        receitaSelecionada: _receitaSelecionada,
      ),
      const EstoqueIngredientesPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _paginaAtual,
        children: paginas,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaAtual,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _paginaAtual = index;

            if (index == 0) {
              _atualizacao++;
            }
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Pesquisar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Cadastrar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Acompanhar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Estoque',
          ),
        ],
      ),
    );
  }
}
