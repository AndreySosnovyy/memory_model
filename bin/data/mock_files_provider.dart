import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:uuid/uuid.dart';

import '../domain/entities/events/file_event.dart';
import '../domain/entities/file.dart';

class MockFilesEventsProvider {
  final StreamController<FileEvent> filesEventsStreamController;

  late final Isolate isolate;

  /// Конструктор
  MockFilesEventsProvider({required this.filesEventsStreamController});

  /// Список сгенерированных файлов
  final files = <File>[];

  /// Запускает поставку новых файлов в поток
  Future start() async {
    isolate = await Isolate.spawn((_) {
      final random = Random();
      Timer.periodic(
        Duration(milliseconds: random.nextInt(99) + 1),
        (_) {
          // todo: generate random events (+ update files list)
          filesEventsStreamController.add(
            FileEvent(File(
              id: Uuid().v4(),
              numberOfMemoryUnits: random.nextInt(9) + 1,
            )),
          );
        },
      );
    }, null);
  }

  /// Останавливает поставку новых файлов  в поток
  void stop() => isolate.kill(priority: Isolate.immediate);
}
