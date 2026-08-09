sealed class AppFailure {
  const AppFailure({required this.code, required this.message});

  final String code;
  final String message;

  @override
  String toString() => '$runtimeType(code: $code)';
}

final class PermissionDeniedFailure extends AppFailure {
  const PermissionDeniedFailure()
    : super(
        code: 'permission_denied',
        message: 'Permissão necessária não concedida.',
      );
}

final class LimitedPermissionFailure extends AppFailure {
  const LimitedPermissionFailure()
    : super(
        code: 'limited_permission',
        message: 'O acesso à galeria está limitado.',
      );
}

final class AssetNotFoundFailure extends AppFailure {
  const AssetNotFoundFailure()
    : super(
        code: 'asset_not_found',
        message: 'A foto não está mais disponível.',
      );
}

final class DeletionRejectedFailure extends AppFailure {
  const DeletionRejectedFailure()
    : super(
        code: 'deletion_rejected',
        message: 'A exclusão não foi autorizada.',
      );
}

final class StorageFailure extends AppFailure {
  const StorageFailure()
    : super(
        code: 'storage_failure',
        message: 'Não foi possível acessar o armazenamento local.',
      );
}

final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure()
    : super(code: 'unexpected_failure', message: 'Ocorreu um erro inesperado.');
}
