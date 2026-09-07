import 'package:flutter/material.dart';

import '../../domain/models/user_profile.dart';
import '../view_models/session_controller.dart';

/// Scelta profilo iniziale (F10, PRIMA della Home).
///
/// - 0 utenti → form di registrazione diretto (primo Giocatore).
/// - ≥1 utenti → lista profili (tap = richiesta password) + "Nuovo profilo".
/// A login/registrazione riusciti la [SessionController] notifica e la root
/// (`MyAppRoot`) monta la Home dell'utente; qui basta mostrare gli errori.
class ProfileSwitchScreen extends StatefulWidget {
  final SessionController session;

  const ProfileSwitchScreen({super.key, required this.session});

  @override
  State<ProfileSwitchScreen> createState() => _ProfileSwitchScreenState();
}

class _ProfileSwitchScreenState extends State<ProfileSwitchScreen> {
  late bool _showRegister;
  String? _selectedId;

  final _registerUser = TextEditingController();
  final _registerPass = TextEditingController();
  final _loginPass = TextEditingController();

  @override
  void initState() {
    super.initState();
    _showRegister = widget.session.users.listUsers().isEmpty;
  }

  @override
  void dispose() {
    _registerUser.dispose();
    _registerPass.dispose();
    _loginPass.dispose();
    super.dispose();
  }

  void _error(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _doRegister() async {
    final username = _registerUser.text.trim();
    final password = _registerPass.text;
    if (username.isEmpty || password.isEmpty) {
      _error('Inserisci nome utente e password.');
      return;
    }
    try {
      await widget.session.register(username: username, password: password);
    } on StateError catch (e) {
      _error(e.message);
    }
  }

  Future<void> _doLogin(String username) async {
    final profile = await widget.session.login(
      username: username,
      password: _loginPass.text,
    );
    if (profile == null) {
      _error('Password errata. Riprova.');
      return;
    }
    _loginPass.clear();
  }

  @override
  Widget build(BuildContext context) {
    final users = widget.session.users.listUsers();
    return Scaffold(
      appBar: AppBar(
        title: const Text('👥 Chi gioca?'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (users.isNotEmpty && !_showRegister) ...[
                    ...users.map(_buildProfileTile),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      key: const Key('profile_new_button'),
                      onPressed: () => setState(() {
                        _showRegister = true;
                        _selectedId = null;
                      }),
                      icon: const Icon(Icons.person_add),
                      label: const Text('Nuovo profilo'),
                    ),
                  ] else ...[
                    if (users.isNotEmpty)
                      TextButton.icon(
                        key: const Key('profile_back_button'),
                        onPressed: () => setState(() {
                          _showRegister = false;
                        }),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Torna alla lista'),
                      ),
                    _buildRegisterForm(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTile(UserProfile profile) {
    final selected = _selectedId == profile.userId;
    return Card(
      key: Key('profile_user_${profile.userId}'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(profile.avatarFrameColorValue),
              child: Text(
                profile.avatarIcon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            title: Text(profile.displayName),
            subtitle: Text(
              'Creato il ${profile.createdAt.day}/${profile.createdAt.month}/${profile.createdAt.year}',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => setState(() {
              _selectedId = selected ? null : profile.userId;
              _loginPass.clear();
            }),
          ),
          if (selected)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('profile_login_password'),
                      controller: _loginPass,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _doLogin(profile.displayName),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    key: const Key('profile_login_submit'),
                    onPressed: () => _doLogin(profile.displayName),
                    child: const Text('Accedi'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Crea il tuo profilo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            const Text(
              'I progressi restano salvati su questo dispositivo, '
              'separati per ogni profilo.',
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('profile_register_username'),
              controller: _registerUser,
              decoration: const InputDecoration(
                labelText: 'Nome utente',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('profile_register_password'),
              controller: _registerPass,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _doRegister(),
            ),
            const SizedBox(height: 12),
            FilledButton(
              key: const Key('profile_register_submit'),
              onPressed: _doRegister,
              child: const Text('Crea e gioca'),
            ),
          ],
        ),
      ),
    );
  }
}
