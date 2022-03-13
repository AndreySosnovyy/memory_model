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
        assert(size > 0),
        _memoryUnits = List.filled(
          size,
          MemoryUnit(id: Uuid().v4()),
          growable: false,
        ) {
    filesEventsStream.listen((event) => handleFile(event));
  }

  /// Память, состоящая из ячеек
  late final List<MemoryUnit> _memoryUnits;

  /// Размер памяти устройства (измеряется в количестве ячеек памяти)
  final int size;

  /// Поток новых файлов, желающих заполучить ячейки памяти устройства
  final Stream<FileEvent> filesEventsStream;

  /// Список имеющихся файлов
  final files = <File>[];

  /// Обработка поступившего события на добавление/расширения/удаления файла
  // todo: implement method
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
  }

  void _addFile(File file, {required _FitType fitType}) {
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
    _memoryUnits
        .where((unit) => unit.file?.id == file.id)
        .map((unit) => unit.free());
  }
}

enum _FitType { firstFit, nextFit, bestFit, worstFit }
