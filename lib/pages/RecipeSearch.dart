import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RecipeService {
  static const String apiKey = "AIzaSyCLePhpmLiXzxONV-ayKEpsSVUzxaerEmI"; 
  static const String url =
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey";

    final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  static final Map<String, Map<String, dynamic>> _recipeCache = {};

  /// Starts voice recognition, returns recognized query
  Future<void> listenAndSearch(
    Function(String) onQueryRecognized,
    Function(bool) onListeningStateChanged,
  ) async {
    onQueryRecognized(""); // Clear UI first

    if (_speech.isListening) {
      await _speech.stop();
      await Future.delayed(Duration(milliseconds: 200));
    }

    bool available = await _speech.initialize();
    if (available) {
      _isListening = true;
      onListeningStateChanged(true);

      _speech.listen(
        onResult: (result) async {
          if (result.finalResult) {
            String spokenText = result.recognizedWords.trim();
            if (spokenText.isNotEmpty) {
              _isListening = false;
              await _speech.stop();
              onListeningStateChanged(false);
              onQueryRecognized(spokenText);
            }
          }
        },
        listenMode: stt.ListenMode.dictation,
        cancelOnError: true,
        partialResults: false,
      );
    }
  }

  /// Speaks out a recipe step or message
  Future<void> speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  /// Fetches a recipe from Gemini and handles errors gracefully
  static Future<Map<String, dynamic>?> getRecipe(
    String query, {
    Function(String)? onError,
  }) async {
    if (_recipeCache.containsKey(query)) {
      print("Using cached recipe for: $query");
      return _recipeCache[query];
    }

    final Map<String, dynamic> requestData = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text":
                  "Give me a **standard and traditional** recipe for '$query' in JSON format **without any code block markers or markdown**. "
                  "Only use this structure with no sub-ingredients or nested objects:\n"
                  "{\n"
                  "  \"name\": \"Recipe Name\",\n"
                  "  \"ingredients\": [\n"
                  "    {\"name\": \"ingredient1\", \"quantity\": \"amount\"},\n"
                  "    {\"name\": \"ingredient2\", \"quantity\": \"amount\"}\n"
                  "  ],\n"
                  "  \"instructions\": [\n"
                  "    \"Step 1\",\n"
                  "    \"Step 2\"\n"
                  "  ]\n"
                  "} "
                  "Return only valid JSON."
            }
          ]
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        String content =
            jsonResponse["candidates"][0]["content"]["parts"][0]["text"];

        // Clean up known bad formatting
        content = content.replaceAll("```json", "").replaceAll("```", "").trim();

        // Fix common malformed pattern: "name": "X": []
        content = content.replaceAllMapped(
          RegExp(r'"name"\s*:\s*"([^"]+)"\s*:\s*\[\],?'),
          (match) => '"name": "${match.group(1)}",',
        );

        Map<String, dynamic> recipeData = jsonDecode(content);
        _recipeCache[query] = recipeData;
        return recipeData;
      } else {
        String message = "Failed to fetch recipe. Status Code: ${response.statusCode}";
        print(message);
        onError?.call(message);
        return null;
      }
    } catch (e) {
      String message = "Error parsing recipe JSON: $e";
      print(message);
      onError?.call(message);
      return null;
    }
  }


  // Save recipe to memory and persist to device
  static Future<void> saveRecipeAndPersist(Map<String, dynamic> recipeData) async {
    _recipeCache[recipeData["name"]] = recipeData;
    await saveRecipesToStorage();
  }

  static Future<void> saveRecipesToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> recipes = _recipeCache.values.map((recipe) => jsonEncode(recipe)).toList();
    await prefs.setStringList('saved_recipes', recipes);
  }

  static Future<void> loadRecipesFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? recipes = prefs.getStringList('saved_recipes');
    if (recipes != null) {
      for (var recipeJson in recipes) {
        final Map<String, dynamic> recipe = jsonDecode(recipeJson);
        _recipeCache[recipe["name"]] = recipe;
      }
    }
  }

  static void removeRecipe(String name) {
    _recipeCache.remove(name);
  }

  static List<Map<String, dynamic>> getSavedRecipes() {
    return _recipeCache.values.toList();
  }
}







// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:http/http.dart' as http;

// class RecipeService {
//   static const String apiKey = "AIzaSyD8YxrCHj12am_YqEpRKqknOF87mOLOS8Q"; // Replace with your actual API key
//   static const String url =
//       "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-pro:generateContent?key=$apiKey";

//     final FlutterTts flutterTts = FlutterTts();
//   final stt.SpeechToText _speech = stt.SpeechToText();
//   bool _isListening = false;

//   static final Map<String, Map<String, dynamic>> _recipeCache = {};

//   /// Starts voice recognition, returns recognized query
//   Future<void> listenAndSearch(
//     Function(String) onQueryRecognized,
//     Function(bool) onListeningStateChanged,
//   ) async {
//     onQueryRecognized(""); // Clear UI first

//     if (_speech.isListening) {
//       await _speech.stop();
//       await Future.delayed(Duration(milliseconds: 200));
//     }

//     bool available = await _speech.initialize();
//     if (available) {
//       _isListening = true;
//       onListeningStateChanged(true);

//       _speech.listen(
//         onResult: (result) async {
//           if (result.finalResult) {
//             String spokenText = result.recognizedWords.trim();
//             if (spokenText.isNotEmpty) {
//               _isListening = false;
//               await _speech.stop();
//               onListeningStateChanged(false);
//               onQueryRecognized(spokenText);
//             }
//           }
//         },
//         listenMode: stt.ListenMode.dictation,
//         cancelOnError: true,
//         partialResults: false,
//       );
//     }
//   }

//   /// Speaks out a recipe step or message
//   Future<void> speak(String text) async {
//     await flutterTts.setLanguage("en-US");
//     await flutterTts.setPitch(1.0);
//     await flutterTts.speak(text);
//   }

//   /// Fetches a recipe from Gemini and handles errors gracefully
//   static Future<Map<String, dynamic>?> getRecipe(
//     String query, {
//     Function(String)? onError,
//   }) async {
//     if (_recipeCache.containsKey(query)) {
//       print("Using cached recipe for: $query");
//       return _recipeCache[query];
//     }

//     final Map<String, dynamic> requestData = {
//       "contents": [
//         {
//           "role": "user",
//           "parts": [
//             {
//               "text":
//                   "Give me a **standard and traditional** recipe for '$query' in JSON format **without any code block markers or markdown**. "
//                   "Only use this structure with no sub-ingredients or nested objects:\n"
//                   "{\n"
//                   "  \"name\": \"Recipe Name\",\n"
//                   "  \"ingredients\": [\n"
//                   "    {\"name\": \"ingredient1\", \"quantity\": \"amount\"},\n"
//                   "    {\"name\": \"ingredient2\", \"quantity\": \"amount\"}\n"
//                   "  ],\n"
//                   "  \"instructions\": [\n"
//                   "    \"Step 1\",\n"
//                   "    \"Step 2\"\n"
//                   "  ]\n"
//                   "} "
//                   "Return only valid JSON."
//             }
//           ]
//         }
//       ]
//     };

//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(requestData),
//       );

//       print("Response Status Code: ${response.statusCode}");
//       print("Response Body: ${response.body}");

//       if (response.statusCode == 200) {
//         final jsonResponse = jsonDecode(response.body);
//         String content =
//             jsonResponse["candidates"][0]["content"]["parts"][0]["text"];

//         // Clean up known bad formatting
//         content = content.replaceAll("```json", "").replaceAll("```", "").trim();

//         // Fix common malformed pattern: "name": "X": []
//         content = content.replaceAllMapped(
//           RegExp(r'"name"\s*:\s*"([^"]+)"\s*:\s*\[\],?'),
//           (match) => '"name": "${match.group(1)}",',
//         );

//         Map<String, dynamic> recipeData = jsonDecode(content);
//         _recipeCache[query] = recipeData;
//         return recipeData;
//       } else {
//         String message = "Failed to fetch recipe. Status Code: ${response.statusCode}";
//         print(message);
//         onError?.call(message);
//         return null;
//       }
//     } catch (e) {
//       String message = "Error parsing recipe JSON: $e";
//       print(message);
//       onError?.call(message);
//       return null;
//     }
//   }
// }