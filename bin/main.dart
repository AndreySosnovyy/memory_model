import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'domain/entities/events/file_event.dart';
import 'features/memory_controller.dart';
import 'data/mock_files_provider.dart';

void main() {
  // Количество ячеек памяти в контроллере
  late final int size;

  // Считывание данных из консоли и валидация
  try {
    stdout.write('Enter number of memory units: ');
    size = int.parse(stdin.readLineSync(encoding: utf8)!);
  } catch (e) {
    print('\n$e');
    print('Application terminated!');
  }

  // Контроллер потока файлов занимающих ячейки памяти
  final filesEventsStreamController = StreamController<FileEvent>();

  // Модуль памяти, обрабатывающий поступающие из потока файлы
  MemoryController(
    size: size,
    filesEventsStream: filesEventsStreamController.stream,
  );

  // Генерация файлов со случайным количеством занимаемых ячеек
  // памяти и случайной продолжительность жизни из отдельного изолята
  final mockFilesProvider = MockFilesEventsProvider(
    filesEventsStreamController: filesEventsStreamController,
  );

  // Запуск генератор случайных файловых событий
  mockFilesProvider.start();

  // Остановка генератора спустя указанный промежуток времени
  Future.delayed(Duration(seconds: 60), mockFilesProvider.stop);
}
