import 'file.dart';

/// Элемент лога ячейки памяти
class MemoryUnitLogEvent {

  /// Файл, захвативший ячейку
  final File file;

  /// Время начала захвата ячейки
  final DateTime startTime;

  /// Время освобождения ячейки
  late final DateTime endTime;

  /// Время, в течении которого ячейка памяти была захвачена
  late final Duration captureDuration;

  /// Конструктор
  MemoryUnitLogEvent({required this.file}) : startTime = DateTime.now();
}
