import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:peregrine_app_taha/utils/app_theme.dart';
import 'package:peregrine_app_taha/utils/app_localizations.dart';
import 'package:peregrine_app_taha/providers/theme_provider.dart';
import 'package:peregrine_app_taha/providers/localization_provider.dart';
import 'package:peregrine_app_taha/services/biometric_service.dart';
import 'package:peregrine_app_taha/screens/login_screen.dart';
import 'package:peregrine_app_taha/services/auth_service.dart';

class SupportSettingsScreen extends StatefulWidget {
  static const String routeName = '/support-settings';
  
  const SupportSettingsScreen({super.key});

  @override
  State<SupportSettingsScreen> createState() => _SupportSettingsScreenState();
}

class _SupportSettingsScreenState extends State<SupportSettingsScreen> {
  bool _notificationsEnabled = true;
  double _fontSize = 16.0;
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
          'إعدادات الدعم',
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
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context.tr('notifications')),
            _buildSettingsCard(
              child: SwitchListTile(
                title: Text(
                  context.tr('enable_notifications'),
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                subtitle: Text(
                  'استلام إشعارات عند وصول طلبات دعم جديدة',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withCustomValues(alpha: (0.7 * 255).toInt()),
                  ),
                ),
                value: _notificationsEnabled,
                onChanged: (value) {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                activeColor: Theme.of(context).primaryColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            
            const SizedBox(height: 24),
            _buildSectionTitle(context.tr('theme')),
            _buildSettingsCard(
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      isDarkMode ? context.tr('light_mode') : context.tr('dark_mode'),
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    subtitle: Text(
                      'تغيير مظهر التطبيق',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withCustomValues(alpha: (0.7 * 255).toInt()),
                      ),
                    ),
                    value: isDarkMode,
                    onChanged: (value) {
                      HapticFeedback.lightImpact();
                      themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                    },
                    activeColor: Theme.of(context).primaryColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('font_size'),
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(LucideIcons.type, 
                                size: 18, 
                                color: Theme.of(context).primaryColor),
                            Expanded(
                              child: Slider(
                                value: _fontSize,
                                min: 12.0,
                                max: 20.0,
                                divisions: 4,
                                label: _fontSize.toStringAsFixed(1),
                                onChanged: (value) {
                                  setState(() {
                                    _fontSize = value;
                                  });
                                },
                                activeColor: Theme.of(context).primaryColor,
                              ),
                            ),
                            Icon(LucideIcons.type, 
                                size: 24, 
                                color: Theme.of(context).primaryColor),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            _buildSectionTitle(context.tr('language')),
            _buildSettingsCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اختر لغة التطبيق',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildLanguageOption('العربية', isArabic, () {
                      localizationProvider.setLocale(const Locale('ar'));
                    }),
                    const Divider(),
                    _buildLanguageOption('English', !isArabic, () {
                      localizationProvider.setLocale(const Locale('en'));
                    }),
                  ],
                ),
              ),
            ),
            
            if (_biometricAvailable) ...[
              const SizedBox(height: 24),
              _buildSectionTitle(context.tr('biometric_settings')),
              _buildSettingsCard(
                child: SwitchListTile(
                  title: Text(
                    context.tr('biometric_login'),
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  subtitle: Text(
                    context.tr('biometric_subtitle'),
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withCustomValues(alpha: (0.7 * 255).toInt()),
                    ),
                  ),
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
                  activeColor: Theme.of(context).primaryColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            _buildSectionTitle(context.tr('preferences')),
            _buildSettingsCard(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(LucideIcons.database, color: Theme.of(context).primaryColor),
                    title: Text(
                      context.tr('clear_cache'),
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    subtitle: Text(
                      'حذف البيانات المؤقتة لتحسين الأداء',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withCustomValues(alpha: (0.7 * 255).toInt()),
                      ),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, 
                                  size: 16, 
                                  color: Theme.of(context).primaryColor),
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      _showClearCacheDialog();
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(LucideIcons.refreshCw, color: Theme.of(context).primaryColor),
                    title: Text(
                      context.tr('reset_settings'),
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    subtitle: Text(
                      'استعادة الإعدادات الافتراضية',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withCustomValues(alpha: (0.7 * 255).toInt()),
                      ),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, 
                                  size: 16, 
                                  color: Theme.of(context).primaryColor),
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      _showResetSettingsDialog();
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            _buildSettingsCard(
              child: ListTile(
                leading: Icon(LucideIcons.logOut, color: Colors.red.shade700),
                title: Text(
                  context.tr('logout'),
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
                  ),
                ),
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _showLogoutConfirmationDialog();
                },
              ),
            ),
            
            const SizedBox(height: 40),
            Center(
              child: Text(
                context.tr('version') + ' 1.0.0',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withCustomValues(alpha: (0.7 * 255).toInt()),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required Widget child}) {
    return Card(
      elevation: 4,
      shadowColor: Theme.of(context).primaryColor.withCustomValues(alpha: (0.2 * 255).toInt()),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _buildLanguageOption(String language, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(
              isSelected ? LucideIcons.checkCircle : LucideIcons.circle,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey[400],
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              language,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          context.tr('clear_cache'),
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في مسح ذاكرة التخزين المؤقت؟',
          style: GoogleFonts.cairo(
            color: Theme.of(context).colorScheme.secondary,
          ),
          textAlign: TextAlign.center,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              context.tr('cancel'),
              style: GoogleFonts.cairo(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withCustomValues(alpha: (0.7 * 255).toInt()),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement cache clearing logic here
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم مسح ذاكرة التخزين المؤقت بنجاح',
                    style: GoogleFonts.cairo(),
                    textAlign: TextAlign.center,
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              context.tr('clear_cache'),
              style: GoogleFonts.cairo(),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          context.tr('reset_settings'),
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في إعادة ضبط جميع الإعدادات إلى الوضع الافتراضي؟',
          style: GoogleFonts.cairo(
            color: Theme.of(context).colorScheme.secondary,
          ),
          textAlign: TextAlign.center,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              context.tr('cancel'),
              style: GoogleFonts.cairo(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withCustomValues(alpha: (0.7 * 255).toInt()),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Reset theme
              final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
              await themeProvider.setThemeMode(ThemeMode.light);
              
              // Reset language
              final localizationProvider = Provider.of<LocalizationProvider>(context, listen: false);
              await localizationProvider.setLocale(const Locale('ar'));
              
              // Reset biometric settings
              await BiometricService.setBiometricLoginEnabled(false);
              
              // Reset other settings
              setState(() {
                _notificationsEnabled = true;
                _fontSize = 16.0;
                _biometricEnabled = false;
              });
              
              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم إعادة ضبط الإعدادات بنجاح',
                      style: GoogleFonts.cairo(),
                      textAlign: TextAlign.center,
                    ),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              context.tr('reset_settings'),
              style: GoogleFonts.cairo(),
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