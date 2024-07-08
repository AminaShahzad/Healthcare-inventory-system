import 'package:flutter/material.dart';
import 'api_file.dart';

class UserManagementBox extends StatefulWidget {
  @override
  _UserManagementBoxState createState() => _UserManagementBoxState();
}

class _UserManagementBoxState extends State<UserManagementBox> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _loginIdController = TextEditingController();
  final _passwordController = TextEditingController();
  String _status = 'Active';

 List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  TextEditingController _searchController = TextEditingController();


 final nameRegExp = RegExp(r'^[a-zA-Z\s]+$');
final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
final intRegExp = RegExp(r'^[0-9]+$');

bool check_values(BuildContext context, String name, String email, String address, String login_ID, String ph_num) {
  if (!nameRegExp.hasMatch(name) ||
      !emailRegExp.hasMatch(email) ||
      !nameRegExp.hasMatch(address) ||
      !intRegExp.hasMatch(login_ID) ||
      !intRegExp.hasMatch(ph_num)) {
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
    _fetchUsers();
    _searchController.addListener(_filterUsers);
  }

 Future<void> _fetchUsers() async {
    try {
      var response = await postDataToServer("fetch_data", {});
      if (response["success"] == true) {
        setState(() {
          _users = List<Map<String, dynamic>>.from(response["data"]);
          _filteredUsers = List.from(_users);
        });
      } else {
        print('Failed to load users');
      }
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

void _filterUsers() {
    setState(() {
      String query = _searchController.text.toLowerCase();
      _filteredUsers = _users
          .where((user) => user['Name'].toLowerCase().contains(query))
          .toList();
    });
  }

 
      




  // Show dialog to update user information
  void showUpdateDialog(Map<String, dynamic> user) {
  _nameController.text = user['Name'] ?? '';
  _addressController.text = user['Address'] ?? '';
  _emailController.text = user['Email'] ?? '';
  _phoneNumberController.text = user['ph_num'] ?? '';
  _passwordController.text=user['password'] ?? '';
  _loginIdController.text = user['login_ID'] ?? '';
   _status = user['Status'] ?? 'Active'; // Set a default status if null

  if (!['Active', 'Inactive'].contains(_status)) {
    _status = 'Active'; // Default to 'Active' if status is invalid
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Update User'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: 'Phone Number'),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _loginIdController,
                decoration: InputDecoration(labelText: 'Login ID'),enabled: false,
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _status,
                items: ['Active', 'Inactive']
                    .map((value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () async {
              _saveUser();
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: Text('Update'),
            onPressed: () async {
              await updateUser();
              Navigator.of(context).pop();
            },
          ), // Adjust the width as needed
                ElevatedButton(
                  onPressed:() async{ await delete();
                  Navigator.of(context).pop();},
                  child: Text('Delete'),
                ),
        ],
      );
    },
  );
}

Future<void> updateUser() async {
  try {
    var data = {
      "action": "update_user",
      "login_ID": _loginIdController.text,
      "password": _passwordController.text,
      "email": _emailController.text,
      "ph_num": _phoneNumberController.text,
      "status": _status,
      "address": _addressController.text,
      "name": _nameController.text,
    };
    if(check_values(context, _nameController.text, _emailController.text, _addressController.text, _loginIdController.text, _phoneNumberController.text)){
      return;
    }
    var response = await postDataToServer("update_user", data);
    print(response);

    if (response["success"] == true) {
      _saveUser(); // Example method to save user data locally
      _fetchUsers(); // Example method to fetch updated user list
      
    } else {
      showErrorDialog('Failed to update user. Please try again.');
    }
  } catch (e) {
    print('Error updating user: $e');
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




  void _saveUser() {
    if (_formKey.currentState!.validate()) {
      _nameController.clear();
      _addressController.clear();
      _emailController.clear();
      _phoneNumberController.clear();
      _loginIdController.clear();
      _passwordController.clear();
      setState(() {
        _status = 'Active';
      });
    }
  }

  Future<void> insert() async {
    String name = _nameController.text;
    String address = _addressController.text;
    String email = _emailController.text;
    String ph_num = _phoneNumberController.text;
    String login_ID = _loginIdController.text;
    String password = _passwordController.text;
    final status = _status;

    if (name.isEmpty ||
        address.isEmpty ||
        login_ID.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
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
    if(check_values(context, name, email, address, login_ID, ph_num)){
      print("gduerwn");
      return;

    }
    try {
      var data = {
        "action": "add_user",
        "login_ID": login_ID,
        "password": password,
        "email": email,
        "ph_num": ph_num,
        "status": status,
        "address": address,
        "name": name
      };
      
      var response = await postDataToServer("add_user", data);
      print(response);

      if (response["success"] == true) {
        _saveUser(); // Example method to save user data locally
        _fetchUsers(); // Example method to fetch updated user list
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Failed to add user. Please try again.'),
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
      print('Error adding user: $e');
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
   Future<void> delete() async {
    String login_ID = _loginIdController.text;
    String password = _passwordController.text;

    if (login_ID.isNotEmpty && password.isNotEmpty) {
      try {
        var data = {
          "action": "delete",
          "login_ID": login_ID,
          "password": password,
        };
        
        var response = await postDataToServer("delete", data);
        print("Response body: $response"); // Print raw response for debugging

        if (response["success"] == true) {
          print("Deleted successfully");
          _saveUser(); // Example method to save user data locally
          _fetchUsers(); // Example method to fetch updated user list
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("User deleted successfully"),
              duration: Duration(seconds: 2),
            ),
          );

          // Clear text fields after 2 seconds
          Future.delayed(Duration(seconds: 2), () {
            _loginIdController.clear();
            _passwordController.clear();
          });
        } else {
          print("Delete failed: ${response['message'] ?? 'Unknown error'}");
          // Show error message to user
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('Failed to delete user. Please try again.'),
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
      print("Login ID and password cannot be empty");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login ID and password cannot be empty")),
      );
    }
  }

@override
Widget build(BuildContext context) {
  return  Theme(
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
    ),child:AlertDialog(
    title: Text('Manage User', style: TextStyle(color: Colors.blue)),
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
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    ),
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
                            DataColumn(label: Text('User_ID')),
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Phone Number')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Address')),
                          ],
                          rows: _filteredUsers.map<DataRow>((user) {
                            return DataRow(
                              cells: [
                                DataCell(IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    showUpdateDialog(user);
                                  },
                                )),
                                DataCell(Text(user['Name'] ?? '')),
                                DataCell(Text(user['login_ID'] ?? '')),
                                DataCell(Text(user['Email'] ?? '')),
                                DataCell(Text(user['ph_num'] ?? '')),
                                DataCell(Text(user['Status'] ?? '')),
                                DataCell(Text(user['Address'] ?? '')),
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
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _phoneNumberController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a phone number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _loginIdController,
                        decoration: InputDecoration(
                          labelText: 'Login ID',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a login ID';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _status,
                        items: ['Active', 'Inactive']
                            .map((value) => DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _status = value!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: insert,
                            child: Text('Save'),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Color.fromARGB(255, 132, 195, 246)),
                            ),
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
    backgroundColor: Colors.white,
    elevation: 4.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
  ),);
}
}