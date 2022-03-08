/// Процесс, способный занять ячейку памяти
class Process {
  /// Иднетификатор процесса
  final String id;

  /// Имя процесса (по умолчанию совпадает с [id])
  late final String name;

  /// Количество ячеек паямти, необходимое процессу
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
}
