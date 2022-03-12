import '../file.dart';
import 'file_event.dart';

class ExpandFileEvent extends FileEvent {
  ExpandFileEvent(
    File file, {
    required this.memoryModelsToRequest,
  }) : super(file);

  final int memoryModelsToRequest;
}
