/// Процесс, способный занять ячейку памяти
class Process {
  /// Идентификатор процесса
  final String id;

  /// Имя процесса (по умолчанию совпадает с [id])
  late final String name;

  /// Количество ячеек памяти, необходимое процессу
  final int numberOfMemoryUnits;

  /// Продолжительность жизни процесса
  final Duration liveDuration;

  /// Конструктор
  Process({
    required this.id,
    String? name,
    required this.numberOfMemoryUnits,
    required this.liveDuration,
  }) {
    // запрашивать хотя бы одну ячейку
    assert(numberOfMemoryUnits > 0);
    // жить хотя бы 1 миллисекунду
    assert(liveDuration.compareTo(Duration(milliseconds: 1)) >= 0);

    this.name = name ?? id;
  }

  /// Формат строки
  factory Process.fromJson(Map<String, dynamic> json) {
    return Process(
      id: json['id'],
      name: json['name'],
      numberOfMemoryUnits: json['numberOfMemoryUnits'],
      liveDuration: Duration(milliseconds: json['liveDuration'] as int),
    );
  }
}
