import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'services/auth_service.dart';
import 'blocs/Auth/auth_bloc.dart';
import 'blocs/Auth/auth_event.dart';
import 'blocs/Auth/auth_state.dart';
import 'blocs/Journal/journal_bloc.dart';
import 'screens/home_screen.dart';
import 'screens/intro_screen.dart';

// import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  await Firebase.initializeApp();
  // testNetwork();
  runApp(const MyApp());
}

// void testNetwork() async {
//   try {
//     final r = await http.get(Uri.parse('https://www.google.com'));
//     print('Google status: ${r.statusCode}');
//   } catch (e) {
//     print('Network test failed: $e');
//   }
// }



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(AuthService())..add(AppStarted()),
        ),
        BlocProvider<JournalBloc>(
          create: (_) => JournalBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Journal App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.indigo,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(color: Colors.black),
          ),
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return HomeScreen(user: state.user);
            } else {
              return const IntroScreen();
            }
          },
        ),
      ),
    );
  }
}
