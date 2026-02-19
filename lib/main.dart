import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hear_and_see_safe/providers/app_state_provider.dart';
import 'package:hear_and_see_safe/providers/accessibility_provider.dart';
import 'package:hear_and_see_safe/services/voice_assistant_service.dart';
import 'package:hear_and_see_safe/utils/accessibility_utils.dart';
import 'package:hear_and_see_safe/screens/language_selection_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize localization
  await EasyLocalization.ensureInitialized();
  
  // Set preferred orientations (mobile only)
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('mk', 'MK'),
        Locale('sq', 'AL'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      child: const HearAndSeeSafeApp(),
    ),
  );
}

class HearAndSeeSafeApp extends StatelessWidget {
  const HearAndSeeSafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => VoiceAssistantService()),
        ChangeNotifierProxyProvider<VoiceAssistantService, AppStateProvider>(
          create: (_) => AppStateProvider(),
          update: (context, voiceAssistant, previous) {
            final appState = previous ?? AppStateProvider();
            appState.setVoiceAssistant(voiceAssistant);
            return appState;
          },
        ),
        ChangeNotifierProvider(create: (_) => AccessibilityProvider()),
      ],
      child: MaterialApp(
        title: 'Hear & See Safe',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF2196F3),
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          fontFamily: 'Roboto',
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
            displayMedium: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
            displaySmall: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
            headlineMedium: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
            bodyLarge: TextStyle(
              fontSize: 18,
              color: Color(0xFF424242),
            ),
            bodyMedium: TextStyle(
              fontSize: 16,
              color: Color(0xFF424242),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              minimumSize: const Size(200, 60),
            ),
          ),
        ),
        home: const LanguageSelectionScreen(),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(
                AccessibilityUtils.getTextScale(context),
              ),
            ),
            child: child!,
          );
        },
      ),
    );
  }
}

