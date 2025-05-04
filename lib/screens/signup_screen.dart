import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up'), centerTitle: true),
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (ctx, state) {
            if (state is AuthAuthenticated) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => HomeScreen(user: state.user)),
                (_) => false,
              );
            } else if (state is AuthError) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  label: 'Name',
                  hint: 'Enter your name',
                  controller: _nameCtrl,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Email address',
                  hint: 'you@example.com',
                  controller: _emailCtrl,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _passCtrl,
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (ctx, state) {
                    if (state is AuthLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return PrimaryButton(
                      label: 'Create account',
                      onPressed: () {
                        context.read<AuthBloc>().add(
                              EmailSignUpRequested(
                                name: _nameCtrl.text.trim(),
                                email: _emailCtrl.text.trim(),
                                password: _passCtrl.text,
                              ),
                            );
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Already have an account? Log in'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
