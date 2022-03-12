class File {
  /// Конструктор
  File({
    required this.id,
    String? name,
    required this.numberOfMemoryUnits,
  }) {
    // запрашивать хотя бы одну ячейку
    assert(numberOfMemoryUnits > 0);

    this.name = name ?? id;
  }

  factory File.fromJson(Map<String, dynamic> json) {
    return File(
      id: json['id'],
      name: json['name'],
      numberOfMemoryUnits: json['numberOfMemoryUnits'],
    );
  }

  /// Идентификатор файла
  final String id;

  /// Имя файла (по умолчанию совпадает с [id])
  late final String name;

  /// Количество ячеек памяти, необходимое файлу изначально
  int numberOfMemoryUnits;
}
