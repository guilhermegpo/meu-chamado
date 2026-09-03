/// Falhas da camada de segurança local. Mensagens genéricas de propósito:
/// nunca citam PIN, chave, rótulo ou caminho.
sealed class SecurityException implements Exception {
  const SecurityException(this.message);

  final String message;

  @override
  String toString() => 'SecurityException: $message';
}

/// Tentativa de usar a proteção antes de ela existir.
class SecurityNotConfiguredException extends SecurityException {
  const SecurityNotConfiguredException()
    : super('A proteção do app ainda não foi configurada.');
}

/// PIN informado não confere com o verificador guardado.
class InvalidPinException extends SecurityException {
  const InvalidPinException() : super('PIN incorreto.');
}

/// PIN novo recusado pela política mínima. A [message] descreve a regra.
class WeakPinException extends SecurityException {
  const WeakPinException(super.message);
}

/// O armazenamento seguro do sistema não respondeu.
class SecurityStorageException extends SecurityException {
  const SecurityStorageException()
    : super('Não foi possível acessar o armazenamento seguro do sistema.');
}

/// A migração do banco para o formato criptografado não pôde ser concluída com
/// segurança. O banco original permanece utilizável.
class DatabaseEncryptionMigrationException extends SecurityException {
  const DatabaseEncryptionMigrationException([String? detail])
    : super(
        detail ??
            'Não foi possível proteger o banco local. Seus dados não foram '
                'alterados. Tente novamente.',
      );
}
