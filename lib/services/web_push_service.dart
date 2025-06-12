import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class WebPushService {
  static const String baseUrl = 'https://story-api.dicoding.dev/v1';
  static const String vapidPublicKey =
      'BCDx2enWG-d0FqFaMg-U7FaMg-1ODxN1WxUlKx+hPmBkt3DrZJqxvzrxBXwuTVR3pH7DONgBf1oGvxlhlcLyPWk';

  Future<Map<String, dynamic>> subscribe({
    required String token,
    required String endpoint,
    required Map<String, dynamic> keys,
  }) async {
    developer.log('Subscribing to web push...', name: 'WebPushService');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/subscribe'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'endpoint': endpoint, 'keys': keys}),
      );

      developer.log(
        'Subscribe response status: ${response.statusCode}',
        name: 'WebPushService',
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['error'] == false) {
        developer.log(
          'Successfully subscribed to web push',
          name: 'WebPushService',
        );
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to subscribe');
      }
    } catch (e) {
      developer.log(
        'Error subscribing to web push',
        name: 'WebPushService',
        error: e,
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> unsubscribe({
    required String token,
    required String endpoint,
  }) async {
    developer.log('Unsubscribing from web push...', name: 'WebPushService');

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/notifications/subscribe'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'endpoint': endpoint}),
      );

      developer.log(
        'Unsubscribe response status: ${response.statusCode}',
        name: 'WebPushService',
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['error'] == false) {
        developer.log(
          'Successfully unsubscribed from web push',
          name: 'WebPushService',
        );
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to unsubscribe');
      }
    } catch (e) {
      developer.log(
        'Error unsubscribing from web push',
        name: 'WebPushService',
        error: e,
      );
      rethrow;
    }
  }
}
