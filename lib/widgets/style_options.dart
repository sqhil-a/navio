import 'package:flutter/material.dart';
import 'package:navio/widgets/notifiers.dart';
import 'package:navio/widgets/buttons/option_button.dart';
import 'package:navio/widgets/vertical_clipper.dart';

class StyleOptions extends StatefulWidget {
  const StyleOptions({super.key});

  @override
  State<StyleOptions> createState() => _StyleOptionsState();
}

class _StyleOptionsState extends State<StyleOptions> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 4, right: 4),
              child: VerticalClipper(
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                  child: ValueListenableBuilder<List<String>>(
                    valueListenable: styleListNotifier,
                    builder: (context, styleList, child) {
                      final filteredList = styleList
                          .where(
                            (style) =>
                                style.toLowerCase().contains(searchQuery),
                          )
                          .toList();
                      return Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: filteredList.map((style) {
                          return ValueListenableBuilder<String?>(
                            valueListenable: selectedStyleNotifier,
                            builder: (context, selectedStyle, _) {
                              final isSelected = selectedStyle == style;
                              return OptionButton(
                                height: 45,
                                text: style,
                                singleChoice: false,
                                selected: isSelected,
                                onTap: () {
                                  // toggle off if already selected
                                  selectedStyleNotifier.value = isSelected
                                      ? null
                                      : style;
                                },
                              );
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
