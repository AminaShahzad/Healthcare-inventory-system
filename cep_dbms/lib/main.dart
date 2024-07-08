import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'api_file.dart';


void main() {
  runApp(HealthCareInventoryApp());
}

class HealthCareInventoryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Care Inventory System',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController login_ID = TextEditingController();
  final TextEditingController password = TextEditingController();


  Future<void> login(BuildContext context, TextEditingController login_ID, TextEditingController password) async {
  print("Yes, here we are");
  String loginId = login_ID.text;
  String pass = password.text;

  if (loginId.isNotEmpty && pass.isNotEmpty) {
    try {
      var data = {
        "login_ID": loginId,
        "password": pass,
      };
      var response = await postDataToServer("login", data);
      print(response);

      if (response["success"] == true) {
        print("Login successful");
        login_ID.clear();
        password.clear();
         String userType = response["user_type"];
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(userType: userType)), // Adjust this according to your project structure
        );
      } else {
        // Show an error message
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Wrong credentials. Please try again.'),
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
      print(e);
    }
  } else {
    print("Please fill all fields!");
  }
}

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Text(
            'Health Care Inventory System',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.normal,
              
            ),
          ),
        ),
        centerTitle: true,
     backgroundColor: Color.fromARGB(255, 51, 155, 240), ),
      body:Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://proclouddevelopment.com.au/medical/wp-content/uploads/2019/01/slidermask-right-blue.png'), // Replace with your image URL
                fit: BoxFit.cover,
              ),
            ),
          ),Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.width * 0.3,
                color: Colors.grey[300],
                child: Image.network(
                  'https://th.bing.com/th/id/OIP.KLKgGkyDWRfPfmedrxbhBgHaEK?w=1280&h=720&rs=1&pid=ImgDetMain',
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: login_ID,
                      decoration: InputDecoration(
                        labelText: 'Login ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: password,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => login(context, login_ID, password),
                      child: Text('Login'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ],),);
  }
}
