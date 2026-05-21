import 'package:flutter/material.dart';
import '../models/movimiento_model.dart';
import '../models/insumo_model.dart';
import '../utils/database_helper.dart';

class MovimientosScreen extends StatefulWidget {
  const MovimientosScreen({super.key});

  @override
  State<MovimientosScreen> createState() => _MovimientosScreenState();
}

class _MovimientosScreenState extends State<MovimientosScreen> {
  List<Movimiento> _movimientos = [];
  List<Insumo> _insumos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    final movimientos = await DatabaseHelper.instance.readAllMovimientos();
    final insumos = await DatabaseHelper.instance.readAllInsumos();
    setState(() {
      _movimientos = movimientos;
      _insumos = insumos;
      _isLoading = false;
    });
  }

  String _getNombreInsumo(int id) {
    final insumo = _insumos.firstWhere((i) => i.id == id, orElse: () => Insumo(nombre: 'Desconocido', descripcion: '', cantidad: 0, unidadMedida: '', categoria: ''));
    return insumo.nombre;
  }

  void _mostrarDialogoMovimiento() {
    String tipoSeleccionado = 'Entrada';
    int? insumoSeleccionado;
    final cantidadCtrl = TextEditingController();
    final motivoCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Nuevo Movimiento'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: tipoSeleccionado,
                      items: ['Entrada', 'Salida'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (val) => setDialogState(() => tipoSeleccionado = val!),
                      decoration: const InputDecoration(labelText: 'Tipo de Movimiento'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      value: insumoSeleccionado,
                      items: _insumos.map((i) => DropdownMenuItem(value: i.id, child: Text(i.nombre))).toList(),
                      onChanged: (val) => setDialogState(() => insumoSeleccionado = val),
                      decoration: const InputDecoration(labelText: 'Insumo'),
                    ),
                    TextField(
                      controller: cantidadCtrl,
                      decoration: const InputDecoration(labelText: 'Cantidad'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: motivoCtrl,
                      decoration: const InputDecoration(labelText: 'Motivo / Referencia'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (insumoSeleccionado != null && cantidadCtrl.text.isNotEmpty) {
                      final mov = Movimiento(
                        insumoId: insumoSeleccionado!,
                        tipo: tipoSeleccionado,
                        cantidad: int.tryParse(cantidadCtrl.text) ?? 0,
                        fecha: DateTime.now().toIso8601String(),
                        motivo: motivoCtrl.text,
                      );
                      await DatabaseHelper.instance.createMovimiento(mov);
                      Navigator.pop(context);
                      _cargarDatos();
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoMovimiento(),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _movimientos.isEmpty
              ? const Center(child: Text('No hay movimientos registrados.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _movimientos.length,
                  itemBuilder: (context, index) {
                    final mov = _movimientos[index];
                    final esEntrada = mov.tipo == 'Entrada';
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: esEntrada ? Colors.green.shade100 : Colors.orange.shade100,
                          child: Icon(
                            esEntrada ? Icons.arrow_downward : Icons.arrow_upward,
                            color: esEntrada ? Colors.green : Colors.orange,
                          ),
                        ),
                        title: Text(_getNombreInsumo(mov.insumoId), style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${mov.fecha.split('T')[0]} - ${mov.motivo}'),
                        trailing: Text(
                          '${esEntrada ? '+' : '-'}${mov.cantidad}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: esEntrada ? Colors.green : Colors.orange,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
