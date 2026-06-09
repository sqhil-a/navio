import 'package:flutter/material.dart';
import 'package:navio/widgets/notifiers.dart';

class AppTitle extends StatelessWidget {
  const AppTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedNavIndexNotifier,
      builder: (context, value, child) {
        return ValueListenableBuilder(
          valueListenable: selectedNavIndexNotifier,
          builder: (context, value, child) {
            final title = getTabName(value);
            return Text(
              title,
              style: TextStyle(fontFamily: "New-York", fontSize: 0),
            );
          },
        );
      },
    );
  }

  String getTabName(int index) {
    switch (index) {
      case 0:
        return "Career Finder";
      case 1:
        return "Portfolio";
      case 2:
        return "Career Simulator";
      default:
        return "Portfolio";
    }
  }
}
