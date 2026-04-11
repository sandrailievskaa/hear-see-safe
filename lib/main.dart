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
import 'package:hear_and_see_safe/voice_system/application/language_manager.dart';
import 'package:hear_and_see_safe/voice_system/application/voice_command_orchestrator.dart';
import 'package:hear_and_see_safe/voice_system/voice_system_config.dart';
import 'package:hear_and_see_safe/voice_system/voice_system_factory.dart';
import 'package:google_fonts/google_fonts.dart';


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
      fallbackLocale: const Locale('mk', 'MK'),
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
        ChangeNotifierProvider(create: (_) => LanguageManager()),
        Provider<VoiceCommandOrchestrator>(
          create: (context) => VoiceSystemFactory.createOrchestrator(
            config: VoiceSystemConfig.fromEnvironment(),
            languageManager: context.read<LanguageManager>(),
            voiceAssistant: context.read<VoiceAssistantService>(),
          ),
          dispose: (_, o) => o.dispose(),
        ),
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
          final scaffoldBg = isHighContrast ? const Color(0xFF000000) : const Color(0xFFF1F5F9);
          final textColor = isHighContrast ? const Color(0xFFFFFFFF) : const Color(0xFF0F172A);
          final bodyColor = isHighContrast ? const Color(0xFFFFFFFF) : const Color(0xFF475569);
          final primaryBg = isHighContrast ? const Color(0xFF1A1A1A) : const Color(0xFF0F766E);
          final primaryFg = isHighContrast ? const Color(0xFFFFFFFF) : Colors.white;
          final baseTextTheme = TextTheme(
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
          );
          final lexendTheme = GoogleFonts.lexendTextTheme(baseTextTheme);

          return MaterialApp(
            title: 'Hear & See Safe',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF0D9488),
                brightness: isHighContrast ? Brightness.dark : Brightness.light,
                primary: primaryBg,
                surface: scaffoldBg,
              ),
              primaryColor: primaryBg,
              scaffoldBackgroundColor: scaffoldBg,
              appBarTheme: AppBarTheme(
                backgroundColor: primaryBg,
                foregroundColor: primaryFg,
                iconTheme: IconThemeData(color: primaryFg),
                titleTextStyle: GoogleFonts.lexend(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: primaryFg,
                ),
                elevation: isHighContrast ? 0 : 0,
              ),
              textTheme: lexendTheme,
              sliderTheme: SliderThemeData(
                activeTrackColor: isHighContrast ? const Color(0xFFFFFFFF) : const Color(0xFF0D9488),
                inactiveTrackColor: isHighContrast ? const Color(0xFF666666) : const Color(0xFFCBD5E1),
                thumbColor: isHighContrast ? const Color(0xFFFFFF00) : const Color(0xFF0F766E),
                overlayColor: (isHighContrast ? const Color(0xFFFFFF00) : const Color(0xFF0D9488)).withValues(alpha: 0.3),
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
                  elevation: isHighContrast ? 0 : 2,
                  minimumSize: const Size(200, 56),
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

