import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future get database async {
    if (_database != null) return _database!;
    _database = await _initDB('card_organizer.db');
    return _database!;
  }

  Future _initDB(String filePath) async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, filePath);

  return await openDatabase(
    path,
    version: 1,
    onCreate: _createDB,
    onOpen: (db) async {
      await db.execute('PRAGMA foreign_keys = ON');  // add this
    },
  );
}

  Future _createDB(Database db, int version) async {
    // Create Folders table
    await db.execute('''
      CREATE TABLE folders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        folder_name TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // Create Cards table with foreign key
    await db.execute('''
      CREATE TABLE cards(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        card_name TEXT NOT NULL,
        suit TEXT NOT NULL,
        image_url TEXT,
        folder_id INTEGER,
        FOREIGN KEY (folder_id) REFERENCES folders (id)
          ON DELETE CASCADE
      )
    ''');

    // Prepopulate folders
    await _prepopulateFolders(db);

    // Prepopulate cards
    await _prepopulateCards(db);
  }

  Future _prepopulateFolders(Database db) async {
    final folders = ['Hearts', 'Diamonds', 'Clubs', 'Spades'];
    for (int i = 0; i < folders.length; i++) {
      await db.insert('folders', {
        'folder_name': folders[i],
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

Future _prepopulateCards(Database db) async {
  final suits = [
    {'name': 'Hearts',   'code': 'H', 'folderId': 1},
    {'name': 'Diamonds', 'code': 'D', 'folderId': 2},
    {'name': 'Clubs',    'code': 'C', 'folderId': 3},
    {'name': 'Spades',   'code': 'S', 'folderId': 4},
  ];

  // value code : display name
  final cards = {
    'A': 'Ace', '2': '2', '3': '3', '4': '4', '5': '5',
    '6': '6', '7': '7', '8': '8', '9': '9', '0': '10',
    'J': 'Jack', 'Q': 'Queen', 'K': 'King',
  };

  for (var suit in suits) {
    for (var entry in cards.entries) {
      await db.insert('cards', {
        'card_name': entry.value,           // "Ace", "10", "King" etc
        'suit': suit['name'],
        'image_url': 'assets/cards/${entry.key}${suit['code']}.png',  // "AH.png", "0D.png"
        'folder_id': suit['folderId'],
      });
    }
  }
}

}