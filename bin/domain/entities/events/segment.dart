import '../memory_unit.dart';

class Segment {
  final List<MemoryUnit> memoryUnits = <MemoryUnit>[];

  void addMemoryUnit(MemoryUnit unit) => memoryUnits.add(unit);

  int get length => memoryUnits.length;
}