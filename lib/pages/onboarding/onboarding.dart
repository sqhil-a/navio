import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:navio/app_storage.dart';
import 'package:navio/pages/onboarding/steps/aoi.dart';
import 'package:navio/pages/onboarding/steps/career.dart';
import 'package:navio/pages/onboarding/steps/name.dart';
import 'package:navio/pages/onboarding/steps/stage.dart';
import 'package:navio/pages/onboarding/steps/style.dart';
import 'package:navio/widgets/line_seperator.dart';
import 'package:navio/widgets/notifiers.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _displayedStep = 0;
  double _opacity = 0.0;
  bool _transitioning = false;

  static const _fadeOutDuration = Duration(milliseconds: 350);
  static const _pauseDuration = Duration(milliseconds: 600);
  static const _fadeInDuration = Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();

    // If already completed, skip straight to the main app
    if (completedOnboardingNotifier.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _completeOnboard(haptic: false);
      });
      return;
    }

    // Reset step in case the notifier was left at a non-zero value
    onboardingStepNotifier.value = 0;
    _displayedStep = 0;

    onboardingStepNotifier.addListener(_onStepChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;
      setState(() => _opacity = 1.0);
    });
  }

  @override
  void dispose() {
    onboardingStepNotifier.removeListener(_onStepChanged);
    super.dispose();
  }

  Future<void> _onStepChanged() async {
    if (_transitioning) return;
    _transitioning = true;

    // Fade out
    setState(() => _opacity = 0.0);
    await Future.delayed(_fadeOutDuration);

    // Optional pause (can set to 0 for smoother feel)
    await Future.delayed(_pauseDuration);

    if (!mounted) return;

    final nextStep = onboardingStepNotifier.value;

    if (nextStep >= 5) {
      await _completeOnboard();
      return;
    }

    // Swap step
    setState(() => _displayedStep = nextStep);

    await Future.delayed(const Duration(milliseconds: 32));
    if (!mounted) return;

    // Fade in
    setState(() => _opacity = 1.0);
    await Future.delayed(_fadeInDuration);

    _transitioning = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Image(
                image: AssetImage("assets/images/Logo.png"),
                width: 180,
              ),
              const LineSeparator(),
              const SizedBox(height: 25),

              Expanded(
                child: AnimatedOpacity(
                  opacity: _opacity,
                  duration: _opacity == 1.0
                      ? _fadeInDuration
                      : _fadeOutDuration,
                  curve: _opacity == 1.0 ? Curves.easeOut : Curves.easeIn,
                  child: _buildStepWidget(_displayedStep),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepWidget(int step) {
    switch (step) {
      case 0:
        return Name(key: const ValueKey(0), completeStep: _onStepComplete);
      case 1:
        return Career(key: const ValueKey(1), completeStep: _onStepComplete);
      case 2:
        return Stage(key: const ValueKey(2), completeStep: _onStepComplete);
      case 3:
        return AOI(key: const ValueKey(3), completeStep: _onStepComplete);
      case 4:
        return Style(key: const ValueKey(4), completeStep: _onStepComplete);
      default:
        return Name(key: const ValueKey(0), completeStep: _onStepComplete);
    }
  }

  void _onStepComplete() {
    onboardingStepNotifier.value += 1;
  }

  Future<void> _completeOnboard({bool haptic = true}) async {
    await AppStorage.saveBool("completedOnboarding", true);
    completedOnboardingNotifier.value = true;
    if (haptic) Haptics.vibrate(HapticsType.success);
  }
}
