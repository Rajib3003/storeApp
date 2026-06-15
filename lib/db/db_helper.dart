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
      version: 3,
      onCreate: (db, version) async {

        // Category
        await db.execute('''
        CREATE TABLE categories(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category_name TEXT NOT NULL
        )
        ''');

        // Brand
        await db.execute('''
        CREATE TABLE brands(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          brand_name TEXT NOT NULL
        )
        ''');

        // Color
        await db.execute('''
        CREATE TABLE colors(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          color_name TEXT NOT NULL
        )
        ''');

        // Size
        await db.execute('''
        CREATE TABLE sizes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          size_name TEXT NOT NULL
        )
        ''');

        // Suppliers
        await db.execute('''
        CREATE TABLE suppliers(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          supplier_name TEXT,
          phone TEXT,
          address TEXT
        )
        ''');

        // Customers
        await db.execute('''
        CREATE TABLE customers(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          customer_name TEXT,
          phone TEXT,
          address TEXT,
          total_due REAL DEFAULT 0
        )
        ''');

        // Users
        await db.execute('''
        CREATE TABLE users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          phone TEXT UNIQUE,
          pin TEXT,
          role_id INTEGER,
          created_at TEXT,
          FOREIGN KEY(role_id)
          REFERENCES roles(id)

        )
        ''');
        // Roles
        await db.execute('''
        CREATE TABLE roles(

        id INTEGER PRIMARY KEY AUTOINCREMENT,

        role_name TEXT NOT NULL UNIQUE

        )
        ''');

        // Settings
        await db.execute('''
        CREATE TABLE settings(
          id INTEGER PRIMARY KEY,
          shop_name TEXT,
          owner_name TEXT,
          phone TEXT,
          address TEXT,
          currency TEXT
        )
        ''');

        // Products
        await db.execute('''
        CREATE TABLE products(
          id INTEGER PRIMARY KEY AUTOINCREMENT,

          barcode TEXT UNIQUE,

          name TEXT NOT NULL,

          photo TEXT,

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

        // Purchases
        await db.execute('''
        CREATE TABLE purchases(
          id INTEGER PRIMARY KEY AUTOINCREMENT,

          supplier_id INTEGER,

          total_amount REAL,

          purchase_date TEXT,

          created_at TEXT
        )
        ''');

        // Purchase Items
        await db.execute('''
        CREATE TABLE purchase_items(
          id INTEGER PRIMARY KEY AUTOINCREMENT,

          purchase_id INTEGER,

          product_id INTEGER,

          qty INTEGER,

          purchase_price REAL,

          total REAL
        )
        ''');

        // Sales (Invoice)
        await db.execute('''
        CREATE TABLE sales(
          id INTEGER PRIMARY KEY AUTOINCREMENT,

          customer_id INTEGER,

          subtotal REAL,

          discount REAL DEFAULT 0,

          grand_total REAL,

          payment_method TEXT,

          created_at TEXT
        )
        ''');

        // Sale Items
        await db.execute('''
        CREATE TABLE sale_items(
          id INTEGER PRIMARY KEY AUTOINCREMENT,

          sale_id INTEGER,

          product_id INTEGER,

          qty INTEGER,

          purchase_price REAL,

          sell_price REAL,

          discount REAL DEFAULT 0,

          total REAL,

          profit REAL
        )
        ''');

        // Expense Categories
        await db.execute('''
        CREATE TABLE expense_categories(
          id INTEGER PRIMARY KEY AUTOINCREMENT,

          name TEXT
        )
        ''');

        // Expenses
        await db.execute('''
        CREATE TABLE expenses(
          id INTEGER PRIMARY KEY AUTOINCREMENT,

          category_id INTEGER,

          amount REAL,

          note TEXT,

          expense_date TEXT
        )
        ''');

        // Stock History
        await db.execute('''
        CREATE TABLE stock_history(
          id INTEGER PRIMARY KEY AUTOINCREMENT,

          product_id INTEGER,

          old_stock INTEGER,

          new_stock INTEGER,

          qty INTEGER,

          action_type TEXT,

          created_at TEXT
        )
        ''');

        // Customer Payments
        await db.execute('''
        CREATE TABLE customer_payments(
          id INTEGER PRIMARY KEY AUTOINCREMENT,

          customer_id INTEGER,

          amount REAL,

          payment_date TEXT,

          note TEXT
        )
        ''');

        // Backup Logs
        await db.execute('''
        CREATE TABLE backup_logs(
          id INTEGER PRIMARY KEY AUTOINCREMENT,

          file_name TEXT,

          google_drive_file_id TEXT,

          backup_date TEXT,

          status TEXT
        )
        ''');

      }
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

