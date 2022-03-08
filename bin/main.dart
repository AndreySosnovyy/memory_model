import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'features/memory_controller.dart';
import 'domain/entities/process.dart';
import 'features/mock_processes_provider.dart';

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
  final processStreamController = StreamController<Process>();

  // Модуль памяти, обрабатывающий поступающие из потока процессы
  final memoryController = MemoryController(
    size: size,
    processStream: processStreamController.stream,
  );

  // Генерация процессов со случайным количеством занимаемых ячеек
  // памяти и случайной продолжительность жизни из отдельного изолята
  final mockProcessesProvider = MockProcessesProvider(
    processesStreamController: processStreamController,
  );
  mockProcessesProvider.start();

  Future.delayed(Duration(seconds: 1), mockProcessesProvider.stop);
}
