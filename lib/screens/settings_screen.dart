import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  bool _isGeneratingMockData = false;

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Appearance'),
            _buildThemeSelector(themeProvider),
            const Divider(),

            _buildSectionHeader('Text Settings'),
            _buildFontSizeSelector(settingsProvider),
            const Divider(),

            _buildSectionHeader('Language'),
            _buildLanguageSelector(settingsProvider),
            const Divider(),

            _buildSectionHeader('Notifications'),
            _buildNotificationSettings(settingsProvider),
            const Divider(),

            _buildSectionHeader('Map Settings'),
            _buildMapSettings(settingsProvider),
            const Divider(),

            _buildSectionHeader('Privacy'),
            _buildPrivacySettings(settingsProvider),
            const Divider(),

            _buildSectionHeader('Accessibility'),
            _buildAccessibilitySettings(),
            const Divider(),

            _buildSectionHeader('About'),
            _buildAboutSection(),
            const SizedBox(height: 16),

            _buildSectionHeader('Developer'),
            _buildDeveloperSection(),

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

  Widget _buildThemeSelector(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: const Text('Dark Theme'),
          subtitle: const Text('Enable dark mode for the app'),
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
          title: const Text('System Theme'),
          subtitle: const Text('Follow system theme settings'),
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
          title: const Text('Light Theme'),
          subtitle: const Text('Use light mode for the app'),
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

  Widget _buildFontSizeSelector(SettingsProvider settingsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: const Text('Font Size'),
          subtitle: Text(
              'Current size: ${_getFontSizeText(settingsProvider.fontSize)}'),
        ),
        Slider(
          value: settingsProvider.fontSize,
          min: 0.8,
          max: 1.4,
          divisions: 6,
          label: _getFontSizeText(settingsProvider.fontSize),
          onChanged: (value) {
            settingsProvider.setFontSize(value);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Small', style: TextStyle(fontSize: 12)),
              Text('Medium', style: TextStyle(fontSize: 14)),
              Text('Large', style: TextStyle(fontSize: 16)),
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
              'Sample Text',
              style: TextStyle(
                fontSize: 16 * settingsProvider.fontSize,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getFontSizeText(double size) {
    if (size <= 0.9) return 'Small';
    if (size <= 1.1) return 'Medium';
    return 'Large';
  }

  Widget _buildLanguageSelector(SettingsProvider settingsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: const Text('App Language'),
          subtitle:
              Text('Current: ${_getLanguageName(settingsProvider.language)}'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _showLanguageDialog(settingsProvider);
          },
        ),
      ],
    );
  }

  void _showLanguageDialog(SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text('English'),
                  value: 'en',
                  groupValue: settingsProvider.language,
                  onChanged: (value) {
                    settingsProvider.setLanguage(value!);
                    Navigator.of(context).pop();
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Chinese (Traditional)'),
                  value: 'zh_HK',
                  groupValue: settingsProvider.language,
                  onChanged: (value) {
                    settingsProvider.setLanguage(value!);
                    Navigator.of(context).pop();
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Chinese (Simplified)'),
                  value: 'zh_CN',
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
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'zh_HK':
        return 'Chinese (Traditional)';
      case 'zh_CN':
        return 'Chinese (Simplified)';
      default:
        return 'English';
    }
  }

  Widget _buildNotificationSettings(SettingsProvider settingsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('Event Notifications'),
          subtitle: const Text('Receive notifications about campus events'),
          value: settingsProvider.notifyEvents,
          onChanged: (value) {
            settingsProvider.setNotifyEvents(value);
          },
        ),
        SwitchListTile(
          title: const Text('Food Menu Updates'),
          subtitle: const Text('Get notified when food menus are updated'),
          value: settingsProvider.notifyFoodMenus,
          onChanged: (value) {
            settingsProvider.setNotifyFoodMenus(value);
          },
        ),
        SwitchListTile(
          title: const Text('Facility Updates'),
          subtitle: const Text('Receive notifications about facility changes'),
          value: settingsProvider.notifyFacilities,
          onChanged: (value) {
            settingsProvider.setNotifyFacilities(value);
          },
        ),
      ],
    );
  }

  Widget _buildMapSettings(SettingsProvider settingsProvider) {
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

  Widget _buildPrivacySettings(SettingsProvider settingsProvider) {
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

  Widget _buildAccessibilitySettings() {
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

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: const Text('App Version'),
          subtitle: const Text('1.0.0'),
        ),
        ListTile(
          title: const Text('Developed By'),
          subtitle: const Text('COMP4521 Project Team'),
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

  Widget _buildDeveloperSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text('Clear Cache'),
          leading: Icon(Icons.cleaning_services),
          onTap: () {
            // Implement clearing cache
          },
        ),
        ListTile(
          title: Text('Generate Mock Data'),
          leading: Icon(Icons.data_array),
          onTap: () async {
            bool confirm = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Generate Mock Data'),
                    content: Text(
                        'This will add sample data to your database. Continue?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('Generate'),
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
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
