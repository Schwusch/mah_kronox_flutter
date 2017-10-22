import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

const stateFile = "state.txt";
const themeFile = "theme.txt";
const ignoreFile = "ignore.txt";

Future<Null> saveScheduleStateToFile(String state) async {
  await saveStringToFile(state, stateFile);
}

Future<Null> saveThemeStateToFile(String state) async {
  await saveStringToFile(state, themeFile);
}

Future<Null> saveIgnoreStateToFile(String state) async {
  await saveStringToFile(state, ignoreFile);
}

Future<String> loadThemeStateFromFile() async {
  return loadStringFromFile(themeFile);
}

Future<String> loadScheduleStateFromFile() async {
  return loadStringFromFile(stateFile);
}

Future<String> loadIgnoreStateFromFile() async {
  return loadStringFromFile(ignoreFile);
}

Future<String> loadStringFromFile(String file) async {
  try {
    String dir = (await getApplicationDocumentsDirectory()).path;
    File stateFile = new File("$dir/$file");
    String state = await stateFile.readAsString();
    return state;
  } on FileSystemException {
    return null;
  }
}

Future<Null> saveStringToFile(String s, String file) async {
  String dir = (await getApplicationDocumentsDirectory()).path;
  File stateFile = new File("$dir/$file");
  await stateFile.writeAsString(s);
}