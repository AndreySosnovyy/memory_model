import '../exceptions/already_captured_exception.dart';
import 'memory_unit_log_event.dart';
import 'file.dart';

///  Ячейка памяти
class MemoryUnit {
  /// Идентификатор ячейки памяти
  final String id;

  /// Получить стояние ячейки: свободна/занята
  bool get isBusy => file != null;

  bool get isNotBusy => !isBusy;

  /// Файл, захвативший ячейку памяти
  File? file;

  /// Лог ячейки памяти (хранит историю захватов ячейки памяти)
  final log = <MemoryUnitLogEvent>[];

  /// Конструктор
  MemoryUnit({required this.id});

  /// Захватить ячейку памяти
  void capture({required File file}) {
    if (isNotBusy) {
      this.file = file;
      log.add(MemoryUnitLogEvent(file: file));
    } else {
      throw AlreadyCapturedException(unit: this);
    }
  }

  /// Освободить ячейку памяти
  void free() {
    file = null;
    if (log.isNotEmpty) {
      log.last.endTime = DateTime.now();
      log.last.captureDuration =
          log.last.endTime.difference(log.last.startTime);
    }
  }
}
