/// Riverpod providers for the profile setup wizard and profile actions.
///
/// - `profileSetupProvider` — `StateNotifierProvider` holding ephemeral form
///   state (`ProfileSetupState`) collected across the 4-page setup wizard.
///   Reset automatically when the provider is disposed.
/// - `saveProfileProvider` — family provider that writes the completed profile
///   to Firestore via `AuthRepository.updateUserProfile`.
/// - `profileLoadingProvider` — simple bool flag for the save button spinner.
/// - `profileErrorProvider` — holds any error message from the save action.
/// - `profileSignOutProvider` — signs the user out from the profile page.
library;

import 'package:fitness_app/core/providers/repository_providers.dart';
import 'package:fitness_app/core/providers/use_case_providers.dart';
import 'package:fitness_app/core/usecases/usecase.dart';
import 'package:fitness_app/features/authentication/presentation/providers/auth_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Ephemeral form state for profile setup wizard
class ProfileSetupState {
  const ProfileSetupState({
    this.name = '',
    this.age = 0,
    this.gender = '',
    this.weightKg = 0.0,
    this.heightCm = 0.0,
    this.activityLevel = '',
    this.fitnessGoal = '',
    this.goalReason = '',
  });

  final String name;
  final int age;
  final String gender;
  final double weightKg;
  final double heightCm;
  final String activityLevel;
  final String fitnessGoal;
  final String goalReason;

  ProfileSetupState copyWith({
    String? name,
    int? age,
    String? gender,
    double? weightKg,
    double? heightCm,
    String? activityLevel,
    String? fitnessGoal,
    String? goalReason,
  }) {
    return ProfileSetupState(
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      activityLevel: activityLevel ?? this.activityLevel,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      goalReason: goalReason ?? this.goalReason,
    );
  }
}

class ProfileSetupNotifier extends StateNotifier<ProfileSetupState> {
  ProfileSetupNotifier() : super(const ProfileSetupState());

  void update(ProfileSetupState Function(ProfileSetupState) updater) {
    state = updater(state);
  }
}

final profileSetupProvider =
    StateNotifierProvider<ProfileSetupNotifier, ProfileSetupState>(
  (ref) => ProfileSetupNotifier(),
);

// Save the completed profile
final saveProfileProvider = Provider.family<Future<void>, ProfileSetupState>(
  (ref, setup) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    final updatedUser = currentUser.copyWith(
      name: setup.name,
      age: setup.age,
      gender: setup.gender,
      weight: setup.weightKg,
      height: setup.heightCm,
      activityLevel: setup.activityLevel,
      fitnessGoal: setup.fitnessGoal,
      goalReason: setup.goalReason,
      updatedAt: DateTime.now(),
    );

    final repo = ref.read(authRepositoryProvider);
    await repo.updateUserProfile(updatedUser);
  },
);

// Profile loading error state
final profileErrorProvider = StateProvider<String?>((ref) => null);
final profileLoadingProvider = StateProvider<bool>((ref) => false);

// Sign out
final profileSignOutProvider = FutureProvider<void>((ref) async {
  final signOut = ref.read(signOutProvider);
  await signOut(NoParams());
});
