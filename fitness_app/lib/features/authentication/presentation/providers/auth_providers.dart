/// Riverpod providers for authentication state and actions.
///
/// - `authStateProvider` — `StreamProvider` that mirrors Firebase Auth state.
///   Emits `null` when signed out, or a full [User] entity when signed in.
///   The router watches this to handle auth redirects.
/// - `currentUserProvider` — synchronous read of the latest user from the stream.
/// - `authLoadingProvider` / `authErrorProvider` — ephemeral UI state for the
///   sign-in/sign-up form.
/// - `signInProvider` / `signUpProvider` — `Provider.family` actions that call
///   the appropriate use case and update loading/error state.
/// - `signOutAsyncProvider` — `FutureProvider` action that signs the user out.
library;

import 'package:fitness_app/core/providers/external_providers.dart';
import 'package:fitness_app/core/providers/repository_providers.dart';
import 'package:fitness_app/core/providers/use_case_providers.dart';
import 'package:fitness_app/core/usecases/usecase.dart';
import 'package:fitness_app/features/authentication/domain/entities/user.dart';
import 'package:fitness_app/features/authentication/domain/usecases/sign_in_with_email.dart';
import 'package:fitness_app/features/authentication/domain/usecases/sign_up_with_email.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Auth State Provider - watches Firebase auth state
final authStateProvider = StreamProvider<User?>((ref) async* {
  final firebaseAuth = ref.read(firebaseAuthProvider);
  final authRepository = ref.read(authRepositoryProvider);
  
  await for (final firebaseUser in firebaseAuth.authStateChanges()) {
    if (firebaseUser == null) {
      yield null;
    } else {
      final result = await authRepository.getCurrentUser();
      yield result.fold(
        (failure) => null,
        (user) => user,
      );
    }
  }
});

// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

// Auth loading state
final authLoadingProvider = StateProvider<bool>((ref) => false);

// Auth error state  
final authErrorProvider = StateProvider<String?>((ref) => null);

// Sign in method
final signInProvider = Provider.family<Future<void>, SignInParams>((ref, params) async {
  final signIn = ref.read(signInWithEmailProvider);
  ref.read(authLoadingProvider.notifier).state = true;
  ref.read(authErrorProvider.notifier).state = null;
  
  try {
    final result = await signIn(params);
    result.fold(
      (failure) {
        ref.read(authErrorProvider.notifier).state = failure.toString();
      },
      (user) {
        // Success - auth state will update automatically
      },
    );
  } finally {
    ref.read(authLoadingProvider.notifier).state = false;
  }
});

// Sign up method
final signUpProvider = Provider.family<Future<void>, SignUpParams>((ref, params) async {
  final signUp = ref.read(signUpWithEmailProvider);
  ref.read(authLoadingProvider.notifier).state = true;
  ref.read(authErrorProvider.notifier).state = null;
  
  try {
    final result = await signUp(params);
    result.fold(
      (failure) {
        ref.read(authErrorProvider.notifier).state = failure.toString();
      },
      (user) {
        // Success - auth state will update automatically
      },
    );
  } finally {
    ref.read(authLoadingProvider.notifier).state = false;
  }
});

// Sign out method
final signOutAsyncProvider = FutureProvider<void>((ref) async {
  final signOut = ref.read(signOutProvider);
  final result = await signOut(NoParams());
  
  result.fold(
    (failure) => throw Exception(failure.toString()),
    (_) => null,
  );
});