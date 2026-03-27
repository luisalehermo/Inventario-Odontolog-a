import 'package:flutter/material.dart';
import '../api_service.dart';

class BuscarSolicitanteForm extends StatefulWidget {
  const BuscarSolicitanteForm({super.key});

  @override
  State<BuscarSolicitanteForm> createState() => _BuscarSolicitanteFormState();
}

class _BuscarSolicitanteFormState extends State<BuscarSolicitanteForm> {
  final Color azulUSM = const Color(0xFF2B27A1);
  final ApiService _api = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _historialPrestamos = [];
  bool _estaCargando = false;
  String _mensajeCentral =
      "Ingrese un parámetro para ver el historial de préstamos";

  Future<void> _realizarBusqueda(String valor) async {
    if (valor.trim().isEmpty) {
      setState(() {
        _historialPrestamos = [];
        _mensajeCentral =
            "Ingrese un parámetro para ver el historial de préstamos";
      });
      return;
    }

    setState(() => _estaCargando = true);

    try {
      // Usamos el método existente en tu ApiService para buscar por cédula
      final resultados = await _api.obtenerPrestamosPorCedula(valor.trim());

      setState(() {
        _historialPrestamos = resultados;
        _estaCargando = false;
        if (resultados.isEmpty) {
          _mensajeCentral =
              "No se encontraron préstamos para este solicitante.";
        }
      });
    } catch (e) {
      setState(() {
        _estaCargando = false;
        _mensajeCentral = "Error al conectar con el servidor.";
      });
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
            "Consultar Solicitantes",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: azulUSM,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            onSubmitted: _realizarBusqueda, // Busca al presionar 'Enter'
            decoration: InputDecoration(
              labelText: "Buscar por Cédula o Apellido",
              suffixIcon: IconButton(
                icon: const Icon(Icons.person_search),
                onPressed: () => _realizarBusqueda(_searchController.text),
              ),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: _estaCargando
                ? const Center(child: CircularProgressIndicator())
                : _historialPrestamos.isEmpty
                ? Center(child: Text(_mensajeCentral))
                : _construirListaHistorial(),
          ),
        ],
      ),
    );
  }

  Widget _construirListaHistorial() {
    return ListView.builder(
      itemCount: _historialPrestamos.length,
      itemBuilder: (context, index) {
        final prestamo = _historialPrestamos[index];
        final bool estaDevuelto = prestamo['estatus'] == 'DEVUELTO';

        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          elevation: 2,
          child: ListTile(
            leading: Icon(
              estaDevuelto ? Icons.check_circle : Icons.pending_actions,
              color: estaDevuelto ? Colors.green : Colors.orange,
            ),
            title: Text("Libro: ${prestamo['titulo_libro'] ?? 'Desconocido'}"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Fecha: ${prestamo['fecha_prestamo']}"),
                Text("Estatus: ${prestamo['estatus']}"),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        );
      },
    );
  }
}
