class Insumo {
  final int? id;
  final String nombre;
  final String descripcion;
  final int cantidad;
  final String unidadMedida;
  final String categoria;

  Insumo({
    this.id,
    required this.nombre,
    required this.descripcion,
    required this.cantidad,
    required this.unidadMedida,
    required this.categoria,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'cantidad': cantidad,
      'unidad_medida': unidadMedida,
      'categoria': categoria,
    };
  }

  factory Insumo.fromMap(Map<String, dynamic> map) {
    return Insumo(
      id: map['id']?.toInt(),
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      cantidad: map['cantidad']?.toInt() ?? 0,
      unidadMedida: map['unidad_medida'] ?? '',
      categoria: map['categoria'] ?? '',
    );
  }
}
