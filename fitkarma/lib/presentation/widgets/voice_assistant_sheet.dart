import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/voice_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/locale_provider.dart';

class VoiceAssistantSheet extends ConsumerStatefulWidget {
  const VoiceAssistantSheet({super.key});

  @override
  ConsumerState<VoiceAssistantSheet> createState() =>
      _VoiceAssistantSheetState();
}

class _VoiceAssistantSheetState extends ConsumerState<VoiceAssistantSheet> {
  String _words = "Listening...";
  bool _isListening = false;
  String _status = "Say something like 'I ate 2 idlis'";

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  Future<void> _startListening() async {
    final available = await voiceService.init();
    if (available) {
      final locale = ref.read(localeProvider);
      final localeId = locale.languageCode == 'hi' ? 'hi_IN' : 'en_IN';

      setState(() {
        _isListening = true;
        _status =
            locale.languageCode == 'hi' ? 'सुन रहा हूँ...' : 'Listening...';
      });

      voiceService.listen(
        localeId: localeId,
        onResult: (words) {
          setState(() {
            _words = words;
          });
          if (words.isNotEmpty && !voiceService.isListening) {
            _processVoice(words);
          }
        },
      );
    } else {
      setState(() {
        _words = "Speech services not available";
      });
    }
  }

  void _processVoice(String text) {
    final intent = voiceService.parseIntent(text);
    setState(() {
      _isListening = false;
      _status = "Processing...";
    });

    // Strategy: In a real app, you'd navigate or trigger providers here.
    // For MVP, we provide visual feedback and a confirmation button.
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pop(context, intent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _status,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Text(
            _words,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          _buildMicIcon(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMicIcon() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.saffronColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppTheme.saffronColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isListening ? Icons.mic : Icons.mic_none,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }
}
