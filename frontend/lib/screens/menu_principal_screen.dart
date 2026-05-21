import 'package:flutter/material.dart';
import '../main.dart'; // Para acceder al themeNotifier
import 'inventario_screen.dart';
import 'movimientos_screen.dart';

class PantallaMenuPrincipal extends StatefulWidget {
  const PantallaMenuPrincipal({super.key});

  @override
  State<PantallaMenuPrincipal> createState() => _PantallaMenuPrincipalState();
}

class _PantallaMenuPrincipalState extends State<PantallaMenuPrincipal> {
  String _seccionActual = "Dashboard";

  Widget _construirVistaContenido() {
    switch (_seccionActual) {
      case "Inventario":
        return const InventarioScreen();
      case "Movimientos":
        return const MovimientosScreen();
      default:
        return _construirPantallaBienvenida();
    }
  }

  Widget _construirPantallaBienvenida() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.local_hospital, size: 48, color: colorScheme.onPrimaryContainer),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Inventario Odontología",
                      style: TextStyle(
                        fontSize: 32,
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Gestión local de insumos médicos y control de stock.",
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          Text(
            "Módulos Principales",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.2,
                children: [
                  _crearTarjetaModulo(
                    titulo: "Inventario",
                    descripcion: "Consulta, registra y edita el catálogo de insumos médicos disponibles.",
                    icono: Icons.inventory,
                    color: Colors.teal,
                    onTap: () => setState(() => _seccionActual = "Inventario"),
                  ),
                  _crearTarjetaModulo(
                    titulo: "Movimientos",
                    descripcion: "Registra entradas y salidas de stock para mantener el inventario actualizado.",
                    icono: Icons.swap_horiz,
                    color: Colors.blueAccent,
                    onTap: () => setState(() => _seccionActual = "Movimientos"),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _crearTarjetaModulo({
    required String titulo,
    required String descripcion,
    required IconData icono,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: theme.dividerColor.withOpacity(0.2)),
        ),
        color: theme.brightness == Brightness.dark 
            ? colorScheme.surfaceContainerHighest.withOpacity(0.3) 
            : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icono, size: 32, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                titulo,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                descripcion,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Row(
        children: [
          // --- SIDEBAR (Menú Lateral) ---
          Container(
            width: 260,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              border: Border(
                right: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _crearCabeceraSidebar(),
                        _itemMenu(Icons.dashboard, "Dashboard"),
                        _itemMenu(Icons.inventory, "Inventario"),
                        _itemMenu(Icons.swap_horiz, "Movimientos"),
                      ],
                    ),
                  ),
                ),
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
                  backgroundColor: theme.scaffoldBackgroundColor,
                  foregroundColor: colorScheme.onSurface,
                  elevation: 0,
                  centerTitle: false,
                ),
                const Divider(height: 1),
                Expanded(
                  child: Container(
                    color: theme.scaffoldBackgroundColor,
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

  Widget _crearCabeceraSidebar() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: colorScheme.primary,
            child: const Icon(Icons.medical_services, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 15),
          const Text(
            "ODONTOLOGÍA",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            "Inventario Local",
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
          ),
          const SizedBox(height: 20),
          
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, currentMode, child) {
              return Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _botonTema(Icons.light_mode, ThemeMode.light, currentMode),
                    _botonTema(Icons.dark_mode, ThemeMode.dark, currentMode),
                    _botonTema(Icons.settings_brightness, ThemeMode.system, currentMode),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _botonTema(IconData icono, ThemeMode modo, ThemeMode activo) {
    bool esActivo = modo == activo;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => themeNotifier.value = modo,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: esActivo ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(
          icono,
          size: 18,
          color: esActivo ? Colors.white : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _itemMenu(IconData icono, String titulo) {
    bool seleccionado = _seccionActual == titulo;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icono, color: seleccionado ? colorScheme.primary : colorScheme.onSurfaceVariant),
      title: Text(
        titulo,
        style: TextStyle(
          color: seleccionado ? colorScheme.primary : colorScheme.onSurface,
          fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: seleccionado,
      onTap: () => setState(() => _seccionActual = titulo),
    );
  }
}
