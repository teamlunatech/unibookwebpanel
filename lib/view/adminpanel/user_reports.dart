import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unibookwebpanel/view/admin_panel.dart';

class Report {
  final String reportText;
  final String reportedUserUid;
  final String reportUid;
  final Timestamp timestamp;

  Report({
    required this.reportText,
    required this.reportedUserUid,
    required this.reportUid,
    required this.timestamp,
  });
}

class ReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Raporlar'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Reports').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No reports available'));
          }

          List<Report> reports = snapshot.data!.docs
              .map((doc) => Report(
                    reportText: doc['reportText'],
                    reportedUserUid: doc['reportedUserUid'],
                    reportUid: doc['reporterUid'],
                    timestamp: doc['timestamp'],
                  ))
              .toList();

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              return _buildReportTile(context, reports[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildReportTile(BuildContext context, Report report) {
    return FutureBuilder<User?>(
      // Fetch the reported user's information
      future: _getUserInfo(report.reportedUserUid),
      builder: (context, reportedUserSnapshot) {
        if (reportedUserSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (reportedUserSnapshot.hasError) {
          return Center(child: Text('Error: ${reportedUserSnapshot.error}'));
        }

        User? reportedUser = reportedUserSnapshot.data;

        return FutureBuilder<User?>(
          // Fetch the reporter user's information
          future: _getUserInfo(report.reportUid),
          builder: (context, reporterUserSnapshot) {
            if (reporterUserSnapshot.connectionState ==
                ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (reporterUserSnapshot.hasError) {
              return Center(
                  child: Text('Error: ${reporterUserSnapshot.error}'));
            }

            User? reporterUser = reporterUserSnapshot.data;

            return ListTile(
              title: Text('Reported by: ${reporterUser?.name ?? 'Unknown'}'),
              subtitle:
                  Text('Reported user: ${reportedUser?.name ?? 'Unknown'}'),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Text: ${report.reportText}'),
                  Text('Timestamp: ${_formatTimestamp(report.timestamp)}'),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<User?> _getUserInfo(String uid) async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();

      if (userSnapshot.exists) {
        return User.fromSnapshot(userSnapshot);
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting user info: $e');
      return null;
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    // Format timestamp as needed (e.g., using DateFormat from the intl package)
    // This is just a placeholder, adjust according to your requirements.
    return timestamp.toDate().toString();
  }
}
