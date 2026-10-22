import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/pdf_repository.dart';
import 'ui/features/home/view_models/home_view_model.dart';
import 'ui/shared/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase Backend
  try {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      // ignore: deprecated_member_use
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  } catch (e) {
    debugPrint('Supabase initialization notice: $e');
  }

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final pdfRepository = PdfRepository();
  final homeViewModel = HomeViewModel(repository: pdfRepository);

  runApp(DbPdfToolsApp(viewModel: homeViewModel));
}

class DbPdfToolsApp extends StatelessWidget {
  final HomeViewModel viewModel;

  const DbPdfToolsApp({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DB PDF Tools',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: MainScreen(viewModel: viewModel),
    );
  }
}
