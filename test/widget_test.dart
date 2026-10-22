import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:db_pdf_tools/data/repositories/pdf_repository.dart';
import 'package:db_pdf_tools/main.dart';
import 'package:db_pdf_tools/ui/features/home/view_models/home_view_model.dart';

void main() {
  testWidgets('DB PDF Tools app renders home dashboard with all sections without login buttons', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = PdfRepository();
    final viewModel = HomeViewModel(repository: repository);

    await tester.pumpWidget(DbPdfToolsApp(viewModel: viewModel));
    await tester.pumpAndSettle();

    // Verify Title & Hero
    expect(find.text('DB PDF Tools'), findsWidgets);
    expect(find.text('All your documents, one place'), findsOneWidget);

    // Verify Login and Sign Up buttons are NOT shown in header
    expect(find.text('Login'), findsNothing);
    expect(find.text('Sign Up'), findsNothing);

    // Verify Quick Actions
    expect(find.text('Quick Actions'), findsOneWidget);
    expect(find.text('Fast OCR'), findsOneWidget);
    expect(find.text('Image to PDF'), findsWidgets);
    expect(find.text('Merge PDF'), findsWidgets);
    expect(find.text('Compress PDF'), findsWidgets);

    // Verify All Tools Grid (3-column grid)
    expect(find.text('All Tools'), findsOneWidget);
    expect(find.text('${PdfRepository.allTools.length} Tools'), findsOneWidget);
    expect(find.text('PDF Reader'), findsOneWidget);
    expect(find.text('PDF to Image'), findsOneWidget);
    expect(find.text('PDF to Word'), findsOneWidget);
    expect(find.text('PDF to Excel'), findsOneWidget);

    // Scroll to reveal Recent Files
    await tester.scrollUntilVisible(
      find.text('Recent Files'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Recent Files'), findsOneWidget);
    expect(find.text('Quarterly_Financial_Report_Compressed.pdf'), findsOneWidget);

    // Verify FAB
    expect(find.text('Scan Doc'), findsWidgets);

    // Verify Bottom Navigation items
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Files'), findsOneWidget);
    expect(find.text('Tools'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('Bottom navigation tab switching test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = PdfRepository();
    final viewModel = HomeViewModel(repository: repository);

    await tester.pumpWidget(DbPdfToolsApp(viewModel: viewModel));
    await tester.pumpAndSettle();

    // Switch to Files tab
    await tester.tap(find.text('Files'));
    await tester.pumpAndSettle();
    expect(find.text('Recent Files'), findsWidgets);

    // Switch to Tools tab
    await tester.tap(find.text('Tools'));
    await tester.pumpAndSettle();
    expect(find.text('PDF Toolbox'), findsOneWidget);

    // Switch to Settings tab
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Supabase Cloud Authentication Ready'), findsOneWidget);
  });

  testWidgets('Clicking a tool opens tool action sheet directly without requiring sign in', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = PdfRepository();
    final viewModel = HomeViewModel(repository: repository);

    await tester.pumpWidget(DbPdfToolsApp(viewModel: viewModel));
    await tester.pumpAndSettle();

    // Tap on 'Merge PDF' tool card
    await tester.tap(find.text('Merge PDF').first);
    await tester.pumpAndSettle();

    // Verify that NO sign in dialog is shown
    expect(find.text('Sign In Required'), findsNothing);

    // Verify tool action bottom sheet is displayed directly
    expect(find.text('Convert'), findsOneWidget);
    expect(find.text('Select Files from Device'), findsOneWidget);

    // Dismiss sheet
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Convert'), findsNothing);
  });

  testWidgets('Clicking Scan Doc opens scanner modal directly without sign in guard', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = PdfRepository();
    final viewModel = HomeViewModel(repository: repository);

    await tester.pumpWidget(DbPdfToolsApp(viewModel: viewModel));
    await tester.pumpAndSettle();

    // Tap on FAB 'Scan Doc'
    await tester.tap(find.text('Scan Doc').first);
    await tester.pumpAndSettle();

    // Verify that NO sign in prompt is shown
    expect(find.text('Sign In Required'), findsNothing);

    // Verify scanner modal appears directly
    expect(find.text('Document Scanner'), findsOneWidget);
  });
}
