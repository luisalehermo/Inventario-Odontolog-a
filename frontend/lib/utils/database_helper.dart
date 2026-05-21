import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;
import '../models/insumo_model.dart';
import '../models/movimiento_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('inventario_odontologia.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Si estamos en Windows, inicializar FFI
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

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
CREATE TABLE insumos (
  id $idType,
  nombre $textType,
  descripcion $textType,
  cantidad $intType,
  unidad_medida $textType,
  categoria $textType
)
''');

    await db.execute('''
CREATE TABLE movimientos (
  id $idType,
  insumo_id $intType,
  tipo $textType,
  cantidad $intType,
  fecha $textType,
  motivo $textType,
  FOREIGN KEY (insumo_id) REFERENCES insumos (id) ON DELETE CASCADE
)
''');

    // Datos iniciales de prueba
    await db.rawInsert('''
      INSERT INTO insumos (nombre, descripcion, cantidad, unidad_medida, categoria)
      VALUES ('Guantes de Látex', 'Caja x 100 unidades Talla M', 50, 'Cajas', 'Material Descartable')
    ''');
    
    await db.rawInsert('''
      INSERT INTO insumos (nombre, descripcion, cantidad, unidad_medida, categoria)
      VALUES ('Anestesia Local', 'Cajas de cartuchos', 20, 'Cajas', 'Fármacos')
    ''');
  }

  // Métodos Insumos
  Future<Insumo> createInsumo(Insumo insumo) async {
    final db = await instance.database;
    final id = await db.insert('insumos', insumo.toMap());
    return Insumo(
      id: id,
      nombre: insumo.nombre,
      descripcion: insumo.descripcion,
      cantidad: insumo.cantidad,
      unidadMedida: insumo.unidadMedida,
      categoria: insumo.categoria,
    );
  }

  Future<List<Insumo>> readAllInsumos() async {
    final db = await instance.database;
    const orderBy = 'nombre ASC';
    final result = await db.query('insumos', orderBy: orderBy);
    return result.map((json) => Insumo.fromMap(json)).toList();
  }

  Future<int> updateInsumo(Insumo insumo) async {
    final db = await instance.database;
    return db.update(
      'insumos',
      insumo.toMap(),
      where: 'id = ?',
      whereArgs: [insumo.id],
    );
  }

  Future<int> deleteInsumo(int id) async {
    final db = await instance.database;
    return await db.delete(
      'insumos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Métodos Movimientos
  Future<Movimiento> createMovimiento(Movimiento mov) async {
    final db = await instance.database;
    
    // Transacción para registrar el movimiento y actualizar el stock
    await db.transaction((txn) async {
      await txn.insert('movimientos', mov.toMap());
      
      // Obtener stock actual
      final insumoMap = await txn.query('insumos', where: 'id = ?', whereArgs: [mov.insumoId]);
      if (insumoMap.isNotEmpty) {
        int stockActual = insumoMap.first['cantidad'] as int;
        int nuevoStock = mov.tipo == 'Entrada' 
            ? stockActual + mov.cantidad 
            : stockActual - mov.cantidad;
            
        await txn.update(
          'insumos',
          {'cantidad': nuevoStock},
          where: 'id = ?',
          whereArgs: [mov.insumoId]
        );
      }
    });
    
    return mov;
  }

  Future<List<Movimiento>> readAllMovimientos() async {
    final db = await instance.database;
    const orderBy = 'fecha DESC';
    final result = await db.query('movimientos', orderBy: orderBy);
    return result.map((json) => Movimiento.fromMap(json)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
