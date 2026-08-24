enum CategoryApplicability {
  expense,
  income,
  both;

  bool get allowsExpenses => this != CategoryApplicability.income;

  bool get allowsIncome => this != CategoryApplicability.expense;
}
