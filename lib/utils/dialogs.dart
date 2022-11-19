import 'package:flutter/material.dart';

Future<String?> createAddDialog(BuildContext context, TextEditingController controller, String title, String hint) {
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Center(child: Text(title)),
      content: TextField(
          autofocus: true,
          autocorrect: false,
          keyboardType: TextInputType.visiblePassword,
          controller: controller,
          decoration: InputDecoration(hintText: hint)),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(controller.text);
            controller.clear();
          },
          child: const Text("Submit"),
        )
      ],
    ),
  );
}

Future<bool?> createRemoveDialog(BuildContext context, String title, String text) async {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Center(child: Text(title)),
      content: Text(text),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Cancel")),
        TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("Confirm")),
      ],
    ),
  );
}
