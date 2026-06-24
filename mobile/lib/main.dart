import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const TranslatorApp());
}

class TranslatorApp extends StatelessWidget {
  const TranslatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Translator',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        fontFamily: 'Roboto', 
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          surface: Colors.black,
          onSurface: Colors.white,
        ),
        fontFamily: 'Roboto',
      ),
      home: const MainTranslationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class NoisePainter extends CustomPainter {
  final double density;
  NoisePainter({this.density = 0.15});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(density)
      ..style = PaintingStyle.fill;
    
    final random = Random(42); 
    
    for (int i = 0; i < size.width * size.height * 0.05; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      canvas.drawRect(Rect.fromLTWH(x, y, 1, 1), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MainTranslationScreen extends StatefulWidget {
  const MainTranslationScreen({super.key});

  @override
  State<MainTranslationScreen> createState() => _MainTranslationScreenState();
}

class _MainTranslationScreenState extends State<MainTranslationScreen> with SingleTickerProviderStateMixin {
  bool isRecording = false;
  String sourceLang = 'sinhala';
  String targetLang = 'tamil';
  
  List<Map<String, String>> transcripts = [
    {"speaker": "source", "text": "ආයුබෝවන්, කොහොමද?"},
    {"speaker": "ai", "text": "வணக்கம், எப்படி இருக்கிறீர்கள்?"},
  ];

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    setState(() {
      isRecording = !isRecording;
    });
  }
  
  void _swapLanguages() {
    setState(() {
      final temp = sourceLang;
      sourceLang = targetLang;
      targetLang = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Stack(
        children: [
          if (isDark)
            Positioned.fill(
              child: Opacity(
                opacity: 0.15,
                child: CustomPaint(painter: NoisePainter(density: 0.15)),
              ),
            ),
          
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Translator",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.5),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.black12,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text("Ready", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                
                GestureDetector(
                  onTap: _swapLanguages,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: isDark ? Colors.white24 : Colors.black12),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(sourceLang.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Icon(Icons.swap_horiz, size: 20),
                        ),
                        Text(targetLang.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    reverse: true,
                    itemCount: transcripts.length,
                    itemBuilder: (context, index) {
                      final item = transcripts[transcripts.length - 1 - index];
                      final isAI = item['speaker'] == 'ai';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        alignment: isAI ? Alignment.centerRight : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: isAI ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAI ? targetLang.toUpperCase() : sourceLang.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10, 
                                fontWeight: FontWeight.w600, 
                                color: isDark ? Colors.white54 : Colors.black54
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['text']!,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: isAI ? FontWeight.w400 : FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                Container(
                  height: 160,
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isRecording)
                        AnimatedBuilder(
                          animation: _animController,
                          builder: (context, child) {
                            return Container(
                              width: 100 + (_animController.value * 40),
                              height: 100 + (_animController.value * 40),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (isDark ? Colors.white : Colors.black).withOpacity(0.1 - (_animController.value * 0.1)),
                              ),
                            );
                          },
                        ),
                      
                      GestureDetector(
                        onTap: _toggleRecording,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? Colors.white : Colors.black,
                            boxShadow: [
                              if (isRecording)
                                BoxShadow(
                                  color: isDark ? Colors.white24 : Colors.black26,
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                )
                            ]
                          ),
                          child: Icon(
                            isRecording ? Icons.stop : Icons.mic,
                            color: isDark ? Colors.black : Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
