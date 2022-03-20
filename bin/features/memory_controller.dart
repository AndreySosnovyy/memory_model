import 'package:uuid/uuid.dart';

import '../data/mock_files_provider.dart';
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

  /// Список имеющихся файлов (Не используется!)
  // final files = <File>[];

  /// Последняя занятая предыдущим файлом ячейка памяти
  int lastCapturedUnit = 0;

  /// Обработка поступившего события на добавление/расширения/удаления файла
  void handleFile(FileEvent event) {
    switch (event.runtimeType) {
      // Добавление нового файла
      case AddFileEvent:
        print(
            '-> AddFileEvent: ${event.file.name} requested ${event.file.numberOfMemoryUnits} memory units');
        final result = _addFile(event.file, fitType: _FitType.firstFit);
        if (result) {
          MockFilesEventsProvider.files.add(event.file);
          print("   File successfully added");
        } else {
          print("   [ERROR] File didn't added due to some error");
        }
        break;

      // Расширение существующего файла
      case ExpandFileEvent:
        print(
            '-> ExpandFileEvent: ${event.file.name} requested ${(event as ExpandFileEvent).numberOfMemoryUnitsToBeRequested} more memory units');
        if (_expandFile(
          event.file,
          numberOfRequestedUnits: event.numberOfMemoryUnitsToBeRequested,
          fitType: _FitType.firstFit,
        )) {
          MockFilesEventsProvider.files
              .singleWhere((file) => file.id == event.file.id)
              .numberOfMemoryUnits += event.numberOfMemoryUnitsToBeRequested;
          print("   File successfully expanded");
        } else {
          print("   [ERROR] File didn't expanded due to some error");
        }
        break;

      // Удаление существующего файла
      case DeleteFileEvent:
        print(
            '-> DeleteFileEvent: ${event.file.name} freed ${event.file.numberOfMemoryUnits} memory units');
        final result = _deleteFile(event.file);
        if (result) {
          MockFilesEventsProvider.files.remove(event.file);
          print("   File successfully removed");
        } else {
          print("   [ERROR] File didn't removed due to some error");
        }
        break;

      // Неизвестное событие
      default:
        print('Undefined event type - ${event.file.name}');
        break;
    }

    print('   Units ratio = ${unitsRatio * 100} %');
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //
  //
  //              ДОБАВЛЕНИЕ ФАЙЛА
  //
  //
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  bool _addFile(File file, {required _FitType fitType}) {
    // todo: check if there are a segment that can accommodate full file
    //  (if there are such segment put file in there, otherwise put file in
    //  the longest available segment plus a segment chosen by one of these methods)

    // Составление списка сегментов
    final segments = <Segment>[Segment()];
    for (var i = 0; i < _memoryUnits.length; i++) {
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

    switch (fitType) {
      // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      //              Первый подходящий
      // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

      // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      //            Следующий подходящий
      // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

      // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      //             Самый подходящий
      // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      case _FitType.bestFit:
        // Выбор наиболее подходящего сегмента и занятие ячеек памяти
        int error = 0;
        while (error < _memoryUnits.length) {
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

      // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      //           Самый неподходящий
      // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      case _FitType.worstFit:
        // Выбор наименее подходящего сегмента и занятие ячеек памяти
        Segment maxSegment = segments.first;
        for (final segment in segments) {
          if (segment.length > maxSegment.length) maxSegment = segment;
        }
        if (maxSegment.length >= file.numberOfMemoryUnits) {
          for (var i = 0; i < file.numberOfMemoryUnits; i++) {
            maxSegment.memoryUnits[i].capture(file: file);
          }
          return true;
        }
        break;
    }

    return false;
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //
  //
  //             РАСШИРЕНИЕ ФАЙЛА
  //
  //
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  bool _expandFile(
    File file, {
    required int numberOfRequestedUnits,
    required _FitType fitType,
  }) {
    final indexes = <int>[];
    for (var i = 0; i < _memoryUnits.length; i++) {
      if (_memoryUnits[i].file?.id == file.id) {
        indexes.add(i);
      }
    }
    if (indexes.isNotEmpty && _rangeIsEmpty(
      start: indexes.last + 1,
      end: indexes.last + 1 + numberOfRequestedUnits,
    )) {
      for (var i = indexes.last + 1;
          i < indexes.last + 1 + numberOfRequestedUnits;
          i++) {
        _memoryUnits[i].capture(file: file);
      }
      lastCapturedUnit = indexes.last;
      print('   file expanded next to the previous part of the file');
      return true;
    } else {
      print('   expand range is not empty');
      switch (fitType) {
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        //            Первый подходящий
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        case _FitType.firstFit:
          break;

        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        //           Следующий подходящий
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        case _FitType.nextFit:
          break;

        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        //              Самый подходящий
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        case _FitType.bestFit:
          break;

        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        //            Самый неподходящий
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        case _FitType.worstFit:
          break;
      }
    }
    return false;
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //
  //
  //              УДАЛЕНИЕ ФАЙЛА
  //
  //
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  bool _deleteFile(File file) {
    if (MockFilesEventsProvider.files.contains(file)) {
      for (var unit in _memoryUnits) {
        if (unit.file?.id == file.id) {
          unit.free();
        }
      }
      return true;
    }
    return false;
  }

  /// Проверяет свободны ли ячейки памяти в заданном диапазоне.
  /// Возвращает true, если все ячейки свободны, возвращает false, если есть хотя бы
  /// одна занятая ячейка или диапазон задан некорректно
  bool _rangeIsEmpty({required int start, required int end}) {
    print('   start - $start');
    print('   end - $end');
    if (start >= 0 && end < _memoryUnits.length) {
      for (var i = start; i < end; i++) {
        if (_memoryUnits[i].isBusy) return false;
      }
    } else {
      return false;
    }
    return true;
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
