import 'package:flutter/material.dart';
import 'package:navio/app_storage.dart';
import 'package:navio/widgets/buttons/label_button.dart';
import 'package:navio/widgets/notifiers.dart';
import 'package:navio/widgets/spacing.dart';

class Stage extends StatefulWidget {
  final VoidCallback completeStep;

  const Stage({super.key, required this.completeStep});

  @override
  State<Stage> createState() => _StyleState();
}

class _StyleState extends State<Stage> {
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Where are you in your education or career?",
            style: TextStyle(fontSize: 20, fontFamily: "SF-Pro"),
          ),

          const Spacer(),

          LabelButton(
            isLoading: false,
            height: 75,
            width: double.infinity,
            text: "Highschool",
            onTap: () {
              AppStorage.saveString("stage", "Highschool");
              stageNotifier.value = "Highschool";
              widget.completeStep();
            },
            enabled: true,
          ),

          const Spacing(height: 20),

          LabelButton(
            isLoading: false,
            height: 75,
            width: double.infinity,
            text: "College / University",
            onTap: () {
              AppStorage.saveString("stage", "College / University");
              stageNotifier.value = "College / University";
              widget.completeStep();
            },
            enabled: true,
          ),

          const Spacing(height: 20),

          LabelButton(
            isLoading: false,
            height: 75,
            width: double.infinity,
            text: "Working",
            onTap: () {
              AppStorage.saveString("stage", "Working");
              stageNotifier.value = "Working";
              widget.completeStep();
            },
            enabled: true,
          ),
        ],
      ),
    );
  }
}
