import 'package:flutter/material.dart';
import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker/pages/category_page.dart';
import 'package:money_tracker/pages/home_page.dart';
import 'package:money_tracker/pages/transaction_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late DateTime selectedDate;
  late List<Widget> _children;
  late int currentIndex;

  @override
  void initState() {
    updateView(0, DateTime.now());
    super.initState();
  }

  void updateView(int index, DateTime date) {
    setState(() {
      selectedDate = DateTime.parse(DateFormat('yyyy-MM-dd').format(date));
      currentIndex = index;
      _children = [
        HomePage(selectedDate: selectedDate),
        CategoryPage(),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (currentIndex == 0)
          ? CalendarAppBar(
              accent: Colors.green,
              backButton: false,
              locale: 'id',
              onDateChanged: (value) {
                setState(() {
                  print('Selected Date' + value.toString());
                  selectedDate = value;
                  updateView(0, selectedDate);
                });
              },
              firstDate: DateTime.now().subtract(Duration(days: 140)),
              lastDate: DateTime.now(),
            ) as PreferredSizeWidget
          : PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: AppBar(
                title: Text(
                  'Categories',
                  style: GoogleFonts.montserrat(fontSize: 24),
                ),
                backgroundColor: Colors.green,
              ),
            ),
      floatingActionButton: Visibility(
        visible: (currentIndex == 0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(
              builder: (context) => TransactionPage(
                transactionWithCategory: null,
              ),
            ))
                .then((value) {
              setState(() {});
            });
          },
          backgroundColor: Colors.green,
          child: Icon(Icons.add),
        ),
      ),
      body: _children[currentIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                updateView(0, DateTime.now());
              },
              icon: Icon(Icons.home),
            ),
            SizedBox(
              width: 20,
            ),
            IconButton(
              onPressed: () {
                updateView(1, DateTime.now());
              },
              icon: Icon(Icons.list),
            ),
          ],
        ),
      ),
    );
  }
}
