import 'package:flutter/material.dart';
import 'api_file.dart';
class ViewOrderScreen extends StatefulWidget {
  @override
  _ViewOrderScreenState createState() => _ViewOrderScreenState();
}

class _ViewOrderScreenState extends State<ViewOrderScreen> {
  late Future<List<ViewOrder>> futureViewOrders;
  List<Map<String, dynamic>> _customers = [];

  Future<List<ViewOrder>> fetchViewOrders() async {
    var data = {
      "action": "fetch_view_orders"
    };

    var response = await ViewOrderDataFromServer("fetch_view_orders", data);
    var cust_response = await CustomerDataFromServer("fetch_data", {});
    if (response["success"] == true) {
      _customers = List<Map<String, dynamic>>.from(cust_response["data"]);
      List<ViewOrder> viewOrders = [];
      for (var order in response["data"]) {
        viewOrders.add(ViewOrder.fromJson(order, _customers));
      }
      return viewOrders;
    } else {
      throw Exception('Failed to load view orders');
    }
  }

  @override
  void initState() {
    super.initState();
    futureViewOrders = fetchViewOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Orders'),backgroundColor: Colors.blue,
      ),
      body:Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://th.bing.com/th/id/R.84d189329245b0db97f707f2d1916fe1?rik=8nda9RzPnhimCA&riu=http%3a%2f%2fclipart-library.com%2fimages%2fLcdjMKEgi.jpg&ehk=aL%2f1%2fKAfUEf3rSv4XgjXcxUFeUvsshVMOXwtF5sFcMk%3d&risl=&pid=ImgRaw&r=0'), // Replace with your image URL
                fit: BoxFit.cover,
              ),
            ),
          ),  FutureBuilder<List<ViewOrder>>(
        future: futureViewOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No orders found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                ViewOrder order = snapshot.data![index];
                return ListTile(
                  title: Text('Order ID: ${order.orderID}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Customer Name: ${order.customerName}'), // Adjusted to use customer name
                      Text('Total Amount: ${order.totalAmt}'),
                      Text('Date: ${order.date}'),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
   ], ),);
  }
}

class ViewOrder {
  final String orderID;
  final String custID;
  final String totalAmt;
  final String date;
  late String customerName; // Define customerName as late

  ViewOrder({required this.orderID, required this.custID, required this.totalAmt, required this.date});

  factory ViewOrder.fromJson(Map<String, dynamic> json, List<Map<String, dynamic>> customers) {
    var customer = customers.firstWhere(
      (cust) => cust['Cust_ID'].toString() == json['Cust_ID'].toString(),
      orElse: () => {'Cust_name': 'Unknown'} // Default to 'Unknown' if customer not found
    );
    
    return ViewOrder(
      orderID: json['Order_ID'].toString(),
      custID: json['Cust_ID'].toString(),
      totalAmt: json['total_amt'].toString(),
      date: json['date'].toString(),
    )..customerName = customer['Cust_name'].toString(); // Assign customer name after object creation
  }
}
