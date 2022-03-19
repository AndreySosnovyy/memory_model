import 'package:uuid/uuid.dart';

import '../domain/entities/events/add_file_event.dart';
import '../domain/entities/events/delete_file_event.dart';
import '../domain/entities/events/expand_file_event.dart';
import '../domain/entities/events/file_event.dart';
import '../domain/entities/events/segment.dart';
import '../domain/entities/file.dart';
import '../domain/entities/memory_unit.dart';

/// Контроллер условной памяти устройства, который может выдавать файлам ячейки памяти
class MemoryController {
  /// Конструктор
  MemoryController({
    required this.size,
    required this.filesEventsStream,
  }) : // Количество ячеек памяти больше 0
        assert(size > 0) {
    for (int i = 0; i < size; i++) {
      _memoryUnits.add(MemoryUnit(id: Uuid().v4()));
    }
    filesEventsStream.listen((event) => handleFile(event));
  }

  /// Память, состоящая из ячеек
  final List<MemoryUnit> _memoryUnits = <MemoryUnit>[];

  /// Размер памяти устройства (измеряется в количестве ячеек памяти)
  final int size;

  /// Поток новых файлов, желающих заполучить ячейки памяти устройства
  final Stream<FileEvent> filesEventsStream;

  /// Список имеющихся файлов
  final files = <File>[];

  /// Последняя занятая предыдущим файлом ячейка памяти
  int lastCapturedUnit = 0;

  /// Обработка поступившего события на добавление/расширения/удаления файла
  void handleFile(FileEvent event) {
    switch (event.runtimeType) {
      // Добавление нового файла
      case AddFileEvent:
        print(
            '-> AddFileEvent: ${event.file.name} requested ${event.file.numberOfMemoryUnits} memory units');
        final result = _addFile(event.file, fitType: _FitType.bestFit);
        if (result) {
          files.add(event.file);
          print("   File successfully added");
        } else {
          print("   File didn't added due to some error");
        }
        break;

      // Расширение существующего файла
      case ExpandFileEvent:
        print(
            '-> ExpandFileEvent: ${event.file.name} requested ${(event as ExpandFileEvent).numberOfMemoryUnitsToBeRequested} more memory units');
        files
            .singleWhere((file) => file.id == event.file.id)
            .numberOfMemoryUnits += event.numberOfMemoryUnitsToBeRequested;
        _expandFile(
          event.file,
          numberOfRequestedUnits: event.numberOfMemoryUnitsToBeRequested,
          fitType: _FitType.firstFit,
        );
        break;

      // Удаление существующего файла
      case DeleteFileEvent:
        print(
            '-> DeleteFileEvent: ${event.file.name} freed ${event.file.numberOfMemoryUnits} memory units');
        files.remove(event.file);
        _deleteFile(event.file);
        break;

      // Неизвестное событие
      default:
        print('Undefined event type - ${event.file.name}');
        break;
    }

    print('   Units ratio = ${unitsRatio * 100} %');
    // for (var unit in _memoryUnits) print(unit.isBusy);
  }

  bool _addFile(File file, {required _FitType fitType}) {
    switch (fitType) {
      // Первый подходящий
      case _FitType.firstFit:
        var indexes = <int>[];
        for (var i = 0; i < _memoryUnits.length; i++) {
          if (_memoryUnits[i].isNotBusy) {
            indexes.add(i);
            if (indexes.length == file.numberOfMemoryUnits) {
              for (var index in indexes) {
                _memoryUnits[index].capture(file: file);
              }
              lastCapturedUnit = indexes.last;
              return true;
            }
          } else {
            indexes.clear();
          }
        }
        break;

      // Следующий подходящий
      case _FitType.nextFit:
        var indexes = <int>[];
        for (var i = lastCapturedUnit; i < _memoryUnits.length; i++) {
          if (_memoryUnits[i].isNotBusy) {
            indexes.add(i);
            if (indexes.length == file.numberOfMemoryUnits) {
              for (var index in indexes) {
                _memoryUnits[index].capture(file: file);
              }
              lastCapturedUnit = indexes.last;
              return true;
            }
          } else {
            indexes.clear();
          }
        }
        for (var i = 0; i < lastCapturedUnit; i++) {
          if (_memoryUnits[i].isNotBusy) {
            indexes.add(i);
            if (indexes.length == file.numberOfMemoryUnits) {
              for (var index in indexes) {
                _memoryUnits[index].capture(file: file);
              }
              lastCapturedUnit = indexes.last;
              return true;
            }
          } else {
            indexes.clear();
          }
        }
        break;

      // Самый подходящий
      case _FitType.bestFit:
        final segments = <Segment>[];
        // Составление списка сегментов
        for (var i = 0; i < _memoryUnits.length; i++) {
          if (segments.isEmpty) {
            segments.add(Segment());
            segments.last.addMemoryUnit(_memoryUnits[i]);
          } else {
            if (_memoryUnits[i].isBusy) {
              if (segments.last.length > 0) {
                segments.add(Segment());
              } else {
                continue;
              }
            } else {
              segments.last.addMemoryUnit(_memoryUnits[i]);
            }
          }
        }

        // Выбор наиболее подходящего сегмента и занятие ячеек памяти
        int error = 0;
        while (error < _memoryUnits.length) {
          // print(error);
          for (final segment in segments) {
            if (segment.length - error == file.numberOfMemoryUnits) {
              for (var i = 0; i < file.numberOfMemoryUnits; i++) {
                segment.memoryUnits[i].capture(file: file);
              }
              return true;
            }
          }
          error++;
        }

        break;

      // Самый неподходящий
      case _FitType.worstFit:
        break;
    }

    return false;
  }

  void _expandFile(
    File file, {
    required int numberOfRequestedUnits,
    required _FitType fitType,
  }) {
    switch (fitType) {
      // Первый подходящий
      case _FitType.firstFit:
        final indexes = <int>[];
        for (var i = 0; i < _memoryUnits.length; i++) {
          if (_memoryUnits[i].file?.id == file.id) {
            indexes.add(i);
          }
        }
        if (_rangeIsEmpty(
          start: indexes.last + 1,
          end: indexes.last + numberOfRequestedUnits + 1,
        )) {
          print('   expand range is empty');
          for (var i = indexes.last + 1;
              i < indexes.last + numberOfRequestedUnits + 1;
              i++) {
            _memoryUnits[i].capture(file: file);
          }
          lastCapturedUnit = indexes.last;
        } else {
          print('   expand range is not empty');
        }
        break;

      // Следующий подходящий
      case _FitType.nextFit:
        break;

      // Самый подходящий
      case _FitType.bestFit:
        break;

      // Самый неподходящий
      case _FitType.worstFit:
        break;
    }
  }

  void _deleteFile(File file) {
    files.remove(file);
    for (var unit in _memoryUnits) {
      if (unit.file?.id == file.id) {
        unit.free();
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

  bool _rangeIsEmpty({required int start, required int end}) {
    bool flag = true;
    for (var i = start; i < end; i++) {
      if (_memoryUnits[i].isBusy) flag = false;
    }
    return flag;
  }
}

enum _FitType { firstFit, nextFit, bestFit, worstFit }
