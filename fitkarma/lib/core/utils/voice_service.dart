import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceIntent {
  final String action; // 'log_food', 'log_workout', 'track_steps', 'unknown'
  final Map<String, dynamic> data;

  VoiceIntent({required this.action, required this.data});
}

class VoiceService {
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  Future<bool> init() async {
    if (_isInitialized) return true;
    _isInitialized = await _speech.initialize();
    await _tts.setLanguage("en-IN"); // Default to Indian English
    await _tts.setPitch(1.0);
    return _isInitialized;
  }

  Future<void> speak(String text) async {
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _speech.stop();
  }

  void listen({
    required Function(String) onResult,
    required String localeId, // 'en_IN' or 'hi_IN'
  }) {
    _speech.listen(
      onResult: (result) => onResult(result.recognizedWords),
      localeId: localeId,
    );
  }

  bool get isListening => _speech.isListening;

  // Rule-based intent parser for offline efficiency
  VoiceIntent parseIntent(String text) {
    final lowerText = text.toLowerCase();

    // 1. Food Logging Intents
    // English: "I ate", "Lunch was", "Add food"
    // Hindi: "मैने खाया", "खाना", "आरंभ"
    if (lowerText.contains("ate") ||
        lowerText.contains("eat") ||
        lowerText.contains("khaya") ||
        lowerText.contains("meal") ||
        lowerText.contains("khaaya")) {
      return VoiceIntent(
        action: 'log_food',
        data: {'query': text},
      );
    }

    // 2. Step Tracking Intents
    if (lowerText.contains("steps") ||
        lowerText.contains("walk") ||
        lowerText.contains("kadam") ||
        lowerText.contains("chala")) {
      return VoiceIntent(
        action: 'track_steps',
        data: {'query': text},
      );
    }

    // 3. Workout Intents
    if (lowerText.contains("workout") ||
        lowerText.contains("gym") ||
        lowerText.contains("kasrat") ||
        lowerText.contains("exercise")) {
      return VoiceIntent(
        action: 'log_workout',
        data: {'query': text},
      );
    }

    return VoiceIntent(action: 'unknown', data: {'query': text});
  }
}

final voiceService = VoiceService();
