import 'package:flutter/material.dart';
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
      floatingActionButton: const FloatingActionButton(onPressed: null, child: Icon(Icons.add)),
      body: Consumer<TagProvider>(builder: (context, tagProvider, child) {
        return RefreshIndicator(
          onRefresh: () async => await tagProvider.refresh(),
          child: Container(),
        );
      }),
    );
  }
}
