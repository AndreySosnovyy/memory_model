import 'package:uuid/uuid.dart';

import '../domain/entities/events/add_file_event.dart';
import '../domain/entities/events/delete_file_event.dart';
import '../domain/entities/events/expand_file_event.dart';
import '../domain/entities/events/file_event.dart';
import '../domain/entities/memory_unit.dart';

/// Контроллер условной памяти устройства, который может выдавать файлам ячейки памяти
class MemoryController {
  /// Память, состоящая из ячеек
  late final List<MemoryUnit> _memoryUnits;

  /// Размер памяти устройства (измеряется в количестве ячеек памяти)
  final int size;

  /// Поток новых файлов, желающих заполучить ячейки памяти устройства
  final Stream<FileEvent> filesEventsStream;

  /// Конструктор
  MemoryController({
    required this.size,
    required this.filesEventsStream,
  })  : // Количество ячеек памяти больше 0
        assert(size > 0),
        _memoryUnits = List.filled(
          size,
          MemoryUnit(id: Uuid().v4()),
          growable: false,
        ) {
    filesEventsStream.listen((event) => handleFile(event));
  }

  /// Обработка поступившего запроса на выдачу ячеек памяти новому файлу
  // todo: implement method
  void handleFile(FileEvent event) {
    switch (event.runtimeType) {
      case AddFileEvent:
        print('AddFileEvent - ${event.file.name}');
        break;
      case ExpandFileEvent:
        print('ExpandFileEvent - ${event.file.name}');
        break;
      case DeleteFileEvent:
        print('DeleteFileEvent - ${event.file.name}');
        break;
      default:
        print('Undefined event type - ${event.file.name}');
    }
  }

  /// Возвращает соотношение количества занятых ячеек от их максимального количества
  double get unitsRatio {
    int numberOfCapturedMemoryUnits = 0;
    for (final memoryUnit in _memoryUnits) {
      if (memoryUnit.isBusy) numberOfCapturedMemoryUnits++;
    }
    return numberOfCapturedMemoryUnits / size;
  }
}
