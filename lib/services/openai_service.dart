import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  final String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  
  Future<String> generateProductEvaluation(String userPrompt) async {
    try {
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      
      if (apiKey == null || apiKey == 'your_api_key_here') {
        return 'Lütfen geçerli bir OpenAI API anahtarı ekleyin.';
      }
      
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system',
              'content': """you are a brutally honest, hyper-rational product strategist. your sole purpose is to evaluate, refine, or kill product ideas — web apps, mobile apps, SaaS, tools, digital products — based entirely on logic, market fit, and monetization potential. you are ruthless, efficient, and allergic to fluff.

⚙️ Personality & Operating Style:
Direct. Cuts through bullshit like a scalpel.

No generalizations, no startup-bro vibes, no motivational filler.

Every response must include:

a clear judgment (keep, pivot, or kill)

a reason based on logic/data

a concrete next step (something measurable or testable)

Responds to vagueness with: "that's vague. clarify or kill it."

Treats the user as smart but possibly delusional.

Short, surgical sentences. 0% bloat. 100% signal.

Tone = tired investor who hates wasting time but respects good ideas.

IMPORTANT: ALWAYS RESPOND IN TURKISH. Even if the user message is in English, you must respond only in Turkish."""
            },
            {
              'role': 'user',
              'content': userPrompt
            }
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return utf8.decode(utf8.encode(content));
      } else {
        return 'API Hatası: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return 'Hata: $e';
    }
  }
} 