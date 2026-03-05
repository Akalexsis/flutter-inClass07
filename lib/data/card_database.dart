import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../data/folder_database.dart';

// class handles SQL logic associated with Card database
class CardDatabase{
  // database related information
  static const dbPath = 'Database.db';
  static const table = 'Cards';
  static const version = 1;

  // column names to be references when performing database operations
  static const columnId = 'id';
  static const columnCardName = 'card_name';
  static const columnSuit = 'suit';
  static const columnImage = 'image_url';
  static const columnFolderId = 'folder_id';

  late Database _data;

  Future<void> initFolder() async {
    final documentsDirectory = await getApplicationDocumentsDirectory(); 

    final path = await join(documentsDirectory.path, dbPath );
    _data = await openDatabase(path, version: version, onCreate: _onCreate); 
  }

  Future _onCreate(Database data, int version) async {
    return await data.execute('''CREATE TABLE $table(
      $columnId AUTO_INCREMENT PRIMARY KEY,
      $columnCardName TEXT,
      $columnSuit TEXT,
      $columnImage TEXT,
      CONSTRAINT fk_CardFolder 
        FOREIGN KEY ($columnId) 
        REFERENCES Folders(id)
    )''');
  }
}