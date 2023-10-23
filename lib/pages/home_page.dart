import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/adapters.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show SystemChrome, SystemUiOverlayStyle;
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:musical_terms/data/database.dart';
import '../main.dart';
import '/data/instruments.dart';
import '/components/search_results_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {
  //reference the hive box
  final _myBox = Hive.box('mybox');
  SearchHistoryDataBase db = SearchHistoryDataBase();

  static const historyLength = 5;
  final List<String> jsonList = [];

  late List<String> filteredJsonList;
  late List<String> filteredSearchHistory;
  late FloatingSearchBarController controller;

  String? selectedTerm;
  String? description;
  String? french;
  String? german;
  String? italian;
  String? spanish;

  @override
  void initState() {
    super.initState();
    _initializeData();
    controller = FloatingSearchBarController();
    filteredSearchHistory = searchHistory();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _initializeData() {
    if (_myBox.get("SEARCHHISTORY") == null) {
      db.createInitialData();
    } else {
      db.loadData();
    }
    fillJsonList();
  }

  void setInstrument(String? term) {
    var instruments = _loadJson();
    for (var instrument in instruments) {
      if (_isMatch(instrument, term)) {
        _assignInstrumentDetails(instrument);
        return;
      }
    }
  }

  bool _isMatch(Map<String, dynamic> instrument, String? term) {
    return instrument.values
        .any((value) => value.toString().toLowerCase() == term?.toLowerCase());
  }

  void _assignInstrumentDetails(Map<String, dynamic> instrument) {
    selectedTerm = instrument['InstrumentName'];
    description = instrument['Description'];
    french = instrument['French'];
    german = instrument['German'];
    italian = instrument['Italian'];
    spanish = instrument['Spanish'];
  }

  dynamic _loadJson() {
    var file = loadInstruments();
    return jsonDecode(file.replaceAll("Instrument Name", "InstrumentName"));
  }

  void fillJsonList() {
    var instruments = _loadJson() as List<dynamic>;
    //var instruments = loadInstruments() as List<dynamic>;
    for (var instrument in instruments) {
      jsonList.add(instrument['InstrumentName']);

      if (!jsonList.contains(instrument['French'])) {
        jsonList.add(instrument['French']);
      }

      if (!jsonList.contains(instrument['German'])) {
        jsonList.add(instrument['German']);
      }

      if (!jsonList.contains(instrument['Spanish'])) {
        jsonList.add(instrument['Spanish']);
      }

      if (!jsonList.contains(instrument['Italian'])) {
        jsonList.add(instrument['Italian']);
      }
    }
  }

  void emptyJsonList() {
    jsonList.clear();
  }

  List<String> searchHistory() {
    return db.searchHistory.reversed.toList();
  }

  List<String> searchTerms({
    required String? filter,
  }) {
    if (filter != null && filter.isNotEmpty) {
      return jsonList
          .where((term) => term.toLowerCase().contains(filter.toLowerCase()))
          .toList();
    } else {
      return jsonList.reversed.toList();
    }
  }

  bool queryExists(query) {
    if (jsonList.contains(query)) {
      return true;
    }
    return false;
  }

  void addSearchTerm(String term) {
    if (db.searchHistory.contains(term)) {
      putSearchTermFirst(term);
      db.updateData();
      return;
    }

    if (term.isEmpty) {
      return;
    }

    db.searchHistory.add(term);
    if (db.searchHistory.length > historyLength) {
      // if history is longer than 5, remove the last one
      db.searchHistory.removeRange(0, db.searchHistory.length - historyLength);
    }
    db.updateData();

    filteredSearchHistory = searchHistory();
  }

  void deleteSearchTerm(String term) {
    db.searchHistory.removeWhere((t) => t == term);
    db.updateData();
    filteredSearchHistory = searchHistory();
  }

  void putSearchTermFirst(String term) {
    deleteSearchTerm(term);
    addSearchTerm(term);
  }

  void toastError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      textColor: Theme.of(context).colorScheme.onErrorContainer,
      fontSize: 16.0,
    );
  }

  dynamic capitalize(dynamic s) => s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    return Scaffold(
      body: FloatingSearchBar(
        controller: controller,
        body: FloatingSearchBarScrollNotifier(
          child: SearchResultsText(
            searchTerm: selectedTerm,
            description: description,
            french: french,
            german: german,
            italian: italian,
            spanish: spanish,
          ),
        ),
        elevation: 0,
        transition: CircularFloatingSearchBarTransition(),
        borderRadius: BorderRadius.circular(20),
        physics: const BouncingScrollPhysics(),
        //backgroundColor: Theme.of(context).colorScheme.onSecondary,
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,  // zoekbalk kleur
        title: Text(
          selectedTerm ?? 'Musical Terms',
          style: Theme.of(context).textTheme.headline6,
        ),
        hint: 'Search...',
        actions: [
          FloatingSearchBarAction.searchToClear(),
        ],
        onQueryChanged: (query) {
          setState(() {
            filteredJsonList = searchTerms(filter: query);
          });
        },
        onSubmitted: (query) {
          setState(() async {
            dynamic firstTerm;
            if (filteredJsonList.isNotEmpty) {
              firstTerm = filteredJsonList[0]; // Als dit niet in deze if staat dan krijg je een error omdat filteredJsonList leeg kan zijn
            }
            if (query.isEmpty) {
              // write error message
              toastError("Please type in an instrument");
            }
            else if (queryExists(capitalize(query)) || !queryExists(query)) {
              if (filteredJsonList.isNotEmpty) {
                print("Instrument found");
                putSearchTermFirst(firstTerm);
                selectedTerm = firstTerm;
                setInstrument(firstTerm);
                controller.close();
              }
              if (filteredJsonList.isEmpty) {
                // write error message
                print("Instrument not found");
                toastError("Instrument not found");
              }
            } else {
              // write error message
              toastError("Instrument not found");
            }
          });
          controller.close();
        },
        builder: (context, transition) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Material(
              color: Theme.of(context).colorScheme.onSecondary, // Zoeklijst kleur
              elevation: 4,
              child: Builder(
                builder: (context) {
                  if (filteredSearchHistory.isEmpty &&
                      controller.query.isEmpty) {
                    return Container(
                      height: 56,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        'Start searching',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    );
                  } else if (controller.query.isNotEmpty) {

                    return SingleChildScrollView(
                      child: SizedBox(
                        height: min(600, filteredJsonList.length * 56.0),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 0),
                          itemCount: filteredJsonList.length,
                          itemBuilder: (BuildContext context, int index) {
                            var term = filteredJsonList[index];
                            return ListTile(
                              title: Text(
                                term,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              leading: const Icon(Icons.search),
                              onTap: () {
                                setState(() {
                                  putSearchTermFirst(term);
                                  selectedTerm = term;
                                  emptyJsonList();
                                  fillJsonList();
                                  setInstrument(selectedTerm);
                                });
                                controller.close();
                              },
                            );
                          },
                        ),
                      ),
                    );
                  } else {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: filteredSearchHistory
                          .map(
                            (term) => ListTile(
                          title: Text(
                            term,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          leading: const Icon(Icons.history),
                          trailing: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                deleteSearchTerm(term);
                              });
                            },
                          ),
                          onTap: () {
                            setState(() {
                              putSearchTermFirst(term);
                              selectedTerm = term;
                              emptyJsonList();
                              fillJsonList();
                              setInstrument(selectedTerm);
                            });
                            controller.close();
                          },
                        ),
                      )
                          .toList(),
                    );
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}