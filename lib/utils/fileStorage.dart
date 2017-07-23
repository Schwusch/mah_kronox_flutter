import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<Null> saveStateToFile(String state) async {
  String dir = (await getApplicationDocumentsDirectory()).path;
  File stateFile = new File("$dir/state.txt");
  await stateFile.writeAsString(state);
}

Future<String> loadStateFromFile() async {
  try {
    String dir = (await getApplicationDocumentsDirectory()).path;
    File stateFile = new File("$dir/state.txt");
    String state = await stateFile.readAsString();
    return state;
  } on FileSystemException {
    return null;
  }
}
