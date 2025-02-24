import '../../repositories/auth/auth_repository.dart';

class Login {
  final AuthRepository authRepository;

  Login(this.authRepository);

  Future<void> execute(String username, String password) {
    return authRepository.login(username, password);
  }
}
