import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:uuid/uuid.dart';

import '../domain/entities/process.dart';

class MockProcessesProvider {
  final StreamController<Process> processesStreamController;

  late Isolate isolate;
  late Timer timer;

  /// Конструктор
  MockProcessesProvider({required this.processesStreamController});

  /// Запускает поставку новых процессов в поток
  Future start() async {
    isolate = await Isolate.spawn((_) {
      final random = Random();
      Timer.periodic(
        Duration(milliseconds: random.nextInt(99) + 1),
        (Timer timer) {
          this.timer = timer;
          processesStreamController.add(Process.fromJson({
            'id': Uuid().v4(),
            'numberOfMemoryUnits': random.nextInt(9) + 1,
            'liveDuration': random.nextInt(99) + 1,
          }));
        },
      );
    }, null);
  }

  /// Останавливает поставку новых процессов в поток
  void stop() {
    isolate.kill(priority: Isolate.immediate);
    timer.cancel();
  }
}
