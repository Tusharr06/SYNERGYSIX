import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../secrets.dart';

class ChatService {
  static const String _model = 'gemini-2.5-flash';

  static Future<String> getReply(String prompt) async {
    if (geminiApiKey.isEmpty) {
      return _fallback(prompt);
    }

    try {
      final uri = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=' + geminiApiKey);

      final body = {
        'contents': [
          {
            'parts': [
              {
                'text':
                    'You are an expert assistant for a precision agriculture app called AgroStick, specialized in sustainable farming practices in Punjab, India. Your goal is to provide farmers with concise, helpful, and practical advice related to:\n'
                    '- Farm mapping and boundary marking\n'
                    '- Disease detection in crops\n'
                    '- Spray guidance based on weather conditions\n'
                    '- Pesticide usage optimization and safety\n'
                    '- Weather-based farming advisories\n\n'
                    'Always respond in simple language understandable by farmers. Avoid technical jargon unless necessary. Provide actionable advice.\n\n'
                    'User: ' +
                        prompt
              }
            ]
          }
        ]
      };

      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (res.statusCode != 200) {
        return _fallback(prompt);
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) return _fallback(prompt);

      final content = candidates.first['content'];
      final parts = content['parts'] as List?;
      if (parts == null || parts.isEmpty) return _fallback(prompt);

      final text = parts.first['text'] as String?;
      return (text == null || text.isEmpty) ? _fallback(prompt) : text.trim();
    } catch (_) {
      return _fallback(prompt);
    }
  }

  static String _fallback(String prompt) {
    final p = prompt.toLowerCase();
    if (p.contains('spray') && p.contains('rain')) {
      return 'Avoid spraying if rain is expected within 24 hours. Check the weekly weather in Home.';
    }
    if (p.contains('fungicide')) {
      return 'Common fungicides: Copper-based for rust, sulfur-based for powdery mildew. Always follow label dosage.';
    }
    if (p.contains('boundary') || p.contains('map')) {
      return 'Use the field mapper to tap and mark your farm boundary. Then view zones and detections on the map.';
    }
    return 'I can help with farm mapping, disease detection, spray guidance, and weather-based advisories. What would you like to know?';
  }
}
