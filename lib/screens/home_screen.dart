import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';

class HomeScreen extends StatelessWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final displayName = user.displayName ?? user.email ?? 'User';
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $displayName'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthBloc>().add(SignOutRequested()),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user.photoURL != null) ...[
              CircleAvatar(
                  radius: 48, backgroundImage: NetworkImage(user.photoURL!)),
              const SizedBox(height: 16),
            ],
            Text(
              'Hello, $displayName!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {}, // TODO: new journal entry
              child: const Text('New Journal Entry'),
            ),
          ],
        ),
      ),
    );
  }
}
