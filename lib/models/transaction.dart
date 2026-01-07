enum TransactionType { income, expense }

class FinanceTransaction {
  final int id;
  final TransactionType type;
  final double amount;
  final String label; // category name for expense, source for income
  final DateTime date;
  final String? note;
  final String? category; // optional for expenses
  final int? linkId; // id of the source income/expense row
  final String? linkType; // 'income' or 'expense'

  FinanceTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.label,
    required this.date,
    this.note,
    this.category,
    this.linkId,
    this.linkType,
  });

  Map<String, dynamic> toMap() => {
        'type': type.name,
        'amount': amount.toString(),
        'label': label,
        'date': date.toIso8601String(),
        'note': note ?? '',
        'category': category,
        'linkId': linkId,
        'linkType': linkType,
      };

  factory FinanceTransaction.fromString(Map<String, dynamic> value) {
    final rawType = value['type']?.toString();
    final rawAmount = value['amount']?.toString();

    return FinanceTransaction(
      id: value['id'] ?? 0,
      type: rawType == 'income' ? TransactionType.income : TransactionType.expense,
      amount: double.tryParse(rawAmount ?? '0') ?? 0,
      label: value['label']?.toString() ?? '',
      date: DateTime.tryParse(value['date']?.toString() ?? '') ?? DateTime.now(),
      note: value['note']?.toString(),
      category: value['category']?.toString(),
      linkId: value['linkId'] is int ? value['linkId'] as int : null,
      linkType: value['linkType']?.toString(),
    );
  }
}
