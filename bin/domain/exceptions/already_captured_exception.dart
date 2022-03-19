import '../entities/memory_unit.dart';

class AlreadyCapturedException implements Exception {
  final MemoryUnit unit;
  final String message;

  AlreadyCapturedException({
    required this.unit,
    String? message,
  }) : message = message ??
      'The unit ${unit.id} is already captured';
}
