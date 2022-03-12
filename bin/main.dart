import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'features/memory_controller.dart';
import 'domain/entities/file.dart';
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

  // Контроллер потока процессов занимающих ячейки памяти
  final filesStreamController = StreamController<File>();

  // Модуль памяти, обрабатывающий поступающие из потока процессы
  final memoryController = MemoryController(
    size: size,
    filesStream: filesStreamController.stream,
  );

  // Генерация процессов со случайным количеством занимаемых ячеек
  // памяти и случайной продолжительность жизни из отдельного изолята
  final mockFilesProvider = MockFilesProvider(
    filesStreamController: filesStreamController,
  );
  mockFilesProvider.start();
  Future.delayed(Duration(seconds: 1), mockFilesProvider.stop);
}
