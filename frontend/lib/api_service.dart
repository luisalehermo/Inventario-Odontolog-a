import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  final String baseUrl = "http://127.0.0.1:8000";

  // Función para traer libros con soporte de búsqueda
  Future<List<dynamic>> obtenerLibros({String? query}) async {
    try {
      final uri = Uri.parse('$baseUrl/libros/').replace(
        queryParameters: query != null && query.isNotEmpty
            ? {'q': query}
            : null,
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint("Error del servidor: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("Error de conexión en obtenerLibros: $e");
      return [];
    }
  }

  // --- MÉTODOS DE REGISTRO ---

  // Mantenemos crearLibro para que coincida con registro_libro_form.dart
  Future<bool> crearLibro(Map<String, dynamic> datosLibro) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/libros/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(datosLibro),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Error crearLibro: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error de conexión crearLibro: $e');
      return false;
    }
  }

  Future<bool> registrarPrestamo(Map<String, dynamic> datos) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/prestamos/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(datos),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint("Error del servidor: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Error de red: $e");
      return false;
    }
  }

  // --- MÉTODOS DE OBTENCIÓN DE DATOS ---

  Future<List<dynamic>> obtenerMaterias() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/materias/'));
      return response.statusCode == 200 ? json.decode(response.body) : [];
    } catch (e) {
      debugPrint('Error obtenerMaterias: $e');
      return [];
    }
  }

  Future<List<dynamic>> obtenerAutores() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/autores/'));
      return response.statusCode == 200 ? json.decode(response.body) : [];
    } catch (e) {
      debugPrint('Error obtenerAutores: $e');
      return [];
    }
  }

  Future<List<dynamic>> obtenerEditoriales() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/editoriales/'));
      return response.statusCode == 200 ? json.decode(response.body) : [];
    } catch (e) {
      debugPrint('Error obtenerEditoriales: $e');
      return [];
    }
  }

  // --- MÉTODOS DE PRÉSTAMOS ---

  // Método añadido para resolver el error en devolucion_libro_form.dart
  Future<Map<String, dynamic>?> obtenerPrestamoPorID(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/prestamos/$id'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error obtenerPrestamoPorID: $e');
      return null;
    }
  }

  Future<List<dynamic>> obtenerPrestamosPorCedula(String cedula) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/prestamos/cedula/$cedula'),
      );
      return response.statusCode == 200 ? json.decode(response.body) : [];
    } catch (e) {
      debugPrint('Error obtenerPrestamosPorCedula: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> obtenerPrestamoPorLibro(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/prestamos/libro/$id'),
      );
      return response.statusCode == 200 ? json.decode(response.body) : null;
    } catch (e) {
      debugPrint('Error obtenerPrestamoPorLibro: $e');
      return null;
    }
  }

  Future<bool> devolverPrestamo(int id) async {
    try {
      // Cambiamos a PUT y a la ruta exacta de Python
      final response = await http.put(
        Uri.parse('$baseUrl/prestamos/devolver/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint("Error al devolver: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint('Error devolverPrestamo: $e');
      return false;
    }
  }

  // --- IMPORTACIÓN ---

  Future<Map<String, dynamic>?> importarLibrosCsv(String csvText) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/importar_libros/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'csv': csvText}),
      );
      return response.statusCode == 200 ? json.decode(response.body) : null;
    } catch (e) {
      debugPrint('Error importarLibrosCsv: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> importarLibrosFile(String filePath) async {
    try {
      var uri = Uri.parse('$baseUrl/importar_libros/');
      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      final streamedResponse = await request.send();
      final respStr = await streamedResponse.stream.bytesToString();
      return streamedResponse.statusCode == 200 ? json.decode(respStr) : null;
    } catch (e) {
      debugPrint('Error importarLibrosFile: $e');
      return null;
    }
  }
}
