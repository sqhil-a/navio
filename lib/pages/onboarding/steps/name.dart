import 'package:flutter/material.dart';
import 'package:navio/app_storage.dart';
import 'package:navio/widgets/custom_text_field.dart';
import 'package:navio/widgets/buttons/label_button.dart';
import 'package:navio/widgets/notifiers.dart';

class Name extends StatefulWidget {
  final VoidCallback completeStep;

  const Name({super.key, required this.completeStep});

  @override
  State<Name> createState() => _NameState();
}

class _NameState extends State<Name> {
  final TextEditingController nameController = TextEditingController();

  bool isNameValid = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What can we call you?",
            style: TextStyle(fontSize: 20, fontFamily: "SF-Pro"),
          ),

          const SizedBox(height: 20),

          CustomTextField(
            maxLines: 1,
            maxLength: 30,
            hintText: "Name",
            controller: nameController,
            onChanged: setName,
          ),

          const Spacer(),

          // Continue button is disabled when name is not valid, to prevent empty name
          LabelButton(
            height: 75,
            width: double.infinity,
            text: "Continue",
            onTap: isNameValid ? widget.completeStep : () {},
            enabled: isNameValid,
            isLoading: false,
          ),
        ],
      ),
    );
  }

  void setName(String value) {
    usernameNotifier.value = value;
    AppStorage.saveString("username", value);

    setState(() {
      isNameValid = value.trim().isNotEmpty;
    });
  }
}
