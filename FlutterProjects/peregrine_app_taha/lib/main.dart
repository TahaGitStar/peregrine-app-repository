import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:peregrine_app_taha/utils/app_theme.dart';
import 'package:peregrine_app_taha/utils/app_localizations.dart';
import 'package:peregrine_app_taha/providers/theme_provider.dart';
import 'package:peregrine_app_taha/providers/localization_provider.dart';
import 'package:peregrine_app_taha/providers/branch_contract_provider.dart';
import 'package:peregrine_app_taha/providers/user_role_provider.dart';
import 'package:peregrine_app_taha/providers/notification_provider.dart';
import 'package:peregrine_app_taha/screens/client/splash_screen.dart';
import 'package:peregrine_app_taha/screens/login_screen.dart';
import 'package:peregrine_app_taha/screens/register_screen.dart';
import 'package:peregrine_app_taha/screens/client/client_home_screen.dart';
import 'package:peregrine_app_taha/screens/client/submit_complaint_screen.dart';
import 'package:peregrine_app_taha/screens/client/submit_request_screen.dart';
import 'package:peregrine_app_taha/screens/client/tracking_screen.dart';
import 'package:peregrine_app_taha/screens/client/guards_screen.dart';
import 'package:peregrine_app_taha/screens/client/accidents_screen.dart';
import 'package:peregrine_app_taha/screens/client/accident_details_screen.dart';
import 'package:peregrine_app_taha/screens/client/report_accident_screen.dart';
import 'package:peregrine_app_taha/screens/support/support_dashboard_screen.dart';
import 'package:peregrine_app_taha/screens/client/role_selector_screen.dart';
import 'package:peregrine_app_taha/screens/change_password_screen.dart';
import 'package:peregrine_app_taha/screens/support/create_client_account_screen.dart';
import 'package:peregrine_app_taha/screens/profile_edit_screen.dart';
import 'package:peregrine_app_taha/screens/client/settings_screen.dart';
import 'package:peregrine_app_taha/screens/support/support_settings_screen.dart';
import 'package:peregrine_app_taha/screens/support/notifications_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize localization
  await AppLocalizations.load();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocalizationProvider()),
        ChangeNotifierProvider(create: (_) => BranchContractProvider()),
        ChangeNotifierProvider(create: (_) => UserRoleProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const PeregrineApp(),
    ),
  );
}

class PeregrineApp extends StatelessWidget {
  const PeregrineApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    
    return MaterialApp(
      title: 'Peregrine App',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.themeMode,

      // Localization configuration
      locale: localizationProvider.locale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Initial splash and named routes
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_)        => const SplashScreen(),
        LoginScreen.routeName: (_)         => const LoginScreen(),
        RegisterScreen.routeName: (_)      => const RegisterScreen(),
        RoleSelectorScreen.routeName: (_)  => const RoleSelectorScreen(),
        ClientHomeScreen.routeName: (_)    => const ClientHomeScreen(),
        SubmitComplaintScreen.routeName: (_) => const SubmitComplaintScreen(),
        SubmitRequestScreen.routeName: (_)   => const SubmitRequestScreen(),
        GuardsScreen.routeName: (_)          => const GuardsScreen(),
        AccidentsScreen.routeName: (_)       => const AccidentsScreen(),
        ReportAccidentScreen.routeName: (_)  => const ReportAccidentScreen(),
        AccidentDetailsScreen.routeName: (context) => AccidentDetailsScreen(
          accidentId: ModalRoute.of(context)!.settings.arguments as String,
        ),
        TrackingScreen.routeName: (_)        => const TrackingScreen(),
        SupportDashboardScreen.routeName: (_) => const SupportDashboardScreen(),
        ChangePasswordScreen.routeName: (_) => const ChangePasswordScreen(),
        CreateClientAccountScreen.routeName: (_) => const CreateClientAccountScreen(),
        ProfileEditScreen.routeName: (_) => const ProfileEditScreen(),
        SettingsScreen.routeName: (_) => const SettingsScreen(),
        SupportSettingsScreen.routeName: (_) => const SupportSettingsScreen(),
        NotificationsScreen.routeName: (_) => const NotificationsScreen(),
        // Note: SupportRequestDetailsScreen is not registered here because it requires parameters
      },
    );
  }
}