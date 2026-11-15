import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class BancoDados {
  static Database? _db;

  static Future<Database> abrirBanco() async {
    if (_db != null) {
      return _db!;
    }

    final caminho = p.join(
      await getDatabasesPath(),
      'receitas.db',
    );

    _db = await openDatabase(
      caminho,
      version: 2,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE receitas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            tempoPreparo INTEGER NOT NULL,
            porcoes INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE ingredientes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            receitaId INTEGER NOT NULL,
            nome TEXT NOT NULL,
            comprado INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (receitaId) REFERENCES receitas(id)
              ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE estoque (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL COLLATE NOCASE UNIQUE
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE estoque (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nome TEXT NOT NULL COLLATE NOCASE UNIQUE
            )
          ''');
        }
      },
    );

    return _db!;
  }

  // CADASTRAR RECEITA
  static Future<int> adicionarReceita(
    String nome,
    int tempoPreparo,
    int porcoes,
    List<String> ingredientes,
  ) async {
    final db = await abrirBanco();

    return db.transaction((txn) async {
      final receitaId = await txn.insert('receitas', {
        'nome': nome,
        'tempoPreparo': tempoPreparo,
        'porcoes': porcoes,
      });

      for (final ingrediente in ingredientes) {
        await txn.insert('ingredientes', {
          'receitaId': receitaId,
          'nome': ingrediente,
          'comprado': 0,
        });
      }

      return receitaId;
    });
  }

  // PESQUISAR RECEITAS E CONTAR INGREDIENTES
  static Future<List<Map<String, dynamic>>> listarReceitas(
    String busca,
    int filtroTempo,
    bool somenteEstoque,
  ) async {
    final db = await abrirBanco();

    final condicoes = <String>[];
    final argumentos = <dynamic>[];

    // Pesquisa pelo nome da receita ou pelo nome do ingrediente.
    if (busca.trim().isNotEmpty) {
      condicoes.add('''
        (
          r.nome LIKE ?
          OR r.id IN (
            SELECT receitaId
            FROM ingredientes
            WHERE nome LIKE ?
          )
        )
      ''');

      final termo = '%${busca.trim()}%';

      argumentos.add(termo);
      argumentos.add(termo);
    }

    // FILTRO DE TEMPO
    if (filtroTempo == 1) {
      condicoes.add('r.tempoPreparo <= ?');
      argumentos.add(30);
    } else if (filtroTempo == 2) {
      condicoes.add('r.tempoPreparo BETWEEN ? AND ?');
      argumentos.add(31);
      argumentos.add(60);
    } else if (filtroTempo == 3) {
      condicoes.add('r.tempoPreparo > ?');
      argumentos.add(60);
    }

    final where = condicoes.isEmpty
        ? ''
        : 'WHERE ${condicoes.join(' AND ')}';

    // FILTRO DE ESTOQUE:
    // Exibe somente receitas com pelo menos 3 ingredientes disponíveis.
    final having = somenteEstoque
        ? '''
          HAVING SUM(
            CASE WHEN e.id IS NOT NULL THEN 1 ELSE 0 END
          ) >= 3
        '''
        : '';

    return db.rawQuery('''
      SELECT
        r.*,

        COUNT(i.id) AS totalIngredientes,

        SUM(
          CASE
            WHEN e.id IS NOT NULL THEN 1
            ELSE 0
          END
        ) AS ingredientesDisponiveis,

        SUM(
          CASE
            WHEN i.id IS NOT NULL AND e.id IS NULL THEN 1
            ELSE 0
          END
        ) AS ingredientesFaltantes

      FROM receitas r

      LEFT JOIN ingredientes i
        ON i.receitaId = r.id

      LEFT JOIN estoque e
        ON LOWER(TRIM(e.nome)) = LOWER(TRIM(i.nome))

      $where

      GROUP BY r.id

      $having

      ORDER BY r.nome COLLATE NOCASE
    ''', argumentos);
  }

  // LISTAR INGREDIENTES DE UMA RECEITA
  static Future<List<Map<String, dynamic>>> listarIngredientes(
    int receitaId,
  ) async {
    final db = await abrirBanco();

    return db.query(
      'ingredientes',
      where: 'receitaId = ?',
      whereArgs: [receitaId],
      orderBy: 'nome COLLATE NOCASE',
    );
  }

  // ATUALIZAR CHECKLIST DE COMPRA
  static Future<int> atualizarIngrediente(
    int id,
    bool comprado,
  ) async {
    final db = await abrirBanco();

    return db.update(
      'ingredientes',
      {
        'comprado': comprado ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ADICIONAR INGREDIENTE AO ESTOQUE
  static Future<int> adicionarEstoque(String nome) async {
    final db = await abrirBanco();

    return db.insert(
      'estoque',
      {
        'nome': nome.trim(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // LISTAR ESTOQUE
  static Future<List<Map<String, dynamic>>> listarEstoque() async {
    final db = await abrirBanco();

    return db.query(
      'estoque',
      orderBy: 'nome COLLATE NOCASE',
    );
  }

  // REMOVER INGREDIENTE DO ESTOQUE
  static Future<int> removerEstoque(int id) async {
    final db = await abrirBanco();

    return db.delete(
      'estoque',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}