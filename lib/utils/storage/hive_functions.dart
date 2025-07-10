import 'package:hive_flutter/hive_flutter.dart';
import 'package:revolutionary_stuff/utils/storage/hive_box.dart';

class HiveFunctions {
  //  Box where we store things
  static final userBox = Hive.box(userHiveBox);
}
