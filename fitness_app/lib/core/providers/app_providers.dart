/// Barrel export for all core Riverpod providers.
///
/// Import this single file anywhere you need access to external services,
/// repositories, use cases, or the router — instead of importing each
/// provider file individually. New provider files added to `core/providers/`
/// should be re-exported here.
library;

// Core app providers - exports all main providers
export 'external_providers.dart';
export 'repository_providers.dart';
export 'router_providers.dart';
export 'use_case_providers.dart';