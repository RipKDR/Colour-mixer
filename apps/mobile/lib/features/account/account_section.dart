import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/appwrite/appwrite_client.dart';
import 'account_provider.dart';

class AccountSection extends ConsumerStatefulWidget {
  const AccountSection({super.key});

  @override
  ConsumerState<AccountSection> createState() => _AccountSectionState();
}

class _AccountSectionState extends ConsumerState<AccountSection> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(appwriteConfigProvider);
    if (!config.isConfigured) {
      return const ListTile(
        leading: Icon(Icons.cloud_off_outlined),
        title: Text('Cloud sync'),
        subtitle: Text('Cloud sync not configured'),
      );
    }

    final userAsync = ref.watch(cloudUserProvider);
    return userAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => ListTile(
        leading: const Icon(Icons.error_outline),
        title: const Text('Cloud account'),
        subtitle: const Text("Couldn't reach the cloud. Try again."),
        trailing: TextButton(
          onPressed: () => refreshCloudSession(ref),
          child: const Text('Retry'),
        ),
      ),
      data: (user) {
        if (user == null) return _signInForm(context);
        return _signedIn(context, user);
      },
    );
  }

  Widget _signedIn(BuildContext context, CloudUser user) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.cloud_done_outlined),
          title: const Text('Signed in'),
          subtitle: Text(user.email),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _busy ? null : () => _signOut(context),
              child: const Text('Sign out'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _signInForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.cloud_outlined),
            title: Text('Cloud sync'),
            subtitle: Text('Sign in to push and pull recipes'),
          ),
          TextField(
            key: const Key('account-email'),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            enabled: !_busy,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 8),
          TextField(
            key: const Key('account-password'),
            controller: _passwordController,
            obscureText: true,
            enabled: !_busy,
            decoration: const InputDecoration(
              labelText: 'Password',
              helperText: 'At least 8 characters',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton(
                onPressed: _busy ? null : () => _submit(context, register: false),
                child: const Text('Sign in'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _busy ? null : () => _submit(context, register: true),
                child: const Text('Create account'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context, {required bool register}) async {
    final auth = ref.read(cloudAuthProvider);
    if (auth == null) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || !email.contains('@')) {
      _snack(context, 'Enter a valid email');
      return;
    }
    if (password.length < 8) {
      _snack(context, 'Password must be at least 8 characters');
      return;
    }

    setState(() => _busy = true);
    try {
      if (register) {
        await auth.register(email: email, password: password);
      } else {
        await auth.signIn(email: email, password: password);
      }
      refreshCloudSession(ref);
      _passwordController.clear();
    } catch (e) {
      if (context.mounted) {
        _snack(context, '$e');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signOut(BuildContext context) async {
    final auth = ref.read(cloudAuthProvider);
    if (auth == null) return;
    setState(() => _busy = true);
    try {
      await auth.signOut();
      refreshCloudSession(ref);
    } catch (e) {
      if (context.mounted) {
        _snack(context, '$e');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
