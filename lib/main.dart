// // import 'package:flutter/material.dart';
// // import 'package:firebase_core/firebase_core.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:flutter_dotenv/flutter_dotenv.dart';

// // import 'services/auth_service.dart';
// // import 'blocs/Auth/auth_bloc.dart';
// // import 'blocs/Auth/auth_event.dart';
// // import 'blocs/Auth/auth_state.dart';
// // import 'blocs/Journal/journal_bloc.dart';
// // import 'screens/home_screen.dart';
// // import 'screens/intro_screen.dart';

// // // import 'package:http/http.dart' as http;

// // Future<void> main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   await dotenv.load(fileName: "assets/.env");
// //   await Firebase.initializeApp();
// //   // testNetwork();
// //   runApp(const MyApp());
// // }

// // // void testNetwork() async {
// // //   try {
// // //     final r = await http.get(Uri.parse('https://www.google.com'));
// // //     print('Google status: ${r.statusCode}');
// // //   } catch (e) {
// // //     print('Network test failed: $e');
// // //   }
// // // }

// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return MultiBlocProvider(
// //       providers: [
// //         BlocProvider<AuthBloc>(
// //           create: (_) => AuthBloc(AuthService())..add(AppStarted()),
// //         ),
// //         BlocProvider<JournalBloc>(
// //           create: (_) => JournalBloc(),
// //         ),
// //       ],
// //       child: MaterialApp(
// //         title: 'Journal App',
// //         debugShowCheckedModeBanner: false,
// //         theme: ThemeData(
// //           useMaterial3: true,
// //           colorSchemeSeed: Colors.indigo,
// //           scaffoldBackgroundColor: Colors.white,
// //           appBarTheme: const AppBarTheme(
// //             elevation: 0,
// //             backgroundColor: Colors.transparent,
// //             iconTheme: IconThemeData(color: Colors.black),
// //           ),
// //         ),
// //         home: BlocBuilder<AuthBloc, AuthState>(
// //           builder: (context, state) {
// //             if (state is AuthAuthenticated) {
// //               return HomeScreen(user: state.user);
// //             } else {
// //               return const IntroScreen();
// //             }
// //           },
// //         ),
// //       ),
// //     );
// //   }
// // }

// // lib/main.dart

// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// import 'services/auth_service.dart';
// import 'blocs/Auth/auth_bloc.dart';
// import 'blocs/Auth/auth_event.dart';
// import 'blocs/Auth/auth_state.dart';
// import 'blocs/Journal/journal_bloc.dart';
// import 'screens/home_screen.dart';
// import 'screens/intro_screen.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await dotenv.load(fileName: "assets/.env");
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }

// class MyApp extends StatefulWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   /// **List every background image** you want cached here.
//   final List<AssetImage> _backgroundImages = [
//     const AssetImage('assets/images/bg2.png'),
//     const AssetImage('assets/images/bg.png'),
//     const AssetImage('assets/images/intro_page_bg.png'),
//   ];

//   /// The **default** background painted behind every screen.
//   /// If you want to use a different one for a particular screen,
//   /// see the note below.
//   late final AssetImage _defaultBackground = _backgroundImages.first;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // Precache all listed images
//     for (final img in _backgroundImages) {
//       precacheImage(img, context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider<AuthBloc>(
//           create: (_) => AuthBloc(AuthService())..add(AppStarted()),
//         ),
//         BlocProvider<JournalBloc>(
//           create: (_) => JournalBloc(),
//         ),
//       ],
//       child: MaterialApp(
//         title: 'Journal App',
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           useMaterial3: true,
//           colorSchemeSeed: Colors.indigo,
//           scaffoldBackgroundColor: Colors.transparent,
//           appBarTheme: const AppBarTheme(
//             elevation: 0,
//             backgroundColor: Colors.transparent,
//             iconTheme: IconThemeData(color: Colors.black),
//           ),
//         ),

//         /// Wrap every route in a DecoratedBox that paints your background
//         builder: (context, child) {

//           if (child is IntroScreen) {
//             return child;
//           }

//           return DecoratedBox(
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 image: _defaultBackground,
//                 fit: BoxFit.cover,
//               ),
//             ),
//             child: child,
//           );
//         },

//         home: BlocBuilder<AuthBloc, AuthState>(
//           builder: (context, state) {
//             if (state is AuthAuthenticated) {
//               return HomeScreen(user: state.user);
//             } else {
//               return const IntroScreen();
//             }
//           },
//         ),
//       ),
//     );
//   }
// }

// lib/main.dart

// lib/main.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'services/auth_service.dart';

// Alias the two AppStarted imports to avoid collision:
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
