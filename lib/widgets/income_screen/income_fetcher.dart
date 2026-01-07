import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/database_provider.dart';
import './income_list.dart';

class IncomeFetcher extends StatefulWidget {
  const IncomeFetcher({super.key});

  @override
  State<IncomeFetcher> createState() => _IncomeFetcherState();
}

class _IncomeFetcherState extends State<IncomeFetcher> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    await provider.fetchIncomes();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: IncomeList(),
    );
  }
}
