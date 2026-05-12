/// Riverpod providers for third-party service singletons.
///
/// Exposes Firebase Auth, Cloud Firestore, and [NetworkInfo] as providers so
/// they can be injected into data sources and repositories via Riverpod rather
/// than being accessed as global singletons directly. This makes them easy to
/// override in tests.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/core/network/network_info.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// External services
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl();
});