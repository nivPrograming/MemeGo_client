import 'package:client/models/Message.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login.dart';
import '../../modules/jwt_storage.dart';
import '../../widgets/appState.dart';




class LoginState extends State<LoginPage>{

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String email = _emailController.text.trim();
    String password = _passwordController.text;

    Uint8List bytesEmail = Uint8List.fromList(utf8.encode(email));
    Uint8List bytesPsw = Uint8List.fromList(utf8.encode(password));

    Message msg = Message(0x0001, 0x0000, [bytesEmail, bytesPsw]);
    context.read<AppState>().com.send(msg);

    Message? reply = await context.read<AppState>().com.recv();


    bool loginSuccess = false;

    if (reply != null && reply.status == 0x0001 && reply.opcode == 0x0001 && reply.fields.isNotEmpty){
      loginSuccess = true;
      await JwtStorage().write(String.fromCharCodes(reply.fields[0]));
    }

    else if (reply == null && mounted){
          Navigator.popAndPushNamed(context, '/reconnect');
    }

    setState(() => _isLoading = false);

    if (mounted && loginSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged in successfully!')),
      );
      
      Navigator.popAndPushNamed(context, "/verify_token");      
    }

    else if (mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('psw or username are incorrect!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    
    JwtStorage().read().then((s) => print(s));

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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

              // Login button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Login'),
                ),
              ),

               // Move to Signup button
              SizedBox(
                width: double.infinity,
                height: 24,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => Navigator.popAndPushNamed(context, "/signup"),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Dont have an acount"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}