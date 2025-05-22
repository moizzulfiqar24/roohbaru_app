import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:roohbaru_app/widgets/social_button.dart';
import '../blocs/Auth/auth_bloc.dart';
import '../blocs/Auth/auth_event.dart';
import '../blocs/Auth/auth_state.dart';
import '../widgets/primary_button.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _agreedToTerms = false;
  bool _showPasswordError = false;
  bool _emailValid = false;

  final _passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$');
  final _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(() {
      setState(() {
        _emailValid = _emailRegex.hasMatch(_emailCtrl.text.trim());
      });
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  bool get _isPasswordValid => _passwordRegex.hasMatch(_passCtrl.text.trim());

  void _submitSignup() {
    final email = _emailCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    final pass = _passCtrl.text;

    setState(() {
      _showPasswordError = !_isPasswordValid;
    });

    if (!_isPasswordValid) return;

    // if (!_agreedToTerms) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text("Please agree to the terms first.")),
    //   );
    //   return;
    // }

    context.read<AuthBloc>().add(
          EmailSignUpRequested(name: name, email: email, password: pass),
        );
  }

  void _handleGoogleSignIn() {
    context.read<AuthBloc>().add(GoogleSignInRequested());
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (ctx, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => HomeScreen(user: state.user)),
              (_) => false,
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  IconButton(
                    // icon: const Icon(Icons.arrow_back),
                    icon: const Icon(
                      // Icons.arrow_back,
                      PhosphorIcons.arrowCircleLeft,
                      size: 32,
                      color: Colors.black,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Let's Get Started!",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign up, fill the form to continue.',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 32),
                  _buildTextField(
                    hint: 'Email',
                    icon: Icons.email_outlined,
                    controller: _emailCtrl,
                    suffixIcon: _emailValid
                        ? Container(
                            margin: const EdgeInsets.only(right: 12),
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check,
                                size: 16, color: Colors.white),
                          )
                        : null,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    hint: 'Name',
                    icon: Icons.person_outline,
                    controller: _nameCtrl,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    hint: 'Password',
                    icon: Icons.lock_outline,
                    controller: _passCtrl,
                    obscure: _obscurePass,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePass
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () =>
                          setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'At least 8 characters, 1 uppercase letter, 1 number, 1 symbol',
                      style: TextStyle(
                        fontSize: 12,
                        color: _showPasswordError ? Colors.red : Colors.black45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Row(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     Transform.scale(
                  //       scale: 1.4,
                  //       child: Checkbox(
                  //         value: _agreedToTerms,
                  //         shape: const CircleBorder(),
                  //         onChanged: (val) =>
                  //             setState(() => _agreedToTerms = val ?? false),
                  //       ),
                  //     ),
                  //     const SizedBox(width: 8),
                  //     Expanded(
                  //       child: Padding(
                  //         padding: const EdgeInsets.only(top: 10),
                  //         child: RichText(
                  //           text: const TextSpan(
                  //             style: TextStyle(
                  //                 fontSize: 13, color: Colors.black54),
                  //             children: [
                  //               TextSpan(
                  //                   text: 'By Signing up, you agree to the '),
                  //               TextSpan(
                  //                 text: 'Terms of Service',
                  //                 style: TextStyle(
                  //                     fontWeight: FontWeight.bold,
                  //                     color: Colors.black),
                  //               ),
                  //               TextSpan(text: ' and '),
                  //               TextSpan(
                  //                 text: 'Privacy Policy',
                  //                 style: TextStyle(
                  //                     fontWeight: FontWeight.bold,
                  //                     color: Colors.black),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 32),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     GestureDetector(
                  //       onTap: _handleGoogleSignIn,
                  //       child: Container(
                  //         padding: const EdgeInsets.all(12),
                  //         decoration: BoxDecoration(
                  //           shape: BoxShape.circle,
                  //           border: Border.all(color: Colors.grey.shade300),
                  //         ),
                  //         child: Image.asset(
                  //           'assets/images/google.png',
                  //           height: 24,
                  //           width: 24,
                  //         ),
                  //       ),
                  //     ),
                  //     const SizedBox(width: 24),
                  //     Container(
                  //       padding: const EdgeInsets.all(12),
                  //       decoration: BoxDecoration(
                  //         shape: BoxShape.circle,
                  //         border: Border.all(color: Colors.grey.shade300),
                  //       ),
                  //       child: const Icon(Icons.apple, size: 28),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 32),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return PrimaryButton(
                        label: 'Sign Up',
                        onPressed: _submitSignup,
                      );
                    },
                  ),
                  // const SizedBox(height: 16),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     const Text("Already have an account? "),
                  //     GestureDetector(
                  //       onTap: () {
                  //         Navigator.pushReplacement(
                  //           context,
                  //           MaterialPageRoute(
                  //               builder: (_) => const LoginScreen()),
                  //         );
                  //       },
                  //       child: const Text(
                  //         'Log in',
                  //         style: TextStyle(
                  //           fontWeight: FontWeight.bold,
                  //           decoration: TextDecoration.underline,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 32),
                  const SizedBox(height: 24),
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
                  Row(
                    children: [
                      SocialButton(
                        assetPath: 'assets/images/google.png',
                        onTap: () => context
                            .read<AuthBloc>()
                            .add(GoogleSignInRequested()),
                      ),
                      const SizedBox(width: 12),
                      SocialButton(
                        assetPath: 'assets/images/apple.png',
                        onTap: () {
                          // TODO: implement Apple Sign In
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                        ),
                        child: Text(
                          'Log In',
                          style: TextStyle(
                            // color: Theme.of(context).colorScheme.primary,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            // decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
