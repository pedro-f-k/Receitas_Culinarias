import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class BancoDados {
  static Database? _db;

  static Future<Database> abrirBanco() async {
    if (_db != null) return _db!;

    final caminho = p.join(await getDatabasesPath(), 'receitas.db');

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

  // Retorna também a quantidade total, disponível e faltante
  // de ingredientes de cada receita.
  static Future<List<Map<String, dynamic>>> listarReceitas(
    String busca,
    int filtroTempo,
    bool somenteEstoque,
  ) async {
    final db = await abrirBanco();

    final condicoes = <String>[];
    final argumentos = <dynamic>[];

    if (busca.trim().isNotEmpty) {
      condicoes.add('''
        (
          receitas.nome LIKE ?
          OR receitas.id IN (
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

    if (filtroTempo == 1) {
      condicoes.add('receitas.tempoPreparo <= ?');
      argumentos.add(30);
    } else if (filtroTempo == 2) {
      condicoes.add('receitas.tempoPreparo BETWEEN ? AND ?');
      argumentos.add(31);
      argumentos.add(60);
    } else if (filtroTempo == 3) {
      condicoes.add('receitas.tempoPreparo > ?');
      argumentos.add(60);
    }

    // Com o filtro ativado, exige pelo menos 3 ingredientes no estoque,
    // em vez de exigir que todos os ingredientes estejam disponíveis.
    if (somenteEstoque) {
      condicoes.add('''
        (
          SELECT COUNT(*)
          FROM ingredientes i
          WHERE i.receitaId = receitas.id
            AND EXISTS (
              SELECT 1
              FROM estoque e
              WHERE LOWER(TRIM(e.nome)) = LOWER(TRIM(i.nome))
            )
        ) >= 3
      ''');
    }

    final where = condicoes.isEmpty
        ? ''
        : 'WHERE ${condicoes.join(' AND ')}';

    return db.rawQuery('''
      SELECT
        receitas.*,
        (
          SELECT COUNT(*)
          FROM ingredientes i
          WHERE i.receitaId = receitas.id
        ) AS totalIngredientes,
        (
          SELECT COUNT(*)
          FROM ingredientes i
          WHERE i.receitaId = receitas.id
            AND EXISTS (
              SELECT 1
              FROM estoque e
              WHERE LOWER(TRIM(e.nome)) = LOWER(TRIM(i.nome))
            )
        ) AS ingredientesDisponiveis,
        (
          SELECT COUNT(*)
          FROM ingredientes i
          WHERE i.receitaId = receitas.id
            AND NOT EXISTS (
              SELECT 1
              FROM estoque e
              WHERE LOWER(TRIM(e.nome)) = LOWER(TRIM(i.nome))
            )
        ) AS ingredientesFaltantes
      FROM receitas
      $where
      ORDER BY receitas.nome COLLATE NOCASE
    ''', argumentos);
  }

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

  static Future<int> atualizarIngrediente(int id, bool comprado) async {
    final db = await abrirBanco();

    return db.update(
      'ingredientes',
      {'comprado': comprado ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> adicionarEstoque(String nome) async {
    final db = await abrirBanco();

    return db.insert(
      'estoque',
      {'nome': nome.trim()},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<List<Map<String, dynamic>>> listarEstoque() async {
    final db = await abrirBanco();

    return db.query('estoque', orderBy: 'nome COLLATE NOCASE');
  }

  static Future<int> removerEstoque(int id) async {
    final db = await abrirBanco();

    return db.delete(
      'estoque',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
