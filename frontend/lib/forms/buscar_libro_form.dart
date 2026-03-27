import 'dart:async';
import 'package:flutter/material.dart';
import '../api_service.dart';

class BuscarLibroForm extends StatefulWidget {
  const BuscarLibroForm({super.key});

  @override
  State<BuscarLibroForm> createState() => _BuscarLibroFormState();
}

class _BuscarLibroFormState extends State<BuscarLibroForm> {
  final Color azulUSM = const Color(0xFF2B27A1);
  final TextEditingController _searchCtrl = TextEditingController();
  final ApiService _api = ApiService();

  Map<String, dynamic>? _libroSeleccionado;
  Map<String, dynamic>? _prestamoLibro;
  bool _cargando = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // FUNCIÓN DE BÚSQUEDA CORREGIDA
  Future<void> _buscarLibros(String termino) async {
    if (termino.isEmpty) {
      setState(() {
        _libroSeleccionado = null;
        _prestamoLibro = null;
      });
      return;
    }

    setState(() => _cargando = true);

    try {
      final resultados = await _api.obtenerLibros(query: termino.trim());

      // Verificación de seguridad después de await
      if (!mounted) return;

      if (resultados.isNotEmpty) {
        final libro =
            resultados.firstWhere((l) {
                  final titulo = (l['titulo'] ?? '').toString().toLowerCase();
                  return titulo.contains(termino.toLowerCase());
                }, orElse: () => resultados.first)
                as Map<String, dynamic>;

        final id = libro['id_libro'] ?? 0;
        final prest = await _api.obtenerPrestamoPorLibro(id);

        if (!mounted) return;

        setState(() {
          _libroSeleccionado = libro;
          _prestamoLibro = prest;
        });
      } else {
        setState(() {
          _libroSeleccionado = null;
          _prestamoLibro = null;
        });
      }
    } catch (e) {
      debugPrint('Error en búsqueda: $e');
      _showSnackBar("Error al conectar con el servidor", Colors.red);
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  // MÉTODO QUE CORRIGE EL ERROR DE LA IMAGEN d8ed38.png
  void _showSnackBar(String mensaje, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() {
        _libroSeleccionado = null;
        _prestamoLibro = null;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 600), () {
      _buscarLibros(value.trim());
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
            "Consultar Catálogo de Libros",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: azulUSM,
            ),
          ),
          const SizedBox(height: 20),
          _barraBusqueda("Escriba el título, autor o materia..."),
          const SizedBox(height: 30),
          if (_cargando)
            const Center(child: CircularProgressIndicator())
          else if (_libroSeleccionado != null)
            _detalleLibroWidget()
          else if (_searchCtrl.text.isNotEmpty)
            const Center(child: Text("No se encontraron coincidencias."))
          else
            const Center(
              child: Text(
                "Ingrese un criterio para ver la información del libro",
              ),
            ),
        ],
      ),
    );
  }

  Widget _barraBusqueda(String hint) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchCtrl,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () => _buscarLibros(_searchCtrl.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: azulUSM,
            padding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Icon(Icons.search, color: Colors.white),
        ),
      ],
    );
  }

  Widget _detalleLibroWidget() {
    final lib = _libroSeleccionado!;
    final prest = _prestamoLibro;
    final bool estaPrestado = prest != null && prest.isNotEmpty;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    lib['titulo']?.toUpperCase() ?? 'SIN TÍTULO',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: estaPrestado
                        ? Colors.orange.shade100
                        : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    estaPrestado ? 'PRESTADO' : 'EN BIBLIOTECA',
                    style: TextStyle(
                      color: estaPrestado
                          ? Colors.orange.shade900
                          : Colors.green.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            Wrap(
              spacing: 20,
              runSpacing: 10,
              children: [
                _datoItem(Icons.person, "Autor", lib['autor_nombre'] ?? 'N/A'),
                _datoItem(
                  Icons.book,
                  "Materia",
                  lib['materia_nombre'] ?? 'N/A',
                ),
                _datoItem(
                  Icons.business,
                  "Editorial",
                  lib['editorial_nombre'] ?? 'N/A',
                ),
              ],
            ),
            if (estaPrestado) ...[
              const SizedBox(height: 25),
              const Text(
                "INFORMACIÓN DEL SOLICITANTE",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _filaDatosSolicitante(
                      "Nombre:",
                      "${prest['solicitante']?['nombre'] ?? ''} ${prest['solicitante']?['apellido'] ?? ''}",
                    ),
                    _filaDatosSolicitante(
                      "Cédula:",
                      prest['solicitante']?['cedula'] ?? 'N/A',
                    ),
                    _filaDatosSolicitante(
                      "Teléfono:",
                      prest['solicitante']?['telefono'] ?? 'N/A',
                    ),
                    _filaDatosSolicitante(
                      "Correo:",
                      prest['solicitante']?['correo'] ?? 'N/A',
                    ),
                    _filaDatosSolicitante(
                      "Facultad:",
                      prest['solicitante']?['facultad'] ?? 'N/A',
                    ),
                    const Divider(),
                    _filaDatosSolicitante(
                      "Fecha Préstamo:",
                      prest['fecha_salida'] ?? 'N/A',
                    ),
                    _filaDatosSolicitante(
                      "Fecha Devolución:",
                      prest['fecha_entrada'] ?? 'N/A',
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _datoItem(IconData icono, String etiqueta, String valor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 18, color: azulUSM),
        const SizedBox(width: 5),
        Text(
          "$etiqueta: ",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(valor),
      ],
    );
  }

  Widget _filaDatosSolicitante(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
