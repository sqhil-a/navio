import 'package:flutter/material.dart';
import 'package:navio/app_storage.dart';
import 'package:navio/widgets/career_options.dart';
import 'package:navio/widgets/buttons/label_button.dart';
import 'package:navio/widgets/navio_theme.dart';
import 'package:navio/widgets/notifiers.dart';
import 'package:navio/widgets/spacing.dart';

class Career extends StatefulWidget {
  final VoidCallback completeStep;

  const Career({super.key, required this.completeStep});

  @override
  State<Career> createState() => _CareerState();
}

class _CareerState extends State<Career> {
  bool isSelectingCareer = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title text
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  isSelectingCareer
                      ? "Please select a career."
                      : "Do you have a career in mind?",
                  style: const TextStyle(fontSize: 20, fontFamily: "SF-Pro"),
                  softWrap: true,
                ),
              ),

              GestureDetector(
                onTap: () {
                  setState(() {
                    isSelectingCareer = false;
                  });
                },
                child: Icon(
                  Icons.close,
                  size: 30,
                  color: isSelectingCareer
                      ? NavioTheme.textPrimary(alpha: 0.8)
                      : Colors.transparent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Show career options only if selecting
          if (isSelectingCareer) const CareerOptions(),

          // Show Yes/No buttons only if not yet selecting
          if (!isSelectingCareer) ...[
            const Spacer(),
            LabelButton(
              isLoading: false,
              height: 75,
              width: double.infinity,
              text: "Yes",
              onTap: () {
                setState(() {
                  isSelectingCareer = true;
                });
              },
              enabled: true,
            ),

            const Spacing(height: 20),

            LabelButton(
              isLoading: false,
              height: 75,
              width: double.infinity,
              text: "No, help me explore",
              onTap: () {
                careerNotifier.value = "";
                AppStorage.saveString("career", "");
                widget.completeStep();
              },
              enabled: true,
            ),
          ] else ...[
            ValueListenableBuilder(
              valueListenable: selectedOptionButtonNotifier,
              builder: (context, option, child) {
                return LabelButton(
                  isLoading: false,
                  height: 75,
                  width: double.infinity,
                  text: "Continue",
                  onTap: () {
                    widget.completeStep();
                    selectedOptionButtonNotifier.value = null;
                  },
                  enabled: option != null,
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
