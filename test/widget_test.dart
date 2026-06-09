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

    await tester.tap(find.text('Tasks').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.auto_awesome_rounded));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('3 left'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.auto_awesome_rounded));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('6 left'), findsOneWidget);
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

    expect(find.text('1'), findsWidgets);
    expect(find.text('task left'), findsOneWidget);
  });
}
