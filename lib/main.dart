import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  _FirestoreListenerPageState createState() =>
      _FirestoreListenerPageState();
}

class _FirestoreListenerPageState extends State<FirestoreListenerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Server App - Real-Time Updates')),
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

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(data['name'] ?? 'No Name'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${data['email'] ?? 'No Email'}'),
                      Text('Message: ${data['message'] ?? 'No Message'}'),
                    ],
                  ),
                  trailing: Text(data['timestamp']?.toDate().toString() ?? ''),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
