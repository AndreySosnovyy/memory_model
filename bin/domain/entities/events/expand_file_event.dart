import '../file.dart';
import 'file_event.dart';

class ExpandFileEvent extends FileEvent {
  ExpandFileEvent(
    File file, {
    required this.numberOfMemoryUnitsToBeRequested,
  }) : super(file);

  final int numberOfMemoryUnitsToBeRequested;
}
