import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:photo_taginator/database_provider.dart';
import 'package:sqflite/sqflite.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _MSettingViewState();
}

class _MSettingViewState extends State<SettingsView> with AutomaticKeepAliveClientMixin<SettingsView> {
  late Database _database;
  List<String> _tags = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    _database = await DatabaseProvider.instance.getDatabase();
    List query = await _database.query("TAGS", columns: ["NAME"]);
    List<String> tags = query.map((entity) => entity["NAME"] as String).toList();
    setState(() {
      _tags = tags;
    });
  }

  Future<void> deleteTag(int index) async {
    log("Deleting tag $index");
    // setState(() {
    //   _tags.removeAt(index);
    // });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
            elevation: 0,
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            centerTitle: true,
            title: const Text('Tags'),
            iconTheme: const IconThemeData(color: Colors.black)),
        body: RefreshIndicator(
            onRefresh: refresh,
            child: SafeArea(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    itemCount: _tags.length,
                    itemBuilder: (BuildContext ctx, index) {
                      return Dismissible(
                        key: UniqueKey(),
                        direction: DismissDirection.endToStart,
                        onDismissed: (dismissDirection) => deleteTag(index),
                        background: Container(
                          color: Colors.red,
                          margin: const EdgeInsets.symmetric(horizontal: 15),
                          alignment: Alignment.centerRight,
                          child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 15),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              )),
                        ),
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          child: ListTile(title: Text(_tags[index])),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ))));
  }
}
