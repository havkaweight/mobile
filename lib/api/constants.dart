class Api {
  Api._();

  static const host = 'nameless-retreat-98318.herokuapp.com';
  static const prefix = '/api/v1';

  static const me = '/users/me';
  static const product = '/product';
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const googleCallback = '/auth/google/callback';
}