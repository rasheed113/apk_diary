import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'diary_entry.dart';
import 'finance_record.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('apk_diary.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE profile
        ADD COLUMN dark_mode INTEGER DEFAULT 0
      ''');
      await db.execute('''
        ALTER TABLE profile
        ADD COLUMN selected_theme TEXT DEFAULT 'classicLight'
      ''');
    }

    if (oldVersion < 3) {
      await db.execute('''
        ALTER TABLE profile
        ADD COLUMN cover_image TEXT
      ''');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE diary_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_name TEXT NOT NULL,
        sizes TEXT,
        pieces INTEGER NOT NULL,
        rate REAL NOT NULL,
        rate_type TEXT,
        total REAL NOT NULL,
        machine_type TEXT,
        job_type TEXT,
        notes TEXT,
        work_date TEXT,
        created_time TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE finance_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        reason TEXT,
        record_date TEXT,
        created_time TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operator_name TEXT,
        mobile_number TEXT,
        company_name TEXT,
        default_machine_type TEXT,
        default_job_type TEXT,
        currency TEXT,
        profile_image TEXT,
        cover_image TEXT,
        dark_mode INTEGER DEFAULT 0,
        selected_theme TEXT DEFAULT 'classicLight'
      )
    ''');
  }

  Future<int> insertEntry(DiaryEntry entry) async {
    final db = await database;
    return await db.insert('diary_entries', entry.toMap());
  }

  Future<List<DiaryEntry>> getAllEntries() async {
    final db = await database;
    final result = await db.query('diary_entries', orderBy: 'id DESC');
    return result.map((e) => DiaryEntry.fromMap(e)).toList();
  }

  Future<int> updateEntry(DiaryEntry entry) async {
    final db = await database;
    return await db.update(
      'diary_entries',
      entry.toMap(),
      where: 'id=?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteEntry(int id) async {
    final db = await database;
    return await db.delete('diary_entries', where: 'id=?', whereArgs: [id]);
  }

  Future<int> insertFinanceRecord(FinanceRecord record) async {
    final db = await database;
    return await db.insert('finance_records', record.toMap());
  }

  Future<List<FinanceRecord>> getAllFinanceRecords() async {
    final db = await database;
    final result = await db.query('finance_records', orderBy: 'id DESC');
    return result.map((e) => FinanceRecord.fromMap(e)).toList();
  }

  Future<int> updateFinanceRecord(FinanceRecord record) async {
    final db = await database;
    return await db.update(
      'finance_records',
      record.toMap(),
      where: 'id=?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteFinanceRecord(int id) async {
    final db = await database;
    return await db.delete('finance_records', where: 'id=?', whereArgs: [id]);
  }

  Future<int> saveProfile(Map<String, dynamic> data) async {
    final db = await database;
    await db.delete('profile');
    return await db.insert('profile', data);
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final db = await database;
    final result = await db.query('profile', limit: 1);
    if (result.isEmpty) return null;
    return result.first;
  }

  Future<double> getTotalEarning() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(total) as total FROM diary_entries',
    );
    return ((result.first['total'] ?? 0) as num).toDouble();
  }

  Future<int> getTotalPieces() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(pieces) as total FROM diary_entries',
    );
    return ((result.first['total'] ?? 0) as num).toInt();
  }

  Future<int> getTotalEntries() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as total FROM diary_entries',
    );
    return ((result.first['total'] ?? 0) as num).toInt();
  }

  Future<double> getTodayEarning() async {
    final db = await database;
    final today = _formatDateForQuery(DateTime.now());
    final result = await db.rawQuery(
      'SELECT SUM(total) as total FROM diary_entries WHERE work_date = ?',
      [today],
    );
    return ((result.first['total'] ?? 0) as num).toDouble();
  }

  Future<double> getWeeklyEarning() async {
    final db = await database;
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day).subtract(
      Duration(days: now.weekday - 1),
    );
    final nextWeek = startOfWeek.add(const Duration(days: 7));
    final startDate = _formatDateForSql(startOfWeek);
    final nextWeekDate = _formatDateForSql(nextWeek);
    final result = await db.rawQuery(
      '''SELECT SUM(total) as total FROM diary_entries
         WHERE substr(work_date, 7, 4) || '-' || substr(work_date, 4, 2) || '-' || substr(work_date, 1, 2) >= ?
           AND substr(work_date, 7, 4) || '-' || substr(work_date, 4, 2) || '-' || substr(work_date, 1, 2) < ?''',
      [startDate, nextWeekDate],
    );
    return ((result.first['total'] ?? 0) as num).toDouble();
  }

  Future<double> getMonthlyEarning() async {
    final db = await database;
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    final startDate = _formatDateForSql(firstDay);
    final nextMonthDate = _formatDateForSql(nextMonth);
    final result = await db.rawQuery(
      '''SELECT SUM(total) as total FROM diary_entries
         WHERE substr(work_date, 7, 4) || '-' || substr(work_date, 4, 2) || '-' || substr(work_date, 1, 2) >= ?
           AND substr(work_date, 7, 4) || '-' || substr(work_date, 4, 2) || '-' || substr(work_date, 1, 2) < ?''',
      [startDate, nextMonthDate],
    );
    return ((result.first['total'] ?? 0) as num).toDouble();
  }

  String _formatDateForQuery(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day-$month-$year';
  }

  String _formatDateForSql(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '${date.year.toString().padLeft(4, '0')}-$month-$day';
  }

  Future<double> getSalaryReceived() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM finance_records
      WHERE type = 'Salary Received'
    ''');
    return ((result.first['total'] ?? 0) as num).toDouble();
  }

  Future<double> getAdvanceReceived() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM finance_records
      WHERE type = 'Advance Received'
    ''');
    return ((result.first['total'] ?? 0) as num).toDouble();
  }

  Future<double> getTotalFinanceReceived() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM finance_records',
    );
    return ((result.first['total'] ?? 0) as num).toDouble();
  }

  Future<double> getBalance() async {
    final total = await getTotalEarning();
    final received = await getTotalFinanceReceived();
    return total - received;
  }
}