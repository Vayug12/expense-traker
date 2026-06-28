class Budget {
  final String id;
  final double amount;
  final int month; // 1-12
  final int year;

  Budget({
    required this.id,
    required this.amount,
    required this.month,
    required this.year,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'month': month,
      'year': year,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      amount: map['amount'],
      month: map['month'],
      year: map['year'],
    );
  }
}
