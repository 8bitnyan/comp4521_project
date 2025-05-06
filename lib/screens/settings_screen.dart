import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import '../mock/mock_data.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final bool _isGeneratingMockData = false;

  @override
  void initState() {
    super.initState();
    // Delay the loading of settings until after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserSettings();
    });
  }

  Future<void> _loadUserSettings() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    if (authProvider.user != null) {
      await settingsProvider.loadSettings(authProvider.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settings_title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(loc.appearance),
            _buildThemeSelector(themeProvider, loc),
            const Divider(),

            _buildSectionHeader(loc.text_settings),
            _buildFontSizeSelector(settingsProvider, loc),
            const Divider(),

            _buildSectionHeader(loc.language),
            _buildLanguageSelector(settingsProvider, loc),
            const Divider(),

            _buildSectionHeader(loc.notifications),
            _buildNotificationSettings(settingsProvider, loc),
            const Divider(),

            _buildSectionHeader(loc.map_settings),
            _buildMapSettings(settingsProvider, loc),
            const Divider(),

            _buildSectionHeader(loc.privacy),
            _buildPrivacySettings(settingsProvider, loc),
            const Divider(),

            _buildSectionHeader(loc.accessibility),
            _buildAccessibilitySettings(loc),
            const Divider(),

            _buildSectionHeader(loc.about),
            _buildAboutSection(loc),
            const SizedBox(height: 16),

            _buildSectionHeader(loc.developer),
            _buildDeveloperSection(loc),

            // Reset all settings button
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Reset All Settings'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Reset Settings'),
                      content: const Text(
                          'Are you sure you want to reset all settings to default?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            settingsProvider.resetToDefaults();
                            themeProvider.setThemeMode(ThemeMode.system);
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Settings have been reset')),
                            );
                          },
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildThemeSelector(
      ThemeProvider themeProvider, AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(loc.dark_theme),
          subtitle: Text(loc.dark_theme_desc),
          trailing: Radio<ThemeMode>(
            value: ThemeMode.dark,
            groupValue: themeProvider.themeMode,
            onChanged: (ThemeMode? value) {
              if (value != null) {
                themeProvider.setThemeMode(value);
              }
            },
          ),
        ),
        ListTile(
          title: Text(loc.system_theme),
          subtitle: Text(loc.system_theme_desc),
          trailing: Radio<ThemeMode>(
            value: ThemeMode.system,
            groupValue: themeProvider.themeMode,
            onChanged: (ThemeMode? value) {
              if (value != null) {
                themeProvider.setThemeMode(value);
              }
            },
          ),
        ),
        ListTile(
          title: Text(loc.light_theme),
          subtitle: Text(loc.light_theme_desc),
          trailing: Radio<ThemeMode>(
            value: ThemeMode.light,
            groupValue: themeProvider.themeMode,
            onChanged: (ThemeMode? value) {
              if (value != null) {
                themeProvider.setThemeMode(value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFontSizeSelector(
      SettingsProvider settingsProvider, AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(loc.font_size),
          subtitle: Text(loc
              .current_size(_getFontSizeText(settingsProvider.fontSize, loc))),
        ),
        Slider(
          value: settingsProvider.fontSize,
          min: 0.8,
          max: 1.4,
          divisions: 6,
          label: _getFontSizeText(settingsProvider.fontSize, loc),
          onChanged: (value) {
            settingsProvider.setFontSize(value);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(loc.small, style: const TextStyle(fontSize: 12)),
              Text(loc.medium, style: const TextStyle(fontSize: 14)),
              Text(loc.large, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              loc.sample_text,
              style: TextStyle(
                fontSize: 16 * settingsProvider.fontSize,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getFontSizeText(double size, AppLocalizations loc) {
    if (size <= 0.9) return loc.small;
    if (size <= 1.1) return loc.medium;
    return loc.large;
  }

  Widget _buildLanguageSelector(
      SettingsProvider settingsProvider, AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(loc.app_language),
          subtitle: Text(loc.current_language(
              _getLanguageName(settingsProvider.language, loc))),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _showLanguageDialog(settingsProvider, loc);
          },
        ),
      ],
    );
  }

  void _showLanguageDialog(
      SettingsProvider settingsProvider, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(loc.select_language),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: Text(loc.english),
                  value: 'en',
                  groupValue: settingsProvider.language,
                  onChanged: (value) {
                    settingsProvider.setLanguage(value!);
                    Navigator.of(context).pop();
                  },
                ),
                RadioListTile<String>(
                  title: Text(loc.korean),
                  value: 'ko',
                  groupValue: settingsProvider.language,
                  onChanged: (value) {
                    settingsProvider.setLanguage(value!);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(loc.cancel),
            ),
          ],
        );
      },
    );
  }

  String _getLanguageName(String languageCode, AppLocalizations loc) {
    switch (languageCode) {
      case 'en':
        return loc.english;
      case 'ko':
        return loc.korean;
      default:
        return loc.english;
    }
  }

  Widget _buildNotificationSettings(
      SettingsProvider settingsProvider, AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: Text(loc.event_notifications),
          subtitle: Text(loc.event_notifications_desc),
          value: settingsProvider.notifyEvents,
          onChanged: (value) {
            settingsProvider.setNotifyEvents(value);
          },
        ),
        SwitchListTile(
          title: Text(loc.food_menu_updates),
          subtitle: Text(loc.food_menu_updates_desc),
          value: settingsProvider.notifyFoodMenus,
          onChanged: (value) {
            settingsProvider.setNotifyFoodMenus(value);
          },
        ),
        SwitchListTile(
          title: Text(loc.facility_updates),
          subtitle: Text(loc.facility_updates_desc),
          value: settingsProvider.notifyFacilities,
          onChanged: (value) {
            settingsProvider.setNotifyFacilities(value);
          },
        ),
      ],
    );
  }

  Widget _buildMapSettings(
      SettingsProvider settingsProvider, AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('Show Current Location'),
          subtitle: const Text('Display your current location on campus maps'),
          value: settingsProvider.showLocation,
          onChanged: (value) {
            settingsProvider.setShowLocation(value);
          },
        ),
        ListTile(
          title: const Text('Default Map Type'),
          subtitle: Text(
              'Current: ${_getMapTypeName(settingsProvider.defaultMapType)}'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _showMapTypeDialog(settingsProvider);
          },
        ),
      ],
    );
  }

  void _showMapTypeDialog(SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Map Type'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<int>(
                  title: const Text('Normal'),
                  value: 1,
                  groupValue: settingsProvider.defaultMapType,
                  onChanged: (value) {
                    settingsProvider.setDefaultMapType(value!);
                    Navigator.of(context).pop();
                  },
                ),
                RadioListTile<int>(
                  title: const Text('Satellite'),
                  value: 2,
                  groupValue: settingsProvider.defaultMapType,
                  onChanged: (value) {
                    settingsProvider.setDefaultMapType(value!);
                    Navigator.of(context).pop();
                  },
                ),
                RadioListTile<int>(
                  title: const Text('Hybrid'),
                  value: 3,
                  groupValue: settingsProvider.defaultMapType,
                  onChanged: (value) {
                    settingsProvider.setDefaultMapType(value!);
                    Navigator.of(context).pop();
                  },
                ),
                RadioListTile<int>(
                  title: const Text('Terrain'),
                  value: 4,
                  groupValue: settingsProvider.defaultMapType,
                  onChanged: (value) {
                    settingsProvider.setDefaultMapType(value!);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  String _getMapTypeName(int mapType) {
    switch (mapType) {
      case 1:
        return 'Normal';
      case 2:
        return 'Satellite';
      case 3:
        return 'Hybrid';
      case 4:
        return 'Terrain';
      default:
        return 'Normal';
    }
  }

  Widget _buildPrivacySettings(
      SettingsProvider settingsProvider, AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('Share Usage Data'),
          subtitle: const Text(
              'Help improve the app by sharing anonymous usage data'),
          value: settingsProvider.shareUsageData,
          onChanged: (value) {
            settingsProvider.setShareUsageData(value);
          },
        ),
        ListTile(
          title: const Text('Privacy Policy'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // Show privacy policy
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Privacy Policy would open here')),
            );
          },
        ),
        ListTile(
          title: const Text('Terms of Service'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // Show terms of service
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Terms of Service would open here')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAccessibilitySettings(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: const Text('Voice Commands'),
          subtitle: const Text('Configure voice command settings and options'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.pushNamed(context, '/accessibility');
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ListTile(
          title: Text('App Version'),
          subtitle: Text('1.0.0'),
        ),
        const ListTile(
          title: Text('Developed By'),
          subtitle: Text('COMP4521 Project Team'),
        ),
        ListTile(
          title: const Text('Send Feedback'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // Send feedback
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Feedback form would open here')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDeveloperSection(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: const Text('Clear Cache'),
          leading: const Icon(Icons.cleaning_services),
          onTap: () {
            // Implement clearing cache
          },
        ),
        ListTile(
          title: const Text('Generate Mock Data'),
          leading: const Icon(Icons.data_array),
          onTap: () async {
            bool confirm = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Generate Mock Data'),
                    content: const Text(
                        'This will add sample data to your database. Continue?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Generate'),
                      ),
                    ],
                  ),
                ) ??
                false;

            if (confirm) {
              try {
                final mockGenerator = MockDataGenerator();
                final accessCheck = await mockGenerator.checkDatabaseAccess();
                bool hasAccess =
                    accessCheck.values.every((canAccess) => canAccess);

                if (!hasAccess) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content:
                          Text('No database access. Check your connection.')));
                  return;
                }

                final results = await mockGenerator.insertAllMockData();
                final success = results.values.every((result) => result);

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(success
                        ? 'Mock data generated successfully!'
                        : 'Failed to generate some mock data')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                        Text('Failed to generate mock data: ${e.toString()}')));
              }
            }
          },
        ),
      ],
    );
  }
}
