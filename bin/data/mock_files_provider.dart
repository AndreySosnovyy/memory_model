import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:uuid/uuid.dart';

import '../domain/entities/events/add_file_event.dart';
import '../domain/entities/events/delete_file_event.dart';
import '../domain/entities/events/expand_file_event.dart';
import '../domain/entities/events/file_event.dart';
import '../domain/entities/file.dart';

final _random = Random();

int randomNumber({required int min, required int max}) =>
    min + _random.nextInt(max - min);

class MockFilesEventsProvider {
  final StreamController<FileEvent> filesEventsStreamController;

  late final Isolate isolate;

  /// Конструктор
  MockFilesEventsProvider({required this.filesEventsStreamController});

  /// Список сгенерированных файлов
  final files = <File>[];

  /// Возвращает случайный ранее созданный файл
  File get randomExistingFile =>
      files[randomNumber(min: 0, max: files.length)];

  /// Запускает поставку новых файлов в поток
  Future start() async {
    isolate = await Isolate.spawn((_) {
      Timer.periodic(
        Duration(milliseconds: randomNumber(min: 1, max: 100)),
        (_) {
          switch (randomNumber(min: 0, max: 3)) {
            // Добавление нового файла
            case 0:
              final generatedFile = File(
                id: Uuid().v4(),
                numberOfMemoryUnits: randomNumber(min: 1, max: 10),
              );
              files.add(generatedFile);
              filesEventsStreamController.add(
                AddFileEvent(generatedFile),
              );
              break;

            // Расширение существующего файла
            case 1:
              if (files.isNotEmpty) {
                final numberOfRequestingMemoryUnits =
                    randomNumber(min: 1, max: 10);
                final fileToBeExpanded = randomExistingFile;
                files
                    .singleWhere((file) => file.id == fileToBeExpanded.id)
                    .numberOfMemoryUnits += numberOfRequestingMemoryUnits;
                filesEventsStreamController.add(
                  ExpandFileEvent(
                    fileToBeExpanded,
                    numberOfMemoryUnitsToBeRequested:
                        numberOfRequestingMemoryUnits,
                  ),
                );
              }
              break;

            // Удаление существующего файла
            case 2:
              if (files.isNotEmpty) {
                final fileToBeDeleted = randomExistingFile;
                files.remove(fileToBeDeleted);
                filesEventsStreamController.add(
                  DeleteFileEvent(fileToBeDeleted),
                );
              }
              break;
          }
        },
      );
    }, null);
  }

  /// Останавливает поставку новых файлов  в поток
  void stop() => isolate.kill(priority: Isolate.immediate);
}
