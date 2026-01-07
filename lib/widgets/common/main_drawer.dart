import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../screens/category_screen.dart';
import '../../screens/profile_screen.dart';
import '../../screens/transactions_screen.dart';


class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = context.watch<ThemeProvider>();
    final user = auth.user;

    final avatarHue = user?.avatarHue ?? 210;
    final avatarColor = HSVColor.fromAHSV(1, avatarHue, 0.55, 0.9).toColor();
    final initials = (user?.displayName.isNotEmpty == true
            ? user!.displayName[0]
            : (user?.email.isNotEmpty == true ? user!.email[0] : '?'))
        .toUpperCase();

    String routeName(BuildContext context) => ModalRoute.of(context)?.settings.name ?? '';

    void goTo(String target) {
      Navigator.of(context).pop();
      if (routeName(context) == target) return;
      Navigator.of(context).pushReplacementNamed(target);
    }

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.grey.shade900),
              currentAccountPicture: CircleAvatar(
                backgroundColor: avatarColor,
                child: Text(
                  initials,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
              ),
              accountName: Text(user?.displayName.isNotEmpty == true ? user!.displayName : 'Guest'),
              accountEmail: Text(user?.email ?? 'Not signed in'),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              onTap: () => goTo(ProfileScreen.name),
            ),
            ListTile(
              leading: const Icon(Icons.category_outlined),
              title: const Text('Categories'),
              onTap: () => goTo(CategoryScreen.name),
            ),
            ListTile(
              leading: const Icon(Icons.assessment_outlined),
              title: const Text('Reports'),
              onTap: () => goTo(TransactionsScreen.name),
            ),
            SwitchListTile(
              secondary: Icon(
                theme.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
              ),
              title: const Text('Dark mode'),
              value: theme.themeMode == ThemeMode.dark,
              onChanged: (isDark) {
                theme.setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.of(context).pop();
                await auth.signOut();
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
