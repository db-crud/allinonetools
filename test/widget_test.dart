import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:db_pdf_tools/data/repositories/pdf_repository.dart';
import 'package:db_pdf_tools/main.dart';
import 'package:db_pdf_tools/ui/features/home/view_models/home_view_model.dart';

void main() {
  testWidgets('DB PDF Tools app renders home dashboard with all sections', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = PdfRepository();
    final viewModel = HomeViewModel(repository: repository);

    await tester.pumpWidget(DbPdfToolsApp(viewModel: viewModel));
    await tester.pumpAndSettle();

    // Verify Title & Hero
    expect(find.text('DB PDF Tools'), findsOneWidget);
    expect(find.text('All your documents, one place'), findsOneWidget);

    // Verify Quick Actions
    expect(find.text('Quick Actions'), findsOneWidget);
    expect(find.text('Fast OCR'), findsOneWidget);
    expect(find.text('Image to PDF'), findsWidgets);
    expect(find.text('Merge PDF'), findsWidgets);
    expect(find.text('Compress PDF'), findsWidgets);

    // Verify All Tools Grid
    expect(find.text('All Tools'), findsOneWidget);
    expect(find.text('12 Tools'), findsOneWidget);
    expect(find.text('PDF Reader'), findsOneWidget);
    expect(find.text('PDF to Image'), findsOneWidget);

    // Scroll to reveal Recent Documents
    await tester.scrollUntilVisible(
      find.text('Recent Documents'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Recent Documents'), findsOneWidget);
    expect(find.text('Quarterly_Financial_Report_2025.pdf'), findsOneWidget);

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
    expect(find.text('My Files'), findsOneWidget);

    // Switch to Tools tab
    await tester.tap(find.text('Tools'));
    await tester.pumpAndSettle();
    expect(find.text('PDF Toolbox'), findsOneWidget);

    // Switch to Settings tab
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsWidgets);
  });
}
