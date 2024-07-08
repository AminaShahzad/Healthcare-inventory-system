import 'package:flutter/material.dart';
import 'manage_User.dart';
import 'manage_catagory.dart';
import 'manage_prod.dart';
import 'manage_order.dart';
import 'manage_customer.dart';
import 'view_order.dart';


class HomeScreen extends StatefulWidget {
  final String userType;

  HomeScreen({required this.userType});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Image.network(
            'https://thumbs.dreamstime.com/z/diagnostic-first-aid-items-laid-out-light-blue-background-diagnostic-first-aid-items-laid-out-blue-background-120370468.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue.shade600, Colors.blue.shade900],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Welcome to Healthcare System!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.userType == 'admin')
                          DecoratedButtonWithIcon(
                            label: 'User',
                            icon: Icons.person,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return UserManagementBox();
                                },
                              );
                            },
                          ),
                        DecoratedButtonWithIcon(
                          label: 'Category',
                          icon: Icons.category,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CatagoryManagementBox();
                              },
                            );
                          },
                        ),
                        DecoratedButtonWithIcon(
                          label: 'Product',
                          icon: Icons.local_offer,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return ProductManagementBox();
                              },
                            );
                          },
                        ),
                        DecoratedButtonWithIcon(
                          label: 'Order',
                          icon: Icons.shopping_cart,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => OrderScreen()),
                            );
                          },
                        ),
                        DecoratedButtonWithIcon(
                          label: 'View Order',
                          icon: Icons.view_list,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ViewOrderScreen()),
                            );
                          },
                        ),
                        DecoratedButtonWithIcon(
                          label: 'Customer',
                          icon: Icons.people,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CustomerScreen()),
                            );
                          },
                        ),
                        DecoratedButtonWithIcon(
                          label: 'Logout',
                          icon: Icons.logout,
                          onPressed: () {
                            Navigator.pop(context); // Navigate back to login screen
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DecoratedButtonWithIcon extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const DecoratedButtonWithIcon({
    Key? key,
    required this.label,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade500, Colors.blue.shade700],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 3,
              offset: Offset(1, 2),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 24, color: Colors.white),
          label: Text(
            label,
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(250, 50),
            padding: EdgeInsets.all(16.0),
            textStyle: TextStyle(fontSize: 18),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
