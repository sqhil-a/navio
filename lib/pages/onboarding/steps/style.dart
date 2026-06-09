import 'package:flutter/material.dart';
import 'package:navio/app_storage.dart';
import 'package:navio/widgets/buttons/label_button.dart';
import 'package:navio/widgets/notifiers.dart';
import 'package:navio/widgets/spacing.dart';
import 'package:navio/widgets/style_options.dart';

class Style extends StatefulWidget {
  final VoidCallback completeStep;

  const Style({super.key, required this.completeStep});

  @override
  State<Style> createState() => _StyleState();
}

class _StyleState extends State<Style> {
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What kind of work sounds most enjoyable?",
            style: TextStyle(fontSize: 20, fontFamily: "SF-Pro"),
          ),

          Spacing(height: 20),

          StyleOptions(),
          Spacer(),
          ValueListenableBuilder(
            valueListenable: selectedStyleNotifier,
            builder: (context, option, child) {
              return LabelButton(
                isLoading: false,
                height: 75,
                width: double.infinity,
                text: "Continue",
                onTap: () async {
                  if (option != null) {
                    await AppStorage.saveString("style", option);
                  }
                  widget.completeStep();
                  selectedOptionButtonNotifier.value = null;
                },
                enabled: option != null,
              );
            },
          ),
        ],
      ),
    );
  }
}
