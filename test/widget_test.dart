import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navio/main.dart';
import 'package:navio/pages/portfolio/portfolio_home.dart';
import 'package:navio/widgets/notifiers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Navio app renders', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'completedOnboarding': true,
      'username': 'Sahil',
    });

    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.textContaining('Good'), findsOneWidget);
  });

  testWidgets('Magic task generation falls back without crashing', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const career = 'Software Engineering';
    SharedPreferences.setMockInitialValues({
      'career': career,
      'careerTitle': 'Software Engineer',
      'username': 'Sahil',
      'stage': 'Highschool',
      'style': 'Problem Solving',
      'aois': '["Technology"]',
      'portfolioTodosCareer': career,
      'portfolioTodos': '[]',
      'cachedPlan':
          '{"steps":[{"title":"Learn Programming","description":"Complete one beginner coding lesson."},{"title":"Build Projects","description":"Create one small portfolio project."},{"title":"Practice Interviews","description":"Write three interview answers."},{"title":"Find Resources","description":"Save one useful learning resource."}]}',
    });

    careerNotifier.value = career;
    careerTitleNotifier.value = 'Software Engineer';
    usernameNotifier.value = 'Sahil';
    stageNotifier.value = 'Highschool';
    selectedStyleNotifier.value = 'Problem Solving';
    selectedAoiNotifier.value = ['Technology'];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PortfolioHome(onOpenPlan: () {})),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.checklist_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.auto_awesome_rounded));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('4 left'), findsOneWidget);
    expect(find.text('Upload your resume'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.auto_awesome_rounded));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('7 left'), findsOneWidget);
  });

  testWidgets('Portfolio dashboard uses singular task label', (
    WidgetTester tester,
  ) async {
    const career = 'Software Engineering';
    SharedPreferences.setMockInitialValues({
      'career': career,
      'careerTitle': 'Software Engineer',
      'username': 'Sahil',
      'stage': 'Highschool',
      'portfolioTodosCareer': career,
      'portfolioTodos':
          '[{"title":"Practice one skill","kind":"normal","isDone":false}]',
    });

    careerNotifier.value = career;
    careerTitleNotifier.value = 'Software Engineer';
    usernameNotifier.value = 'Sahil';
    stageNotifier.value = 'Highschool';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PortfolioHome(onOpenPlan: () {})),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2'), findsWidgets);
    expect(find.text('tasks left'), findsOneWidget);
  });
}
