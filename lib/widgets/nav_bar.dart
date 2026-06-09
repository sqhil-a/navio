import 'package:flutter/material.dart';
import 'package:navio/widgets/buttons/nav_button.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: const [
        Expanded(
          child: NavButton(
            index: 0,
            iconDefault: Icons.explore_outlined,
            iconSelected: Icons.explore,
            label: "Finder",
          ),
        ),
        Expanded(
          child: NavButton(
            index: 1,
            iconDefault: Icons.person_outline_rounded,
            iconSelected: Icons.person,
            label: "Portfolio",
          ),
        ),
        Expanded(
          child: NavButton(
            index: 2,
            iconDefault: Icons.psychology_outlined,
            iconSelected: Icons.psychology,
            label: "Simulator",
          ),
        ),
      ],
    );
  }
}
