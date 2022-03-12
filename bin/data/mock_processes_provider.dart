import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:uuid/uuid.dart';

import '../domain/entities/file.dart';

class MockProcessesProvider {
  final StreamController<File> processesStreamController;

  late final Isolate isolate;

  /// Конструктор
  MockProcessesProvider({required this.processesStreamController});

  /// Запускает поставку новых процессов в поток
  Future start() async {
    isolate = await Isolate.spawn((_) {
      final random = Random();
      Timer.periodic(
        Duration(milliseconds: random.nextInt(99) + 1),
        (_) {
          processesStreamController.add(File.fromJson({
            'id': Uuid().v4(),
            'numberOfMemoryUnits': random.nextInt(9) + 1,
            'liveDuration': random.nextInt(99) + 1,
          }));
        },
      );
    }, null);
  }

  /// Останавливает поставку новых процессов в поток
  void stop() => isolate.kill(priority: Isolate.immediate);
}
