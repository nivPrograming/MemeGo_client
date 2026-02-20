import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';

import 'signup.dart';
import '../../modules/Communication.dart';
import '../../models/Message.dart';


class SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String email = _emailController.text.trim();
    String password = _passwordController.text;
    String username = _usernameController.text;

    Uint8List bytesEmail = Uint8List.fromList(utf8.encode(email));
    Uint8List bytesPsw = Uint8List.fromList(utf8.encode(password));
    Uint8List bytesUsername = Uint8List.fromList(utf8.encode(username));

    Message msg = Message(0x0002, 0x0000, [bytesEmail, bytesPsw, bytesUsername]);
    widget.com.send(msg);

    Message? reply = await widget.com.recv();


    bool signupSuccess = false;

    if (reply != null && reply.status == 0x0001 && reply.opcode == 0x0002){
      signupSuccess = true;

    }

    setState(() => _isLoading = false);

    if (mounted && signupSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );

      Navigator.popAndPushNamed(context, '/login');
    }

    else if (mounted && reply != null && reply.status == 0x0003 && reply.opcode == 0x0002) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email already used!')),
      );
    }

    else if (mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('something whent wrong!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Username field
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a username';
                  }
                  if (value.trim().length < 3) {
                    return 'Username must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password field
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _isPasswordVisible = !_isPasswordVisible);
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Sign up button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignup,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Sign Up'),
                ),
              ),

                // Move to login button
              SizedBox(
                width: double.infinity,
                height: 24,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => Navigator.popAndPushNamed(context, "/login"),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Already have an acount?"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}