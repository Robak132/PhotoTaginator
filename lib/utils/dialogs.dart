import 'package:flutter/material.dart';

Future<String?> createAddDialog(BuildContext context, TextEditingController controller, String title, String hint) {
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Center(child: Text(title)),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(controller.text), child: const Text("Submit"))],
      content: TextField(
          autofocus: true,
          autocorrect: false,
          keyboardType: TextInputType.visiblePassword,
          controller: controller,
          decoration: InputDecoration(hintText: hint)),
    ),
  );
}
