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

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    // WORK ENTRIES
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

    // FINANCE
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

    // PROFILE / SETTINGS
    await db.execute('''
    CREATE TABLE profile (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      operator_name TEXT,
      mobile_number TEXT,
      company_name TEXT,
      default_machine_type TEXT,
      default_job_type TEXT,
      currency TEXT,
      profile_image TEXT
    )
    ''');
  }

  // ================= WORK =================

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

  // ================= FINANCE =================

  Future<int> insertFinanceRecord(FinanceRecord record) async {
    final db = await database;

    return await db.insert('finance_records', record.toMap());
  }

  Future<List<FinanceRecord>> getAllFinanceRecords() async {
    final db = await database;

    final result = await db.query('finance_records', orderBy: 'id DESC');

    return result.map((e) => FinanceRecord.fromMap(e)).toList();
  }

  Future<int> deleteFinanceRecord(int id) async {
    final db = await database;

    return await db.delete('finance_records', where: 'id=?', whereArgs: [id]);
  }

  // ================= PROFILE =================

  Future<int> saveProfile(Map<String, dynamic> data) async {
    final db = await database;

    await db.delete('profile');

    return await db.insert('profile', data);
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final db = await database;

    final result = await db.query('profile', limit: 1);

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  // ================= DASHBOARD =================

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

    // Get today's date in dd-MM-yyyy format
    final today = _formatDateForQuery(DateTime.now());

    final result = await db.rawQuery(
      'SELECT SUM(total) as total FROM diary_entries WHERE work_date = ?',
      [today],
    );

    return ((result.first['total'] ?? 0) as num).toDouble();
  }

  Future<double> getWeeklyEarning() async {
    final db = await database;

    // Get the current week's start (Monday) and end (Sunday)
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    final startDate = _formatDateForQuery(startOfWeek);
    final endDate = _formatDateForQuery(endOfWeek);

    final result = await db.rawQuery(
      '''SELECT SUM(total) as total FROM diary_entries
         WHERE work_date >= ? AND work_date <= ?''',
      [startDate, endDate],
    );

    return ((result.first['total'] ?? 0) as num).toDouble();
  }

  Future<double> getMonthlyEarning() async {
    final db = await database;

    // Get the current month's first and last day
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);

    final startDate = _formatDateForQuery(firstDay);
    final endDate = _formatDateForQuery(lastDay);

    final result = await db.rawQuery(
      '''SELECT SUM(total) as total FROM diary_entries
         WHERE work_date >= ? AND work_date <= ?''',
      [startDate, endDate],
    );

    return ((result.first['total'] ?? 0) as num).toDouble();
  }

  // Helper method to format date for database queries (dd-MM-yyyy)
  String _formatDateForQuery(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day-$month-$year';
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
    final earning = await getTotalEarning();
    final received = await getTotalFinanceReceived();

    return earning - received;
  }

  Future<int> updateFinanceRecord(FinanceRecord record) async {
    final db = await database;

    return await db.update(
      'finance_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }
}
