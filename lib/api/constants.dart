class Api {
  Api._();

  static const host = 'nameless-retreat-98318.herokuapp.com';
  static const prefix = '/api/v1';

  static const me = '/users/me';

  static const products = '/product';
  static const productsAdd = '/product/add';
  static const productsByRequest = '/product/searching';
  static const productByBarcode = '/product/barcode';

  static const userProducts = '/users/me/product';
  static const userProductsAdd = '/users/me/product/add';
  static const userProductsDelete = '/users/me/product';
  static const userProductsWeightingAdd = '/users/me/product/weighting/add';
  static const userProductsWeightingsHistory = '/users/me/product/weighting';

  static const devices = '/devices';

  static const userDevices = '/users/me/devices';
  static const userDevicesAdd = '/users/me/devices/add';

  static const devicesServices = '/users/me/devices/add';
  static const serviceByName = '/devices/service';

  static const login = '/auth/login';
  static const register = '/auth/register';

  static const googleAuthorize = '/auth/google/authorize';
  static const googleCallback = '/auth/google/callback';

}