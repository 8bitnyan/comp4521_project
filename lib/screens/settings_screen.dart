import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    _loadUserSettings();
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
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: settingsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
              ? const Center(
                  child: Text('You must be logged in to view settings.'))
              : settingsProvider.settings == null
                  ? const Center(child: Text('No settings found.'))
                  : ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        _buildSectionHeader('Appearance'),
                        _buildSettingItem(
                          icon: Icons.dark_mode,
                          title: 'Dark Mode',
                          subtitle: 'Toggle between light and dark theme',
                          trailing: Switch(
                            value: settingsProvider.settings!.darkMode,
                            onChanged: (value) async {
                              final newSettings = settingsProvider.settings!
                                  .copyWith(darkMode: value);
                              await settingsProvider.updateSettings(
                                  user.id, newSettings);
                            },
                          ),
                        ),
                        const Divider(),
                        _buildSectionHeader('Notifications'),
                        _buildSettingItem(
                          icon: Icons.notifications,
                          title: 'Push Notifications',
                          subtitle:
                              'Receive notifications about campus events and updates',
                          trailing: Switch(
                            value:
                                settingsProvider.settings!.notificationsEnabled,
                            onChanged: (value) async {
                              final newSettings = settingsProvider.settings!
                                  .copyWith(notificationsEnabled: value);
                              await settingsProvider.updateSettings(
                                  user.id, newSettings);
                            },
                          ),
                        ),
                        const Divider(),
                        _buildSectionHeader('About'),
                        _buildSettingItem(
                          icon: Icons.info,
                          title: 'App Version',
                          subtitle: '1.0.0',
                        ),
                        _buildSettingItem(
                          icon: Icons.description,
                          title: 'Terms of Service',
                          onTap: () {
                            _showInfoDialog('Terms of Service',
                                'Terms and conditions for using the School Guide app.');
                          },
                        ),
                        _buildSettingItem(
                          icon: Icons.privacy_tip,
                          title: 'Privacy Policy',
                          onTap: () {
                            _showInfoDialog('Privacy Policy',
                                'Information about how we collect and use your data.');
                          },
                        ),
                        if (settingsProvider.error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text(
                              settingsProvider.error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
