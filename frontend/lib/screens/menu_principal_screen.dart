import 'package:flutter/material.dart';
import 'login_screen.dart';

// Importación de formularios con los nombres de clase corregidos
import '../forms/prestamo_libro_form.dart';
import '../forms/registro_libro_form.dart';
import '../forms/devolucion_libro_form.dart';
import '../forms/importar_libros_form.dart';
import '../forms/buscar_libro_form.dart';
import '../forms/buscar_solicitante_form.dart';
import '../forms/reporte_libros_form.dart';
import '../forms/estadisticas_generales_form.dart';
import '../forms/inventario_libros_form.dart';

class PantallaMenuPrincipal extends StatefulWidget {
  const PantallaMenuPrincipal({super.key});

  @override
  State<PantallaMenuPrincipal> createState() => _PantallaMenuPrincipalState();
}

class _PantallaMenuPrincipalState extends State<PantallaMenuPrincipal> {
  String _seccionActual = "Principal";
  final Color azulUSM = const Color(0xFF2B27A1);

  /// Método que renderiza el formulario seleccionado en el Sidebar
  Widget _construirVistaContenido() {
    switch (_seccionActual) {
      case "Registrar Préstamo":
        return const PrestamoLibroForm(); // Clase en prestamo_libro_form.dart
      case "Registrar libro":
        return const RegistroLibroForm();
      case "Registrar Devolución":
        return const DevolucionLibroForm(); // Clase en devolucion_libro_form.dart
      case "Importar libros":
        return const ImportarLibrosForm();
      case "Buscar libro":
        return const BuscarLibroForm();
      case "Buscar solicitante":
        return const BuscarSolicitanteForm();
      case "Inventario":
        return const InventarioLibrosForm();
      case "Reporte de libros":
        return const ReporteLibrosForm();
      case "Estadísticas generales":
        return const EstadisticasGeneralesForm();
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_balance, size: 100, color: Colors.grey[300]),
              const SizedBox(height: 15),
              Text(
                "Bienvenido al Sistema USM",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Text("Seleccione una opción en el menú lateral"),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // --- SIDEBAR (Menú Lateral) ---
          Container(
            width: 260,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              border: Border(
                right: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _crearCabeceraSidebar(),
                        _itemMenu(Icons.dashboard, "Principal"),

                        // Grupo Actas
                        _grupoMenu(Icons.swap_horiz, "Actas", [
                          "Registrar Préstamo",
                          "Registrar Devolución",
                          "Registrar libro",
                          "Importar libros",
                        ]),

                        // Grupo Consultas
                        _grupoMenu(Icons.search, "Consultas", [
                          "Buscar libro",
                          "Buscar solicitante",
                          "Inventario",
                        ]),

                        // Grupo Estadísticas
                        _grupoMenu(Icons.pie_chart, "Estadísticas", [
                          "Reporte de libros",
                          "Estadísticas generales",
                        ]),
                      ],
                    ),
                  ),
                ),
                // Botón Cerrar Sesión
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    "Cerrar Sesión",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PantallaLogin(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),

          // --- CONTENIDO DINÁMICO (Derecha) ---
          Expanded(
            child: Column(
              children: [
                AppBar(
                  title: Text(
                    _seccionActual,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  centerTitle: false,
                ),
                const Divider(height: 1),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: _construirVistaContenido(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES PARA EL SIDEBAR ---

  Widget _crearCabeceraSidebar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: azulUSM,
            child: const Icon(Icons.person, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 15),
          const Text(
            "Administrador USM",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            "Biblioteca Central",
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _itemMenu(IconData icono, String titulo) {
    bool seleccionado = _seccionActual == titulo;
    return ListTile(
      leading: Icon(icono, color: seleccionado ? azulUSM : Colors.grey),
      title: Text(
        titulo,
        style: TextStyle(
          color: seleccionado ? azulUSM : Colors.black,
          fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: seleccionado,
      onTap: () => setState(() => _seccionActual = titulo),
    );
  }

  Widget _grupoMenu(IconData icono, String titulo, List<String> subItems) {
    return ExpansionTile(
      leading: Icon(icono),
      title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w500)),
      children: subItems
          .map(
            (item) => ListTile(
              contentPadding: const EdgeInsets.only(left: 60),
              title: Text(
                item,
                style: TextStyle(
                  fontSize: 14,
                  color: _seccionActual == item ? azulUSM : Colors.black87,
                ),
              ),
              onTap: () => setState(() => _seccionActual = item),
              selected: _seccionActual == item,
            ),
          )
          .toList(),
    );
  }
}
