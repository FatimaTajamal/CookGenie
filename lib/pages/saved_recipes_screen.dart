import 'package:flutter/material.dart';

class SavedRecipesScreen extends StatefulWidget {
  final List<Map<String, dynamic>> savedRecipes;
  final VoidCallback onBack;

  const SavedRecipesScreen({
    super.key,
    required this.savedRecipes,
    required this.onBack,
  });

  @override
  State<SavedRecipesScreen> createState() => _SavedRecipesScreenState();
}

class _SavedRecipesScreenState extends State<SavedRecipesScreen> {
  late List<Map<String, dynamic>> _localSavedRecipes;

  @override
  void initState() {
    super.initState();
    _localSavedRecipes = List.from(widget.savedRecipes); // make a copy to track changes
  }

  void _removeRecipe(int index) {
    setState(() {
      _localSavedRecipes.removeAt(index);
      widget.savedRecipes.removeAt(index); // update original list as well
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Recipes"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: _localSavedRecipes.isEmpty
          ? const Center(child: Text("No saved recipes yet!"))
          : ListView.builder(
              itemCount: _localSavedRecipes.length,
              itemBuilder: (context, index) {
                final recipe = _localSavedRecipes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              recipe['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeRecipe(index),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text("Ingredients:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        ...recipe['ingredients']
                            .map<Widget>((i) => Text("${i['name']} - ${i['quantity']}")),
                        const SizedBox(height: 10),
                        const Text("Instructions:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        ...recipe['instructions'].map<Widget>((step) => Text(step)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}









// import 'package:flutter/material.dart';

// class SavedRecipesScreen extends StatelessWidget {
//   const SavedRecipesScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Saved Recipes")),
//       body: const Center(child: Text("No saved recipes yet!")),
//     );
//   }
// }
