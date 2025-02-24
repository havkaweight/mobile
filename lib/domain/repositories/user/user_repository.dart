import '../../entities/user/user.dart';

abstract class UserRepository {
  Future<List<User>> getAllUsers();
  Future<User> getUserById(String id);
  Future<User> getMe();

  Future<User> createUser(User user);
  Future<User> updateUser(User user);
  Future<void> deleteUser(String id);
}