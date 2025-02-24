import '../../repositories/auth/auth_repository.dart';

class Logout {
  final AuthRepository authRepository;

  Logout(this.authRepository);

  Future<void> execute() {
    return authRepository.logout();
  }
}
