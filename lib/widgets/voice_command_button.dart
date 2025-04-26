import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_command_provider.dart';

class VoiceCommandButton extends StatelessWidget {
  const VoiceCommandButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceCommandProvider>(
      builder: (context, voiceProvider, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Show recognized text when listening
            if (voiceProvider.isListening)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  voiceProvider.currentText.isEmpty
                      ? 'Listening...'
                      : voiceProvider.currentText,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),

            // The floating action button
            FloatingActionButton(
              onPressed: () {
                if (voiceProvider.isListening) {
                  voiceProvider.stopListening();
                } else {
                  voiceProvider.startListening(context);
                }
              },
              tooltip: 'Voice Commands',
              backgroundColor: voiceProvider.isListening
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
              child: Icon(
                voiceProvider.isListening ? Icons.mic_off : Icons.mic,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        );
      },
    );
  }
}
