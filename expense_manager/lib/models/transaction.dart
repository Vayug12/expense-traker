class ExpenseTransaction {
  final String id;
  final double amount;
  final String type; // 'income' or 'expense'
  final String category;
  final String note;
  final DateTime date;
  final DateTime createdAt;

  ExpenseTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    this.note = '',
    required this.date,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'category': category,
      'note': note,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ExpenseTransaction.fromMap(Map<String, dynamic> map) {
    return ExpenseTransaction(
      id: map['id'],
      amount: map['amount'],
      type: map['type'],
      category: map['category'],
      note: map['note'] ?? '',
      date: DateTime.parse(map['date']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  ExpenseTransaction copyWith({
    String? id,
    double? amount,
    String? type,
    String? category,
    String? note,
    DateTime? date,
  }) {
    return ExpenseTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt,
    );
  }

  static const List<String> categories = [
    'Food',
    'Travel',
    'Shopping',
    'Bills',
    'Entertainment',
    'Health',
    'Education',
    'Salary',
    'Freelance',
    'Investment',
    'Gift',
    'Other',
  ];

  static const List<String> expenseCategories = [
    'Food',
    'Travel',
    'Shopping',
    'Bills',
    'Entertainment',
    'Health',
    'Education',
    'Other',
  ];

  static const List<String> incomeCategories = [
    'Salary',
    'Freelance',
    'Investment',
    'Gift',
    'Other',
  ];
}
