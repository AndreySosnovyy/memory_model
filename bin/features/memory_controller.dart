import 'package:uuid/uuid.dart';

import '../domain/entities/events/add_file_event.dart';
import '../domain/entities/events/delete_file_event.dart';
import '../domain/entities/events/expand_file_event.dart';
import '../domain/entities/events/file_event.dart';
import '../domain/entities/file.dart';
import '../domain/entities/memory_unit.dart';

/// Контроллер условной памяти устройства, который может выдавать файлам ячейки памяти
class MemoryController {
  /// Конструктор
  MemoryController({
    required this.size,
    required this.filesEventsStream,
  })  : // Количество ячеек памяти больше 0
        assert(size > 0) {
    for (int i = 0; i < size; i++) {
      _memoryUnits.add(MemoryUnit(id: Uuid().v4()));
    }
    filesEventsStream.listen((event) => handleFile(event));
  }

  /// Память, состоящая из ячеек
  final List _memoryUnits = <MemoryUnit>[];

  /// Размер памяти устройства (измеряется в количестве ячеек памяти)
  final int size;

  /// Поток новых файлов, желающих заполучить ячейки памяти устройства
  final Stream<FileEvent> filesEventsStream;

  /// Список имеющихся файлов
  final files = <File>[];

  /// Обработка поступившего события на добавление/расширения/удаления файла
  void handleFile(FileEvent event) {
    switch (event.runtimeType) {
      // Добавление нового файла
      case AddFileEvent:
        print('AddFileEvent - ${event.file.name}');
        files.add(event.file);
        _addFile(event.file, fitType: _FitType.firstFit);
        break;

      // Расширение существующего файла
      case ExpandFileEvent:
        print('ExpandFileEvent - ${event.file.name}');
        files
                .singleWhere((file) => file.id == event.file.id)
                .numberOfMemoryUnits +=
            (event as ExpandFileEvent).numberOfMemoryUnitsToBeRequested;
        _expandFile(event.file, fitType: _FitType.firstFit);
        break;

      // Удаление существующего файла
      case DeleteFileEvent:
        print('DeleteFileEvent - ${event.file.name}');
        files.remove(event.file);
        _deleteFile(event.file);
        break;

      // Неизвестное событие
      default:
        print('Undefined event type - ${event.file.name}');
    }
    print('Units ratio = ${(unitsRatio * 100).toInt()}%');
  }

  void _addFile(File file, {required _FitType fitType}) {
    switch (fitType) {
      case _FitType.firstFit:
        var indexes = <int>[];
        for (var i = 0; i < _memoryUnits.length; i++) {
          if (_memoryUnits[i].isNotBusy) {
            indexes.add(i);
            if (indexes.length == file.numberOfMemoryUnits) {
              for (var index in indexes) {
                _memoryUnits[index].capture(file: file);
              }
              break;
            }
          } else {
            indexes.clear();
          }
        }
        break;
      case _FitType.nextFit:
        break;
      case _FitType.bestFit:
        break;
      case _FitType.worstFit:
        break;
    }
  }

  void _expandFile(File file, {required _FitType fitType}) {
    switch (fitType) {
      case _FitType.firstFit:
        break;
      case _FitType.nextFit:
        break;
      case _FitType.bestFit:
        break;
      case _FitType.worstFit:
        break;
    }
  }

  void _deleteFile(File file) {
    files.remove(file);
    for (var unit in _memoryUnits) {
      if (unit.id == file.id) {
        unit.free();
        print('FREE');
      }
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

enum _FitType { firstFit, nextFit, bestFit, worstFit }
