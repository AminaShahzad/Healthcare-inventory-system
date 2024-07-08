import 'package:flutter/material.dart';
import 'api_file.dart'; // Assuming this file contains API functions




class CustomerScreen extends StatefulWidget {
  @override
  _CustomerScreenState createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phonenoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _filteredCustomers = [];




 final nameRegExp = RegExp(r'^[a-zA-Z\s]+$');
final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
final intRegExp = RegExp(r'^[0-9]+$');



bool check_values(BuildContext context, String name,String email,String address, String phone) {
  if (!nameRegExp.hasMatch(name)||!emailRegExp.hasMatch(email)||!nameRegExp.hasMatch(address)||!intRegExp.hasMatch(phone) 
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
    fetchCustomers();
  }

 
 Future<void> fetchCustomers() async {
    try {
      var response = await CustomerDataFromServer("fetch_data", {});
      print(response);
      if (response["success"] == true) {
        setState(() {
          _customers = List<Map<String, dynamic>>.from(response["data"]);
          _filteredCustomers = List.from(_customers);
        });
      } else {
        print('Failed to load customers');
      }
    } catch (e) {
      print('Error fetching customers: $e');
    }
  }





  void _filterCustomers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCustomers = List.from(_customers);
      } else {
        _filteredCustomers = _customers
            .where((customer) =>
                customer['Cust_name']
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                customer['ph_num']
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _showUpdateDialog(Map<String, dynamic> customer) {
    _nameController.text = customer['Cust_name'] ?? '';
    _emailController.text = customer['email'] ?? '';
    _phonenoController.text = customer['ph_num'] ?? '';
    _addressController.text = customer['address'] ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Customer'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _phonenoController,
                  decoration: InputDecoration(labelText: 'Phone No'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: 'Address'),
                ),
                SizedBox(height: 10),
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
                await _updateCustomer(customer);
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Delete'),
              onPressed: () async {
                await _deleteCustomer(customer);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateCustomer(Map<String, dynamic> customer) async {
     String customer_ID= customer['Cust_ID'];
     if (check_values(context, _nameController.text, _emailController.text, _addressController.text, _phonenoController.text)){
      return;
     }
    try {
      var data = {
        "action": "update_customer",
        "Cust_ID": customer_ID,
        "ph_num": _phonenoController.text,
        "Cust_name": _nameController.text,
        "email": _emailController.text,
        "address": _addressController.text,
      };

      var response = await CustomerDataFromServer("update_customer", data);
      if (response["success"] == true) {
        _clearInputFields();
        fetchCustomers();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Customer updated successfully"),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update customer. Please try again."),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error updating customer: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An unexpected error occurred. Please try again."),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteCustomer(Map<String, dynamic> customer) async {
    String cust_Id= customer['Cust_ID'];
    String ph_num = customer['ph_num'];
    try {
      var data = {
        "action": "delete",
        "Cust_ID": cust_Id,
        "ph_num": ph_num,
      };

      var response = await CustomerDataFromServer("delete", data);
      if (response["success"] == true) {
        _clearInputFields();
        fetchCustomers();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Customer deleted successfully"),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete customer. Please try again."),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error deleting customer: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An unexpected error occurred. Please try again."),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _addCustomer() async {
     if (_nameController.text.isEmpty || _addressController.text.isEmpty || _emailController.text.isEmpty || _phonenoController.text.isEmpty) {
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
  if(check_values(context, _nameController.text, _emailController.text, _addressController.text, _phonenoController.text)){
    return;
  }
    try {
      var data = {
        "action": "add_customer",
        "Cust_name": _nameController.text,
        "email": _emailController.text,
        "address": _addressController.text,
        "ph_num": _phonenoController.text,
      };

      var response = await CustomerDataFromServer("add_customer", data);
      if (response["success"] == true) {
        fetchCustomers();
        _showSuccessDialog();
        _clearInputFields();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to add customer. Please try again."),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error adding customer: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An unexpected error occurred. Please try again."),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Customer saved successfully'),
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

  void _clearInputFields() {
    _nameController.clear();
    _emailController.clear();
    _phonenoController.clear();
    _addressController.clear();
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
    ),child:Scaffold(
    appBar: AppBar(
      title: Text('Customer Management'),
    ),
    body: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Left Side - Customer List and Actions
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Phone')),
                            DataColumn(label: Text('Address')),
                          ],
                          rows: _filteredCustomers.map<DataRow>((customer) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      _showUpdateDialog(customer);
                                    },
                                  ),
                                ),
                                DataCell(Text(customer['Cust_name'] ?? '')),
                                DataCell(Text(customer['email']?.toString() ?? '')),
                                DataCell(Text(customer['ph_num']?.toString() ?? '')),
                                DataCell(Text(customer['address']?.toString() ?? '')),
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
        ),
        
        // Right Side - Add Customer Form
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Add New Customer',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _phonenoController,
                  decoration: InputDecoration(labelText: 'Phone No'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: 'Address'),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: _addCustomer,
                      child: Text('Save Customer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  ),);
}
}