
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '2FA Authenticator',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Purpose:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'The 2FA Authenticator app is designed to enhance security by generating time-based one-time passwords (TOTP) for two-factor authentication.',
            ),
            SizedBox(height: 16),
            Text(
              'Author:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('Oleksander'),
            SizedBox(height: 16),
            Text(
              'Creation Date:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('May 19, 2025'),
            SizedBox(height: 16),
            Text(
              'License:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('MIT License'),
          ],
        ),
      ),
    );
  }
}
