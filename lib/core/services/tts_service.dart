import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// Web-specific imports for browser-native audio playback
import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// Multilingual Text-to-Speech service using gTTS (Google TTS)
/// via the Flask backend. Supports 13 Indian languages + English.
///
/// Uses the browser's native HTMLAudioElement for reliable web playback.
class TtsService {
  // Auto-detect backend URL: use same host as the page on web, localhost for native
  static String _baseUrl = _detectBaseUrl();

  static String _detectBaseUrl() {
    if (kIsWeb) {
      final location = web.window.location;
      final port = location.port;
      // When served via nginx (Docker), use same origin — nginx proxies API calls
      final isNginxServed = port == '' || port == '80' || port == '9090';
      if (isNginxServed) {
        return location.origin;
      }
      return 'http://${location.hostname}:5001';
    }
    return 'http://localhost:5001';
  }

  static bool _isSpeaking = false;
  static web.HTMLAudioElement? _audioElement;
  static String? _currentBlobUrl;

  /// Override the backend URL
  static void setBaseUrl(String url) => _baseUrl = url;

  /// Whether audio is currently playing
  static bool get isSpeaking => _isSpeaking;

  /// Supported languages with display names (matches backend)
  static const Map<String, String> supportedLanguages = {
    'hindi': 'हिन्दी (Hindi)',
    'english': 'English',
    'bengali': 'বাংলা (Bengali)',
    'gujarati': 'ગુજરાતી (Gujarati)',
    'marathi': 'मराठी (Marathi)',
    'tamil': 'தமிழ் (Tamil)',
    'telugu': 'తెలుగు (Telugu)',
    'kannada': 'ಕನ್ನಡ (Kannada)',
    'malayalam': 'മലയാളം (Malayalam)',
    'punjabi': 'ਪੰਜਾਬੀ (Punjabi)',
    'urdu': 'اردو (Urdu)',
    'nepali': 'नेपाली (Nepali)',
    'odia': 'ଓଡ଼ିଆ (Odia)',
  };

  /// Synthesize text to speech audio bytes.
  /// Returns MP3 audio bytes or null on failure.
  static Future<Uint8List?> synthesize(
    String text, {
    String language = 'hindi',
  }) async {
    try {
      final body = <String, dynamic>{
        'text': text,
        'language': language,
      };

      debugPrint('TTS: Requesting "$language" for "${text.substring(0, text.length.clamp(0, 50))}..."');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/tts'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        debugPrint('TTS: Got ${response.bodyBytes.length} bytes of audio');
        return response.bodyBytes;
      } else {
        final errorBody = response.body;
        debugPrint('TTS error: ${response.statusCode} $errorBody');
        return null;
      }
    } catch (e) {
      debugPrint('TTS request failed: $e');
      return null;
    }
  }

  /// Speak text aloud: synthesize → play.
  /// Returns true if playback started successfully.
  static Future<bool> speak(
    String text, {
    String language = 'hindi',
    VoidCallback? onStart,
    VoidCallback? onComplete,
    Function(String)? onError,
  }) async {
    // Stop any current playback first
    await stop();

    onStart?.call();
    _isSpeaking = true;

    try {
      final audioBytes = await synthesize(text, language: language);

      if (audioBytes == null || audioBytes.isEmpty) {
        _isSpeaking = false;
        onError?.call('Failed to generate speech. Backend may be unavailable.');
        return false;
      }

      // Create a Blob from the MP3 bytes for browser-native playback
      final jsArray = audioBytes.toJS;
      final blob = web.Blob(
        [jsArray].toJS,
        web.BlobPropertyBag(type: 'audio/mpeg'),
      );

      // Clean up previous blob URL
      if (_currentBlobUrl != null) {
        web.URL.revokeObjectURL(_currentBlobUrl!);
      }

      // Create object URL and play via HTMLAudioElement
      _currentBlobUrl = web.URL.createObjectURL(blob);
      _audioElement = web.HTMLAudioElement()..src = _currentBlobUrl!;

      // Listen for end of playback
      _audioElement!.onEnded.first.then((_) {
        _isSpeaking = false;
        onComplete?.call();
        _cleanup();
      });

      // Listen for errors
      _audioElement!.onError.first.then((_) {
        _isSpeaking = false;
        onError?.call('Audio playback error');
        _cleanup();
      });

      await _audioElement!.play().toDart;
      return true;
    } catch (e) {
      _isSpeaking = false;
      onError?.call('Playback error: $e');
      debugPrint('TTS speak error: $e');
      return false;
    }
  }

  /// Stop current playback
  static Future<void> stop() async {
    try {
      if (_audioElement != null) {
        _audioElement!.pause();
        _audioElement!.currentTime = 0;
      }
      _isSpeaking = false;
      _cleanup();
    } catch (_) {}
  }

  static void _cleanup() {
    if (_currentBlobUrl != null) {
      web.URL.revokeObjectURL(_currentBlobUrl!);
      _currentBlobUrl = null;
    }
    _audioElement = null;
  }

  /// Check if TTS endpoint is available on the backend
  static Future<bool> isAvailable() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/tts/languages'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Translate text to target language using Google Translate via backend.
  /// Returns translated text or original text on failure.
  static Future<String> translate(
    String text, {
    String targetLanguage = 'hindi',
    String sourceLanguage = 'english',
  }) async {
    // If same language, return as-is
    if (targetLanguage == sourceLanguage) return text;

    try {
      final body = {
        'text': text,
        'target_language': targetLanguage,
        'source_language': sourceLanguage,
      };

      debugPrint('Translate: "$sourceLanguage" → "$targetLanguage"');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/translate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translated = data['translated_text'] as String? ?? text;
        debugPrint('Translated: "${translated.substring(0, translated.length.clamp(0, 80))}..."');
        return translated;
      } else {
        debugPrint('Translation error: ${response.statusCode} ${response.body}');
        return text; // Return original on failure
      }
    } catch (e) {
      debugPrint('Translation request failed: $e');
      return text; // Return original on failure
    }
  }

  /// Summarize an action plan into a clear regional language summary,
  /// then speak it aloud. This creates a human-friendly summary
  /// instead of raw word-by-word translation.
  static Future<bool> summarizeAndSpeak(
    Map<String, dynamic> actionPlan, {
    String language = 'hindi',
    VoidCallback? onStart,
    VoidCallback? onComplete,
    Function(String)? onError,
    Function(String englishSummary, String translatedSummary)? onSummaryReady,
  }) async {
    try {
      // Call the /summarize endpoint
      final body = {
        'action_plan': actionPlan,
        'target_language': language,
      };

      debugPrint('Summarize: requesting $language summary...');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/summarize'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final englishSummary = data['summary_english'] as String? ?? '';
        final translatedSummary = data['summary_translated'] as String? ?? '';
        final textToSpeak = translatedSummary.isNotEmpty ? translatedSummary : englishSummary;

        debugPrint('Summary ready (${textToSpeak.length} chars)');

        // Notify caller with the summary text
        onSummaryReady?.call(englishSummary, translatedSummary);

        if (textToSpeak.isEmpty) {
          onError?.call('No summary generated');
          return false;
        }

        // Speak the translated summary
        return speak(
          textToSpeak,
          language: language,
          onStart: onStart,
          onComplete: onComplete,
          onError: onError,
        );
      } else {
        debugPrint('Summarize error: ${response.statusCode} ${response.body}');
        onError?.call('Failed to generate summary');
        return false;
      }
    } catch (e) {
      debugPrint('Summarize request failed: $e');
      onError?.call('Summary error: $e');
      return false;
    }
  }

  /// Translate text first, then speak in target language.
  /// This is the main method to call for multilingual TTS.
  static Future<bool> translateAndSpeak(
    String text, {
    String language = 'hindi',
    VoidCallback? onStart,
    VoidCallback? onComplete,
    Function(String)? onError,
  }) async {
    // If English, speak directly without translation
    if (language == 'english') {
      return speak(text, language: language, onStart: onStart, onComplete: onComplete, onError: onError);
    }

    // Translate first
    final translatedText = await translate(text, targetLanguage: language, sourceLanguage: 'english');

    // Then speak the translated text
    return speak(translatedText, language: language, onStart: onStart, onComplete: onComplete, onError: onError);
  }

  /// Dispose resources
  static void dispose() {
    stop();
  }
}
