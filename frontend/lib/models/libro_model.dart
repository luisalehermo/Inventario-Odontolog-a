class LibroModel {
  final int? idLibro;
  final String titulo;
  final int? nroEjemplar;
  final String? nroEdicion;
  final String? lugarPublicacion;
  final String? fechaPublicacion; // Mantengo String para no forzar formato
  final String? paginaCm;
  final String? anexos;
  final String? ilustraciones;
  final int? idMateria;
  final int? idAutor;
  final int? idEditorial;
  final List<dynamic>? descriptores;

  LibroModel({
    this.idLibro,
    required this.titulo,
    this.nroEjemplar,
    this.nroEdicion,
    this.lugarPublicacion,
    this.fechaPublicacion,
    this.paginaCm,
    this.anexos,
    this.ilustraciones,
    this.idMateria,
    this.idAutor,
    this.idEditorial,
    this.descriptores,
  });

  factory LibroModel.fromJson(Map<String, dynamic> json) => LibroModel(
    idLibro: json['id_libro'] as int?,
    titulo: (json['titulo'] ?? '') as String,
    nroEjemplar: json['nro_ejemplar'] as int?,
    nroEdicion: json['nro_edicion'] as String?,
    lugarPublicacion: json['lugar_publicacion'] as String?,
    fechaPublicacion: json['fecha_publicacion'] as String?,
    paginaCm: json['pagina_cm'] as String?,
    anexos: json['anexos'] as String?,
    ilustraciones: json['ilustraciones'] as String?,
    idMateria: json['id_materia'] as int?,
    idAutor: json['id_autor'] as int?,
    idEditorial: json['id_editorial'] as int?,
    descriptores: json['descriptores'] is List
        ? json['descriptores'] as List<dynamic>
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id_libro': idLibro,
    'titulo': titulo,
    'nro_ejemplar': nroEjemplar,
    'nro_edicion': nroEdicion,
    'lugar_publicacion': lugarPublicacion,
    'fecha_publicacion': fechaPublicacion,
    'pagina_cm': paginaCm,
    'anexos': anexos,
    'ilustraciones': ilustraciones,
    'id_materia': idMateria,
    'id_autor': idAutor,
    'id_editorial': idEditorial,
    'descriptores': descriptores,
  };
}
