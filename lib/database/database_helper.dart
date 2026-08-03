import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/diary_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'diary_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        is_encrypted INTEGER NOT NULL DEFAULT 0,
        analyzed_for_patterns INTEGER NOT NULL DEFAULT 0,
        entry_type TEXT,
        ai_insight TEXT,
        who TEXT,
        "where" TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE insights(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        date_generated TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertEntry(DiaryEntry entry) async {
    Database db = await database;
    return await db.insert(
      'entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DiaryEntry>> getAllEntries() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('entries', orderBy: 'timestamp DESC');
    return List.generate(maps.length, (i) {
      return DiaryEntry.fromMap(maps[i]);
    });
  }

  Future<List<DiaryEntry>> getEntriesForAnalysis() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'entries',
      where: 'is_encrypted = 0 AND analyzed_for_patterns = 0',
      orderBy: 'timestamp ASC',
    );
    return List.generate(maps.length, (i) {
      return DiaryEntry.fromMap(maps[i]);
    });
  }

  Future<int> updateEntry(DiaryEntry entry) async {
    Database db = await database;
    return await db.update(
      'entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<List<DiaryEntry>> searchUnencryptedEntries(String query) async {
    Database db = await database;
    
    List<String> words = query.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return [];

    final stopWords = {'when', 'i', 'my', 'the', 'a', 'to', 'what', 'where', 'how'};
    
    List<String> filteredWords = words
        .where((word) => !stopWords.contains(word.toLowerCase()))
        .toList();

    if (filteredWords.isEmpty) return [];

    String whereClause = 'is_encrypted = 0 AND (';
    List<dynamic> whereArgs = [];

    for (int i = 0; i < filteredWords.length; i++) {
      whereClause += 'content LIKE ?';
      if (i < filteredWords.length - 1) {
        whereClause += ' OR ';
      }
      whereArgs.add('%${filteredWords[i]}%');
    }
    whereClause += ')';

    final List<Map<String, dynamic>> maps = await db.query(
      'entries',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'timestamp DESC',
      limit: 20,
    );

    return List.generate(maps.length, (i) {
      return DiaryEntry.fromMap(maps[i]);
    });
  }

  Future<List<Map<String, dynamic>>> getInsights() async {
    Database db = await database;
    return await db.query(
      'insights',
      orderBy: 'date_generated DESC',
    );
  }

  Future<void> insertInsight(String content) async {
    Database db = await database;
    await db.insert(
      'insights',
      {
        'content': content,
        'date_generated': DateTime.now().toIso8601String(),
      },
    );
  }
}
