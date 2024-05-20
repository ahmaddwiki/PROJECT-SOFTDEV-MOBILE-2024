import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:money_tracker/models/category.dart';
import 'package:money_tracker/models/transaction.dart';
import 'package:money_tracker/models/transaction_with_category.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

@DriftDatabase(tables: [Categories, Transactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // CRUD category methods

  Future<List<Category>> getAllCategoryRepo(int type) async {
    return await (select(categories)..where((tbl) => tbl.type.equals(type)))
        .get();
  }

  Future updateCategoryRepo(int id, String name) async {
    return (update(categories)..where((tbl) => tbl.id.equals(id)))
        .write(CategoriesCompanion(name: Value(name)));
  }

  Future deleteCategoryRepo(int id) async {
    return (delete(categories)..where((tbl) => tbl.id.equals(id))).go();
  }

  // CRUD transaction methods

  // //Delete transaction by category id
  // Future deleteTransactionByCategoryIdRepo(int categoryId) async {
  //   return (delete(transactions)
  //         ..where((tbl) => tbl.category_id.equals(categoryId)))
  //       .go();
  // }

  // Function to get all transactions
  Stream<List<TransactionWithCategory>> getAllTransactionRepo() {
    final query = select(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.category_id))
    ]);
    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCategory(
          row.readTable(transactions),
          row.readTable(categories),
        );
      }).toList();
    });
  }

  Stream<List<TransactionWithCategory>> getTransactionByDateRepo(
      DateTime selectedDate) {
    final query = select(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.category_id))
    ])
      ..where(transactions.Transaction_date.equals(selectedDate));
    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCategory(
          row.readTable(transactions),
          row.readTable(categories),
        );
      }).toList();
    });
  }

  Future updateTransactionRepo(int id, int amount, int categoryId,
      DateTime transactionDate, String nameDetail) async {
    return (update(transactions)..where((tbl) => tbl.id.equals(id))).write(
        TransactionsCompanion(
            name: Value(nameDetail),
            amount: Value(amount),
            category_id: Value(categoryId),
            Transaction_date: Value(transactionDate)));
  }

  Future deleteTransactionRepo(int id) async {
    await (delete(transactions)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<double> getTotalIncome(DateTime date) async {
    final totalIncome = await (selectOnly(transactions)
          ..addColumns([transactions.amount.sum() as Expression<Object>])
          ..where(transactions.amount.isBiggerThanValue(0))
          ..where(transactions.Transaction_date.equals(date)))
        .map((row) => row.read(transactions.amount.sum as Expression<Object>))
        .getSingle();

    return (totalIncome ?? 0) as double;
  }

  Future<double> getTotalExpense(DateTime date) async {
    final totalExpense = await (selectOnly(transactions)
          ..addColumns([transactions.amount.sum() as Expression<Object>])
          ..where(transactions.amount.isSmallerThanValue(0))
          ..where(transactions.Transaction_date.equals(date)))
        .map((row) => row.read(transactions.amount.sum as Expression<Object>))
        .getSingle();

    return (totalExpense ?? 0) as double;
  }

//   // Fungsi untuk menghitung total income berdasarkan periode
//   Future<double> getTotalIncomeByPeriod(DateTime startDate, DateTime endDate) async {
//     final totalIncome = await (selectOnly(transactions)
//           ..addColumns([transactions.amount.sum() as Expression<Object>])
//           ..where(transactions.amount.isBiggerThanValue(0))
//           ..where(transactions.Transaction_date.isBiggerOrEqualValue(startDate))
//           ..where(transactions.Transaction_date.isSmallerOrEqualValue(endDate)))
//         .map((row) => row.read(transactions.amount.sum as Expression<Object>))

// }

//  // Fungsi untuk menghitung total expense berdasarkan periode
//   Future<double> getTotalExpenseByPeriod(DateTime startDate, DateTime endDate) async {
//     final totalExpense = await (selectOnly(transactions)
//           ..addColumns([transactions.amount.sum() as Expression<Object>])
//           ..where(transactions.amount.isSmallerThanValue(0))
//           ..where(transactions.Transaction_date.isBiggerOrEqualValue(startDate))
//           ..where(transactions.Transaction_date.isSmallerOrEqualValue(endDate)))
//         .map((row) => row.read(transactions.amount.sum as Expression<Object>))
// }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
