import 'package:flutter/material.dart';
import 'api_file.dart';

class CatagoryManagementBox extends StatefulWidget {
  @override
  _CatagoryManagementBoxState createState() => _CatagoryManagementBoxState();
}

class _CatagoryManagementBoxState extends State<CatagoryManagementBox> {
  final _formKey = GlobalKey<FormState>();
  final _CatagorynameController = TextEditingController();
  
  final _searchController = TextEditingController();

  List<Map<String, dynamic>> _Catagory = [];
  List<Map<String, dynamic>> _filteredCat = [];
final nameRegExp = RegExp(r'^[a-zA-Z\s]+$');



bool check_values(BuildContext context, String name) {
  if (!nameRegExp.hasMatch(name) 
      ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Invalid data entered!'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return true;
  }return false;
}



  @override
  void initState() {
    super.initState();
    fetchCatagory();
    _searchController.addListener(_filterCat);
  }

  Future<void> fetchCatagory() async {
    try {
      var response = await CatagoryDataFromServer("fetch_catagory", {});
      if (response["success"] == true) {
        setState(() {
          _Catagory = List<Map<String, dynamic>>.from(response["data"]);
          _filteredCat = List.from(_Catagory);
        });
      } else {
        print('Failed to load catagory');
      }
    } catch (e) {
      print('Error fetching catagory: $e');
    }
  }

  void _filterCat() {
    setState(() {
      String query = _searchController.text.toLowerCase();
      _filteredCat = _Catagory
          .where((catagory) => catagory['Catagory_name'].toLowerCase().contains(query))
          .toList();
    });
  }

  void showUpdateDialog(Map<String, dynamic> catagory) {
    _CatagorynameController.text = catagory['catagory_name'] ?? '';
   
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update catagory'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _CatagorynameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Update'),
              onPressed: () async {
                await updateCatagory(catagory);
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: () async {
                await delete(catagory);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateCatagory(Map<String, dynamic> catagory) async {
      String  cat_ID = catagory['catagory_ID'] ?? '00';

    try {
      var data = {
        "action": "update_catagory",
        "catagory_ID": cat_ID,
        "catagory_name": _CatagorynameController.text,
        
      };
 if(check_values(context, _CatagorynameController.text)){
  return;
 }
      var response = await CatagoryDataFromServer("update_Catagory", data);
      print(response);

      if (response["success"] == true) {
        _saveCatagory();
        fetchCatagory();
      } else {
        showErrorDialog('Failed to update catagory. Please try again.');
      }
    } catch (e) {
      print('Error updating catagory: $e');
      showErrorDialog('An unexpected error occurred. Please try again later.');
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _saveCatagory() {
    if (_formKey.currentState!.validate()) {
      _CatagorynameController.clear();
    }
  }

  Future<void> insert() async {
  String name = _CatagorynameController.text;
if(check_values(context, name)){
  return;
}
  if (name.isEmpty) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Please fill the required field.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return;
  }

  try {
    var data = {
      "action": "add_catagory",
      "catagory_name": name // Ensure this matches your PHP script variable name
    };

    var response = await CatagoryDataFromServer("add_catagory", data);
    print(response);

    if (response["success"] == true) {
      _saveCatagory(); // Function to save locally if needed
      fetchCatagory(); // Function to fetch updated categories
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to add category. Please try again.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  } catch (e) {
    print('Error adding category: $e');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('An unexpected error occurred. Please try again later.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

  Future<void> delete(Map<String, dynamic> catagory) async {
    String name = _CatagorynameController.text;
    String cat_ID = catagory['catagory_ID'] ?? '';

    if (name.isNotEmpty) {
      try {
        var data = {
          "action": "delete_catagory",
        
          "catagory_ID":cat_ID,
        };

        var response = await CatagoryDataFromServer("delete", data);
        print("Response body: $response");

        if (response["success"] == true) {
          print("Deleted successfully");
          _saveCatagory();
          fetchCatagory();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("catagory deleted successfully"),
              duration: Duration(seconds: 2),
            ),
          );

          Future.delayed(Duration(seconds: 2), () {
            _CatagorynameController.clear();
          });
        } else {
          print("Delete failed: ${response['message'] ?? 'Unknown error'}");
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('Failed to delete catagory. Please try again.'),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        print("Error occurred: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error occurred: $e")),
        );
      }
    } else {
      print("field cannot be empty");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("field cannot be empty")),
      );
    }
  }

@override
Widget build(BuildContext context) {
  return Theme(
    data: ThemeData(
      primaryColor: Colors.blue,
      hintColor: Colors.blueAccent,
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.blue,
        textTheme: ButtonTextTheme.primary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2.0),
        ),
        labelStyle: TextStyle(color: Colors.blue),
        errorStyle: TextStyle(color: Colors.red),
      ),
    ),child: AlertDialog(
    title: Text('Manage Category'),
    content: SizedBox(
      width: double.maxFinite,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columnSpacing: 20,
                      columns: [
                        DataColumn(label: Text('Update')),
                        DataColumn(label: Text('Name')),
                      ],
                      rows: _filteredCat.map<DataRow>((category) {
                        return DataRow(
                          cells: [
                            DataCell(IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                showUpdateDialog(category);
                              },
                            )),
                            DataCell(Text(category['catagory_name'] ?? '')),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _CatagorynameController,
                        decoration: InputDecoration(labelText: 'Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: insert,
                            child: Text('Save', style: TextStyle(color: Colors.blue)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text('Close', style: TextStyle(color: Colors.blue)),
      ),
    ],
  ),);
}
}