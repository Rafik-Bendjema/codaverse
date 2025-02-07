import 'package:flutter/material.dart';
import 'package:gdg_hack/auth/authService.dart';
import 'signIn.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _selectedRole; // Role selection: Mentor or Participant
  bool _isCompany = false;

  final AuthService _authService = AuthService();

  void _signUp() async {
    String? result = await _authService.signUp(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _isCompany ? "" : (_selectedRole ?? ""), // If company, role is empty
      _isCompany, // Boolean value
      "", // Hackathon ID remains empty
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.toString())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Signup")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Password"),
            ),

            // Show dropdown for role selection only if it's NOT a company
            if (!_isCompany)
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(labelText: "Role"),
                items: ["Mentor", "Participant"]
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value;
                  });
                },
              ),

            Row(
              children: [
                Checkbox(
                  value: _isCompany,
                  onChanged: (bool? value) {
                    setState(() {
                      _isCompany = value ?? false;
                    });
                  },
                ),
                Text("Is a company? (Hide role)"),
              ],
            ),

            SizedBox(height: 20),
            ElevatedButton(onPressed: _signUp, child: Text("Signup")),
            TextButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              ),
              child: Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}
