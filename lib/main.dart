
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'database/banco_dados.dart';
import 'pages/pesquisa_receita.dart';
import 'pages/adiciona_receita.dart';
import 'pages/acompanha_receita.dart';
import 'pages/estoque_ingredientes.dart';
import 'models/receita.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await BancoDados.abrirBanco();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: TemaAplicativo.tema,
    home: const PaginaPrincipal(),
  ));
}

// Tema visual do aplicativo
class TemaAplicativo {
  static final ThemeData tema = ThemeData(
    useMaterial3: true,

    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2E7D5B),
      primary: const Color(0xFF2E7D5B),
      secondary: const Color(0xFF81A88E),
      surface: Colors.white,
    ),

    scaffoldBackgroundColor: const Color(0xFFF6F8F6),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF6F8F6),
      foregroundColor: Color(0xFF26352D),
      elevation: 0,
      centerTitle: false,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE0E7E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE0E7E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF2E7D5B),
          width: 1.5,
        ),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2E7D5B),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 15,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF2E7D5B),
      unselectedItemColor: Color(0xFF89958D),
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
      ),
      elevation: 8,
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
      EstoqueIngredientesPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _paginaAtual,
        children: paginas,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaAtual,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2E7D5B),
        unselectedItemColor: const Color(0xFF89958D),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 8,

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
            icon: Icon(Icons.add_circle_outline),
            label: 'Cadastrar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Acompanhar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Estoque',
          ),
        ],
      ),
    );
  }
}
