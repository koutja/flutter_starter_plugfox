/// Database interfaces
library;

import 'dart:async';

/// Key-value storage interface for SQLite and IndexedDB
abstract interface class KeyValueStorage {
  /// Get value by key
  FutureOr<T?> getKey<T extends Object>(String key);

  /// Set value by key
  FutureOr<void> setKey(String key, Object? value);

  /// Remove value by key
  FutureOr<void> removeKey(String key);

  /// Get all values
  FutureOr<Map<String, Object?>> getAll();

  /// Set all values
  FutureOr<void> setAll(Map<String, Object?> data);
}
