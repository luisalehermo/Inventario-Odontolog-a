class PrestamoModel {
  final int? idPrestamo;
  final String fechaSalida;
  final String? fechaEntrada;
  final String estatus;
  final int idLibro;
  final String cedulaSolicitante;
  final String facultad; // Nuevo campo para el registro

  PrestamoModel({
    this.idPrestamo,
    required this.fechaSalida,
    this.fechaEntrada,
    required this.estatus,
    required this.idLibro,
    required this.cedulaSolicitante,
    required this.facultad,
  });

  factory PrestamoModel.fromJson(Map<String, dynamic> json) => PrestamoModel(
    idPrestamo: json['id_prestamo'] as int?,
    fechaSalida: (json['fecha_salida'] ?? '') as String,
    fechaEntrada: json['fecha_entrada'] as String?,
    estatus: (json['estatus'] ?? '') as String,
    idLibro: json['id_libro'] as int,
    cedulaSolicitante: (json['cedula_solicitante'] ?? '') as String,
    facultad: (json['facultad'] ?? '') as String,
  );

  Map<String, dynamic> toJson() {
    final map = {
      'fecha_salida': fechaSalida,
      'fecha_entrada': fechaEntrada,
      'estatus': estatus,
      'id_libro': idLibro,
      'cedula_solicitante': cedulaSolicitante,
      'facultad': facultad,
    };
    if (idPrestamo != null) map['id_prestamo'] = idPrestamo;
    return map;
  }
}
