import '../file.dart';
import 'file_event.dart';

class DeleteFileEvent extends FileEvent {
  DeleteFileEvent(File file) : super(file);
}