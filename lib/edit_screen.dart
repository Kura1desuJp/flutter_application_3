import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:base32/base32.dart';
import 'database_helper.dart';
import 'two_factor_code.dart';

class EditScreen extends StatefulWidget {
  final TwoFactorCode? code;

  EditScreen({this.code});

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late TextEditingController _websiteController;
  late TextEditingController _emailController;
  late TextEditingController _secretController;

  final _formKey = GlobalKey<FormState>();
  Color _selectedColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _websiteController = TextEditingController(text: widget.code?.website ?? '');
    _emailController = TextEditingController(text: widget.code?.email ?? '');
    _secretController = TextEditingController(text: widget.code?.secret ?? '');
    _selectedColor = widget.code?.color ?? Colors.blue;
    // If creating new code, generate initial secret
    if (widget.code == null) {
      _generateSecret();
    }
  }

  void _generateSecret() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    final secret = base32.encode(Uint8List.fromList(bytes));
    _secretController.text = secret.replaceAll('=', '');
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _secretController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Secret copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.code == null ? 'Add Code' : 'Edit Code'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              ColorPicker(
                selectedColor: _selectedColor,
                onColorSelected: (color) => setState(() => _selectedColor = color),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _websiteController,
                decoration: InputDecoration(
                  labelText: 'Website',
                  border: OutlineInputBorder(),
                  errorStyle: TextStyle(color: Colors.red),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a website name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  errorStyle: TextStyle(color: Colors.red),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _secretController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Secret Key',
                        border: OutlineInputBorder(),
                        errorStyle: TextStyle(color: Colors.red),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.copy),
                          onPressed: _copyToClipboard,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please generate a secret key';
                        }
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.autorenew),
                    onPressed: () {
                      _generateSecret();
                      setState(() {});
                    },
                    tooltip: 'Generate new secret',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text('Save'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveCode();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveCode() async {
    final code = TwoFactorCode(
      id: widget.code?.id,
      color: _selectedColor,
      website: _websiteController.text,
      email: _emailController.text,
      secret: _secretController.text,
    );

    if (code.id == null) {
      await DatabaseHelper.instance.insertCode(code);
    } else {
      await DatabaseHelper.instance.updateCode(code);
    }

    Navigator.pop(context);
  }
}

class ColorPicker extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  ColorPicker({required this.selectedColor, required this.onColorSelected});

  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: colors.map((color) {
        return GestureDetector(
          onTap: () => onColorSelected(color),
          child: Container(
            margin: EdgeInsets.all(8),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: color == selectedColor ? Colors.black : Colors.transparent,
                width: 2,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}