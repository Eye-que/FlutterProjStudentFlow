import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';

/// SQLite Database Service
/// Handles all database operations (CRUD) for tasks
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  /// Get database instance (singleton pattern)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  /// Initialize database and create tables
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  /// Create tasks table
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        subject TEXT NOT NULL,
        deadline INTEGER NOT NULL,
        priority TEXT NOT NULL,
        status TEXT NOT NULL,
        userId TEXT NOT NULL
      )
    ''');
  }

  /// Create: Insert a new task
  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  /// Read: Get all tasks for a specific user
  Future<List<Task>> getAllTasks(String userId) async {
    final db = await database;
    final maps = await db.query(
      'tasks',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'deadline ASC',
    );

    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  /// Read: Get task by ID
  Future<Task?> getTaskById(int id) async {
    final db = await database;
    final maps = await db.query('tasks', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Task.fromMap(maps.first);
    }
    return null;
  }

  /// Read: Get tasks by status
  Future<List<Task>> getTasksByStatus(String userId, String status) async {
    final db = await database;
    final maps = await db.query(
      'tasks',
      where: 'userId = ? AND status = ?',
      whereArgs: [userId, status],
      orderBy: 'deadline ASC',
    );

    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  /// Read: Get tasks by subject
  Future<List<Task>> getTasksBySubject(String userId, String subject) async {
    final db = await database;
    final maps = await db.query(
      'tasks',
      where: 'userId = ? AND subject = ?',
      whereArgs: [userId, subject],
      orderBy: 'deadline ASC',
    );

    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  /// Update: Update task details
  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  /// Update: Mark task as completed
  Future<int> completeTask(int id) async {
    final db = await database;
    return await db.update(
      'tasks',
      {'status': 'Completed'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete: Remove a task
  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  /// Get all unique subjects for a user
  Future<List<String>> getSubjects(String userId) async {
    final db = await database;
    final maps = await db.rawQuery(
      'SELECT DISTINCT subject FROM tasks WHERE userId = ?',
      [userId],
    );

    return maps.map((map) => map['subject'] as String).toList();
  }

  /// Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
