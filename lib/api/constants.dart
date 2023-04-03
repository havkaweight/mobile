class Api {
  Api._();

  static const host = 'havka.one';
  static const prefix = '/api/v1';

  static const authService = '/auth';
  static const monolithService = '/monolith';

  static const signin = '/signin/email';
  static const signInGoogle = '/signin/google';
  static const signup = '/signup/email';

  static const me = '/user/me';

  static const products = '/product';
  static const productsAdd = '/product/add';
  static const productsByRequest = '/product/searching';
  static const productByBarcode = '/product/barcode';

  static const userProducts = '/user/me/product';
  static const userProductsWeightingAdd = '/users/me/product/weighting/add';
  static const userProductsWeightingsHistory = '/users/me/product/weighting';

  static const devices = '/devices';

  static const userDevices = '/users/me/devices';
  static const userDevicesAdd = '/users/me/devices/add';

  static const devicesServices = '/users/me/devices/add';
  static const serviceByName = '/devices/service';

  static const googleAuthorize = '/auth/google/authorize';
  static const googleCallback = '/auth/google/callback';
}
