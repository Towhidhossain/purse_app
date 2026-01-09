import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../models/database_provider.dart';
import '../../models/transaction.dart';
import '../../providers/auth_provider.dart';

class MonthlyStatementAction extends StatefulWidget {
  const MonthlyStatementAction({super.key});

  @override
  State<MonthlyStatementAction> createState() => _MonthlyStatementActionState();
}

class _MonthlyStatementActionState extends State<MonthlyStatementAction> {
  DateTime _selected = DateTime.now();
  bool _working = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Monthly Statement',
      icon: const Icon(Icons.picture_as_pdf_outlined),
      onPressed: _working ? null : () => _openPicker(context),
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    final now = DateTime.now();
    final minYear = now.year - 4;
    final maxYear = now.year + 1;

    await showDialog(
      context: context,
      builder: (ctx) {
        int month = _selected.month;
        int year = _selected.year;
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              title: const Text('Monthly Bank Statement'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text('Month'),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: month,
                          items: List.generate(12, (i) => i + 1)
                              .map((m) => DropdownMenuItem(
                                    value: m,
                                    child: Text(DateFormat.MMMM().format(DateTime(0, m))),
                                  ))
                              .toList(),
                          onChanged: (val) => setLocal(() => month = val ?? month),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Year'),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: year,
                          items: List.generate(maxYear - minYear + 1, (i) => minYear + i)
                              .map((y) => DropdownMenuItem(value: y, child: Text(y.toString())))
                              .toList(),
                          onChanged: (val) => setLocal(() => year = val ?? year),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Generate'),
                  onPressed: _working
                      ? null
                      : () async {
                          Navigator.of(ctx).pop();
                          setState(() => _selected = DateTime(year, month));
                          await _generate(context, DateTime(year, month));
                        },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _generate(BuildContext context, DateTime month) async {
    setState(() => _working = true);
    final db = context.read<DatabaseProvider>();
    final profile = context.read<AuthProvider>().user;
    await db.fetchTransactions();

    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final monthTx = db.transactions
        .where((t) => !t.date.isBefore(start) && !t.date.isAfter(end))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final incomeTotal = monthTx
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (s, t) => s + t.amount);
    final expenseTotal = monthTx
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (s, t) => s + t.amount);
    final monthBalance = incomeTotal - expenseTotal;

    final opening = db.transactions
        .where((t) => t.date.isBefore(start))
        .fold<double>(0, (s, t) =>
            s + (t.type == TransactionType.income ? t.amount : -t.amount));
    final closing = opening + monthBalance;

    if (monthTx.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No transactions found for selected month.')),
        );
      }
      setState(() => _working = false);
      return;
    }

    final pdfBytes = await _buildPdf(
      month: month,
      transactions: monthTx,
      incomeTotal: incomeTotal,
      expenseTotal: expenseTotal,
      opening: opening,
      closing: closing,
      accountHolder: profile?.displayName ?? 'Not provided',
    );

    final fileName = 'Purse_Statement_${month.year}_${month.month.toString().padLeft(2, '0')}.pdf';
    await _savePdf(context, pdfBytes, fileName);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Statement generated: $fileName')),
      );
    }
    setState(() => _working = false);
  }

  Future<Uint8List> _buildPdf({
    required DateTime month,
    required List<FinanceTransaction> transactions,
    required double incomeTotal,
    required double expenseTotal,
    required double opening,
    required double closing,
    required String accountHolder,
  }) async {
    final doc = pw.Document();
    final currency = NumberFormat.currency(symbol: 'Tk ', decimalDigits: 2);
    final monthLabel = DateFormat('MMMM yyyy').format(month);

    doc.addPage(
      pw.MultiPage(
        pageTheme: const pw.PageTheme(
          margin: pw.EdgeInsets.all(32),
          orientation: pw.PageOrientation.portrait,
        ),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Purse', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Monthly Bank Statement'),
                  ],
                ),
                pw.Text(monthLabel, style: pw.TextStyle(fontSize: 16)),
              ],
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Account Holder:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(accountHolder.isNotEmpty ? accountHolder : 'Not provided'),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Opening Balance:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(currency.format(opening)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Table.fromTextArray(
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue50),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
            headers: const ['Date', 'Title', 'Category', 'Type', 'Amount'],
            data: transactions
                .map((t) {
                  final category = t.category?.isNotEmpty == true
                      ? t.category!
                      : (t.type == TransactionType.income ? 'Income' : '—');
                  return [
                    DateFormat('MMM dd, yyyy').format(t.date),
                    t.label,
                    category,
                    t.type == TransactionType.income ? 'Income' : 'Expense',
                    currency.format(t.amount),
                  ];
                })
                .toList(),
          ),
          pw.SizedBox(height: 16),
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Text('Summary', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: const {
              0: pw.FractionColumnWidth(.6),
              1: pw.FractionColumnWidth(.4),
            },
            children: [
              _summaryRow('Total Income', currency.format(incomeTotal)),
              _summaryRow('Total Expenses', currency.format(expenseTotal)),
              _summaryRow('Net for Month', currency.format(incomeTotal - expenseTotal)),
              _summaryRow('Opening Balance', currency.format(opening)),
              _summaryRow('Closing Balance', currency.format(closing)),
            ],
          ),
        ],
      ),
    );

    return doc.save();
  }

  pw.TableRow _summaryRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: pw.Text(label),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
      ],
    );
  }

  Future<void> _savePdf(BuildContext context, Uint8List bytes, String filename) async {
    if (kIsWeb) {
      await Printing.sharePdf(bytes: bytes, filename: filename);
      return;
    }

    Directory? dir;
    try {
      dir = await getDownloadsDirectory();
    } catch (_) {}
    dir ??= await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes);

    // Offer quick preview/share
    await Printing.sharePdf(bytes: bytes, filename: filename);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved to ${dir.path}')),
      );
    }
  }
}