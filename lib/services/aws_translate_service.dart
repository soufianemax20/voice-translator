import 'dart:convert';
import 'package:http/http.dart' as http;

class AWSTranslateService {
  static Future<String?> translate({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    try {
      // Utiliser Google Translate (API publique gratuite)
      final url = Uri.parse(
        'https://translate.googleapis.com/translate_a/single'
        '?client=gtx'
        '&sl=$sourceLang'
        '&tl=$targetLang'
        '&dt=t'
        '&q=${Uri.encodeComponent(text)}'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // La réponse est un tableau complexe : [[[traduction, original], ...], ...]
        final translatedText = data[0][0][0] as String;
        print('✅ Google Translate: $translatedText');
        return translatedText;
      } else {
        print('❌ Translate error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Translate exception: $e');
      return null;
    }
  }
}
