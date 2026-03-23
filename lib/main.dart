import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hear_and_see_safe/providers/app_state_provider.dart';
import 'package:hear_and_see_safe/providers/accessibility_provider.dart';
import 'package:hear_and_see_safe/services/voice_assistant_service.dart';
import 'package:hear_and_see_safe/services/speech_command_service.dart';
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
      saveLocale: true,
      useFallbackTranslations: true,
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
        Provider(create: (_) => SpeechCommandService()),
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
      child: Consumer<AccessibilityProvider>(
        builder: (context, accessibility, _) {
          final isHighContrast = accessibility.highContrastMode;
          final scaffoldBg = isHighContrast ? const Color(0xFF000000) : const Color(0xFFF5F5F5);
          final textColor = isHighContrast ? const Color(0xFFFFFFFF) : const Color(0xFF212121);
          final bodyColor = isHighContrast ? const Color(0xFFFFFFFF) : const Color(0xFF424242);
          final primaryBg = isHighContrast ? const Color(0xFF1A1A1A) : const Color(0xFF2196F3);
          final primaryFg = isHighContrast ? const Color(0xFFFFFFFF) : Colors.white;

          return MaterialApp(
            title: 'Hear & See Safe',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              primaryColor: primaryBg,
              scaffoldBackgroundColor: scaffoldBg,
              appBarTheme: AppBarTheme(
                backgroundColor: primaryBg,
                foregroundColor: primaryFg,
                iconTheme: IconThemeData(color: primaryFg),
                titleTextStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryFg,
                ),
              ),
              fontFamily: 'Roboto',
              textTheme: TextTheme(
                displayLarge: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                displayMedium: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                displaySmall: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                headlineMedium: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                bodyLarge: TextStyle(
                  fontSize: 18,
                  color: bodyColor,
                ),
                bodyMedium: TextStyle(
                  fontSize: 16,
                  color: bodyColor,
                ),
              ),
              sliderTheme: SliderThemeData(
                activeTrackColor: isHighContrast ? const Color(0xFFFFFFFF) : const Color(0xFF2196F3),
                inactiveTrackColor: isHighContrast ? const Color(0xFF666666) : const Color(0xFFBDBDBD),
                thumbColor: isHighContrast ? const Color(0xFFFFFF00) : const Color(0xFF2196F3),
                overlayColor: (isHighContrast ? const Color(0xFFFFFF00) : const Color(0xFF2196F3)).withValues(alpha: 0.3),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBg,
                  foregroundColor: primaryFg,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: isHighContrast
                      ? RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Color(0xFFFFFFFF), width: 2),
                        )
                      : RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                  elevation: isHighContrast ? 0 : 4,
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
          );
        },
      ),
    );
  }
}

