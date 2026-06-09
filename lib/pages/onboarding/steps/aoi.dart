import 'package:flutter/material.dart';
import 'package:navio/app_storage.dart';
import 'package:navio/widgets/aoi_options.dart';
import 'package:navio/widgets/buttons/label_button.dart';
import 'package:navio/widgets/navio_theme.dart';
import 'package:navio/widgets/notifiers.dart';
import 'package:navio/widgets/spacing.dart';

class AOI extends StatefulWidget {
  final VoidCallback completeStep;
  const AOI({super.key, required this.completeStep});

  @override
  State<AOI> createState() => _AOIState();
}

class _AOIState extends State<AOI> {
  int _frozenCount = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Which areas interest you the most?",
            style: TextStyle(fontSize: 20, fontFamily: "SF-Pro"),
          ),
          const Spacing(height: 10),
          ValueListenableBuilder<List<String>>(
            valueListenable: selectedAoiNotifier,
            builder: (context, selectedAois, _) {
              final displayCount = _frozenCount > 0
                  ? _frozenCount
                  : selectedAois.length;
              return Text(
                "$displayCount/3 selected",
                style: TextStyle(
                  color: NavioTheme.textSecondary(alpha: 0.58),
                  fontSize: 13,
                  fontFamily: "SF-Pro",
                ),
              );
            },
          ),
          const Spacing(height: 20),
          AOIOptions(),
          ValueListenableBuilder<List<String>>(
            valueListenable: selectedAoiNotifier,
            builder: (context, selectedAois, child) {
              return LabelButton(
                height: 75,
                width: double.infinity,
                text: "Continue",
                isLoading: false,
                onTap: () async {
                  setState(
                    () => _frozenCount = selectedAois.length,
                  ); // snapshot first
                  await AppStorage.saveStringList("aois", selectedAois);
                  widget.completeStep();
                },
                enabled: selectedAois.isNotEmpty,
              );
            },
          ),
        ],
      ),
    );
  }
}
