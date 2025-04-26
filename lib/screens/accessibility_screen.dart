import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_command_provider.dart';
import '../widgets/base_screen.dart';

class AccessibilityScreen extends StatelessWidget {
  const AccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final voiceProvider = Provider.of<VoiceCommandProvider>(context);

    return BaseScreen(
      appBar: AppBar(
        title: const Text('Accessibility Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Voice Command Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Enable Voice Commands'),
                      subtitle: const Text(
                          'Use voice to navigate and control the app'),
                      value: voiceProvider.voiceCommandsEnabled,
                      onChanged: (value) {
                        voiceProvider.setVoiceCommandsEnabled(value);
                      },
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Speech Rate'),
                      subtitle: Slider(
                        value: voiceProvider.speechRate,
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        label: voiceProvider.speechRate.toStringAsFixed(1),
                        onChanged: (value) {
                          voiceProvider.setSpeechRate(value);
                        },
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () {
                          voiceProvider
                              .speak("This is a test of the speech rate");
                        },
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Speech Pitch'),
                      subtitle: Slider(
                        value: voiceProvider.speechPitch,
                        min: 0.5,
                        max: 2.0,
                        divisions: 15,
                        label: voiceProvider.speechPitch.toStringAsFixed(1),
                        onChanged: (value) {
                          voiceProvider.setSpeechPitch(value);
                        },
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () {
                          voiceProvider
                              .speak("This is a test of the speech pitch");
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Voice Command Guide',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCommandItem(
                      'Navigation',
                      'Say "go to [dashboard, events, map, settings, venues, facilities, accessibility]"',
                    ),
                    const Divider(),
                    _buildCommandItem(
                      'Theme',
                      'Say "switch to [dark mode, light mode, system theme]"',
                    ),
                    const Divider(),
                    _buildCommandItem(
                      'Back',
                      'Say "go back" to return to the previous screen',
                    ),
                    const Divider(),
                    _buildCommandItem(
                      'Help',
                      'Say "help" to hear available commands',
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.mic),
                        label: const Text('Try Voice Commands Now'),
                        onPressed: () {
                          voiceProvider.startListening(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommandItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
