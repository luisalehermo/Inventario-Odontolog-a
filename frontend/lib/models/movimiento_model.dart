class Movimiento {
  final int? id;
  final int insumoId;
  final String tipo; // 'Entrada' o 'Salida'
  final int cantidad;
  final String fecha;
  final String motivo;

  Movimiento({
    this.id,
    required this.insumoId,
    required this.tipo,
    required this.cantidad,
    required this.fecha,
    required this.motivo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'insumo_id': insumoId,
      'tipo': tipo,
      'cantidad': cantidad,
      'fecha': fecha,
      'motivo': motivo,
    };
  }

  factory Movimiento.fromMap(Map<String, dynamic> map) {
    return Movimiento(
      id: map['id']?.toInt(),
      insumoId: map['insumo_id']?.toInt() ?? 0,
      tipo: map['tipo'] ?? '',
      cantidad: map['cantidad']?.toInt() ?? 0,
      fecha: map['fecha'] ?? '',
      motivo: map['motivo'] ?? '',
    );
  }
}
