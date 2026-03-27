import 'package:flutter/material.dart';
import '../api_service.dart';

class ReporteLibrosForm extends StatefulWidget {
  const ReporteLibrosForm({super.key});

  @override
  State<ReporteLibrosForm> createState() => _ReporteLibrosFormState();
}

class _ReporteLibrosFormState extends State<ReporteLibrosForm> {
  final Color azulUSM = const Color(0xFF2B27A1);
  final ApiService _api = ApiService();

  List<dynamic> _prestamosActivos = [];
  bool _estaCargando = true;
  int _totalLibros = 0;

  @override
  void initState() {
    super.initState();
    _cargarDatosReporte();
  }

  Future<void> _cargarDatosReporte() async {
    setState(() => _estaCargando = true);
    try {
      // 1. Obtenemos todos los libros para la estadística general
      final libros = await _api.obtenerLibros();

      // 2. Obtenemos todos los préstamos usando una búsqueda vacía
      final todosPrestamos = await _api.obtenerPrestamosPorCedula("");

      if (!mounted) return;

      setState(() {
        _totalLibros = libros.length;

        // MODIFICACIÓN: Filtro robusto que ignora mayúsculas/minúsculas
        _prestamosActivos = todosPrestamos.where((p) {
          final estatus = p['estatus']?.toString().toUpperCase() ?? '';
          return estatus == 'PRESTADO';
        }).toList();

        _estaCargando = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _estaCargando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al cargar reportes: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Reportes de Inventario",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: azulUSM,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _cardMiniEstadistica(
                "Total Libros",
                "$_totalLibros",
                Icons.book,
                Colors.blue,
              ),
              _cardMiniEstadistica(
                "En Préstamo",
                "${_prestamosActivos.length}",
                Icons.outbox,
                Colors.orange,
              ),
              _cardMiniEstadistica("Dañados", "0", Icons.warning, Colors.red),
            ],
          ),
          const SizedBox(height: 30),
          const Text(
            "Detalle de Libros en Préstamo",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _estaCargando
                ? const Center(child: CircularProgressIndicator())
                : _prestamosActivos.isEmpty
                ? const Center(
                    child: Text("No hay libros prestados actualmente."),
                  )
                : _tablaReportePrestamos(),
          ),
        ],
      ),
    );
  }

  Widget _tablaReportePrestamos() {
    return Card(
      elevation: 3,
      child: SizedBox(
        width: double.infinity, // Asegura que ocupe todo el ancho disponible
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              azulUSM.withValues(alpha: 0.1),
            ),
            columns: const [
              DataColumn(
                label: Text(
                  'Libro',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Solicitante',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Cédula',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Fecha',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            rows: _prestamosActivos.map((p) {
              return DataRow(
                cells: [
                  DataCell(Text(p['titulo_libro'] ?? 'S/N')),
                  DataCell(Text("${p['nombre'] ?? ''} ${p['apellido'] ?? ''}")),
                  // MODIFICACIÓN: Coincidir con 'cedula_solicitante' de tu DB
                  DataCell(Text(p['cedula_solicitante']?.toString() ?? '')),
                  // MODIFICACIÓN: Coincidir con 'fecha_salida' de tu DB
                  DataCell(Text(p['fecha_salida']?.toString() ?? '')),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _cardMiniEstadistica(String t, String v, IconData i, Color c) {
    return Expanded(
      child: Card(
        child: ListTile(
          leading: Icon(i, color: c, size: 40),
          title: Text(t, style: const TextStyle(fontSize: 12)),
          subtitle: Text(
            v,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
