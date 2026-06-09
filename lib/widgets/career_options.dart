import 'package:flutter/material.dart';
import 'package:navio/app_storage.dart';
import 'package:navio/widgets/custom_text_field.dart';
import 'package:navio/widgets/notifiers.dart';
import 'package:navio/widgets/buttons/option_button.dart';
import 'package:navio/widgets/spacing.dart';

class CareerOptions extends StatefulWidget {
  const CareerOptions({super.key});

  @override
  State<CareerOptions> createState() => _CareerOptionsState();
}

class _CareerOptionsState extends State<CareerOptions> {
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

          // Scroll view now expands naturally
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 4, right: 4),
              child: _VerticalClipper(
                // clips only top/bottom, not left/right
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                  child: ValueListenableBuilder<List<String>>(
                    valueListenable: careerListNotifier,
                    builder: (context, careerList, child) {
                      final filteredList = careerList
                          .where(
                            (career) =>
                                career.toLowerCase().contains(searchQuery),
                          )
                          .toList();
                      return Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: filteredList.map((career) {
                          return OptionButton(
                            height: 45,
                            text: career,
                            singleChoice: true,
                            onTap: () {
                              careerNotifier.value = career;
                              AppStorage.saveString("career", career);
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

class _VerticalClipper extends StatelessWidget {
  final Widget child;
  const _VerticalClipper({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRect(clipper: _VerticalOnlyClipper(), child: child);
  }
}

class _VerticalOnlyClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    // Clip top/bottom exactly, but extend left/right by 20px for shadow room
    return Rect.fromLTRB(-20, 0, size.width + 20, size.height);
  }

  @override
  bool shouldReclip(_VerticalOnlyClipper oldClipper) => false;
}
