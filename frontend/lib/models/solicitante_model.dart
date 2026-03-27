class SolicitanteModel {
  final String cedula;
  final String nombre;
  final String apellido;
  final String telefono;
  final String facultad; // El campo que ya tenías en Python

  SolicitanteModel({
    required this.cedula,
    required this.nombre,
    required this.apellido,
    required this.telefono,
    required this.facultad,
  });

  factory SolicitanteModel.fromJson(Map<String, dynamic> json) =>
      SolicitanteModel(
        cedula: json['cedula_solicitante'],
        nombre: json['nombre_solicitante'],
        apellido: json['apellido_solicitante'],
        telefono: json['telefono_solicitante'],
        facultad: json['facultad'],
      );

  Map<String, dynamic> toJson() => {
    'cedula_solicitante': cedula,
    'nombre_solicitante': nombre,
    'apellido_solicitante': apellido,
    'telefono_solicitante': telefono,
    'facultad': facultad,
  };
}
