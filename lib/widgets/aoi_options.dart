import 'package:flutter/material.dart';
import 'package:navio/widgets/custom_text_field.dart';
import 'package:navio/widgets/notifiers.dart';
import 'package:navio/widgets/buttons/option_button.dart';
import 'package:navio/widgets/spacing.dart';
import 'package:navio/widgets/vertical_clipper.dart';

class AOIOptions extends StatefulWidget {
  const AOIOptions({super.key});

  @override
  State<AOIOptions> createState() => _AOIOptionsState();
}

class _AOIOptionsState extends State<AOIOptions> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            maxLines: 1,
            maxLength: 30,
            hintText: "Search",
            controller: searchController,
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase();
              });
            },
          ),
          const Spacing(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 4, right: 4),
              child: VerticalClipper(
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                  child: ValueListenableBuilder<List<String>>(
                    valueListenable: aoiListNotifier,
                    builder: (context, aoiList, child) {
                      final filteredList = aoiList
                          .where(
                            (aoi) => aoi.toLowerCase().contains(searchQuery),
                          )
                          .toList();
                      return Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: filteredList.map((aoi) {
                          return ValueListenableBuilder<List<String>>(
                            valueListenable: selectedAoiNotifier,
                            builder: (context, selectedAois, _) {
                              final isSelected = selectedAois.contains(aoi);
                              return OptionButton(
                                height: 45,
                                text: aoi,
                                singleChoice: false,
                                selected: isSelected,
                                onTap: () {
                                  final selected = List<String>.from(
                                    selectedAoiNotifier.value,
                                  );
                                  if (selected.contains(aoi)) {
                                    selected.remove(aoi);
                                  } else {
                                    if (selected.length >= 3) return;
                                    selected.add(aoi);
                                  }
                                  selectedAoiNotifier.value = selected;
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
