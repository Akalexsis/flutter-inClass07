import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

// class handles SQL logic associated with Folder database
class Folder{
  // database related information
  static const dbPath = 'Database.db';
  static const table = 'Folders';
  static const version = 1;

  // column names to be references when performing database operations
  static const columnId = 'id';
  static const columnFolderName = 'folder_name';
  static const columnTimestamp = 'timestamp';

  late Database _data;

  Future<void> initFolder() async {
    final documentsDirectory = await getApplicationDocumentsDirectory(); 

    final path = await join(documentsDirectory.path, dbPath );
    _data = await openDatabase(path, version: version, onCreate: _onCreate); 
  }

  Future _onCreate(Database data, int version) async {
    return await data.execute('''CREATE TABLE $table(
      $columnId AUTO_INCREMENT PRIMARY KEY,
      $columnFolderName TEXT,
      $columnTimestamp TIMESTAMP
    )''');
  }
}