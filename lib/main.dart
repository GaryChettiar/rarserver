import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';  // Import url_launcher

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ServerApp());
}

class ServerApp extends StatelessWidget {
  const ServerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FirestoreListenerPage(),
    );
  }
}

class FirestoreListenerPage extends StatefulWidget {
  @override
  _FirestoreListenerPageState createState() => _FirestoreListenerPageState();
}

class _FirestoreListenerPageState extends State<FirestoreListenerPage> {
  // Function to launch Google Maps with the given latitude and longitude
  Future<void> _openGoogleMaps(double latitude, double longitude) async {
    final url = 'https://www.google.com/maps?q=$latitude,$longitude';
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri); // Launch the Google Maps URL
    } else {
      throw 'Could not open the map.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Server App')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('formData')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              // Extract latitude and longitude
              final latitude = data['location']?['latitude'] ?? 0.0;
              final longitude = data['location']?['longitude'] ?? 0.0;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(data['name'] ?? 'No Name'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${data['email'] ?? 'No Email'}'),
                      Text('Message: ${data['message'] ?? 'No Message'}'),
                      Text('Latitude: $latitude'),
                      Text('Longitude: $longitude'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.map),
                    onPressed: () {
                      _openGoogleMaps(latitude, longitude);  // Open Google Maps
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
