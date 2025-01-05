import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart'; // Ensure url_launcher is imported

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  String filterType = 'all'; // 'all', 'accepted', 'pending'

  // Function to launch the PDF URL externally
  Future<void> _launchPDF(String fileUrl) async {
    try {
      await launchUrl(
        Uri.parse(fileUrl),
        mode: LaunchMode.externalApplication, // Open in an external app
      );
    } catch (e) {
      throw 'Could not open PDF file: $e';
    }
  }

  // Function to accept user and add a 'accepted' field
  Future<void> _acceptUser(BuildContext context, Map<String, dynamic> userData) async {
    try {
      // Show dialog with email and password for copying
      showDialog(
        context: context,
        barrierDismissible: true, // Allow closing the dialog by tapping outside
        builder: (context) {
          return AlertDialog(
            title: const Text("User Accepted"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Email: ${userData['email']}'),
                Text('Password: ${userData['password']}'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: userData['email']));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Email copied to clipboard')),
                    );
                  },
                  child: const Text('Copy Email'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: userData['password']));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password copied to clipboard')),
                    );
                  },
                  child: const Text('Copy Password'),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );

      // Update the 'teacher_requests' collection by adding an 'accepted' field
      await FirebaseFirestore.instance.collection('teacher_requests').doc(userData['id']).update({
        'accepted': true,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User accepted successfully. Email: ${userData['email']}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accepting user: $e')),
      );
    }
  }

  // Function to reject user and set 'accepted' field to false
  Future<void> _rejectUser(BuildContext context, String userId) async {
    try {
      await FirebaseFirestore.instance.collection('teacher_requests').doc(userId).update({
        'accepted': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User rejected successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error rejecting user: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
        backgroundColor: const Color(0xFF0096AB), // AppBar background color
        centerTitle: true,
        foregroundColor: Colors.white, // Title text color
      ),
      body: Column(
        children: [
          // Buttons to filter users
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Accept button
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      filterType = 'accepted';
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.orange; // Orange color when pressed
                      }
                      return filterType == 'accepted' ? Colors.orange : Colors.blue;
                    }),
                    padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 15, vertical: 10)),
                    textStyle: MaterialStateProperty.all(TextStyle(fontSize: 14, color: Colors.white)), // White text
                  ),
                  child: const Text('Accepted Users'),
                ),
                const SizedBox(width: 10),
                // Pending button
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      filterType = 'pending';
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.orange; // Orange color when pressed
                      }
                      return filterType == 'pending' ? Colors.orange : Colors.blue;
                    }),
                    padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 15, vertical: 10)),
                    textStyle: MaterialStateProperty.all(TextStyle(fontSize: 14, color: Colors.white)), // White text
                  ),
                  child: const Text('Pending Users'),
                ),
                const SizedBox(width: 10),
                // All button
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      filterType = 'all';
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.orange; // Orange color when pressed
                      }
                      return filterType == 'all' ? Colors.orange : Colors.blue;
                    }),
                    padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 15, vertical: 10)),
                    textStyle: MaterialStateProperty.all(TextStyle(fontSize: 14, color: Colors.white)), // White text
                  ),
                  child: const Text('All Requests'),
                ),
              ],
            ),
          ),
          // StreamBuilder to display filtered users based on filterType
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('teacher_requests')
                  .where('accepted', isEqualTo: filterType == 'all' ? null : filterType == 'accepted')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var users = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var user = users[index];
                    final fileUrl = user['cvUrl'] ?? ''; // Use empty string if cvUrl is missing
                    bool isAccepted = user['accepted'] ?? false;

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        title: Text(user['fullName']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${user['email']}'),
                            Text('Password: ${user['password']}'),
                            Text('Phone: ${user['phone']}'),
                            Text('Degree: ${user['degree']}'),
                          ],
                        ),
                        isThreeLine: true, // To allow for more space for data
                        contentPadding: const EdgeInsets.all(16.0),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // PDF button
                            IconButton(
                              icon: const Icon(Icons.picture_as_pdf, color: Colors.orange), // Orange color
                              onPressed: () async {
                                if (fileUrl.isNotEmpty) {
                                  try {
                                    await _launchPDF(fileUrl);
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Could not open PDF file: $e')),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('No CV available')),
                                  );
                                }
                              },
                            ),
                            // Only show Accept button if user is not accepted
                            if (!isAccepted)
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green), // Green color
                                onPressed: () async {
                                  var userData = {
                                    'email': user['email'],
                                    'full_name': user['fullName'],
                                    'password': user['password'],
                                    'phone': user['phone'],
                                    'id': user.id, // Add user ID to the data
                                  };
                                  await _acceptUser(context, userData);
                                },
                              ),
                            // Reject button
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red), // Red color
                              onPressed: () async {
                                await _rejectUser(context, user.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
