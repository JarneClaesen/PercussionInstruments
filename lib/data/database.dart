import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SearchHistoryDataBase {

  List<String> searchHistory = [];

  // reference the box
  final _myBox = Hive.box('mybox');

  void createInitialData() {
    searchHistory = [];
  }

  void loadData() {
    searchHistory = _myBox.get("SEARCHHISTORY");
  }

  void updateData() {
    _myBox.put("SEARCHHISTORY", searchHistory);
  }

}