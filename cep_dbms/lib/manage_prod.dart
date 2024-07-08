import 'package:flutter/material.dart';
import 'api_file.dart';



class ProductManagementBox extends StatefulWidget {
  @override
  _ProductManagementBoxState createState() => _ProductManagementBoxState();
}

class _ProductManagementBoxState extends State<ProductManagementBox> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  
  final _categoryIdController = TextEditingController();

  final _searchController = TextEditingController();

  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  List<Map<String,dynamic>> _Catagory=[];
 String? _selectedCategory;

final nameRegExp = RegExp(r'^[a-zA-Z\s]+$');
final decimalRegExp = RegExp(r'^\d+(\.\d+)?$');


bool check_values(BuildContext context, String name,String stock,String price) {
  if (!nameRegExp.hasMatch(name)||!decimalRegExp.hasMatch(stock)||!decimalRegExp.hasMatch(price) 
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
    fetchProducts();
    _searchController.addListener(_filterProducts);
    _fetch_Catagory();
     
}
  


  Future <void>fetchProducts() async {
    try {
      var response = await ProductDataFromServer("fetch_product", {});
      if (response["success"] == true) {
        setState(() {
          _products = List<Map<String, dynamic>>.from(response["data"]);
          _filteredProducts = List.from(_products);
        });
      } else {
        print('Failed to load products');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _products.where((product) {
        return product['prod_name']
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
      }).toList();
    });
  }



 void showUpdateDialog(Map<String, dynamic> product_catagory_view) {
    _productNameController.text = product_catagory_view['prod_name'] ?? '';
    _priceController.text = product_catagory_view['price']?.toString() ?? '';
    _stockController.text = product_catagory_view['stock']?.toString() ?? '';
    
    _categoryIdController.text = product_catagory_view['catagory_name']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Product'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _productNameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _stockController,
                  decoration: InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _categoryIdController,
                  decoration: InputDecoration(labelText: 'Category'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Update'),
              onPressed: () async {
                await updateProduct(product_catagory_view);
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: () async {
                await deleteProduct(product_catagory_view);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateProduct(Map<String, dynamic> product) async {
    String productId = product['prod_ID']?.toString() ?? '0'; // Replace 'product_id' with your actual identifier
    String catagory_ID= product['catagory_ID'] ?? 0;
    if(check_values(context, _productNameController.text, _stockController.text, _priceController.text)){
      return;
    }
    try {
      var data = {
        "action": "update_product",
        "prod_ID": productId,
        "prod_name": _productNameController.text,
        "price": _priceController.text,
        "stock": _stockController.text,
        
        "catagory_ID": catagory_ID,
      };
      
      var response = await ProductDataFromServer("update_product", data);

      if (response["success"] == true) {
        // Handle success, e.g., refresh product list
          _productNameController.clear();
    _priceController.clear();
    _stockController.clear();
   
    _categoryIdController.clear();
        
        fetchProducts();
       
      } else {
        showErrorDialog('Failed to update product. Please try again.');
      }
    } catch (e) {
      print('Error updating product: $e');
      showErrorDialog('An unexpected error occurred. Please try again later.');
    }
  }

void _saveProduct() {
  if (_formKey.currentState!.validate()) {
    _productNameController.clear();
    _priceController.clear();
    _stockController.clear();
   
    _categoryIdController.clear();
  }
}


 Future<void> insert() async {
  String productName = _productNameController.text;
  String price = _priceController.text;
  String stock = _stockController.text;
  String categoryId = _categoryIdController.text;

  // Validate required fields
  if (productName.isEmpty || price.isEmpty || stock.isEmpty || categoryId.isEmpty) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Please fill all required fields.'),
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
  if(check_values(context, productName, stock, price)){
    return;
  }
  try {
    var data = {
      "action": "add_product",
      "prod_name": productName,
      "price": price,
      "stock": stock,
      "catagory_ID": categoryId,
    };

    var response = await ProductDataFromServer("add_product", data);
    print(response["success"]);
    if (response["success"] == true) {
    
      _saveProduct(); // Clear form fields after successful insert
      fetchProducts(); // Refresh product list
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to add product. Please try again.'),
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
    print('Error adding product: $e');
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
Future<void> _fetch_Catagory() async {
    try {
      var response = await CatagoryDataFromServer("fetch_catagory", {});
      if (response["success"] == true) {
        setState(() {
          _Catagory = List<Map<String, dynamic>>.from(response["data"]);
          
        });
      } else {
        print('Failed to load catagory');
      }
    } catch (e) {
      print('Error fetching catagory: $e');
    }
  }



   Future<void> deleteProduct(Map<String, dynamic> product) async {
    String productId = product['prod_ID']?.toString() ?? '0'; // Replace 'product_id' with your actual identifier

    try {
      var data = {
        "action": "delete_product",
        "prod_ID": productId,
      };

      var response = await ProductDataFromServer("delete_product", data);

      if (response["success"] == true) {
        // Handle success, e.g., refresh product list
        fetchProducts();
        _saveProduct();
      } else {
        showErrorDialog('Failed to delete product. Please try again.');
      }
    } catch (e) {
      print('Error deleting product: $e');
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
    ), child:AlertDialog(
    title: Text(
      'Manage Product',
      style: TextStyle(color: Colors.blue), // Title text color
    ),
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
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 20,
                          columns: [
                            DataColumn(label: Text('Update')),
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Price')),
                            DataColumn(label: Text('Stock')),
                            DataColumn(label: Text('Category')),
                          ],
                          rows: _filteredProducts.map<DataRow>((product_catagory_view) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      showUpdateDialog(product_catagory_view);
                                    },
                                  ),
                                ),
                                DataCell(Text(product_catagory_view['prod_name'] ?? '')),
                                DataCell(Text(product_catagory_view['price']?.toString() ?? '')),
                                DataCell(Text(product_catagory_view['stock']?.toString() ?? '')),
                                DataCell(Text(product_catagory_view['catagory_name']?.toString() ?? '')),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
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
                        controller: _productNameController,
                        decoration: InputDecoration(
                          labelText: 'Product Name',
                          border: OutlineInputBorder(), // Add border
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a product name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(), // Add border
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a price';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _stockController,
                        decoration: InputDecoration(
                          labelText: 'Stock',
                          border: OutlineInputBorder(), // Add border
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the stock';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        items: _Catagory.map((catagory) {
                          String displayValue = '${catagory['catagory_ID']} - ${catagory['catagory_name']}';
                          return DropdownMenuItem<String>(
                            value: displayValue,
                            child: Text(displayValue),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                            _categoryIdController.text = value.split(' ')[0];
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(), // Add border
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a category';
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
                            child: Text('Save'),
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
        child: Text('Close', style: TextStyle(color: Colors.blue)), // Close button text color
      ),
    ],
    backgroundColor: Color.fromARGB(255, 251, 252, 252), // Background color of the dialog
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0), // Rounded corners
    ),
    elevation: 4, // Shadow elevation
  ),);
}
}