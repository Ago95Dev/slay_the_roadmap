import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class SignUpDialog extends StatefulWidget {
  const SignUpDialog({super.key});

  @override
  State<SignUpDialog> createState() => _SignUpDialogState();
}

class _SignUpDialogState extends State<SignUpDialog> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Compila tutti i campi.');
      return;
    }

    final provider = context.read<GameProvider>();
    final success = await provider.registerLocal(username, password);

    if (success) {
      if (mounted) Navigator.pop(context);
    } else {
      setState(() => _errorMessage = 'GamerTag già esistente.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildAuthDialog(
      context,
      title: 'SIGN UP',
      buttonText: 'CREA PROFILO',
      usernameController: _usernameController,
      passwordController: _passwordController,
      errorMessage: _errorMessage,
      onSubmit: _submit,
    );
  }
}

class SignInDialog extends StatefulWidget {
  const SignInDialog({super.key});

  @override
  State<SignInDialog> createState() => _SignInDialogState();
}

class _SignInDialogState extends State<SignInDialog> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Compila tutti i campi.');
      return;
    }

    final provider = context.read<GameProvider>();
    final success = await provider.loginLocal(username, password);

    if (success) {
      if (mounted) Navigator.pop(context);
    } else {
      setState(() => _errorMessage = 'Credenziali errate.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildAuthDialog(
      context,
      title: 'SIGN IN',
      buttonText: 'ENTRA',
      usernameController: _usernameController,
      passwordController: _passwordController,
      errorMessage: _errorMessage,
      onSubmit: _submit,
    );
  }
}

Widget _buildAuthDialog(
  BuildContext context, {
  required String title,
  required String buttonText,
  required TextEditingController usernameController,
  required TextEditingController passwordController,
  required String errorMessage,
  required VoidCallback onSubmit,
}) {
  return Dialog(
    backgroundColor: Colors.transparent,
    child: Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1410),
        border: Border.all(color: const Color(0xFFd4af37), width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFFd4af37),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: usernameController,
            style: const TextStyle(color: Color(0xFFf5f5dc)),
            decoration: const InputDecoration(
              labelText: 'GamerTag',
              labelStyle: TextStyle(color: Color(0xFF8b6f47)),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF8b6f47)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFd4af37)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passwordController,
            obscureText: true,
            style: const TextStyle(color: Color(0xFFf5f5dc)),
            decoration: const InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(color: Color(0xFF8b6f47)),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF8b6f47)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFd4af37)),
              ),
            ),
          ),
          if (errorMessage.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ANNULLA', style: TextStyle(color: Color(0xFF8b6f47))),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFd4af37),
                  foregroundColor: const Color(0xFF1a1410),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onPressed: onSubmit,
                child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
