import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/about_page.dart';
import 'package:flutter_application_3/auth_screen.dart';
import 'package:flutter_application_3/export_screen.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'two_factor_code.dart';
import 'edit_screen.dart';
import 'totp_generator.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late ValueNotifier<int> _secondsRemaining;
  late ValueNotifier<double> _progress;
  late ValueNotifier<DateTime> _tick;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = ValueNotifier<int>(30);
    _progress = ValueNotifier<double>(1.0);
    _tick = ValueNotifier(DateTime.now());
    _startTimer();
  }

  void _startTimer() {
    _updateProgress();
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      _updateProgress();
    });
  }

  void _updateProgress() {
    final now = DateTime.now();
    final second = now.second;
    final milli = now.millisecond;
    final totalMillis = (second % 30) * 1000 + milli;
    final remaining = 30000 - totalMillis;

    _secondsRemaining.value = (remaining / 1000).floor();
    _progress.value = remaining / 30000;

    if (second % 30 == 0 && milli < 120) {
      // Trigger update only once per new cycle
      _tick.value = DateTime.now();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _secondsRemaining.dispose();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('2FA Codes'),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutPage()),
              );
            },
            tooltip: 'About',
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ExportScreen()),
              );
            },
            tooltip: 'Export Codes',
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => AuthScreen()),
              );
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEditScreen(context),
        child: Icon(Icons.add),
        tooltip: 'Add new 2FA code',
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      body: FutureBuilder<List<TwoFactorCode>>(
        future: DatabaseHelper.instance.getAllCodes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading codes'));
          }

          final codes = snapshot.data ?? [];

          if (codes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_clock, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No 2FA codes found'),
                  SizedBox(height: 8),
                  Text(
                    'Tap the + button to add a new code',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: 100),
              itemCount: codes.length,
              itemBuilder: (context, index) {
                final code = codes[index];
                return ValueListenableBuilder<DateTime>(
                  valueListenable: _tick,
                  builder: (context, time, _) {
                    final totp = TOTPGenerator.generate(code.secret);

                    return Dismissible(
                      key: Key(code.id.toString()),
                      background: Container(color: Colors.red),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: Text('Delete Code'),
                                content: Text(
                                  'Are you sure you want to delete ${code.website}?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                        );
                      },
                      onDismissed: (direction) async {
                        await DatabaseHelper.instance.deleteCode(code.id!);
                        setState(() {});
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: code.color,
                          child: Text(
                            code.website.isNotEmpty ? code.website[0] : '?',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(code.website),
                        subtitle: Text(code.email),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              totp,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            SizedBox(width: 12),
                            ValueListenableBuilder<int>(
                              valueListenable: _secondsRemaining,
                              builder: (context, seconds, _) {
                                return Text(
                                  '$seconds s',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                            SizedBox(width: 8),
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: ValueListenableBuilder<double>(
                                valueListenable: _progress,
                                builder: (context, progress, _) {
                                  return CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: 2,
                                    backgroundColor: Colors.grey.shade300,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).primaryColor,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        onTap: () => _navigateToEditScreen(context, code),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _navigateToEditScreen(
    BuildContext context, [
    TwoFactorCode? code,
  ]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditScreen(code: code)),
    );
    setState(() {});
  }
}
