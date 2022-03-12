import '../entities/file.dart';

class OutOfMemoryCellsException implements Exception {
  final File file;
  final String message;

  OutOfMemoryCellsException({
    required this.file,
    String? message,
  }) : message = message ??
            'There are no more memory cells to be captured by the file ${file.id} at the time';
}
