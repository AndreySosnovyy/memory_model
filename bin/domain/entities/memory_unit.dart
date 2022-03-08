import 'memory_unit_log_event.dart';
import 'process.dart';

///  Ячейка памяти
class MemoryUnit {
  /// Получить стояние ячейки: свободна/занята
  bool get isBusy => process != null;

  /// Процесс, захвативший ячейку памяти
  late Process? process;

  /// Лог ячейки памяти (хранит историю захватов ячейки памяти)
  final log = <MemoryUnitLogEvent>[];

  /// Конструктор
  MemoryUnit();

  /// Захватить ячейку памяти
  void capture({required Process process}) {
    this.process = process;
    log.add(MemoryUnitLogEvent(process: process));
  }

  /// Освободить ячейку памяти
  void free() {
    process = null;
    if (log.isNotEmpty) {
      log.last.endTime = DateTime.now();
      log.last.captureDuration =
          log.last.endTime.difference(log.last.startTime);
    }
  }
}
