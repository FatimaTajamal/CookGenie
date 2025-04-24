import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'grocery_list_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String recipeTitle;
  const RecipeDetailScreen({super.key, required this.recipeTitle});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool isFavorite = false; // To track if the recipe is favorited
  final ScrollController _scrollController =
      ScrollController(); // Scroll Controller

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipeTitle),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: () {
              setState(() {
                isFavorite = !isFavorite;
              });
              final snackBar = SnackBar(
                content: Text(
                  isFavorite
                      ? "Added to Favorites ❤️"
                      : "Removed from Favorites 💔",
                ),
                duration: const Duration(seconds: 1),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
          ),
        ],
      ),
      body: Scrollbar(
        controller: _scrollController, // Attach ScrollController
        thickness: 6.0,
        radius: const Radius.circular(10),
        thumbVisibility: true,
        child: ListView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          children: [
            /// **📌 Recipe Name**
            Center(
              child: Text(
                widget.recipeTitle,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 15),

            /// **🍽️ Recipe Icon Placeholder**
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.restaurant_menu,
                  size: 100,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 20),

            /// **🛒 Ingredients List**
            _buildSectionTitle("Ingredients"),
            _buildCardContent("""
- 1 cup Flour
- 2 Eggs
- 1/2 tsp Salt
- 1/2 cup Milk
- 1 tbsp Butter
            """),
            const SizedBox(height: 20),

            /// **📖 Cooking Steps**
            _buildSectionTitle("Steps to Cook"),
            _buildCardContent("""
1️⃣ Mix flour, eggs, and salt in a bowl.  
2️⃣ Slowly add milk while whisking to make a smooth batter.  
3️⃣ Melt butter in a pan and pour batter evenly.  
4️⃣ Cook on low heat until golden brown. Flip and cook the other side.  
5️⃣ Serve hot and enjoy! 🍽️  
            """),
            const SizedBox(height: 30),

            /// **🛍️ Add to Grocery List Button**
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.to(() => GroceryListScreen());
                },
                icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
                label: const Text("Add to Grocery List"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// **📌 Helper Function: Section Titles**
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  /// **📌 Helper Function: Card Styling**
  Widget _buildCardContent(String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(content, style: const TextStyle(fontSize: 16, height: 1.5)),
    );
  }
}
