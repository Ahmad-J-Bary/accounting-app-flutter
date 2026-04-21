import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:storage/storage.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('accounting.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create accounts table
    await db.execute('''
      CREATE TABLE accounts (
        id TEXT PRIMARY KEY,
        code TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        description TEXT,
        type TEXT NOT NULL,
        parent_id TEXT,
        balance REAL DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create customers table
    await db.execute('''
      CREATE TABLE customers (
        id TEXT PRIMARY KEY,
        code TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        address TEXT,
        credit_limit REAL DEFAULT 0,
        current_balance REAL DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create suppliers table
    await db.execute('''
      CREATE TABLE suppliers (
        id TEXT PRIMARY KEY,
        code TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        address TEXT,
        tax_number TEXT,
        credit_limit REAL DEFAULT 0,
        current_balance REAL DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create products table
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        code TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        description TEXT,
        type TEXT NOT NULL,
        category_id TEXT,
        category_name TEXT,
        purchase_price REAL DEFAULT 0,
        sale_price REAL DEFAULT 0,
        cost REAL DEFAULT 0,
        unit TEXT,
        tax_rate REAL DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create sales_invoices table
    await db.execute('''
      CREATE TABLE sales_invoices (
        id TEXT PRIMARY KEY,
        invoice_number TEXT NOT NULL UNIQUE,
        customer_id TEXT NOT NULL,
        invoice_date TEXT NOT NULL,
        due_date TEXT,
        subtotal REAL DEFAULT 0,
        tax_amount REAL DEFAULT 0,
        discount_amount REAL DEFAULT 0,
        total_amount REAL DEFAULT 0,
        paid_amount REAL DEFAULT 0,
        status TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES customers(id)
      )
    ''');

    // Create journal_entries table
    await db.execute('''
      CREATE TABLE journal_entries (
        id TEXT PRIMARY KEY,
        entry_number TEXT NOT NULL UNIQUE,
        entry_date TEXT NOT NULL,
        type TEXT NOT NULL,
        reference TEXT,
        description TEXT,
        total_debit REAL DEFAULT 0,
        total_credit REAL DEFAULT 0,
        is_posted INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create journal_lines table
    await db.execute('''
      CREATE TABLE journal_lines (
        id TEXT PRIMARY KEY,
        entry_id TEXT NOT NULL,
        account_id TEXT NOT NULL,
        account_name TEXT NOT NULL,
        account_code TEXT NOT NULL,
        debit REAL DEFAULT 0,
        credit REAL DEFAULT 0,
        description TEXT,
        FOREIGN KEY (entry_id) REFERENCES journal_entries(id),
        FOREIGN KEY (account_id) REFERENCES accounts(id)
      )
    ''');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
