/// Contract interface for local encrypted persistence layer (Drift + SQLCipher).
abstract interface class LocalDatabase {
  Future<void> initialize({required String encryptionKey});
  Future<void> close();
  Future<void> wipeLocalData();
}
