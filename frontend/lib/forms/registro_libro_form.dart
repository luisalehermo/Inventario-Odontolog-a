import 'package:flutter/material.dart';
import '../api_service.dart';

class RegistroLibroForm extends StatefulWidget {
  const RegistroLibroForm({super.key});

  @override
  State<RegistroLibroForm> createState() => _RegistroLibroFormState();
}

class _RegistroLibroFormState extends State<RegistroLibroForm> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _api = ApiService();

  final Color azulUSM = const Color(0xFF2B27A1);
  final Color fondoGris = const Color(0xFFF5F6F9);

  // Solo los 4 controladores necesarios
  final _tituloController = TextEditingController();
  final _autorController = TextEditingController();
  final _anioController = TextEditingController();
  final _cantidadController = TextEditingController(text: "1");

  @override
  void dispose() {
    _tituloController.dispose();
    _autorController.dispose();
    _anioController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }

  Future<void> _guardarLibro() async {
    if (_formKey.currentState!.validate()) {
      // Objeto simplificado para el API
      final datos = {
        'titulo': _tituloController.text,
        'autor': _autorController.text,
        'anio': _anioController.text, // Cambiado para coincidir con tus Excel
        'cantidad': int.tryParse(_cantidadController.text) ?? 1,
      };

      final exito = await _api.crearLibro(datos);

      if (!mounted) return;

      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Libro registrado exitosamente"),
            backgroundColor: Colors.green,
          ),
        );
        _formKey.currentState!.reset();
        _cantidadController.text = "1"; // Reiniciar a valor por defecto
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Error al registrar el libro. Verifique la conexión.",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondoGris,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Registro Simplificado de Libros",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),
              Container(
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
                    _inputField(
                      "Título del Libro",
                      Icons.book,
                      _tituloController,
                    ),
                    _inputField("Autor(es)", Icons.person, _autorController),
                    Row(
                      children: [
                        Expanded(
                          child: _inputField(
                            "Año",
                            Icons.calendar_today,
                            _anioController,
                            isNumber: true,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _inputField(
                            "Nº Ejemplares",
                            Icons.copy,
                            _cantidadController,
                            isNumber: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _guardarLibro,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: azulUSM,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "REGISTRAR LIBRO",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(
    String label,
    IconData icon,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: azulUSM),
          filled: true,
          fillColor: fondoGris,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? "Requerido" : null,
      ),
    );
  }
}
