import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../api_service.dart';

class ImportarLibrosForm extends StatefulWidget {
  const ImportarLibrosForm({super.key});

  @override
  State<ImportarLibrosForm> createState() => _ImportarLibrosFormState();
}

class _ImportarLibrosFormState extends State<ImportarLibrosForm> {
  final ApiService _api = ApiService();
  final TextEditingController _csvController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _csvController.dispose();
    super.dispose();
  }

  void _showStatus(String msg, bool isError) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _pickFile() async {
    final resFile = await FilePicker.platform.pickFiles(withData: false);
    if (resFile == null) return;

    final path = resFile.files.single.path;
    if (path == null) return;

    setState(() => _loading = true);
    try {
      final resultApi = await _api.importarLibrosFile(path);
      if (!mounted) return;
      setState(() => _loading = false);

      if (resultApi != null) {
        _showStatus(
          'Importación completa: ${resultApi['inserted']} insertados',
          false,
        );
      } else {
        _showStatus('Error al importar archivo', true);
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      _showStatus('Error de conexión', true);
    }
  }

  void _openCsvDialog(BuildContext context) {
    _csvController.clear();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Pegar contenido CSV'),
        content: SizedBox(
          width: 600,
          child: TextField(
            controller: _csvController,
            maxLines: 12,
            decoration: const InputDecoration(
              hintText: 'Cabeceras: titulo,autor,editorial...',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final csv = _csvController.text.trim();
              if (csv.isEmpty) return;
              Navigator.pop(dialogContext);
              setState(() => _loading = true);
              final res = await _api.importarLibrosCsv(csv);
              if (!mounted) return;
              setState(() => _loading = false);
              if (res != null) {
                _showStatus('Insertados: ${res['inserted']}', false);
              } else {
                _showStatus('Error en CSV', true);
              }
            },
            child: const Text('Importar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.upload_file, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _openCsvDialog(context),
            icon: const Icon(Icons.paste),
            label: const Text('Pegar CSV'),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _pickFile,
            icon: const Icon(Icons.file_open),
            label: const Text('Seleccionar Archivo'),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
