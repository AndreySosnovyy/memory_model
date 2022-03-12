import '../file.dart';
import 'file_event.dart';

class AddFileEvent extends FileEvent{
  AddFileEvent(File file) : super(file);
}