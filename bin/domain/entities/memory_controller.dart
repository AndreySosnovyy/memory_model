import 'package:uuid/uuid.dart';

import 'memory_unit.dart';
import 'process.dart';

/// Контроллер условной памяти устройства, который может выдавать процессам ячейки памяти
class MemoryController {
  /// Память, состоящая из ячеек
  late final List<MemoryUnit> _memoryUnits;

  /// Размер памяти устройства (измеряется в количестве ячеек памяти)
  final int size;

  /// Поток новых процессов, желающих заполучить ячейки памяти устройства
  final Stream<Process> processStream;

  /// Конструктор
  MemoryController({
    required this.size,
    required this.processStream,
  })  : // Количество ячеек памяти больше 0
        assert(size > 0),
        _memoryUnits = List.filled(
          size,
          MemoryUnit(id: Uuid().v4()),
          growable: false,
        ) {
    processStream.listen((process) => handleProcess(process));
  }

  /// Обработка поступившего запроса на выдачу ячеек памяти новому процессу
  // todo: implement method
  void handleProcess(Process process) => throw UnimplementedError();

  /// Возвращает соотношение количества занятых ячеек от их максимального количества
  double get unitsRatio {
    int numberOfCapturedMemoryUnits = 0;
    for (final memoryUnit in _memoryUnits) {
      if (memoryUnit.isBusy) numberOfCapturedMemoryUnits++;
    }
    return numberOfCapturedMemoryUnits / size;
  }
}
