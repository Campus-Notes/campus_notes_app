import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campus_notes_app/data/dummy_data.dart';
import 'package:campus_notes_app/services/theme_service.dart';
import 'package:campus_notes_app/routes/route_names.dart';
import 'package:campus_notes_app/routes/routes.dart';
import 'package:campus_notes_app/theme/app_theme.dart';
import 'features/notes/presentation/pages/note_detail_page.dart';
import 'features/payment/presentation/pages/checkout_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final themeService = ThemeService();
  await themeService.init();
  
  runApp(CampusNotesApp(themeService: themeService));
}

class CampusNotesApp extends StatelessWidget {
  final ThemeService themeService;
  
  const CampusNotesApp({super.key, required this.themeService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: themeService,
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'Campus Notes+',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: themeService.themeMode,
            initialRoute: AppRoutes.splash,
            routes: AppRouter.routes,
            onGenerateRoute: (settings) {
              if (settings.name == AppRoutes.noteDetail) {
                final note = settings.arguments as NoteItem;
                return MaterialPageRoute(builder: (_) => NoteDetailPage(note: note));
              }
              if (settings.name == AppRoutes.checkout) {
                final note = settings.arguments as NoteItem;
                return MaterialPageRoute(builder: (_) => CheckoutPage(note: note));
              }
              return null;
            },
          );
        },
      ),
    );
  }
}