import 'package:flutter/material.dart';
import 'package:flutter_application_3/database_helper.dart';
import 'package:flutter_application_3/two_factor_code.dart';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';

class ExportScreen extends StatelessWidget {
  Future<String> _exportCodes() async {
    final codes = await DatabaseHelper.instance.getAllCodes();
    final List<Map<String, dynamic>> codeMaps = codes.map((code) => {
      'website': code.website,
      'email': code.email,
      'secret': code.secret,
      'color': code.color.value,
    }).toList();

    return jsonEncode(codeMaps);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export 2FA Codes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.lock, size: 60, color: Colors.blueAccent),
            const SizedBox(height: 20),
            const Text(
              'Export Your 2FA Codes',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'This will generate a JSON file containing your saved 2FA codes including secrets, websites, and email associations. You can use this file to import or back up your codes.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.redAccent),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.red),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '⚠️ Exported 2FA secrets are sensitive. Do not share or store them in insecure places!',
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.share),
              label: const Text('Export and Share'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
              ),
              onPressed: () async {
                try {
                  final exportData = await _exportCodes();
                  await Share.share(exportData, subject: 'Exported 2FA Codes');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to export: $e')),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
