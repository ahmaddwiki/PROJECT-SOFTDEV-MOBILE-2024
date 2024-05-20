import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tracker/models/database.dart';
import 'package:money_tracker/models/transaction_with_category.dart';
import 'package:money_tracker/pages/transaction_page.dart';

class HomePage extends StatefulWidget {
  final DateTime selectedDate;
  const HomePage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppDatabase db = AppDatabase();

  // final List<TransactionWithCategory> transactions = [];
  // final int totalIncome = 0;
  // final int totalExpense = 0;

  @override
  void initState() {
    super.initState();
    // getAllTransactions();
  }

  // Function to get all transactions by Date
  // void getAllTransactions() {
  //   db.getTransactionByDateRepo(widget.selectedDate).listen((event) {
  //     setState(() {
  //       transactions.clear();
  //       transactions.addAll(event);
  //     });
  //   });
  // }

  // Function to get total income
  int getTotalIncome(List<TransactionWithCategory> transactions) {
    int total = 0;
    transactions.forEach((element) {
      if (element.category.type == 1) {
        total += element.transaction.amount;
      }
    });
    return total;
  }

  // Function to get total expense
  int getTotalExpense(List<TransactionWithCategory> transactions) {
    int total = 0;
    transactions.forEach((element) {
      if (element.category.type == 2) {
        total += element.transaction.amount;
      }
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    // Dummy data for income and expense
    int income = 1000000; // Example income amount
    int expense = 500000; // Example expense amount

    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.download, color: Colors.green),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Income",
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // streamBuilder for total income
                            StreamBuilder<List<TransactionWithCategory>>(
                              stream: db.getTransactionByDateRepo(
                                  widget.selectedDate),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text(
                                    "Rp. 0",
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  );
                                } else {
                                  if (snapshot.hasData) {
                                    final int totalIncome =
                                        getTotalIncome(snapshot.data!);
                                    return Text(
                                      "Rp. ${totalIncome}",
                                      style: GoogleFonts.montserrat(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    );
                                  } else {
                                    return Text(
                                      "Rp. 0",
                                      style: GoogleFonts.montserrat(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.upload, color: Colors.red),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Expense",
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 10),
                            StreamBuilder<List<TransactionWithCategory>>(
                              stream: db.getTransactionByDateRepo(
                                  widget.selectedDate),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text(
                                    "Rp. 0",
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  );
                                } else {
                                  if (snapshot.hasData) {
                                    final int totalExpense =
                                        getTotalExpense(snapshot.data!);
                                    return Text(
                                      "Rp. ${totalExpense}",
                                      style: GoogleFonts.montserrat(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    );
                                  } else {
                                    return Text(
                                      "Rp. 0",
                                      style: GoogleFonts.montserrat(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Text transaction history
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Transactions",
                style: GoogleFonts.montserrat(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            StreamBuilder<List<TransactionWithCategory>>(
              stream: db.getTransactionByDateRepo(widget.selectedDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  if (snapshot.hasData) {
                    if (snapshot.data!.length > 0) {
                      return Container(
                        height: MediaQuery.of(context).size.height / 2.4,
                        child: ListView.builder(
                          shrinkWrap: true,
                          // scrollDirection: Axis.vertical,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Card(
                                elevation: 10,
                                color: snapshot.data![index].category.type == 2
                                    ? Colors.red
                                    : Colors.green,
                                child: ListTile(
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () async {
                                          await db.deleteTransactionRepo(
                                              snapshot
                                                  .data![index].transaction.id);
                                          setState(() {});
                                        },
                                      ),
                                      SizedBox(width: 10),
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  TransactionPage(
                                                transactionWithCategory:
                                                    snapshot.data![index],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  title: Text(
                                    "Rp. " +
                                        snapshot.data![index].transaction.amount
                                            .toString(),
                                  ),
                                  subtitle: Text(
                                    snapshot.data![index].category.name +
                                        " (" +
                                        snapshot.data![index].transaction.name +
                                        ")",
                                  ),
                                  leading: Container(
                                    child: snapshot
                                                .data![index].category.type ==
                                            2
                                        ? Icon(Icons.upload, color: Colors.red)
                                        : Icon(Icons.download,
                                            color: Colors.green),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    } else {
                      return Center(
                        child: Text("Empty Data"),
                      );
                    }
                  } else {
                    return Center(
                      child: Text("No data"),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
