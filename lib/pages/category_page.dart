import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tracker/models/database.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  bool isExpense = true;
  int type = 1;
  final AppDatabase database = AppDatabase();
  TextEditingController CategoryNameController = TextEditingController();

  Future insert(String name, int type) async {
    DateTime now = DateTime.now();
    final row = await database.into(database.categories).insertReturning(
        CategoriesCompanion.insert(
            name: name, type: type, createdAt: now, updatedAt: now));
    print('DONE :' + row.toString());
  }

  Future<List<Category>> getAllCategory(int type) async {
    return await database.getAllCategoryRepo(type);
  }

  Future update(int categoryId, String newName) async {
    return await database.updateCategoryRepo(categoryId, newName);
  }

  void OpenDialog(Category? category) {
    if (category != null) {
      CategoryNameController.text = category.name;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Text(
                    (isExpense) ? "Add Expense" : "Add Income",
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      color: (isExpense) ? Colors.red : Colors.green,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: CategoryNameController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), hintText: "Name"),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                      onPressed: () {
                        if (category == null) {
                          insert(
                              CategoryNameController.text, isExpense ? 2 : 1);
                        } else {
                          update(category.id, CategoryNameController.text);
                        }

                        Navigator.of(context, rootNavigator: true)
                            .pop('dialog');
                        setState(() {});
                        CategoryNameController.clear();
                      },
                      child: Text("Save"))
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Switch(
                value: isExpense,
                onChanged: (bool value) {
                  setState(() {
                    isExpense = value;
                    type = value ? 2 : 1;
                  });
                },
                inactiveTrackColor: Colors.green.shade200,
                inactiveThumbColor: Colors.green,
                activeTrackColor: Colors.red.shade200,
                activeColor: Colors.red,
              ),
              IconButton(
                onPressed: () {
                  OpenDialog(null);
                },
                icon: Icon(Icons.add),
              ),
            ],
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
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Card(
                              elevation: 10,
                              child: ListTile(
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          database.deleteCategoryRepo(
                                              snapshot.data![index].id);
                                          setState(() {});
                                        },
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          OpenDialog(snapshot.data![index]);
                                        },
                                      )
                                    ],
                                  ),
                                  leading: Container(
                                      padding: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: (isExpense)
                                          ? Icon(Icons.upload,
                                              color: Colors.redAccent[400])
                                          : Icon(
                                              Icons.download,
                                              color: Colors.greenAccent[400],
                                            )),
                                  title: Text(snapshot.data![index].name)),
                            ),
                          );
                        });
                  } else {
                    return Center(
                      child: Text("No has data"),
                    );
                  }
                } else {
                  return Center(
                    child: Text("No has data"),
                  );
                }
              }
            }),
      ],
    ));
  }
}
