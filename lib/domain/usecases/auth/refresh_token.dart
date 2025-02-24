import '../../repositories/auth/auth_repository.dart';

class RefreshToken {
  final AuthRepository authRepository;

  RefreshToken(this.authRepository);

  Future<void> execute() {
    return authRepository.refreshToken();
  }
}
