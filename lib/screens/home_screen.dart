import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import '../blocs/journal_bloc.dart';
import '../blocs/journal_event.dart';
import '../blocs/journal_state.dart';
import '../models/journal_entry.dart';
import 'edit_entry_screen.dart';
import 'intro_screen.dart';
import 'new_entry_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<JournalBloc>().add(LoadEntries(widget.user.uid));
  }

  void _confirmDelete(BuildContext context, JournalEntry entry) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      context.read<JournalBloc>().add(DeleteEntry(entry.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.user.displayName ?? widget.user.email ?? "User";

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const IntroScreen()),
            (_) => false,
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Welcome, $name"),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthBloc>().add(SignOutRequested());
              },
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NewEntryScreen(userId: widget.user.uid),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
        body: BlocBuilder<JournalBloc, JournalState>(
          builder: (context, state) {
            if (state is JournalLoading || state is JournalInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is JournalLoaded) {
              if (state.entries.isEmpty) {
                return const Center(child: Text("No journal entries yet."));
              }
              return ListView.builder(
                itemCount: state.entries.length,
                itemBuilder: (context, index) {
                  final entry = state.entries[index];
                  return ListTile(
                    title: Text(entry.title),
                    subtitle: Text(entry.content,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Text(
                      "${entry.timestamp.month}/${entry.timestamp.day}/${entry.timestamp.year}",
                      style: const TextStyle(fontSize: 12),
                    ),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: Text(entry.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(entry.content),
                              ),
                              const Divider(),
                              ListTile(
                                leading: const Icon(Icons.edit),
                                title: const Text('Edit'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EditEntryScreen(entry: entry),
                                    ),
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.delete),
                                title: const Text('Delete'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  _confirmDelete(context, entry);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            } else if (state is JournalError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
