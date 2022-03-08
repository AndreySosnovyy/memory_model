import 'process.dart';

/// Элемент лога ячейки памяти
class MemoryUnitLogEvent {

  /// Процесс, захвативший ячейку
  final Process process;

  /// Время начала захвата ячейки
  final DateTime startTime;

  /// Время освобождения ячейки
  late final DateTime endTime;

  /// Время, в течении которого ячейка памяти была захвачена
  late final Duration captureDuration;

  /// Конструктор
  MemoryUnitLogEvent({required this.process}) : startTime = DateTime.now();
}
