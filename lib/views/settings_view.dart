import 'package:flutter/material.dart';
import 'package:photo_taginator/models/tag.dart';
import 'package:photo_taginator/providers/tag_provider.dart';
import 'package:provider/provider.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _MSettingViewState();
}

class _MSettingViewState extends State<SettingsView> with AutomaticKeepAliveClientMixin<SettingsView> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Tags'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // handle the press
          },
        ),
      ),
      body: Consumer<TagProvider>(builder: (context, tagProvider, child) {
        List<Tag> tags = tagProvider.tags;

        return RefreshIndicator(
          onRefresh: tagProvider.refresh,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
            Expanded(
              child: ListView.builder(
                  itemCount: tags.length,
                  itemBuilder: (BuildContext ctx, index) {
                    return Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.endToStart,
                      onDismissed: (dismissDirection) => tagProvider.removeAt(index),
                      background: Container(
                        color: Colors.red,
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        alignment: Alignment.centerRight,
                        child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 15),
                            child: const Icon(Icons.delete, color: Colors.white)),
                      ),
                      child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          child: ListTile(title: Text(tags[index].name))),
                    );
                  }),
            )
          ]),
        );
      }),
      floatingActionButton: const FloatingActionButton(onPressed: null, child: Icon(Icons.add)),
    );
  }
}
