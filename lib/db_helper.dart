import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'store.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {

        // 🔥 PRODUCTS TABLE
        await db.execute('''
          CREATE TABLE products(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            barcode TEXT,
            purchase_price REAL,
            selling_price REAL,
            stock INTEGER
          )
        ''');

        // 🔥 SALES TABLE
        await db.execute('''
       CREATE TABLE sales(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        barcode TEXT,
        qty INTEGER,
        sell_price REAL,
        total REAL,
        date TEXT
      )
        ''');
      },
    );
  }

  // insert product
  static Future<int> insertProduct(Map<String, dynamic> data) async {
    final dbClient = await db;
    return await dbClient.insert('products', data);
  }

  // get product by barcode
  static Future<List<Map<String, dynamic>>> getProduct(String barcode) async {
    final dbClient = await db;
    return await dbClient.query(
      'products',
      where: 'barcode = ?',
      whereArgs: [barcode],
    );
  }

  // update stock
  static Future<int> updateStock(String barcode, int stock) async {
    final dbClient = await db;
    return await dbClient.update(
      'products',
      {'stock': stock},
      where: 'barcode = ?',
      whereArgs: [barcode],
    );
  }

  // get all products
  static Future<List<Map<String, dynamic>>> getAll() async {
    final dbClient = await db;
    return await dbClient.query('products');
  }
}