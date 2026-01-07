import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/theme_provider.dart';

class ThemeToggleAction extends StatelessWidget {
  const ThemeToggleAction({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (_, theme, __) {
      final current = theme.themeMode;
      IconData icon;
      switch (current) {
        case ThemeMode.light:
          icon = Icons.light_mode;
          break;
        case ThemeMode.dark:
          icon = Icons.dark_mode;
          break;
        case ThemeMode.system:
        default:
          icon = Icons.brightness_auto;
      }

      return PopupMenuButton<ThemeMode>(
        tooltip: 'Theme',
        icon: Icon(icon),
        onSelected: (mode) => theme.setThemeMode(mode),
        itemBuilder: (_) => const [
          PopupMenuItem(
            value: ThemeMode.system,
            child: _MenuRow(label: 'System'),
          ),
          PopupMenuItem(
            value: ThemeMode.light,
            child: _MenuRow(label: 'Light'),
          ),
          PopupMenuItem(
            value: ThemeMode.dark,
            child: _MenuRow(label: 'Dark'),
          ),
        ],
      );
    });
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false);
    final selected = _isSelected(theme.themeMode, label);
    return Row(
      children: [
        Icon(
          selected ? Icons.check_circle : Icons.circle_outlined,
          color: selected ? Theme.of(context).colorScheme.primary : null,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  bool _isSelected(ThemeMode mode, String label) {
    switch (label) {
      case 'System':
        return mode == ThemeMode.system;
      case 'Light':
        return mode == ThemeMode.light;
      case 'Dark':
        return mode == ThemeMode.dark;
      default:
        return false;
    }
  }
}
