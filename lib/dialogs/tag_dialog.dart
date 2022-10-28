import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:photo_taginator/database_provider.dart';
import 'package:sqflite/sqflite.dart';

class TagDialog extends StatefulWidget {
  const TagDialog({
    super.key,
    required this.cities,
    required this.selectedCities,
    required this.onSelectedCitiesListChanged,
  });

  final List<String> cities;
  final List<String> selectedCities;
  final ValueChanged<List<String>> onSelectedCitiesListChanged;

  @override
  State<TagDialog> createState() => _TagDialogState();
}

class _TagDialogState extends State<TagDialog> {
  late Database _database;
  List<String> _allTags = [];
  List<String> _currentTags = [];
  Map<String, bool> valuesMap = {};

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    log("Refresh");
    _database = await DatabaseProvider.instance.getDatabase();
    List query = await _database.query("TAGS", columns: ["NAME"]);
    List<String> tags = query.map((entity) => entity["NAME"] as String).toList();
    setState(() {
      _allTags = tags;
      _currentTags = tags;
      valuesMap = {for (String tag in _allTags) tag: _currentTags.contains(tag)};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        insetPadding: const EdgeInsets.only(top: 100, bottom: 100, left: 50, right: 50),
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: Container(),
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            centerTitle: true,
            title: const Text('Manage Tags'),
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                    itemCount: _allTags.length,
                    itemBuilder: (BuildContext context, int index) {
                      final String tag = _allTags[index];
                      return CheckboxListTile(
                          title: Text(tag),
                          value: valuesMap[tag],
                          onChanged: (value) {
                            setState(() {
                              valuesMap[tag] = value!;
                            });
                          });
                    }),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
            ],
          ),
        ));
  }
}
