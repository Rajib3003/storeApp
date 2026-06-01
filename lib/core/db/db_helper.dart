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
      version: 2,
      onCreate: (db, version) async {
         await db.execute('''
          CREATE TABLE categories (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              category_name TEXT
          )
          ''');

          await db.execute('''
          CREATE TABLE brands (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              brand_name TEXT
          )
          ''');

          await db.execute('''
          CREATE TABLE colors (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              color_name TEXT
          )
          ''');

          await db.execute('''
          CREATE TABLE sizes (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              size_name TEXT
          )
          ''');

          await db.execute('''
          CREATE TABLE products (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              barcode TEXT UNIQUE,
              name TEXT,
              category_id INTEGER,
              brand_id INTEGER,
              size_id INTEGER,
              color_id INTEGER,
              purchase_price REAL,
              selling_price REAL,
              stock INTEGER DEFAULT 0,
              low_stock_alert INTEGER DEFAULT 2,
              created_at TEXT,
              updated_at TEXT
          )
          ''');

          await db.execute('''
          CREATE TABLE customers (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              customer_name TEXT,
              phone TEXT,
              address TEXT,
              total_due REAL DEFAULT 0
          )
          ''');

          await db.execute('''
          CREATE TABLE sales (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              invoice_no TEXT,
              customer_id INTEGER,
              total_amount REAL,
              discount REAL,
              paid_amount REAL,
              due_amount REAL,
              profit REAL,
              sale_date TEXT
          )
          ''');

          await db.execute('''
          CREATE TABLE sale_items (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              sale_id INTEGER,
              product_id INTEGER,
              qty INTEGER,
              purchase_price REAL,
              sell_price REAL,
              total REAL,
              profit REAL
          )
          ''');

          await db.execute('''
          CREATE TABLE stock_history (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              product_id INTEGER,
              old_stock INTEGER,
              new_stock INTEGER,
              qty INTEGER,
              action_type TEXT,
              created_at TEXT
          )
          ''');

          await db.execute('''
          CREATE TABLE purchases (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              supplier_name TEXT,
              total_amount REAL,
              purchase_date TEXT
          )
          ''');

          await db.execute('''
          CREATE TABLE purchase_items (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              purchase_id INTEGER,
              product_id INTEGER,
              qty INTEGER,
              purchase_price REAL,
              total REAL
          )
          ''');

          await db.execute('''
          CREATE TABLE expenses (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              expense_type TEXT,
              amount REAL,
              note TEXT,
              expense_date TEXT
          )
          ''');

          await db.execute('''
          CREATE TABLE users (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT,
              password TEXT,
              role TEXT
          )
          ''');

          await db.execute('''
          CREATE TABLE customer_payments (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              customer_id INTEGER,
              amount REAL,
              payment_date TEXT,
              note TEXT
          )
          ''');

          await db.execute('''
          CREATE TABLE backup_logs (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              backup_date TEXT,
              backup_type TEXT
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