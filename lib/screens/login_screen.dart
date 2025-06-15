// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../blocs/Auth/auth_bloc.dart';
import '../blocs/Auth/auth_event.dart';
import '../blocs/Auth/auth_state.dart';
import '../blocs/Login/login_form_bloc.dart';
import '../blocs/Login/login_form_event.dart';
import '../blocs/Login/login_form_state.dart';
import '../widgets/primary_button.dart';
import '../widgets/social_button.dart';
import 'home_screen.dart';
import 'signup_screen.dart';
import 'welcome_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8eed5),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background overlay
          Image.asset('assets/images/bg2.png', fit: BoxFit.cover),

          SafeArea(
            child: BlocProvider(
              create: (_) => LoginFormBloc(),
              child: BlocListener<AuthBloc, AuthState>(
                listener: (ctx, state) {
                  if (state is AuthError) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  } else if (state is AuthAuthenticated) {
                    Navigator.of(ctx).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (_) => HomeScreen(user: state.user)),
                      (_) => false,
                    );
                  }
                },
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  children: [
                    // ← Back + Title
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            PhosphorIcons.arrowCircleLeft,
                            size: 32,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const WelcomeScreen()),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Log in',
                          // style: TextStyle(
                          //   fontSize: 32,
                          //   fontWeight: FontWeight.bold,
                          // ),
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'lufga-regular',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Email & Password Fields
                    BlocBuilder<LoginFormBloc, LoginFormState>(
                      builder: (ctx, form) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Email
                            TextField(
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (v) => ctx
                                  .read<LoginFormBloc>()
                                  .add(LoginEmailChanged(v)),
                              decoration: InputDecoration(
                                labelText: 'Email address',
                                hintText: 'you@example.com',
                                prefixIcon: const Icon(Icons.email_outlined),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 18),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                suffixIcon: form.emailValid
                                    ? Container(
                                        margin:
                                            const EdgeInsets.only(right: 12),
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Password
                            TextField(
                              obscureText: form.obscurePassword,
                              onChanged: (v) => ctx
                                  .read<LoginFormBloc>()
                                  .add(LoginPasswordChanged(v)),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                hintText: '••••••••',
                                prefixIcon: const Icon(Icons.lock_outline),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 18),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(form.obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined),
                                  onPressed: () => ctx
                                      .read<LoginFormBloc>()
                                      .add(LoginTogglePasswordVisibility()),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    // Align(
                    //   alignment: Alignment.centerRight,
                    //   child: TextButton(
                    //     onPressed: () {
                    //       // TODO: forgot password
                    //     },
                    //     child: const Text('Forgot password?'),
                    //   ),
                    // ),

                    const SizedBox(height: 24),

                    // Log in button
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (ctx2, state) {
                        if (state is AuthLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        return PrimaryButton(
                          label: 'Log in',
                          onPressed: () {
                            // Use ctx2 so we access the LoginFormBloc below us
                            final form = ctx2.read<LoginFormBloc>().state;
                            ctx2.read<AuthBloc>().add(
                                  EmailSignInRequested(
                                    email: form.email.trim(),
                                    password: form.password,
                                  ),
                                );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Or Log In With
                    Row(
                      children: const [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('Or Log In With'),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // BlocConsumer<AuthBloc, AuthState>(
                    //   listener: (ctx3, state) {
                    //     if (state is AuthAuthenticated) {
                    //       Navigator.of(ctx3).pushAndRemoveUntil(
                    //         MaterialPageRoute(
                    //             builder: (_) => HomeScreen(user: state.user)),
                    //         (_) => false,
                    //       );
                    //     }
                    //   },
                    //   builder: (ctx3, state) {
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
                    //           onTap: () => ctx3
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
                              'Log In with Google',
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

                    const SizedBox(height: 24),

                    // Link to Sign up
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          // style: TextStyle(fontFamily: 'lufga-regular'),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignupScreen()),
                          ),
                          child: const Text(
                            'Sign up',
                            // style: TextStyle(
                            //   color: Colors.blue,
                            //   fontWeight: FontWeight.w600,
                            // ),
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
