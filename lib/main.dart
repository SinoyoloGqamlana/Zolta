import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const ZoltaApp());
}

class ZoltaApp extends StatelessWidget {
  const ZoltaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zolta',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ZoltaHomePage(),
    );
  }
}

class ZoltaHomePage extends StatefulWidget {
  const ZoltaHomePage({super.key});

  @override
  State<ZoltaHomePage> createState() => _ZoltaHomePageState();
}

class _ZoltaHomePageState extends State<ZoltaHomePage> {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _textController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  
  bool _speechEnabled = false;
  bool _isListening = false;
  bool _isThinking = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _initTts() async {
    await _flutterTts.setLanguage("en-ZA");
    await _flutterTts.setSpeechRate(0.5);
  }

  void _startListening() async {
    if (_speechEnabled) {
      setState(() => _isListening = true);
      await _speechToText.listen(onResult: (result) {
        setState(() {
          _textController.text = result.recognizedWords;
        });
      });
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() => _isListening = false);
    _sendMessage();
  }

  Future<void> _sendMessage() async {
    if (_textController.text.isEmpty) return;
    
    String userMessage = _textController.text;
    setState(() {
      _messages.add({"role": "user", "text": userMessage});
      _textController.clear();
      _isThinking = true;
    });

    // AI RESPONSE - Replace with your AI Studio API later
    String aiResponse = await _getAIResponse(userMessage);
    
    setState(() {
      _messages.add({"role": "zolta", "text": aiResponse});
      _isThinking = false;
    });
    
    await _flutterTts.speak(aiResponse);
  }

  Future<String> _getAIResponse(String message) async {
    // TEMP RESPONSE - We'll connect to AI Studio API next
    await Future.delayed(const Duration(seconds: 1));
    return "I hear you said: '$message'. Zolta is live bro 🔥 How can I help you today?";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zolta AI'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                bool isUser = msg["role"] == "user";
                return Align(
                  alignment: isUser? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser? Colors.deepPurple : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      msg["text"]!,
                      style: TextStyle(
                        color: isUser? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isThinking) const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Zolta is thinking..."),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Talk to Zolta...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _isListening? _stopListening : _startListening,
                  child: CircleAvatar(
                    backgroundColor: _isListening? Colors.red : Colors.deepPurple,
                    child: Icon(
                      _isListening? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepPurple),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
