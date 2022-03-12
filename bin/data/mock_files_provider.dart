import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:uuid/uuid.dart';

import '../domain/entities/file.dart';

class MockFilesProvider {
  final StreamController<File> filesStreamController;

  late final Isolate isolate;

  /// Конструктор
  MockFilesProvider({required this.filesStreamController});

  /// Запускает поставку новых файлов в поток
  Future start() async {
    isolate = await Isolate.spawn((_) {
      final random = Random();
      Timer.periodic(
        Duration(milliseconds: random.nextInt(99) + 1),
        (_) {
          filesStreamController.add(File.fromJson({
            'id': Uuid().v4(),
            'numberOfMemoryUnits': random.nextInt(9) + 1,
            'liveDuration': random.nextInt(99) + 1,
          }));
        },
      );
    }, null);
  }

  /// Останавливает поставку новых файлов  в поток
  void stop() => isolate.kill(priority: Isolate.immediate);
}
