class Income {
  final int id;
  final double amount;
  final String source;
  final DateTime date;
  final String? note;

  Income({
    required this.id,
    required this.amount,
    required this.source,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toMap() => {
        'amount': amount.toString(),
        'source': source,
        'date': date.toIso8601String(),
        'note': note ?? '',
      };

  factory Income.fromString(Map<String, dynamic> value) => Income(
        id: value['id'],
        amount: double.parse(value['amount']),
        source: value['source'],
        date: DateTime.parse(value['date']),
        note: value['note'],
      );
}
