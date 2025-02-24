import 'package:havka/utils/utils.dart';

Future<String?> getUserIdFromToken(String? token) async {
  try {
    if (token == null) return null;
    final parts = token.split(".");
    final String? userId = decodeBase64(parts[1])["user_id"];
    return userId;
  } catch (e) {
    print("Error getting access token: $e");
    return null;
  }
}