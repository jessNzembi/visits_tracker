import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/visit.dart';
import '../models/activity.dart';
import '../models/customer.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(
      databasePath,
      'visits_tracker.db',
    );

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // when db is creation for the first time
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE visits(
        id INTEGER PRIMARY KEY, -- Assuming backend provides ID, remove AUTOINCREMENT for manual IDs
        customer_id INTEGER,
        visit_date INTEGER, -- Store as Unix timestamp
        status TEXT,
        location TEXT,
        notes TEXT,
        activities_done TEXT, -- Store as JSON string
        created_at INTEGER, -- Store as Unix timestamp
        -- Denormalized UI fields for faster access if needed (optional)
        customer_name TEXT,
        activity_descriptions TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE activities(
        id INTEGER PRIMARY KEY,
        description TEXT,
        created_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE customers(
        id INTEGER PRIMARY KEY,
        name TEXT,
        created_at INTEGER
      )
    ''');
  }

  // CRUD Operations for Visits

  Future<int> insertVisit(Visit visit) async {
    final db = await database;
    // Used conflictAlgorithm: ConflictAlgorithm.replace to handle cases where
    // a visit might already exist (e.g., re-fetching from API)
    return await db.insert(
      'visits',
      visit.toSqlMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Visit>> getVisits() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('visits');
    return List.generate(maps.length, (i) {
      return Visit.fromSqlMap(maps[i]);
    });
  }

  Future<int> updateVisit(Visit visit) async {
    final db = await database;
    return await db.update(
      'visits',
      visit.toSqlMap(),
      where: 'id = ?',
      whereArgs: [visit.id],
    );
  }

  Future<int> deleteVisit(int id) async {
    final db = await database;
    return await db.delete('visits', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllVisits() async {
    final db = await database;
    return await db.delete('visits');
  }

  // CRUD Operations for Activities (Fetch Only)

  Future<int> insertActivity(Activity activity) async {
    final db = await database;
    return await db.insert(
      'activities',
      activity.toSqlMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Activity>> getActivities() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('activities');
    return List.generate(maps.length, (i) {
      return Activity.fromSqlMap(maps[i]);
    });
  }

  Future<int> deleteAllActivities() async {
    final db = await database;
    return await db.delete('activities');
  }

  // --- CRUD Operations for Customers (Fetch Only) ---

  Future<int> insertCustomer(Customer customer) async {
    final db = await database;
    return await db.insert(
      'customers',
      customer.toSqlMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Customer>> getCustomers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('customers');
    return List.generate(maps.length, (i) {
      return Customer.fromSqlMap(maps[i]);
    });
  }

  Future<int> deleteAllCustomers() async {
    final db = await database;
    return await db.delete('customers');
  }
}
