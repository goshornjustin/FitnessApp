/// A base value object that provides equality based on an `id` and a `date`.
///
/// Extend this when you need a domain object whose identity is determined by
/// both a string ID and a date (e.g. daily records where the same ID can
/// appear on different dates and should be treated as distinct objects).
library;

import 'package:equatable/equatable.dart';

class DateIdEquatable extends Equatable {
  const DateIdEquatable({required this.id, required this.date});

  final String id;
  final DateTime date;

  @override
  List<Object?> get props => [id, date];
}
