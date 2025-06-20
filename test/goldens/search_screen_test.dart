import 'package:alchemist/alchemist.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:roohbaru_app/blocs/Auth/auth_bloc.dart';
import 'package:roohbaru_app/blocs/Auth/auth_event.dart';
import 'package:roohbaru_app/blocs/Auth/auth_state.dart';
import 'package:roohbaru_app/blocs/Journal/journal_bloc.dart';
import 'package:roohbaru_app/blocs/Journal/journal_event.dart';
import 'package:roohbaru_app/blocs/Journal/journal_state.dart';
import 'package:roohbaru_app/screens/search_screen.dart';

class MockJournalBloc extends MockBloc<JournalEvent, JournalState>
    implements JournalBloc {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

// fallback values so mocktail + bloc_test won’t complain
class _FakeJournalEvent extends Fake implements JournalEvent {}

class _FakeJournalState extends Fake implements JournalState {}

class _FakeAuthEvent extends Fake implements AuthEvent {}

class _FakeAuthState extends Fake implements AuthState {}

// Minimal fake User that only needs a UID
class MockUser extends Mock implements User {}

void main() {
  setUpAll(() {
    // register fakes for any `registerFallbackValue<T>()` calls
    registerFallbackValue(_FakeJournalEvent());
    registerFallbackValue(_FakeJournalState());
    registerFallbackValue(_FakeAuthEvent());
    registerFallbackValue(_FakeAuthState());
  });

  late MockJournalBloc journalBloc;
  late MockAuthBloc authBloc;
  late User fakeUser;

  setUp(() {
    journalBloc = MockJournalBloc();
    authBloc = MockAuthBloc();
    fakeUser = MockUser();

    // stub out the fake user's UID
    when(() => fakeUser.uid).thenReturn('u1');

    // make JournalBloc be already "loaded" with an empty list
    when(() => journalBloc.state).thenReturn(JournalLoaded([]));
    whenListen(
      journalBloc,
      Stream.value(JournalLoaded([])),
      initialState: JournalLoaded([]),
    );

    // make AuthBloc be authenticated
    when(() => authBloc.state).thenReturn(AuthAuthenticated(fakeUser));
    whenListen(
      authBloc,
      Stream.value(AuthAuthenticated(fakeUser)),
      initialState: AuthAuthenticated(fakeUser),
    );
  });

  tearDown(() {
    journalBloc.close();
    authBloc.close();
  });

  group('SearchScreen golden', () {
    goldenTest(
      'initial—filters visible, no results',
      fileName: 'search_screen',
      builder: () => GoldenTestGroup(
        // simulate an iPhone 16 Pro Max in portrait
        scenarioConstraints: BoxConstraints.tight(Size(430, 932)),
        children: [
          GoldenTestScenario(
            name: 'empty',
            child: MultiBlocProvider(
              providers: [
                BlocProvider<JournalBloc>.value(value: journalBloc),
                BlocProvider<AuthBloc>.value(value: authBloc),
              ],
              child: MaterialApp(
                home: const SearchScreen(),
                debugShowCheckedModeBanner: false,
                theme: ThemeData(useMaterial3: true),
              ),
            ),
          ),
        ],
      ),
    );
  });
}
