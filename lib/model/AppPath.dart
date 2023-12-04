import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../util/PathUtil.dart';

class AppPath {
  static const String AppDirName = "sdviewer-alongthecloud";
  static const String OutputDirName = "outputs";
  static const String DataDirName = "data";
  static const String ConfigFileName = "sdviewer-config.json";
  static const String DataFileName = "sdviewer-database.json";

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

  String _appDataDirPath = '';
  String get appDataDirPath => _appDataDirPath;

  String _appDataFilePath = '';
  String get appDataFilePath => _appDataFilePath;

  Future<void> init() async {
    Directory appDocumentDir = await getApplicationDocumentsDirectory();

    _appDocumentDirPath = appDocumentDir.path;
    _appDirPath = path.join(appDocumentDirPath, AppDirName);
    _outputDirPath = path.join(appDirPath, OutputDirName);
    _appConfigFilePath = path.join(appDirPath, ConfigFileName);
    _appDataDirPath = path.join(appDirPath, DataDirName);
    _appDataFilePath = path.join(_appDataDirPath, DataFileName);
  }

  bool isExistPath() {
    return Directory(_appDirPath).existsSync();
  }

  Future<void> makeDir() async {
    await PathUtil.makeDir(appDataDirPath);
    await PathUtil.makeDir(appDirPath);
    await PathUtil.makeDir(outputDirPath);
  }
}
