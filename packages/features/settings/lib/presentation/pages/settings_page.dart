import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:settings/settings.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSection(
            context,
            title: 'Appearance',
            children: [
              _buildThemeSelector(context, ref, settings),
              _buildLanguageSelector(context, ref, settings),
            ],
          ),
          _buildSection(
            context,
            title: 'Notifications',
            children: [
              _buildSwitchTile(
                context,
                title: 'Enable Notifications',
                subtitle: 'Receive push notifications',
                value: settings.notificationsEnabled,
                onChanged: (value) {
                  ref.read(appSettingsProvider.notifier).toggleNotifications();
                },
              ),
              _buildSwitchTile(
                context,
                title: 'Sound',
                subtitle: 'Play sound for notifications',
                value: settings.soundEnabled,
                onChanged: (value) {
                  ref.read(appSettingsProvider.notifier).toggleSound();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, WidgetRef ref, AppSettings settings) {
    return ListTile(
      title: const Text('Theme'),
      subtitle: Text(settings.theme.name.toUpperCase()),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showThemeDialog(context, ref, settings.theme),
    );
  }

  Widget _buildLanguageSelector(BuildContext context, WidgetRef ref, AppSettings settings) {
    return ListTile(
      title: const Text('Language'),
      subtitle: Text(settings.language.name.toUpperCase()),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showLanguageDialog(context, ref, settings.language),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref, AppTheme currentTheme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppTheme.values.map((theme) {
            return RadioListTile<AppTheme>(
              title: Text(theme.name.toUpperCase()),
              value: theme,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  ref.read(appSettingsProvider.notifier).updateTheme(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref, AppLanguage currentLanguage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppLanguage.values.map((language) {
            return RadioListTile<AppLanguage>(
              title: Text(language.name.toUpperCase()),
              value: language,
              groupValue: currentLanguage,
              onChanged: (value) {
                if (value != null) {
                  ref.read(appSettingsProvider.notifier).updateLanguage(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
