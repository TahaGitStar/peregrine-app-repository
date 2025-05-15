import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:peregrine_app_taha/utils/app_theme.dart';
import 'package:peregrine_app_taha/utils/app_localizations.dart';
import 'package:peregrine_app_taha/providers/theme_provider.dart';
import 'package:peregrine_app_taha/providers/localization_provider.dart';
import 'package:peregrine_app_taha/screens/change_password_screen.dart';
import 'package:peregrine_app_taha/screens/profile_edit_screen.dart';
import 'package:peregrine_app_taha/screens/login_screen.dart';
import 'package:peregrine_app_taha/services/biometric_service.dart';
import 'package:peregrine_app_taha/services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  static const String routeName = '/settings';
  
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  
  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }
  
  Future<void> _checkBiometricAvailability() async {
    final isAvailable = await BiometricService.isBiometricAvailable();
    final isEnabled = await BiometricService.isBiometricLoginEnabled();
    
    if (mounted) {
      setState(() {
        _biometricAvailable = isAvailable;
        _biometricEnabled = isEnabled;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final isArabic = localizationProvider.locale.languageCode == 'ar';
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          context.tr('settings'),
          style: GoogleFonts.cairo(
            color: Theme.of(context).appBarTheme.foregroundColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 8,
        shadowColor: Theme.of(context).primaryColor.withCustomValues(alpha: (0.5 * 255).toInt()),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          color: Theme.of(context).appBarTheme.foregroundColor,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Account Section
                _buildSectionHeader(context.tr('account')),
                _buildSettingCard(
                  icon: LucideIcons.user,
                  title: context.tr('profile'),
                  subtitle: context.tr('edit_profile'),
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pushNamed(context, ProfileEditScreen.routeName);
                  },
                ),
                _buildSettingCard(
                  icon: LucideIcons.lock,
                  title: context.tr('change_password'),
                  subtitle: context.tr('change_password'),
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pushNamed(context, ChangePasswordScreen.routeName);
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Preferences Section
                _buildSectionHeader(context.tr('preferences')),
                _buildSwitchSettingCard(
                  icon: LucideIcons.bell,
                  title: context.tr('notifications'),
                  subtitle: context.tr('enable_notifications'),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                if (_biometricAvailable) _buildSwitchSettingCard(
                  icon: LucideIcons.fingerprint,
                  title: context.tr('biometric_login'),
                  subtitle: context.tr('biometric_subtitle'),
                  value: _biometricEnabled,
                  onChanged: (value) async {
                    HapticFeedback.lightImpact();
                    final success = await BiometricService.setBiometricLoginEnabled(value);
                    if (success && mounted) {
                      setState(() {
                        _biometricEnabled = value;
                      });
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value ? context.tr('biometric_enable') : context.tr('biometric_disable'),
                            style: GoogleFonts.cairo(),
                            textAlign: TextAlign.center,
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                        ),
                      );
                      
                      // If enabled, offer to test biometric authentication
                      if (value) {
                        Future.delayed(const Duration(milliseconds: 500), () {
                          _showTestBiometricDialog();
                        });
                      }
                    }
                  },
                ),
                _buildSwitchSettingCard(
                  icon: isDarkMode ? LucideIcons.sun : LucideIcons.moon,
                  title: context.tr('theme'),
                  subtitle: isDarkMode ? context.tr('light_mode') : context.tr('dark_mode'),
                  value: isDarkMode,
                  onChanged: (value) {
                    HapticFeedback.lightImpact();
                    themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                  },
                ),
                _buildLanguageSettingCard(
                  icon: LucideIcons.languages,
                  title: context.tr('language'),
                  subtitle: isArabic ? context.tr('english') : context.tr('arabic'),
                  value: isArabic,
                  onChanged: (value) {
                    HapticFeedback.lightImpact();
                    final newLocale = value ? const Locale('ar') : const Locale('en');
                    localizationProvider.setLocale(newLocale);
                  },
                ),
                
                const SizedBox(height: 20),
                
                // About Section
                _buildSectionHeader(context.tr('about')),
                _buildSettingCard(
                  icon: LucideIcons.info,
                  title: context.tr('about_app'),
                  subtitle: context.tr('version') + ' 1.0.0',
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    _showAboutDialog();
                  },
                ),
                _buildSettingCard(
                  icon: LucideIcons.helpCircle,
                  title: context.tr('help_support'),
                  subtitle: context.tr('help_support'),
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    // Navigate to help screen or show help dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          context.tr('help_support'),
                          style: GoogleFonts.cairo(),
                          textAlign: TextAlign.center,
                        ),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(LucideIcons.logOut, size: 20),
                    label: Text(
                      context.tr('logout'),
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 6,
                    ),
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      _showLogoutConfirmationDialog();
                    },
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }
  
  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shadowColor: Theme.of(context).shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withCustomValues(alpha: (0.1 * 255).toInt()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withCustomValues(alpha: (0.7 * 255).toInt()),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).primaryColor,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSwitchSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shadowColor: Theme.of(context).shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withCustomValues(alpha: (0.1 * 255).toInt()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withCustomValues(alpha: (0.7 * 255).toInt()),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Theme.of(context).primaryColor,
              activeTrackColor: Theme.of(context).primaryColor.withCustomValues(alpha: (0.3 * 255).toInt()),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLanguageSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shadowColor: Theme.of(context).shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withCustomValues(alpha: (0.1 * 255).toInt()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withCustomValues(alpha: (0.7 * 255).toInt()),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Theme.of(context).primaryColor,
              activeTrackColor: Theme.of(context).primaryColor.withCustomValues(alpha: (0.3 * 255).toInt()),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          context.tr('about_app'),
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Image.asset(
              'assets/images/logo1.png',
              height: 80,
              width: 80,
            ),
            const SizedBox(height: 20),
            Text(
              context.tr('app_name'),
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              context.tr('version') + ' 1.0.0',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withCustomValues(alpha: (0.7 * 255).toInt()),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'تطبيق بيريجرين هو منصة متكاملة لإدارة خدمات الأمن والحراسة، يوفر واجهة سهلة الاستخدام للعملاء وأفراد الأمن.',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Theme.of(context).colorScheme.secondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              context.tr('cancel'),
              style: GoogleFonts.cairo(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          context.tr('logout'),
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          context.tr('logout_confirm'),
          style: GoogleFonts.cairo(
            fontSize: 16,
            color: Theme.of(context).colorScheme.secondary,
          ),
          textAlign: TextAlign.center,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              context.tr('cancel'),
              style: GoogleFonts.cairo(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withCustomValues(alpha: (0.7 * 255).toInt()),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Perform logout
              await AuthService.logout();
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  LoginScreen.routeName,
                  (route) => false,
                );
              }
            },
            child: Text(
              context.tr('logout'),
              style: GoogleFonts.cairo(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showTestBiometricDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          context.tr('biometric_test'),
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          context.tr('biometric_test_prompt'),
          style: GoogleFonts.cairo(
            fontSize: 16,
            color: Theme.of(context).colorScheme.secondary,
          ),
          textAlign: TextAlign.center,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              context.tr('biometric_test_later'),
              style: GoogleFonts.cairo(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withCustomValues(alpha: (0.7 * 255).toInt()),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Test biometric authentication
              final authenticated = await BiometricService.authenticate();
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      authenticated 
                          ? context.tr('biometric_test_success')
                          : BiometricService.lastErrorMessage ?? context.tr('biometric_test_failed'),
                      style: GoogleFonts.cairo(),
                      textAlign: TextAlign.center,
                    ),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: authenticated ? Colors.green.shade700 : Colors.red.shade700,
                    duration: const Duration(seconds: 5), // Longer duration to read error message
                  ),
                );
              }
            },
            child: Text(
              context.tr('biometric_test_now'),
              style: GoogleFonts.cairo(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}