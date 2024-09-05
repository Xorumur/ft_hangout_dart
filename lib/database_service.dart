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
 
    // await deleteDatabase(path);

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
    const image = 'TEXT NOT NULL';

    await db.execute('''
    CREATE TABLE contacts (
      id $idType,
      firstName $textType,
      lastName $textType,
      phone $textType,
      email $textType,
      age $intType,
      image $image
    )
    ''');

    await db.execute('''
    CREATE TABLE messages (
      id $idType,
      contactId $intType,
      message $textType,
      timestamp $textType,
      isSent $intType
    )
    ''');
  }

  Future<Contact> createContact(Contact contact) async {
    final db = await instance.database;
    final id = await db.insert('contacts', contact.toMap());
    return contact.copyWith(id: id);
  }

  Future<List<Contact>> readAllContacts() async {
    final db = await instance.database;
    var result = [];

    try {
      result = await db.query('contacts');
    } catch (e) {
      print('An error occurred: $e');
      return [];
    }

    return result.map((json) => Contact.fromMap(json)).toList();
  }

  Future<Contact> findById(int id) {
    return readAllContacts().then((contacts) => contacts.firstWhere((contact) => contact.id == id));
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

  Future<void> insertMessage(int contactId, String message, bool isSent) async {
    final db = await instance.database;

    await db.insert('messages', {
      'contactId': contactId,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      'isSent': isSent ? 1 : 0,
    });
  }

  Future<List<Map<String, dynamic>>> getMessages(int contactId) async {
    final db = await instance.database;

    return await db.query(
      'messages',
      where: 'contactId = ?',
      whereArgs: [contactId],
      orderBy: 'timestamp ASC',
    );
  }
}
