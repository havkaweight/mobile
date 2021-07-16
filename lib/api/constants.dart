class Api {
  Api._();

  static const host = 'nameless-retreat-98318.herokuapp.com';
  static const prefix = '/api/v1';

  static const me = '/users/me';

  static const products = '/products';

  static const userProducts = '/users/me/products';
  static const userProductsAdd = '/users/me/products/add';

  static const devices = '/devices';

  static const userDevices = '/users/me/devices';
  static const userDevicesAdd = '/users/me/devices/add';

  static const login = '/auth/login';
  static const register = '/auth/register';

  static const googleAuthorize = '/auth/google/authorize';
  static const googleCallback = '/auth/google/callback';

}