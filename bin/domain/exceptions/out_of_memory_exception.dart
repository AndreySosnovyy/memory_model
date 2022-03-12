import '../entities/file.dart';

class OutOfMemoryCellsException implements Exception {
  final File process;
  final String message;

  OutOfMemoryCellsException({
    required this.process,
    String? message,
  }) : message = message ??
            'There are no more memory cells to be captured by the process ${process.id} at the time';
}
