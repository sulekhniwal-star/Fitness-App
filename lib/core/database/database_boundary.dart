/// Contract interface for local encrypted persistence layer (Drift + SQLCipher).
abstract interface class LocalDatabase {
  /// Whether the database has been successfully initialized and opened.
  bool get isInitialized;

  /// Initializes and opens the encrypted database with the given key.
  Future<void> initialize({required String encryptionKey});

  /// Closes the underlying database connection.
  Future<void> close();

  /// Wipes all local persistent data safely across all tables in a transaction.
  Future<void> wipeLocalData();

  /// Executes an arbitrary action inside an atomic database transaction.
  Future<T> runInTransaction<T>(Future<T> Function() action);
}
