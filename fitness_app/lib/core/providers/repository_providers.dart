/// Riverpod providers that wire up data sources and repositories.
///
/// Each feature's data source and repository implementation is created here
/// and injected with its required dependencies (Firestore, FirebaseAuth,
/// NetworkInfo) from `external_providers.dart`.
///
/// Consumers should depend on the abstract repository type (e.g.
/// `AuthRepository`) via these providers rather than the concrete `Impl`
/// classes, keeping the domain layer decoupled from Firebase internals.
library;

import 'package:fitness_app/core/providers/external_providers.dart';
import 'package:fitness_app/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:fitness_app/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:fitness_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:fitness_app/features/nutrition/data/datasources/nutrition_remote_data_source.dart';
import 'package:fitness_app/features/nutrition/data/repositories/nutrition_repository_impl.dart';
import 'package:fitness_app/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:fitness_app/features/workout/data/datasources/workout_remote_data_source.dart';
import 'package:fitness_app/features/workout/data/repositories/workout_repository_impl.dart';
import 'package:fitness_app/features/workout/domain/repositories/workout_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Data Sources
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    firebaseAuth: ref.read(firebaseAuthProvider),
    firestore: ref.read(firestoreProvider),
  );
});

final nutritionRemoteDataSourceProvider = Provider<NutritionRemoteDataSource>((ref) {
  return NutritionRemoteDataSourceImpl(firestore: ref.read(firestoreProvider));
});

final workoutRemoteDataSourceProvider = Provider<WorkoutRemoteDataSource>((ref) {
  return WorkoutRemoteDataSourceImpl(firestore: ref.read(firestoreProvider));
});

// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) {
  return NutritionRepositoryImpl(
    remoteDataSource: ref.read(nutritionRemoteDataSourceProvider),
  );
});

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepositoryImpl(
    remoteDataSource: ref.read(workoutRemoteDataSourceProvider),
  );
});
