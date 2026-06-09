import 'package:flutter/material.dart';
import 'package:navio/pages/portfolio/portfolio_home.dart';
import 'package:navio/pages/portfolio/portfolio_plan.dart';
import 'package:navio/widgets/navio_theme.dart';
import 'package:navio/widgets/notifiers.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  bool _showPlan = showPlanNotifier.value;

  @override
  void initState() {
    super.initState();
    showPlanNotifier.addListener(_onShowPlanChanged);
  }

  @override
  void dispose() {
    showPlanNotifier.removeListener(_onShowPlanChanged);
    super.dispose();
  }

  void _onShowPlanChanged() {
    setState(() => _showPlan = showPlanNotifier.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: AnimatedSwitcher(
            duration: NavioTheme.normal,
            layoutBuilder: (currentChild, previousChildren) {
              return currentChild ?? const SizedBox.shrink();
            },
            transitionBuilder: _fadeTransition,
            child: KeyedSubtree(
              key: ValueKey(_showPlan),
              child: _showPlan
                  ? PortfolioPlan(onBack: () => showPlanNotifier.value = false)
                  : PortfolioHome(
                      onOpenPlan: () => showPlanNotifier.value = true,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fadeTransition(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      child: child,
    );
  }
}
