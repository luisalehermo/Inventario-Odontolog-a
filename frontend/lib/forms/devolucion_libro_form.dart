import 'package:flutter/material.dart';
import '../api_service.dart';

class DevolucionLibroForm extends StatefulWidget {
  const DevolucionLibroForm({super.key});

  @override
  State<DevolucionLibroForm> createState() => _DevolucionLibroFormState();
}

class _DevolucionLibroFormState extends State<DevolucionLibroForm> {
  final Color azulUSM = const Color(0xFF2B27A1);
  final Color fondoGris = const Color(0xFFF5F6F9);
  final _searchController = TextEditingController();
  final ApiService _api = ApiService();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondoGris,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Registrar Devolución",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 25),
            _cardBusquedaEstilizada(),
          ],
        ),
      ),
    );
  }

  Widget _cardBusquedaEstilizada() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Universidad Santa María",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: azulUSM,
            ),
          ),
          Text(
            "Biblioteca Central",
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 30),
          const Text(
            "Ingrese el ID del Préstamo o Cédula del Alumno",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Ej: 30482551",
                    prefixIcon: Icon(Icons.search, color: azulUSM),
                    filled: true,
                    fillColor: fondoGris,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              ElevatedButton(
                onPressed: _ejecutarBusqueda,
                style: ElevatedButton.styleFrom(
                  backgroundColor: azulUSM,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 35,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "BUSCAR",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _ejecutarBusqueda() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      _showSnackBar('Por favor, ingrese cédula o ID', Colors.orange);
      return;
    }

    final isNumeric = int.tryParse(query) != null;
    if (isNumeric) {
      final id = int.parse(query);
      // CORRECCIÓN: Nombre del método según ApiService
      final dynamic result = await _api.obtenerPrestamoPorID(id);

      if (!mounted) return;
      if (result != null &&
          result is Map<String, dynamic> &&
          result.isNotEmpty) {
        _navegarADetalle(result);
        return;
      }
    }

    final List<dynamic> lista = await _api.obtenerPrestamosPorCedula(query);
    if (!mounted) return;

    if (lista.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DevolucionesListaScreen(prestamos: lista),
        ),
      );
    } else {
      _showSnackBar('No se encontraron préstamos activos', Colors.redAccent);
    }
  }

  void _navegarADetalle(Map<String, dynamic> prestamo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DevolucionDetalleScreen(prestamo: prestamo),
      ),
    );
  }

  void _showSnackBar(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class DevolucionesListaScreen extends StatelessWidget {
  final List<dynamic> prestamos;
  const DevolucionesListaScreen({super.key, required this.prestamos});

  @override
  Widget build(BuildContext context) {
    const Color azulUSM = Color(0xFF2B27A1);
    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar Préstamo')),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: prestamos.length,
        itemBuilder: (context, index) {
          final p = prestamos[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: azulUSM.withValues(alpha: 0.1),
                child: const Icon(Icons.book, color: azulUSM),
              ),
              title: Text(p['titulo_libro'] ?? 'Sin título'),
              subtitle: Text(
                '${p['nombre_solicitante']} ${p['apellido_solicitante']}',
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DevolucionDetalleScreen(prestamo: p),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DevolucionDetalleScreen extends StatelessWidget {
  final Map<String, dynamic> prestamo;
  const DevolucionDetalleScreen({super.key, required this.prestamo});

  @override
  Widget build(BuildContext context) {
    final api = ApiService();
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Devolución')),
      body: Center(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _infoRow("Libro", prestamo['titulo_libro']),
              _infoRow(
                "Solicitante",
                "${prestamo['nombre_solicitante']} ${prestamo['apellido_solicitante']}",
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B27A1),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () async {
                  final idValue = prestamo['id_prestamo'];
                  if (idValue == null) return;
                  final int id = idValue is int
                      ? idValue
                      : int.parse(idValue.toString());
                  final ok = await api.devolverPrestamo(id);
                  if (!context.mounted) return;
                  if (ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Devuelto!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                child: const Text("REGISTRAR DEVOLUCIÓN"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value?.toString() ?? 'N/A'),
        ],
      ),
    );
  }
}
