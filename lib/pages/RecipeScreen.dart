import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'RecipeSearch.dart';
import 'saved_recipes_screen.dart';

class RecipeScreen extends StatefulWidget {
  final List<Map<String, dynamic>> savedRecipes;

  const RecipeScreen({Key? key, required this.savedRecipes}) : super(key: key);

  @override
  _RecipeScreenState createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final TextEditingController _controller = TextEditingController();
  final FlutterTts _tts = FlutterTts();
  late stt.SpeechToText _speech;

  bool _isSpeaking = false;
  bool _isListening = false;
  bool _hasSearched = false;
  bool _isLoading = false;
  bool _isFavorite = false;

  String _ttsText = "";
  double _speechRate = 0.5;
  int _currentTextIndex = 0;
  List<String> _formattedTextParts = [];

  Map<String, dynamic>? _recipe;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts.setVolume(1.0);
    _tts.setSpeechRate(_speechRate);
    _tts.setPitch(1.0);
    _tts.setCompletionHandler(() {
      setState(() => _isSpeaking = false);
    });
  }

  @override
  void dispose() {
    _tts.stop();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _searchRecipe(String query) async {
    setState(() {
      _hasSearched = true;
      _isLoading = true;
    });

    final recipe = await RecipeService.getRecipe(query);

    if (recipe != null) {
      setState(() {
        _recipe = recipe;
        _isFavorite = widget.savedRecipes.any((r) => r['name'] == recipe['name']);
        _ttsText = _formatRecipe(recipe);
        _formattedTextParts = _ttsText.split(RegExp(r'(?<=[.!?])\s+'));
        _currentTextIndex = 0;
        _isLoading = false;
      });
    } else {
      setState(() {
        _recipe = null;
        _ttsText = "";
        _formattedTextParts.clear();
        _isLoading = false;
      });
    }
  }

  String _formatRecipe(Map<String, dynamic> recipe) {
    final buffer = StringBuffer();
    buffer.writeln('Recipe: ${recipe['name']}');
    buffer.writeln('Ingredients:');
    for (var ingredient in recipe['ingredients']) {
      buffer.writeln('${ingredient['name']} - ${ingredient['quantity']}');
    }
    buffer.writeln('Instructions:');
    for (var step in recipe['instructions']) {
      buffer.writeln(step);
    }
    return buffer.toString();
  }

  void _playTTS() {
    if (_currentTextIndex < _formattedTextParts.length) {
      final textToRead = _formattedTextParts.sublist(_currentTextIndex).join(' ');
      _tts.speak(textToRead);
      setState(() => _isSpeaking = true);
    }
  }

  void _pauseTTS() {
    _tts.stop();
    setState(() => _isSpeaking = false);
  }

  void _rewind() {
    if (_currentTextIndex > 0) {
      _currentTextIndex--;
      _tts.stop().then((_) => _playTTS());
    }
  }

  void _fastForward() {
    if (_currentTextIndex < _formattedTextParts.length - 1) {
      _currentTextIndex++;
      _tts.stop().then((_) => _playTTS());
    }
  }

  void _toggleFavorite() {
    if (_recipe == null) return;
    setState(() {
      if (_isFavorite) {
        widget.savedRecipes.removeWhere((r) => r['name'] == _recipe!['name']);
        _isFavorite = false;
      } else {
        widget.savedRecipes.add(_recipe!);
        _isFavorite = true;
      }
    });
  }

  Future<void> _listen() async {
    if (kIsWeb) {
      _startListening();
      return;
    }

    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission denied')),
        );
        return;
      }
    }

    _startListening();
  }

  void _startListening() async {
    if (_speech.isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    bool available = await _speech.initialize(
      onStatus: (val) => _onSpeechStatus(val),
      onError: (val) => _onSpeechError(val),
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) async {
          if (val.finalResult) {
            setState(() {
              _controller.text = val.recognizedWords;
              _isListening = false;
              _isLoading = true;
            });
            await _speech.stop();
            await _searchRecipe(val.recognizedWords);
          } else {
            setState(() {
              _controller.text = val.recognizedWords;
            });
          }
        },
        listenFor: const Duration(seconds: 5),
        pauseFor: const Duration(seconds: 3),
      );
    }
  }

  void _onSpeechStatus(String status) {
    if (status == 'done') {
      setState(() => _isListening = false);
    }
  }

  void _onSpeechError(dynamic error) {
    setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cook Genie'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: "Enter recipe name",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: _searchRecipe,
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: _isListening ? 70 : 60,
                  height: _isListening ? 70 : 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isListening ? Colors.redAccent : Colors.blue,
                    boxShadow: _isListening
                        ? [
                            BoxShadow(
                              color: Colors.redAccent.withOpacity(0.6),
                              spreadRadius: 8,
                              blurRadius: 12,
                            )
                          ]
                        : [],
                  ),
                  child: GestureDetector(
                    onTap: _listen,
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _hasSearched
                  ? _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _recipe != null
                          ? _buildRecipeDetails()
                          : const Center(child: Text('No recipe found.'))
                  : const Center(child: Text('Search for a recipe to begin.')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeDetails() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recipe: ${_recipe!['name']}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : null,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text('Ingredients:', style: TextStyle(fontWeight: FontWeight.bold)),
          ..._recipe!['ingredients'].map<Widget>((i) =>
              Text('${i['name']} - ${i['quantity']}')).toList(),
          const SizedBox(height: 10),
          const Text('Instructions:', style: TextStyle(fontWeight: FontWeight.bold)),
          ..._recipe!['instructions'].map<Widget>((s) => Text(s)).toList(),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: const Icon(Icons.fast_rewind), onPressed: _rewind),
              IconButton(
                icon: Icon(_isSpeaking ? Icons.pause : Icons.play_arrow),
                onPressed: () {
                  _isSpeaking ? _pauseTTS() : _playTTS();
                },
              ),
              IconButton(icon: const Icon(Icons.fast_forward), onPressed: _fastForward),
            ],
          ),
        ],
      ),
    );
  }
}




// class RecipeScreen extends StatefulWidget {
//   final List<Map<String, dynamic>> savedRecipes;

//   const RecipeScreen({super.key, required this.savedRecipes});

//   @override
//   _RecipeScreenState createState() => _RecipeScreenState();
// }

// class _RecipeScreenState extends State<RecipeScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final FlutterTts _tts = FlutterTts();
//   Map<String, dynamic>? _recipe;
//   bool _isSpeaking = false;
//   bool _hasSearched = false;
//   bool _isLoading = false;
//   bool _isFavorite = false;

//   String _ttsText = "";
//   double _speechRate = 0.5;
//   int _currentTextIndex = 0;
//   List<String> _formattedTextParts = [];

//   @override
//   void initState() {
//     super.initState();
//     _tts.setVolume(1.0);
//     _tts.setSpeechRate(_speechRate);
//     _tts.setPitch(1.0);
//     _tts.setCompletionHandler(() {
//       setState(() {
//         _isSpeaking = false;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _tts.stop(); // Stops TTS playback when leaving the screen
//     _controller.dispose(); // Dispose of text controller
//     super.dispose();
//   }

//   Future<void> _searchRecipe(String query) async {
//     setState(() {
//       _hasSearched = true;
//       _isLoading = true;
//     });

//     final recipe = await RecipeService.getRecipe(query);

//     if (recipe != null) {
//       setState(() {
//         _recipe = recipe;
//         _isFavorite = widget.savedRecipes.any((r) => r['name'] == recipe['name']);
//         _ttsText = _formatRecipe(recipe);
//         _formattedTextParts = _ttsText.split(RegExp(r'(?<=[.!?])\s+'));
//         _currentTextIndex = 0;
//         _isLoading = false;
//       });
//     } else {
//       setState(() {
//         _recipe = null;
//         _ttsText = "";
//         _formattedTextParts.clear();
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Recipe not found')),
//       );
//     }
//   }

//   String _formatRecipe(Map<String, dynamic> recipe) {
//     final buffer = StringBuffer();
//     buffer.writeln('Recipe: ${recipe['name']}');
//     buffer.writeln('Ingredients:');
//     for (var ingredient in recipe['ingredients']) {
//       buffer.writeln('${ingredient['name']} - ${ingredient['quantity']}');
//     }
//     buffer.writeln('Instructions:');
//     for (var step in recipe['instructions']) {
//       buffer.writeln(step);
//     }
//     return buffer.toString();
//   }

//   void _playTTS() {
//     if (_currentTextIndex < _formattedTextParts.length) {
//       final textToRead = _formattedTextParts.sublist(_currentTextIndex).join(' ');
//       _tts.speak(textToRead);
//       setState(() => _isSpeaking = true);
//     }
//   }

//   void _pauseTTS() {
//     _tts.stop();
//     setState(() => _isSpeaking = false);
//   }

//   void _rewind() {
//     if (_currentTextIndex > 0) {
//       _currentTextIndex--;
//       _tts.stop().then((_) => _playTTS());
//     }
//   }

//   void _fastForward() {
//     if (_currentTextIndex < _formattedTextParts.length - 1) {
//       _currentTextIndex++;
//       _tts.stop().then((_) => _playTTS());
//     }
//   }

//   void _toggleFavorite() {
//     if (_recipe == null) return;
//     setState(() {
//       if (_isFavorite) {
//         widget.savedRecipes.removeWhere((r) => r['name'] == _recipe!['name']);
//         _isFavorite = false;
//       } else {
//         widget.savedRecipes.add(_recipe!);
//         _isFavorite = true;
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Cook Genie'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: _controller,
//               decoration: const InputDecoration(
//                 labelText: "Enter recipe name",
//                 border: OutlineInputBorder(),
//               ),
//               onSubmitted: _searchRecipe,
//             ),
//             const SizedBox(height: 16),
//             Expanded(
//               child: _hasSearched
//                   ? _isLoading
//                       ? const Center(child: CircularProgressIndicator())
//                       : _recipe != null
//                           ? SingleChildScrollView(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text('Recipe: ${_recipe!['name']}',
//                                           style: const TextStyle(
//                                               fontSize: 20, fontWeight: FontWeight.bold)),
//                                       IconButton(
//                                         icon: Icon(
//                                           _isFavorite ? Icons.favorite : Icons.favorite_border,
//                                           color: _isFavorite ? Colors.red : null,
//                                         ),
//                                         onPressed: _toggleFavorite,
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 10),
//                                   const Text('Ingredients:',
//                                       style: TextStyle(fontWeight: FontWeight.bold)),
//                                   ..._recipe!['ingredients'].map<Widget>((i) =>
//                                       Text('${i['name']} - ${i['quantity']}')),
//                                   const SizedBox(height: 10),
//                                   const Text('Instructions:',
//                                       style: TextStyle(fontWeight: FontWeight.bold)),
//                                   ..._recipe!['instructions'].map<Widget>((s) => Text(s)),
//                                   const SizedBox(height: 20),
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       IconButton(icon: const Icon(Icons.fast_rewind), onPressed: _rewind),
//                                       IconButton(
//                                         icon: Icon(
//                                             _isSpeaking ? Icons.pause : Icons.play_arrow),
//                                         onPressed: () {
//                                           _isSpeaking ? _pauseTTS() : _playTTS();
//                                         },
//                                       ),
//                                       IconButton(icon: const Icon(Icons.fast_forward), onPressed: _fastForward),
//                                     ],
//                                   )
//                                 ],
//                               ),
//                             )
//                           : const Center(child: Text('No recipe found.'))
//                   : const Center(child: Text('Search for a recipe to begin.')),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
