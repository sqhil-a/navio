import 'package:flutter/material.dart';
import 'package:navio/app_storage.dart';
import 'package:navio/pages/careerfinder.dart';
import 'package:navio/pages/careersimulator.dart';
import 'package:navio/pages/onboarding/onboarding.dart';
import 'package:navio/pages/portfolio/portfolio.dart';
import 'package:navio/widgets/line_seperator.dart';
import 'package:navio/widgets/navio_theme.dart';
import 'package:navio/widgets/nav_bar.dart';
import 'package:navio/widgets/spacing.dart';
import 'package:navio/widgets/title.dart';
import 'package:navio/widgets/notifiers.dart';
import 'package:lottie/lottie.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.wait([
      loadSavedValues(),
      Future.delayed(const Duration(milliseconds: 450)),
    ]);
    if (!mounted) return;

    setState(() => _isLoaded = true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "New-York",
        scaffoldBackgroundColor: NavioTheme.background,
        canvasColor: NavioTheme.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: NavioTheme.accent,
          brightness: Brightness.dark,
        ),
      ),
      title: "Navio",
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeOut,

            transitionBuilder: (child, animation) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              );

              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.015),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              );
            },

            child: _isLoaded
                ? _AppShell(key: const ValueKey('shell'))
                : _SplashScreen(key: const ValueKey('splash')),
          ),
        ),
      ),
    );
  }
}

/// Shown while [loadSavedValues] is running.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        'assets/animations/loading.json',
        width: 100,
        height: 100,
        fit: BoxFit.contain,
      ),
    );
  }
}

/// The real app shell - only mounted after values are loaded.
class _AppShell extends StatelessWidget {
  /// Controls length of crossfade in milliseconds.
  static const Duration crossfadeDuration = Duration(milliseconds: 100);

  const _AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentGeometry.topCenter,
      children: [
        // Content
        ValueListenableBuilder(
          valueListenable: completedOnboardingNotifier,
          builder: (context, onboardingComplete, child) {
            return ValueListenableBuilder(
              valueListenable: selectedNavIndexNotifier,
              builder: (context, value, child) {
                return ValueListenableBuilder(
                  valueListenable: showAuthPageNotifier,
                  builder: (context, auth, child) {
                    return AnimatedSwitcher(
                      duration: crossfadeDuration,
                      switchInCurve: Curves.easeIn,
                      switchOutCurve: Curves.easeOut,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: KeyedSubtree(
                        key: ValueKey('${onboardingComplete}_$value'),
                        child: getPage(value),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
        // NavBar
        ValueListenableBuilder(
          valueListenable: completedOnboardingNotifier,
          builder: (context, onboardingComplete, child) {
            if (!onboardingComplete) return const SizedBox.shrink();

            return Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: NavioTheme.background,
                  boxShadow: [
                    BoxShadow(
                      color: NavioTheme.background.withValues(alpha: 0.96),
                      blurRadius: 24,
                      spreadRadius: 18,
                      offset: const Offset(0, -10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const LineSeparator(),
                    Spacing(height: 20),
                    const NavBar(),
                  ],
                ),
              ),
            );
          },
        ),
        // App header
        SafeArea(child: AppTitle()),
      ],
    );
  }
}

Future<void> loadSavedValues() async {
  // Load local first (instant)
  careerNotifier.value = await AppStorage.loadString("career") ?? "";
  careerTitleNotifier.value = await AppStorage.loadString("careerTitle") ?? "";
  usernameNotifier.value = await AppStorage.loadString("username") ?? "";
  stageNotifier.value = await AppStorage.loadString("stage") ?? "";
  selectedStyleNotifier.value = await AppStorage.loadString("style");
  selectedAoiNotifier.value = await AppStorage.loadStringList("aois");
  completedOnboardingNotifier.value =
      await AppStorage.loadBool("completedOnboarding") ?? false;
}

Widget getPage(int index) {
  if (!completedOnboardingNotifier.value) {
    return OnboardingPage();
  }

  switch (index) {
    case 0:
      return CareerFinderPage();
    case 1:
      return PortfolioPage();
    case 2:
      return CareerSimulatorPage();
    default:
      return PortfolioPage();
  }
}
