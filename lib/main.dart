import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/auth_service.dart';
import 'blocs/app/app_bloc.dart';
import 'blocs/app/app_event.dart' as app_event;
import 'blocs/app/app_state.dart';
import 'blocs/Auth/auth_bloc.dart';
import 'blocs/Auth/auth_event.dart' as auth_event;
import 'blocs/Auth/auth_state.dart';
import 'blocs/Journal/journal_bloc.dart';
import 'screens/intro_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // The global bg2.png we’ll cache + paint
  static const AssetImage _bg2 = AssetImage('assets/images/bg2.png');

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // AppBloc uses app_event.AppStarted()
        BlocProvider(
            create: (_) => AppBloc()..add(const app_event.AppStarted())),
        // AuthBloc uses auth_event.AppStarted()
        BlocProvider(
            create: (_) =>
                AuthBloc(AuthService())..add(auth_event.AppStarted())),
        BlocProvider(create: (_) => JournalBloc()),
      ],
      child: BlocBuilder<AppBloc, AppState>(
        builder: (context, appState) {
          // Phase 1: Splash only
          if (appState is SplashInProgress) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: IntroScreen(),
            );
          }

          // Phase 2: Real app with global bg2.png
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.indigo,
              scaffoldBackgroundColor: Colors.transparent,
              appBarTheme: const AppBarTheme(
                elevation: 0,
                backgroundColor: Colors.transparent,
                iconTheme: IconThemeData(color: Colors.black),
              ),
            ),
            builder: (context, child) {
              // Precache and paint bg2 on every screen
              precacheImage(_bg2, context);
              return DecoratedBox(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: _bg2,
                    fit: BoxFit.cover,
                  ),
                ),
                child: child,
              );
            },
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (ctx, authState) {
                if (authState is AuthAuthenticated) {
                  return HomeScreen(user: authState.user);
                }
                // fallback (e.g. after sign-out)
                return const IntroScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
