import 'package:flutter/material.dart';
import '../models/insumo_model.dart';
import '../utils/database_helper.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  List<Insumo> _insumos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarInsumos();
  }

  Future<void> _cargarInsumos() async {
    setState(() => _isLoading = true);
    final insumos = await DatabaseHelper.instance.readAllInsumos();
    setState(() {
      _insumos = insumos;
      _isLoading = false;
    });
  }

  void _mostrarDialogoInsumo({Insumo? insumo}) {
    final nombreCtrl = TextEditingController(text: insumo?.nombre ?? '');
    final descripcionCtrl = TextEditingController(text: insumo?.descripcion ?? '');
    final cantidadCtrl = TextEditingController(text: insumo?.cantidad.toString() ?? '');
    final unidadCtrl = TextEditingController(text: insumo?.unidadMedida ?? '');
    final categoriaCtrl = TextEditingController(text: insumo?.categoria ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(insumo == null ? 'Nuevo Insumo' : 'Editar Insumo'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
                TextField(controller: descripcionCtrl, decoration: const InputDecoration(labelText: 'Descripción')),
                TextField(
                  controller: cantidadCtrl,
                  decoration: const InputDecoration(labelText: 'Cantidad Inicial'),
                  keyboardType: TextInputType.number,
                  enabled: insumo == null, // Solo editable al crear
                ),
                TextField(controller: unidadCtrl, decoration: const InputDecoration(labelText: 'Unidad de Medida')),
                TextField(controller: categoriaCtrl, decoration: const InputDecoration(labelText: 'Categoría')),
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
                final nuevoInsumo = Insumo(
                  id: insumo?.id,
                  nombre: nombreCtrl.text,
                  descripcion: descripcionCtrl.text,
                  cantidad: int.tryParse(cantidadCtrl.text) ?? 0,
                  unidadMedida: unidadCtrl.text,
                  categoria: categoriaCtrl.text,
                );

                if (insumo == null) {
                  await DatabaseHelper.instance.createInsumo(nuevoInsumo);
                } else {
                  await DatabaseHelper.instance.updateInsumo(nuevoInsumo);
                }

                Navigator.pop(context);
                _cargarInsumos();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _eliminarInsumo(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Insumo'),
        content: const Text('¿Está seguro de que desea eliminar este insumo?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmar == true) {
      await DatabaseHelper.instance.deleteInsumo(id);
      _cargarInsumos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoInsumo(),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _insumos.isEmpty
              ? const Center(child: Text('No hay insumos registrados.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _insumos.length,
                  itemBuilder: (context, index) {
                    final insumo = _insumos[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: insumo.cantidad < 10 ? Colors.red.shade100 : Colors.teal.shade100,
                          child: Text(
                            insumo.cantidad.toString(),
                            style: TextStyle(
                              color: insumo.cantidad < 10 ? Colors.red : Colors.teal.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(insumo.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${insumo.categoria} | ${insumo.unidadMedida}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _mostrarDialogoInsumo(insumo: insumo),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _eliminarInsumo(insumo.id!),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
