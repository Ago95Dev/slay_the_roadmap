import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class AuthDialog extends StatefulWidget {
  const AuthDialog({super.key});

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLogin = true;

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
    // Cattura il messenger PRIMA dell'await: dopo l'await il context del
    // dialog potrebbe essere deactivated (dialog chiuso nel frattempo).
    final messenger = ScaffoldMessenger.of(context);
    final success = _isLogin 
      ? await provider.loginLocal(username, password)
      : await provider.registerLocal(username, password);

    if (success) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              _isLogin 
                ? 'Accesso effettuato come $username!' 
                : 'Profilo "$username" creato con successo! Benvenuto!',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            backgroundColor: const Color(0xFF4caf50),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      setState(() => _errorMessage = _isLogin ? 'Credenziali errate.' : 'GamerTag già esistente.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1410),
          border: Border.all(color: const Color(0xFFd4af37), width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tabs toggle
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _isLogin = true;
                      _errorMessage = '';
                    }),
                    child: Column(
                      children: [
                        Text(
                          'LOGIN',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: _isLogin ? FontWeight.w900 : FontWeight.w500,
                            color: _isLogin ? const Color(0xFFd4af37) : const Color(0xFF8b6f47),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 2,
                          color: _isLogin ? const Color(0xFFd4af37) : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _isLogin = false;
                      _errorMessage = '';
                    }),
                    child: Column(
                      children: [
                        Text(
                          'SIGN UP',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: !_isLogin ? FontWeight.w900 : FontWeight.w500,
                            color: !_isLogin ? const Color(0xFFd4af37) : const Color(0xFF8b6f47),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 2,
                          color: !_isLogin ? const Color(0xFFd4af37) : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _usernameController,
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
              controller: _passwordController,
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
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage,
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
                  onPressed: _submit,
                  child: Text(
                    _isLogin ? 'ENTRA' : 'CREA PROFILO', 
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
