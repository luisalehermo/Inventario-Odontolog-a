import 'package:flutter/material.dart';
import '../api_service.dart';

class InventarioLibrosForm extends StatefulWidget {
  const InventarioLibrosForm({super.key});

  @override
  State<InventarioLibrosForm> createState() => _InventarioLibrosFormState();
}

class _InventarioLibrosFormState extends State<InventarioLibrosForm> {
  final Color azulUSM = const Color(0xFF2B27A1);
  final ApiService _api = ApiService();
  List<dynamic> _libros = [];
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _cargarInventario();
  }

  Future<void> _cargarInventario() async {
    setState(() {
      _cargando = true;
    });
    try {
      _libros = await _api.obtenerLibros();
    } catch (e) {
      debugPrint('Error al cargar inventario: $e');
      _libros = [];
    }
    setState(() {
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Inventario de Libros",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: azulUSM,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(child: _tablaInventario()),
        ],
      ),
    );
  }

  Widget _tablaInventario() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_libros.isEmpty) {
      return const Center(child: Text('No hay libros en el inventario.'));
    }

    // muchos campos, colocar scroll horizontal
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Título')),
          DataColumn(label: Text('Autor')),
          DataColumn(label: Text('Materia')),
          DataColumn(label: Text('Editorial')),
          DataColumn(label: Text('Edición')),
          DataColumn(label: Text('Lugar Pub.')),
          DataColumn(label: Text('Fecha Pub.')),
          DataColumn(label: Text('Ejemplares')),
          DataColumn(label: Text('Tamaño (cm)')),
          DataColumn(label: Text('Ilustraciones')),
          DataColumn(label: Text('Anexos')),
        ],
        rows: _libros.map((lib) {
          return DataRow(
            cells: [
              DataCell(Text(lib['titulo'] ?? '')),
              DataCell(Text(lib['autor_nombre'] ?? '')),
              DataCell(Text(lib['materia_nombre'] ?? '')),
              DataCell(Text(lib['editorial_nombre'] ?? '')),
              DataCell(Text(lib['nro_edicion'] ?? '')),
              DataCell(Text(lib['lugar_publicacion'] ?? '')),
              DataCell(Text(lib['fecha_publicacion'] ?? '')),
              DataCell(Text(lib['nro_ejemplar']?.toString() ?? '0')),
              DataCell(Text(lib['pagina_cm'] ?? '')),
              DataCell(Text(lib['ilustraciones'] ?? '')),
              DataCell(Text(lib['anexos'] ?? '')),
            ],
          );
        }).toList(),
      ),
    );
  }
}
