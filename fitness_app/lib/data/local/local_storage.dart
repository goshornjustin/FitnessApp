/// Hive-backed local storage wrapper.
///
/// [LocalStorage] tracks whether the user has previously created an account
/// on this device using a dedicated Hive box (`firstTime`). This is used
/// at app startup to decide whether to show onboarding.
///
/// The `_CreateAccount` class is the Hive object model for that box.
/// Its adapter is code-generated — run `flutter packages pub run build_runner
/// build` after modifying it.
library;

import 'package:fitness_app/data/local/hive_registrar.g.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

part 'local_storage.g.dart';

class LocalStorage {
  static const _createdAccBox = 'firstTime';
  static const _key = 'created';
  void initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapters();
  }

  Future hasAccount() async {
    final box = await Hive.openBox(_createdAccBox);
    return await box.get(_key);
  }

  void createdAccount(bool created) async {
    final box = await Hive.openBox(_createdAccBox);
    await box.put(_key, true);
  }
}

@GenerateAdapters([AdapterSpec<_CreateAccount>()])
class _CreateAccount extends HiveObject {
  _CreateAccount({required this.accountCreated});

  final bool accountCreated;
}
