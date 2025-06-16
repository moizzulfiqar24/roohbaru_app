import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../blocs/Auth/auth_bloc.dart';
import '../blocs/Auth/auth_event.dart';
import '../blocs/Auth/auth_state.dart';
import '../blocs/Signup/signup_form_bloc.dart';
import '../blocs/Signup/signup_form_event.dart';
import '../blocs/Signup/signup_form_state.dart';
import '../widgets/primary_button.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8eed5),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // bg2.png overlay
          Image.asset(
            'assets/images/bg2.png',
            fit: BoxFit.cover,
          ),

          SafeArea(
            child: BlocProvider(
              create: (_) => SignupFormBloc(),
              child: BlocListener<AuthBloc, AuthState>(
                listener: (ctx, state) {
                  if (state is AuthAuthenticated) {
                    Navigator.of(ctx).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (_) => HomeScreen(user: state.user)),
                      (_) => false,
                    );
                  } else if (state is AuthError) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    const SizedBox(height: 16),

                    // ← Back + Title
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            PhosphorIcons.arrowCircleLeft,
                            size: 32,
                            color: Colors.black,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Signup with Email',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'lufga-regular',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // FORM FIELDS
                    BlocBuilder<SignupFormBloc, SignupFormState>(
                      builder: (ctx, form) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Email
                            TextField(
                              onChanged: (v) => ctx
                                  .read<SignupFormBloc>()
                                  .add(EmailChanged(v)),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.email_outlined),
                                hintText: 'Email',
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 18),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                suffixIcon: form.isEmailValid
                                    ? Container(
                                        margin:
                                            const EdgeInsets.only(right: 12),
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.check,
                                            size: 16, color: Colors.white),
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Name
                            TextField(
                              onChanged: (v) => ctx
                                  .read<SignupFormBloc>()
                                  .add(NameChanged(v)),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.person_outline),
                                hintText: 'Name',
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 18),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Password
                            TextField(
                              onChanged: (v) => ctx
                                  .read<SignupFormBloc>()
                                  .add(PasswordChanged(v)),
                              obscureText: form.obscurePassword,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock_outline),
                                hintText: 'Password',
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 18),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    form.obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                  onPressed: () => ctx
                                      .read<SignupFormBloc>()
                                      .add(TogglePasswordVisibility()),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Password guideline / error
                            Text(
                              'At least 8 characters, 1 uppercase letter, 1 number, 1 symbol',
                              style: TextStyle(
                                fontSize: 12,
                                color: form.showPasswordError
                                    ? Colors.red
                                    : Colors.black45,
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // SIGN UP BUTTON
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (ctx, authState) {
                        if (authState is AuthLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        return BlocBuilder<SignupFormBloc, SignupFormState>(
                          builder: (ctx, form) => PrimaryButton(
                            label: 'Sign Up',
                            onPressed: () {
                              ctx
                                  .read<SignupFormBloc>()
                                  .add(ValidatePassword());
                              if (!ctx
                                  .read<SignupFormBloc>()
                                  .state
                                  .showPasswordError) {
                                final s = ctx.read<SignupFormBloc>().state;
                                ctx.read<AuthBloc>().add(
                                      EmailSignUpRequested(
                                        name: s.name.trim(),
                                        email: s.email.trim(),
                                        password: s.password,
                                      ),
                                    );
                              }
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // OR Google
                    Row(
                      children: const [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('Or Sign Up With'),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Wrap SocialButton in a Row so its internal Expanded has a Flex parent
                    // BlocConsumer<AuthBloc, AuthState>(
                    //   listener: (ctx, state) {
                    //     if (state is AuthAuthenticated) {
                    //       Navigator.of(ctx).pushAndRemoveUntil(
                    //         MaterialPageRoute(
                    //             builder: (_) => HomeScreen(user: state.user)),
                    //         (_) => false,
                    //       );
                    //     } else if (state is AuthError) {
                    //       ScaffoldMessenger.of(ctx).showSnackBar(
                    //         SnackBar(content: Text(state.message)),
                    //       );
                    //     }
                    //   },
                    //   builder: (ctx, state) {
                    //     if (state is AuthLoading) {
                    //       return const SizedBox(
                    //         width: double.infinity,
                    //         height: 50,
                    //         child: Center(child: CircularProgressIndicator()),
                    //       );
                    //     }
                    //     return Row(
                    //       children: [
                    //         SocialButton(
                    //           assetPath: 'assets/images/google.png',
                    //           onTap: () => ctx
                    //               .read<AuthBloc>()
                    //               .add(GoogleSignInRequested()),
                    //         ),
                    //       ],
                    //     );
                    //   },
                    // ),

                    BlocConsumer<AuthBloc, AuthState>(
                      listener: (ctx, state) {
                        if (state is AuthAuthenticated) {
                          Navigator.of(ctx).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => HomeScreen(user: state.user)),
                            (_) => false,
                          );
                        } else if (state is AuthError) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text(state.message)),
                          );
                        }
                      },
                      builder: (ctx, state) {
                        if (state is AuthLoading) {
                          return const SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        return SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            icon: Image.asset(
                              'assets/images/google.png',
                              height: 24,
                              width: 24,
                            ),
                            label: const Text(
                              'Sign up with Google',
                              style: TextStyle(fontFamily: 'lufga-regular'),
                            ),
                            onPressed: () {
                              ctx.read<AuthBloc>().add(GoogleSignInRequested());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.black,
                              side: BorderSide(
                                // color: Colors.grey.shade400,
                                color: Colors.black54,
                                width: 1.5,
                              ),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Already have an account?
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(fontFamily: 'lufga-regular'),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                          ),
                          child: const Text(
                            'Log in',
                            style: TextStyle(
                              color: Colors.blue,
                              // decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'lufga-regular',
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
