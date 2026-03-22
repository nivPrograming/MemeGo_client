import 'package:client/models/Message.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth.dart';

import '../../widgets/appState.dart';




class AuthState extends State<AuthPage>{

  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();


  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String code = _codeController.text.trim();

    Uint8List bytesCode = Uint8List.fromList(utf8.encode(code));


    Message msg = Message(0x0004, 0x0000, [bytesCode,]);
    context.read<AppState>().com.send(msg);

    Message? reply = await context.read<AppState>().com.recv();

    bool authSuccess = false;
    bool authCodeExp = false;

    if (reply != null && reply.status == 0x0001 && reply.opcode == 0x0004){
      authSuccess = true;
    }

    else if (reply != null && reply.status == 0x0003 && reply.opcode == 0x0004){
      authCodeExp = true;
    }

    else if (reply == null && mounted){
      Navigator.popAndPushNamed(context, '/reconnect');
    }

    setState(() => _isLoading = false);

    if (mounted && authSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authenticated in successfully!')),
      );
      
      Navigator.popAndPushNamed(context, "/login");      
    }

    else if (mounted && authCodeExp) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication expired!')),
      );
      
      Navigator.popAndPushNamed(context, "/signup");      
    }

    else if (mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('incorrect code!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Email Authentication')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Code field
              TextFormField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Validation Code',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty || value.trim().length != 4) {
                    return 'Please enter a valid 4 digit code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Login button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleAuth,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Authenticate'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}