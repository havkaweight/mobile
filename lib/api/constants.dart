class Api {
  Api._();

  static const host = 'havka.one';
  static const prefix = '/api/v1/';

  static const monolithService = '/monolith';

  static const userService = 'user/';

  static const authService = 'auth/';
  static const signUp = 'signup/email';
  static const signIn = 'signin/emailOrUsername';
  static const signInGoogle = 'signin/google';
  static const signInApple = 'signin/apple';

  static const tokenUpdate = 'token/update';
  static const tokenVerify = 'token/verify';
  static const me = '';

  static const profileService = 'user/profile/';

  static const productService = 'product/';
  static const productsByRequest = 'search/';
  static const productByBarcode = 'barcode/';
  static const productTag = 'tag/';

  static const fridgeService = 'fridge/';
  static const fridgeUser = 'user/';
  static const fridgeItem = 'item/';

  static const userProductsWeightingAdd = '/users/me/product/weighting/add';
  static const userProductsWeightingsHistory = '/users/me/product/weighting';

  static const consumptionService = 'consumption/';
  static const consumptionUser = 'user/';

  static const devices = '/devices';

  static const userDevices = '/users/me/devices';
  static const userDevicesAdd = '/users/me/devices/add';

  static const devicesServices = '/users/me/devices/add';
  static const serviceByName = '/devices/service';

  static const googleAuthorize = '/auth/google/authorize';
  static const googleCallback = '/auth/google/callback';
}
