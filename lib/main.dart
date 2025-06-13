import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'routes/app_router.dart';
import 'providers/session_provider.dart';
import 'providers/story_provider.dart';
import 'providers/story_detail_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/notification_provider.dart';
import 'services/notification_service.dart';
import 'services/background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  await BackgroundService.initialize();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    NotificationService.init();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => StoryProvider()),
        ChangeNotifierProvider(create: (_) => StoryDetailProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder:
            (context, localeProvider, child) => MaterialApp.router(
              debugShowCheckedModeBanner: false,
              routerConfig: AppRouter.router,
              locale: localeProvider.locale,
              supportedLocales: const [Locale('en'), Locale('id')],
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              title: 'Dicoding Story App',
              theme: ThemeData(
                primarySwatch: Colors.blue,
                useMaterial3: true,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
      ),
    );
  }
}
