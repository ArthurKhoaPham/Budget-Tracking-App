import "package:flutter/material.dart";
import "package:supabase_flutter/supabase_flutter.dart";

import "goals_page.dart";

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage("Please fill in all fields.");
      return;
    }

    if (password.length < 6) {
      _showMessage("Password must be at least 6 characters.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user != null) {
        await supabase.from("profiles").upsert({
          "id": user.id,
          "email": email,
          "name": name,
        });
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GoalsPage()),
      );
    } on AuthException catch (error) {
      _showMessage(error.message);
    } catch (error) {
      _showMessage("Unexpected error: $error");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _authBackground(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _logo(),
            const SizedBox(height: 42),
            _authCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                  const Text("Name", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  _textField(_nameController, "Name"),

                  const SizedBox(height: 22),
                  const Text("Email", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  _textField(_emailController, "Email"),

                  const SizedBox(height: 22),
                  const Text("Password", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  _textField(_passwordController, "Password", obscure: true),

                  const SizedBox(height: 34),
                  _gradientButton("REGISTER", _isLoading ? null : _register),

                  const SizedBox(height: 24),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        "Already have an account? Login",
                        style: TextStyle(
                          color: Color(0xFF11AEEA),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _authBackground({required Widget child}) {
  return Container(
    width: double.infinity,
    height: double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFFA7D8C8), Color(0xFF0F4B4B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    child: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
        child: child,
      ),
    ),
  );
}

Widget _logo() {
  return Container(
    width: 170,
    height: 170,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white,
    ),
    padding: const EdgeInsets.all(38),
    child: Image.asset(
      "assets/logo.png",
      fit: BoxFit.contain,
    ),
  );
}

Widget _authCard({required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      boxShadow: const [
        BoxShadow(
          color: Colors.black38,
          blurRadius: 14,
          offset: Offset(0, 7),
        ),
      ],
    ),
    child: child,
  );
}

Widget _textField(
    TextEditingController controller,
    String hint, {
      bool obscure = false,
    }) {
  return TextField(
    controller: controller,
    obscureText: obscure,
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: const BorderSide(color: Color(0xFF15908E), width: 1.7),
      ),
    ),
  );
}

Widget _gradientButton(String text, VoidCallback? onPressed) {
  return GestureDetector(
    onTap: onPressed,
    child: Opacity(
      opacity: onPressed == null ? 0.6 : 1,
      child: Container(
        width: double.infinity,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFA7E2D1), Color(0xFF157A7A)],
          ),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    ),
  );
}