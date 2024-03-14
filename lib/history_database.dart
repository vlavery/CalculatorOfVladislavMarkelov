//history_database.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class HistoryDatabase {
  static const String tableName = 'history';
  static const String columnId = 'id';
  static const String columnCalculation = 'calculation';
  static const String columnTime = 'time';

  static Future<Database> initializeDatabase() async {
    final String path = join(await getDatabasesPath(), 'history_database.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $tableName(
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnCalculation TEXT,
            $columnTime TEXT
          )
        ''');
      },
    );
  }

  static Future<void> insertHistory(String calculation) async {
    final Database db = await initializeDatabase();
    await db.insert(
      tableName,
      {
        columnCalculation: calculation,
        columnTime: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
      },
    );
  }

  static Future<List<Map<String, dynamic>>> getHistory() async {
    final Database db = await initializeDatabase();
    return db.query(tableName, orderBy: '$columnTime DESC');
  }
}
