import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/database_provider.dart';
import '../widgets/common/main_drawer.dart';
import '../screens/expense_screen.dart';

class WebLandingScreen extends StatelessWidget {
  const WebLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: color.surface,
      drawer: const MainDrawer(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroSection(isWide: isWide),
                  const SizedBox(height: 32),
                  _StatsSection(),
                  const SizedBox(height: 32),
                  _FeaturesSection(isWide: isWide),
                  const SizedBox(height: 32),
                  _CtaCard(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.isWide});
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Flex(
      direction: isWide ? Axis.horizontal : Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Purse – Track every taka effortlessly',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: color.onSurface,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Add expenses, incomes, categories, and see clean charts. Works on mobile and web with the same codebase.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color.onSurfaceVariant,
                      height: 1.35,
                    ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Open the App'),
                    onPressed: () => Navigator.of(context).pushNamed('/app'),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.bar_chart),
                    label: const Text('View Expenses'),
                    onPressed: () => Navigator.of(context).pushNamed(ExpenseScreen.name),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (isWide) const SizedBox(width: 24) else const SizedBox(height: 24),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.primaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quick snapshot',
                    style: TextStyle(
                      color: color.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 12),
                _MiniStat(label: 'Works on Web', value: 'Flutter Web'),
                _MiniStat(label: 'Data', value: 'Local SQLite via ffi_web'),
                _MiniStat(label: 'Charts', value: 'fl_chart'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Consumer<DatabaseProvider>(
      builder: (_, db, __) {
        final total = db.calculateTotalEntriesAndAmount();
        final amount = (total['totalAmount'] as num?)?.toDouble() ?? 0;
        final entries = total['entries'] as int? ?? 0;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Wrap(
            spacing: 24,
            runSpacing: 12,
            children: [
              _StatCard(label: 'Total Expense', value: '৳${amount.toStringAsFixed(0)}'),
              _StatCard(label: 'Entries', value: entries.toString()),
              _StatCard(label: 'Current Range', value: db.period.name),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.outlineVariant.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(color: color.onSurfaceVariant)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color.onSurface,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 18, color: color.onPrimaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label • $value',
              style: TextStyle(
                color: color.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection({required this.isWide});
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final items = [
      _Feature(icon: Icons.wallet, title: 'Expenses & Incomes', text: 'Track all money flows with categories and notes.'),
      _Feature(icon: Icons.category, title: 'Categories', text: 'Custom categories with totals and entries.'),
      _Feature(icon: Icons.insights, title: 'Charts', text: 'Weekly/monthly charts powered by fl_chart.'),
      _Feature(icon: Icons.date_range, title: 'Date Ranges', text: 'Week / Month / Custom range filters.'),
      _Feature(icon: Icons.delete_outline, title: 'Swipe to Delete', text: 'Remove entries with confirmation.'),
      _Feature(icon: Icons.devices, title: 'Web + Mobile', text: 'One Flutter codebase across platforms.'),
    ];

    final crossAxis = isWide ? 3 : 1;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxis,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (_, i) => items[i],
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.title, required this.text});
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color.primary),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: color.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: TextStyle(color: color.onSurfaceVariant, height: 1.3),
          ),
        ],
      ),
    );
  }
}

class _CtaCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ready to manage your purse?'
            ,
            style: TextStyle(
              color: color.onPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Open the app, add a few expenses, and see live charts immediately.',
            style: TextStyle(
              color: color.onPrimary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: [
              FilledButton.tonal(
                style: FilledButton.styleFrom(
                  backgroundColor: color.onPrimary,
                  foregroundColor: color.primary,
                ),
                onPressed: () => Navigator.of(context).pushNamed('/app'),
                child: const Text('Open the App'),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: color.onPrimary,
                  side: BorderSide(color: color.onPrimary.withOpacity(0.6)),
                ),
                onPressed: () => Navigator.of(context).pushNamed(ExpenseScreen.name),
                child: const Text('View Expenses'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
