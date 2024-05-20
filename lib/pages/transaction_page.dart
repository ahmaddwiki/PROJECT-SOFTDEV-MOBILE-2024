import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker/models/database.dart';
import 'package:money_tracker/models/transaction_with_category.dart';

class TransactionPage extends StatefulWidget {
  final TransactionWithCategory? transactionWithCategory;
  const TransactionPage({
    Key? key,
    required this.transactionWithCategory,
  }) : super(key: key);

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final AppDatabase database = AppDatabase();
  late int type;
  bool isExpense = true;
  List<String> list = [
    'Sedekah dan Menabung',
    'Transportasi',
    'Nonton Bioskop'
  ];

  late String dropdownValue = list.first;
  TextEditingController dateController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController detailController = TextEditingController();
  Category? selectedCategory;
  DateTime? pickedDate;

  Color getAmountTextColor() {
    return isExpense ? Colors.red : Colors.green;
  }

  Color getInputBorder() {
    return isExpense ? Colors.red : Colors.green;
  }

  Future insert(
      int amount, DateTime date, String nameDetail, int categoryId) async {
    DateTime now = DateTime.now();
    final row = await database.into(database.transactions).insertReturning(
        TransactionsCompanion.insert(
            name: nameDetail,
            category_id: categoryId,
            amount: amount,
            Transaction_date: date,
            createdAt: now,
            updatedAt: now));
    print('DONE :' + row.toString());
  }

  Future<List<Category>> getAllCategory(int type) async {
    return await database.getAllCategoryRepo(type);
  }

  Future update(int transactionId, int amount, int categoryId,
      DateTime transactionDate, String nameDetail) async {
    return await database.updateTransactionRepo(
        transactionId, amount, categoryId, transactionDate, nameDetail);
  }

  @override
  void initState() {
    if (widget.transactionWithCategory != null) {
      updateTransactionView(widget.transactionWithCategory!);
    } else {
      type = 2;
      pickedDate = DateTime.now(); // Mengisi pickedDate dengan tanggal saat ini
    }

    super.initState();
  }

  void updateTransactionView(TransactionWithCategory transactionWithCategory) {
    amountController.text =
        transactionWithCategory.transaction.amount.toString();
    detailController.text = transactionWithCategory.transaction.name;
    dateController.text = DateFormat.yMMMd()
        .format(transactionWithCategory.transaction.Transaction_date);
    type = transactionWithCategory.category.type;
    type == 2 ? isExpense = true : isExpense = false;
    selectedCategory = transactionWithCategory.category;
  }

  @override
  Widget build(BuildContext context) {
    // Jika tanggal yang dipilih belum ada (kosong), maka atur tanggal saat ini sebagai nilai default
    if (pickedDate != null) {
      dateController.text = DateFormat.yMMMd().format(pickedDate!);
    } else {
      pickedDate = DateTime.now();
      dateController.text = DateFormat.yMMMd().format(pickedDate!);
    }
    return Scaffold(
      appBar: AppBar(title: Text("Add Transaction")),
      body: Theme(
        data: ThemeData(
          primaryColor: Colors.green, // Mengubah warna tema utama menjadi hijau
        ),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Switch(
                      value: isExpense,
                      onChanged: (bool value) {
                        setState(() {
                          isExpense = value;
                          type = isExpense ? 2 : 1;
                          selectedCategory = null;
                        });
                      },
                      inactiveTrackColor: Colors.green[200],
                      inactiveThumbColor: Colors.green,
                      activeColor: Colors.red,
                    ),
                    Text(
                      isExpense ? 'Expense' : 'Income',
                      style: GoogleFonts.montserrat(fontSize: 14),
                    )
                  ],
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                getInputBorder()), // Mengatur warna garis tepi
                      ),
                      labelText: "Amount",
                      labelStyle: TextStyle(
                          color:
                              getAmountTextColor()), // Mengatur warna teks berdasarkan isExpense
                    ),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Category',
                    style: GoogleFonts.montserrat(fontSize: 16),
                  ),
                ),
                FutureBuilder<List<Category>>(
                    future: getAllCategory(type),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        if (snapshot.hasData) {
                          if (snapshot.data!.length > 0) {
                            selectedCategory = (selectedCategory == null)
                                ? snapshot.data!.first
                                : selectedCategory;
                            print('DONE : ' + snapshot.toString());
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: DropdownButton<Category>(
                                value: (selectedCategory == null)
                                    ? snapshot.data!.first
                                    : selectedCategory,
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_downward),
                                items: snapshot.data!.map((Category item) {
                                  return DropdownMenuItem<Category>(
                                    value: item,
                                    child: Text(item.name),
                                  );
                                }).toList(),
                                onChanged: (Category? value) {
                                  setState(() {
                                    selectedCategory = value;
                                    print('SELECTED CATEGORY' + value!.name);
                                  });
                                },
                              ),
                            );
                          } else {
                            return Center(
                              child: Text("Data Empty"),
                            );
                          }
                        } else {
                          return Center(
                            child: Text("No Has Data"),
                          );
                        }
                      }
                    }),
                SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    controller: dateController,
                    decoration: InputDecoration(labelText: "Date"),
                    onTap: () async {
                      pickedDate = await showDatePicker(
                        context: context,
                        initialDate: pickedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2025),
                      );

                      if (pickedDate != null) {
                        String formattedDate =
                            DateFormat.yMMMd().format(pickedDate!);
                        dateController.text = formattedDate;
                      }
                    },
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    controller: detailController,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                getInputBorder()), // Mengatur warna garis tepi
                      ),
                      labelText: "Detail",
                      labelStyle: TextStyle(
                          color:
                              getAmountTextColor()), // Mengatur warna teks berdasarkan isExpense
                    ),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Center(
                  child: GestureDetector(
                    onTap: () async {
                      // Validasi dan konversi teks tanggal
                      try {
                        // Parsing teks tanggal menjadi objek DateTime
                        pickedDate =
                            DateFormat.yMMMd().parse(dateController.text);
                      } catch (e) {
                        // Tangani kesalahan jika format tanggal tidak sesuai
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Error"),
                              content: Text(
                                  "Invalid date format. Please enter date in MMM d, yyyy format."),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                        return; // Keluar dari metode onPressed() jika format tanggal tidak valid
                      }

                      (widget.transactionWithCategory == null)
                          ? await insert(
                              int.parse(amountController.text),
                              pickedDate!,
                              detailController.text,
                              selectedCategory!.id)
                          : await update(
                              widget.transactionWithCategory!.transaction.id,
                              int.parse(amountController.text),
                              selectedCategory!.id,
                              pickedDate!,
                              detailController.text);
                      // Update tampilan homepage langsung setelah menyimpan data
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Save",
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
