import 'package:flutter/material.dart';
import 'package:lembarpena/Main/screens/menu.dart';
import 'package:lembarpena/bookforum/screens/forum_page.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:lembarpena/checkoutbook/models/checkout.dart';
import 'package:lembarpena/wishlist/screens/explore_book.dart';
import 'package:lembarpena/config.dart';

class MyOrderPage extends StatefulWidget {
  const MyOrderPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyOrderPageState createState() => _MyOrderPageState();
}

class _MyOrderPageState extends State<MyOrderPage> {
  late Future<List<Checkoutbook>> futureOrder;
  @override
  void initState() {
    super.initState();
    futureOrder = fetchOrder();
  }

  Future<List<Checkoutbook>> fetchOrder() async {
    // Sent through CookieRequest so the session cookie identifies the user;
    // the backend only returns that user's orders.
    final request = context.read<CookieRequest>();
    var data = await request.get('$baseUrl/checkoutbook/get_order_json_all/');
    if (data is! List) {
      throw Exception(data['message'] ?? 'Gagal memuat pesanan.');
    }

    List<Checkoutbook> fetchedOrder = [];
    for (var item in data) {
      fetchedOrder.add(Checkoutbook.fromJson(item));
    }
    return fetchedOrder;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Saya'),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Checkoutbook>>(
          future: futureOrder,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.data == null || snapshot.data!.isEmpty) {
              return const Center(child: Text('Anda belum memesan apapun!'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Checkoutbook order = snapshot.data![index];
                  return Card(
                    elevation: 2.0,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text("Checkout $index"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Alamat: ${order.fields.alamat}"),
                          Text(
                              "Metode Pembayaran: ${order.fields.metodePembayaran}"),
                          Text(
                              "Total Price: SAR ${order.fields.totalPrice.toStringAsFixed(2)}"),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        // currentIndex: 2,
        backgroundColor: Colors.indigo,
        selectedItemColor: const Color.fromARGB(255, 156, 143, 255),
        unselectedItemColor: const Color.fromARGB(255, 156, 143, 255),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Explore Book',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: 'Book Forum',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => MyHomePage(),
                  transitionDuration: Duration.zero,
                ),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const ExploreBooksPage(),
                  transitionDuration: Duration.zero,
                ),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const ForumPage(),
                  transitionDuration: Duration.zero,
                ),
              );
              break;
          }
        },
      ),
    );
  }
}
