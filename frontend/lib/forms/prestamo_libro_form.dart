import 'package:flutter/material.dart';
import '../api_service.dart';

class PrestamoLibroForm extends StatefulWidget {
  const PrestamoLibroForm({super.key});

  @override
  State<PrestamoLibroForm> createState() => _PrestamoLibroFormState();
}

class _PrestamoLibroFormState extends State<PrestamoLibroForm> {
  final Color azulUSM = const Color(0xFF2B27A1);
  final ApiService _api = ApiService();
  final _formKey = GlobalKey<FormState>(); // Añadido para validación formal

  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _libroController = TextEditingController();
  final _telefonoController = TextEditingController(); // Nuevo
  final _correoController = TextEditingController(); // Nuevo
  String? _facultadSeleccionada;
  final List<String> _facultades = [
    'Ingeniería y Arquitectura',
    'FACES',
    'Derecho',
    'Farmacia',
    'Odontología',
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _cedulaController.dispose();
    _libroController.dispose();
    super.dispose();
  }

  Future<void> _procesarPrestamo() async {
    // Validación inicial
    if (!_formKey.currentState!.validate() || _facultadSeleccionada == null) {
      _msg("Por favor complete todos los campos", Colors.orange);
      return;
    }

    try {
      // 1. Buscar el libro
      final librosDb = await _api.obtenerLibros(
        query: _libroController.text.trim(),
      );

      if (!mounted) return;

      if (librosDb.isEmpty) {
        _msg("Libro no encontrado en el inventario", Colors.red);
        return;
      }

      // 2. Registrar el préstamo
      // Se asume que obtenerLibros retorna una lista de mapas con 'id_libro'
      final exito = await _api.registrarPrestamo({
        'cedula_solicitante': _cedulaController.text.trim(),
        'id_libro': int.parse(librosDb[0]['id_libro'].toString()),
        'nombre': _nombreController.text.trim(),
        'apellido': _apellidoController.text.trim(),
        'facultad': _facultadSeleccionada,
        'telefono': _telefonoController.text.trim(), // Nuevo
        'correo': _correoController.text.trim(),
        'estatus': 'PRESTADO',
      });

      if (!mounted) return;

      if (exito) {
        _msg("¡Préstamo registrado con éxito!", Colors.green);
        _limpiar();
      } else {
        _msg("No se pudo registrar el préstamo", Colors.red);
      }
    } catch (e) {
      if (mounted) _msg("Error de conexión: $e", Colors.red);
    }
  }

  void _msg(String texto, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _limpiar() {
    _nombreController.clear();
    _apellidoController.clear();
    _cedulaController.clear();
    _libroController.clear();
    setState(() => _facultadSeleccionada = null);
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Form(
        // Añadido Form para manejar validaciones
        key: _formKey,
        child: Column(
          children: [
            Text(
              "Préstamo de Libros USM",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: azulUSM,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    _buildTextField(_cedulaController, "Cédula", Icons.badge),
                    const SizedBox(height: 15),
                    _buildTextField(_nombreController, "Nombre", Icons.person),
                    const SizedBox(height: 15),
                    _buildTextField(
                      _apellidoController,
                      "Apellido",
                      Icons.person_outline,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      _telefonoController,
                      "Teléfono",
                      Icons.phone,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      _correoController,
                      "Correo Electrónico",
                      Icons.email,
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      initialValue: _facultadSeleccionada,
                      decoration: InputDecoration(
                        labelText: "Facultad",
                        prefixIcon: Icon(Icons.account_balance, color: azulUSM),
                        border: const OutlineInputBorder(),
                      ),
                      items: _facultades
                          .map(
                            (f) => DropdownMenuItem(value: f, child: Text(f)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _facultadSeleccionada = val),
                      validator: (value) =>
                          value == null ? "Seleccione una facultad" : null,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      _libroController,
                      "Título del Libro",
                      Icons.book,
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: _procesarPrestamo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: azulUSM,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "PROCESAR PRÉSTAMO",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper para mantener el código limpio y evitar repetición
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: azulUSM),
        border: const OutlineInputBorder(),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? "Campo requerido" : null,
    );
  }
}
