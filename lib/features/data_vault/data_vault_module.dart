/// Data Vault feature module boundary.
///
/// Encapsulates DPDP privacy controls, local/cloud data inspection,
/// user data export, and right-to-erasure cascading deletion requests.
abstract final class DataVaultModule {
  static const String featureName = 'data_vault';
}
