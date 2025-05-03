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
    final photoUrl = user.photoURL;
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
            if (photoUrl != null) ...[
              CircleAvatar(radius: 48, backgroundImage: NetworkImage(photoUrl)),
              const SizedBox(height: 16),
            ],
            Text(
              'Hello, $displayName!',
              style: Theme.of(context).textTheme.titleLarge, // was headline6
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to journal-entry screen
              },
              child: const Text('New Journal Entry'),
            ),
          ],
        ),
      ),
    );
  }
}
