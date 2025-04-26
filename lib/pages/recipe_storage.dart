import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RecipeStorage {
  static const _savedRecipesKey = 'saved_recipes';

  // Save the recipes to SharedPreferences
  static Future<void> saveRecipes(List<Map<String, dynamic>> recipes) async {
    final prefs = await SharedPreferences.getInstance();
    final recipesJson = jsonEncode(recipes); // Convert list to JSON string
    await prefs.setString(_savedRecipesKey, recipesJson); // Save the JSON string
  }

  // Load the recipes from SharedPreferences
  static Future<List<Map<String, dynamic>>> loadRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final recipesJson = prefs.getString(_savedRecipesKey);

    if (recipesJson == null) {
      return []; // Return an empty list if no saved recipes
    } else {
      final List<dynamic> recipesList = jsonDecode(recipesJson);
      return List<Map<String, dynamic>>.from(recipesList);
    }
  }
}
