import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Recuperar preferência de tema salva
  final preferencias = await SharedPreferences.getInstance();
  final modoEscuro = preferencias.getBool('modo_escuro') ?? false;

  runApp(Aplicativo(modoEscuroInicial: modoEscuro));
}

// APLICATIVO
class Aplicativo extends StatefulWidget {
  final bool modoEscuroInicial;

  const Aplicativo({
    super.key,
    required this.modoEscuroInicial,
  });

  @override
  State<Aplicativo> createState() => _AplicativoState();
}

class _AplicativoState extends State<Aplicativo> {
  late bool _modoEscuro;

  @override
  void initState() {
    super.initState();
    _modoEscuro = widget.modoEscuroInicial;
  }

  // ALTERAR E SALVAR TEMA
  Future<void> _alternarTema() async {
    setState(() {
      _modoEscuro = !_modoEscuro;
    });

    final preferencias = await SharedPreferences.getInstance();

    await preferencias.setBool('modo_escuro', _modoEscuro);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: TemaAplicativo.temaClaro,
      darkTheme: TemaAplicativo.temaEscuro,
      themeMode: _modoEscuro ? ThemeMode.dark : ThemeMode.light,
      home: PaginaPrincipal(
        modoEscuro: _modoEscuro,
        alternarTema: _alternarTema,
      ),
    );
  }
}

// TEMAS VISUAIS DO APLICATIVO
class TemaAplicativo {
  // TEMA CLARO
  static final ThemeData temaClaro = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2E7D5B),
      brightness: Brightness.light,
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

  // TEMA ESCURO
  static final ThemeData temaEscuro = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF81A88E),
      brightness: Brightness.dark,
      primary: const Color(0xFF81A88E),
      secondary: const Color(0xFFA5C9AE),
      surface: const Color(0xFF26352D),
    ),
    scaffoldBackgroundColor: const Color(0xFF18231D),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF18231D),
      foregroundColor: Color(0xFFF1F5F2),
      elevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF26352D),
      labelStyle: const TextStyle(
        color: Color(0xFFB5C2B9),
      ),
      hintStyle: const TextStyle(
        color: Color(0xFF89958D),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF405448)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF405448)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF81A88E),
          width: 1.5,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF81A88E),
        foregroundColor: const Color(0xFF18231D),
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
      backgroundColor: Color(0xFF26352D),
      selectedItemColor: Color(0xFFA5C9AE),
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

// PÁGINA PRINCIPAL
class PaginaPrincipal extends StatefulWidget {
  final bool modoEscuro;
  final VoidCallback alternarTema;

  const PaginaPrincipal({
    super.key,
    required this.modoEscuro,
    required this.alternarTema,
  });

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
          // QUANDO CLICAR NO TEMA
          if (index == 4) {
            widget.alternarTema();
            return;
          }

          setState(() {
            _paginaAtual = index;

            if (index == 0) {
              _atualizacao++;
            }
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Pesquisar',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Cadastrar',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Acompanhar',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Estoque',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              widget.modoEscuro
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            label: widget.modoEscuro ? 'Claro' : 'Escuro',
          ),
        ],
      ),
    );
  }
}
