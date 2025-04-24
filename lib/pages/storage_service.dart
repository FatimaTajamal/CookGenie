import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keySavedRecipes = 'saved_recipes';

  // Save recipes to SharedPreferences
  static Future<void> saveRecipes(List<Map<String, dynamic>> recipes) async {
    final prefs = await SharedPreferences.getInstance();
    final recipesJson = json.encode(recipes);
    await prefs.setString(_keySavedRecipes, recipesJson);
  }

  // Load recipes from SharedPreferences
  static Future<List<Map<String, dynamic>>> loadSavedRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final recipesJson = prefs.getString(_keySavedRecipes);
    if (recipesJson != null) {
      final List<dynamic> recipesList = json.decode(recipesJson);
      return recipesList.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  // Clear saved recipes (optional)
  static Future<void> clearSavedRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySavedRecipes);
  }
}
