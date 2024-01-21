import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unibookwebpanel/view/adminpanel/user_reports.dart';

class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  int _selectedIndex = 0;

  List<String> _pages = ["Page 1", "Page 2", "Page 3", "Page 4"];
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pages[_selectedIndex]),
      ),
      body: Row(
        children: [
          // Side Navigation Panel
          NavigationPanel(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
                _pageController.animateToPage(index,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut);
              });
            },
          ),
          // Content Area
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              itemBuilder: (context, index) {
                // Display UserPage when Page 2 is selected
                if (index == 0) {
                  return UserConfirmationListPage();
                }
                // Display UserPage when Page 2 is selected
                else if (index == 1) {
                  return UserPage();
                } else if (index == 2) {
                  return ReportPage();
                }
                // Display other pages
                return Center(
                  child: Text(
                    _pages[index],
                    style: TextStyle(fontSize: 24),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class NavigationPanel extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  NavigationPanel({required this.selectedIndex, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: Colors.grey[200],
      child: ListView.builder(
        itemCount: 4,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text("Page ${index + 1}"),
            selected: index == selectedIndex,
            onTap: () => onItemSelected(index),
          );
        },
      ),
    );
  }
}

class UserConfirmationListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users with isConfirmed = 0'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .where('isConfirmed', isEqualTo: 0)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Text('No users with isConfirmed = 0');
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var user = snapshot.data!.docs[index];
              var name = user['name'];
              var email = user['email'];
              var imageUrl = user[
                  'student card']; // Assuming 'imageUrl' is the field holding the image URL

              return ListTile(
                title: Text(name),
                subtitle: Text(email),
                leading: Image.network(
                  imageUrl,
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    // Call a function to update isConfirmed to 1
                    confirmUser(user.id);
                  },
                  child: Text('Onayla'),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> confirmUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('Users').doc(userId).update({
        'isConfirmed': 1,
      });
      print('User confirmed successfully');
    } catch (e) {
      print('Error confirming user: $e');
    }
  }
}

class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Users'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No users available'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              User user = User.fromSnapshot(snapshot.data!.docs[index]);
              return ListTile(
                title: Text(user.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email: ${user.email}'),
                    Text('Phone: ${user.phone}'),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    _banUser(user);
                  },
                  child: Text("Ban"),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _banUser(User user) async {
    try {
      // Move user's information to "BannedUsers" collection
      await FirebaseFirestore.instance
          .collection('BannedUsers')
          .doc(user.uid)
          .set({
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        // Add other fields as needed
      });

      // Delete user's information from "Users" collection
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .delete();

      // Delete books associated with the banned user from "Books" collection
      QuerySnapshot booksSnapshot = await FirebaseFirestore.instance
          .collection('books')
          .where('user_uid', isEqualTo: user.uid)
          .get();

      for (QueryDocumentSnapshot bookDoc in booksSnapshot.docs) {
        await FirebaseFirestore.instance
            .collection('books')
            .doc(bookDoc.id)
            .delete();
      }
    } catch (e) {
      print('Error banning user: $e');
      // Handle error appropriately
    }
  }
}

class User {
  final String uid;
  final String name;
  final String email;
  final String phone;

  User({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
  });

  // Create a factory constructor to easily create User instances from a DocumentSnapshot
  factory User.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return User(
      uid: snapshot.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
    );
  }
}
