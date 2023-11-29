import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class AppPath {
  static const String ConfigFileName = "sdviewer-config.json";
  static const String AppDirName = "sdviewer-alongthecloud";
  static const String OutputDirName = "outputs";

  factory AppPath() => _instance;
  AppPath._();
  static final _instance = AppPath._();

  String _appDocumentDirPath = '';
  String get appDocumentDirPath => _appDocumentDirPath;

  String _appDirPath = '';
  String get appDirPath => _appDirPath;

  String _outputDirPath = '';
  String get outputDirPath => _outputDirPath;

  String _appConfigFilePath = '';
  String get appConfigFilePath => _appConfigFilePath;

  Future<void> init() async {
    Directory appDocumentDir = await getApplicationDocumentsDirectory();
    _appDocumentDirPath = appDocumentDir.path;

    _appDirPath = path.join(appDocumentDirPath, AppDirName);
    _outputDirPath = path.join(appDirPath, OutputDirName);
    _appConfigFilePath = path.join(appDirPath, ConfigFileName);
  }
}
