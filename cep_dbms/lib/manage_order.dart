import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'api_file.dart';
//import 'package:intl/intl.dart';

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController customerIDController = TextEditingController();
  final TextEditingController customeremailController = TextEditingController();
  final TextEditingController customerphoneController = TextEditingController();
  final TextEditingController customeradddressController = TextEditingController();
  final TextEditingController prodCategaryController = TextEditingController();
  final TextEditingController prodPriceController = TextEditingController();
  final TextEditingController prodQuantityController = TextEditingController();
  final TextEditingController prodNameController = TextEditingController();
   final TextEditingController prodIdController = TextEditingController();
  

  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _Catagory = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  List<Map<String, dynamic>> cart = [];
  List<Map<String,dynamic>> _order = [];
   
  Map<String, dynamic>? _selectedCustomer;
  Map<String, dynamic>? _selectedProduct;

  int? _nextOrder_ID;



  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<int?> fetchData() async {
    try {
      var response = await ProductDataFromServer("fetch_product", {});
      var cat_response = await CatagoryDataFromServer("fetch_catagory", {});
      var cust_response = await CustomerDataFromServer("fetch_data", {});
      if (response["success"] == true && cat_response['success'] == true && cust_response['success'] == true) {
        setState(() {
          _products = List<Map<String, dynamic>>.from(response["data"]);
          _customers = List<Map<String, dynamic>>.from(cust_response["data"]);
          _Catagory = List<Map<String, dynamic>>.from(cat_response["data"]);
          _filteredProducts = List.from(_products);});
         

  int? _currentOrder_ID= await fetchOrderId();
   if (_currentOrder_ID != Null) {
    setState(() {
            _nextOrder_ID = _currentOrder_ID + 1;
          });
  
    return _nextOrder_ID  ;
    // Use the nextOrderId as needed
    };
          
        
      } else {
        print('Failed to load ');
      }
    } catch (e) {
      print('Error fetching : $e');
    }
  
  }

  
  
  
Future<void> insert_order() async {
  if (prodNameController.text.isEmpty || prodQuantityController.text.isEmpty || customerNameController.text.isEmpty) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Please fill the required fields.'),
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

  double? price = double.tryParse(prodPriceController.text);
  int? quantity = int.tryParse(prodQuantityController.text);

  if (price == null || quantity == null) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Invalid price or quantity. Please enter valid values.'),
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

  double sub_total = price * quantity;

  try {
    var data = {
      "action": "add_order",
      "Order_ID":_nextOrder_ID.toString(),
      "prod_ID": prodIdController.text,
      "sub_total": sub_total.toString(),
      "quantity": prodQuantityController.text,
    };

    var response = await OrderDataFromServer("add_order", data);
    print(response);

    if (response["success"] == true) {
       
      await fetchOrders();
      
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to add order. Please try again.'),
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
    print('Error: $e');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('An unexpected error occurred. Please try again.'),
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

void clear_all(){
  prodNameController.clear();
  prodPriceController.clear();
  prodQuantityController.clear();
  customerNameController.clear();
  customeradddressController.clear();
  customeremailController.clear();
  customerphoneController.clear();
  prodCategaryController.clear();
  

}

Future<int> fetchOrderId() async {
  

  var data = {
    "action": "fetch_orderId",
  };

  try {
    var response = await OrderDataFromServer("fetch_orderId", data);
  
    print(response);
    if (response['success']) {
      int orderId = int.parse(response['Order_ID']);
      return orderId ;
    } else {
      print('Failed to fetch order ID: ${response['message']}');
      return 0;
    }
  } catch (e) {
    print('Error fetching order ID: $e');
    return 0;
  }
}
Future<void> fetchOrders() async {
  
  try {
    var data = {
      "action": "fetch_order",
      "Order_ID": _nextOrder_ID.toString(),
    };

    var response = await OrderDataFromServer("fetch_order", data);
    if (response["success"] == true) {
      setState(() {
        _order = List<Map<String, dynamic>>.from(response["data"]);
        print(_order);
      });
      
    } else {
      print('Failed to load orders');
    }
  } catch (e) {
    print('Error fetching orders: $e');
  }
}


void deleteOrder(String prodId) async {
  
  print(prodId);
  try {
    // Perform update operation
    var data = {
      "action": "delete_order",
      "Order_ID": _nextOrder_ID.toString(),
      "prod_ID": prodId,
      
      // Add other parameters as needed for update
    };

    var response = await OrderDataFromServer("delete_order", data);


    if (response["success"] == true) {
      // Refresh order list after update
      await fetchOrders();
     
      print(_order);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Order updated successfully.'),
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
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to update order. Please try again.'),
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
    print('Error updating order: $e');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('An unexpected error occurred. Please try again.'),
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

double calculateTotalBill() {
  double totalBill = 0.0;
  for (var order in _order) {
    totalBill += double.tryParse(order['sub_total'].toString()) ?? 0.0;
  }
  return totalBill;
}

Future<void> insertViewOrder() async {
  double totalBill = calculateTotalBill();
  
 
  try{
    print(customerIDController.text);
    print(_nextOrder_ID);



  var data = {
    "action": "confirm_order",
    "Order_ID": _nextOrder_ID.toString(),
    "Cust_ID": customerIDController.text.toString(),
    "total_amt": totalBill.toString(),
    
  };

  var response = await OrderDataFromServer("confirm_order", data);
 print(response);
  if (response["success"] == true) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('success'),
          content: Text('Order Confirmed!'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                pop_out();
              },
            ),
          ],
        );
      },
    );
  } else {
    // Handle failure
   showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Failed to add Order !'),
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
}catch(e){
  print(e);
} }


void pop_out(){
  Navigator.pop(context);
}






  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Manage Order'),
      backgroundColor: Colors.blue, // Setting app bar background color to blue
    ),
    body:Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://static.vecteezy.com/system/resources/previews/004/697/690/non_2x/blue-white-shapes-background-abstract-with-halftone-free-vector.jpg'), // Replace with your image URL
                fit: BoxFit.cover,
              ),
            ),
          ), Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section for Customer Details
                  Text(
                    'Customer',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  DropdownButtonFormField<Map<String, dynamic>>(
                    value: _selectedCustomer,
                    onChanged: (customer) {
                      setState(() {
                        _selectedCustomer = customer;
                        customerNameController.text = customer?['Cust_name'] ?? '';
                        customeremailController.text = customer?['email'] ?? '';
                        customerphoneController.text = customer?['ph_num']?.toString() ?? '';
                        customeradddressController.text = customer?['address'] ?? '';
                        customerIDController.text = customer?['Cust_ID'] ?? '';
                      });
                    },
                    items: _customers.map<DropdownMenuItem<Map<String, dynamic>>>((customer) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: customer,
                        child: Text(customer['Cust_name'] ?? ''),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Select Customer',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: customerNameController,
                    decoration: InputDecoration(
                      labelText: 'Customer Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: customeremailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: customerphoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: customeradddressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section for Product Selection
                  Text(
                    'Products',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  DropdownButtonFormField<Map<String, dynamic>>(
                    value: _selectedProduct,
                    onChanged: (product) {
                      setState(() {
                        _selectedProduct = product;
                        prodIdController.text = product?['prod_ID'] ?? '';
                        prodNameController.text = product?['prod_name'] ?? '';
                        prodPriceController.text = product?['price']?.toString() ?? '';
                        var catagory_ID = product?['catagory_ID'] ?? '';
                        prodCategaryController.text = _Catagory.firstWhere(
                          (cat) => cat['catagory_ID'] == catagory_ID,
                        )['catagory_name'];
                      });
                    },
                    items: _filteredProducts.map<DropdownMenuItem<Map<String, dynamic>>>((product) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: product,
                        child: Text(product['prod_name'] ?? ''),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Select Product',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: prodNameController,
                    decoration: InputDecoration(
                      labelText: 'Product Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: prodPriceController,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: prodCategaryController,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: prodQuantityController,
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: insert_order,
                    child: Text('Place Order'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 141, 196, 241), // Button color
                      textStyle: TextStyle(color: Colors.white), // Text color
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section for Order Summary
                  Text(
                    'Order ID: ${_nextOrder_ID}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _order.length,
                      itemBuilder: (context, index) {
                        String prodId = _order[index]['prod_ID'].toString();
                        String prodName = _products.firstWhere(
                          (prod) => prod['prod_ID'].toString() == prodId,
                        )['prod_name']; // Fetch product name based on prodId
                        String cat_ID = _products.firstWhere(
                          (prod) => prod['prod_ID'].toString() == prodId,
                        )['catagory_ID'];
                        String category = _Catagory.firstWhere(
                          (cat) => cat['catagory_ID'].toString() == cat_ID,
                        )['catagory_name']; // Fetch category name based on prodId

                        return ListTile(
                          title: Text('Product ID: $prodId'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Product Name: $prodName'),
                              Text('Category: $category'),
                              Text('Quantity: ${_order[index]['quantity'].toString()}'),
                              Text('Subtotal: ${_order[index]['sub_total'].toString()}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              deleteOrder(_order[index]['prod_ID'].toString());
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: insertViewOrder,
                    child: Text('Confirm Order'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 125, 187, 237), // Button color
                      textStyle: TextStyle(color: Colors.white), // Text color
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  ],),);
}
}