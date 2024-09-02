import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'contact.dart';

class DatabaseService {
  // Singleton pattern pour s'assurer qu'il n'y a qu'une instance de la base de données
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('contacts.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    await deleteDatabase(path);


    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }


  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
    CREATE TABLE contacts (
      id $idType,
      firstName $textType,
      lastName $textType,
      phone $textType,
      email $textType,
      age $intType
    )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }


  Future<Contact> createContact(Contact contact) async {
    final db = await instance.database;
    final id = await db.insert('contacts', contact.toMap());
    return contact.copyWith(id: id);
  }

  Future<List<Contact>> readAllContacts() async {
    final db = await instance.database;

    final result = await db.query('contacts');

    return result.map((json) => Contact.fromMap(json)).toList();
  }

  Future<int> updateContact(Contact contact) async {
    final db = await instance.database;

    return db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<int> deleteContact(int id) async {
    final db = await instance.database;

    return await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
