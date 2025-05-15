import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'recipe_detail_screen.dart';
import 'RecipeScreen.dart';
import 'RecipeSearch.dart';

class HomeScreen extends StatefulWidget {
  final List<Map<String, dynamic>> savedRecipes;

  const HomeScreen({super.key, required this.savedRecipes});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> categories = [
    {
      "title": "Breakfast",
      "icon": Icons.free_breakfast,
      "color": Colors.orange,
    },
    {"title": "Lunch", "icon": Icons.lunch_dining, "color": Color(0xFF87EB8A)},
    {"title": "Dinner", "icon": Icons.restaurant, "color": Color(0xFF81BDEE)},
    {
      "title": "Brunch",
      "icon": Icons.brunch_dining,
      "color": Color(0xFFCF86DC),
    },
    {"title": "Snacks", "icon": Icons.fastfood, "color": Color(0xFFE2AAA6)},
  ];

  @override
 @override
void initState() {
  super.initState();
  loadSavedRecipes();
}

void loadSavedRecipes() async {
  await RecipeService.loadRecipesFromStorage();
  setState(() {});
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cook Genie"),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        elevation: 0,
      ),
      body: Scrollbar(
        controller: _scrollController,
        thickness: 6,
        radius: const Radius.circular(10),
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                const SizedBox(height: 20),
                const Text(
                  "Recipe Categories",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                _buildCategoryGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () => Get.to(() => RecipeScreen(savedRecipes: widget.savedRecipes)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 10),
            Text(
              "Search for recipes...",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => Get.to(
            () => RecipeDetailScreen(recipeTitle: categories[index]['title']),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: categories[index]['color'],
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 5,
                  spreadRadius: 2,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(categories[index]['icon'], size: 50, color: Colors.white),
                const SizedBox(height: 10),
                Text(
                  categories[index]['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}












// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'recipe_detail_screen.dart';
// import 'RecipeScreen.dart';

// class HomeScreen extends StatefulWidget {
//   final List<Map<String, dynamic>> savedRecipes;

//   const HomeScreen({super.key, required this.savedRecipes});

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }


// class _HomeScreenState extends State<HomeScreen> {
//   final ScrollController _scrollController = ScrollController();

//   final List<Map<String, dynamic>> categories = [
//     {
//       "title": "Breakfast",
//       "icon": Icons.free_breakfast,
//       "color": Colors.orange,
//     },
//     {"title": "Lunch", "icon": Icons.lunch_dining, "color": Color(0xFF87EB8A)},
//     {"title": "Dinner", "icon": Icons.restaurant, "color": Color(0xFF81BDEE)},
//     {
//       "title": "Brunch",
//       "icon": Icons.brunch_dining,
//       "color": Color(0xFFCF86DC),
//     },
//     {"title": "Snacks", "icon": Icons.fastfood, "color": Color(0xFFE2AAA6)},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Cook Genie"),
//         centerTitle: true,
//         backgroundColor: Colors.deepOrange,
//         elevation: 0,
//       ),
//       body: Scrollbar(
//         controller: _scrollController,
//         thickness: 6,
//         radius: const Radius.circular(10),
//         thumbVisibility: true, // ✅ Forces scrollbar visibility
//         child: SingleChildScrollView(
//           controller: _scrollController,
//           physics: const AlwaysScrollableScrollPhysics(), // ✅ Ensures scrolling
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildSearchBar(),
//                 const SizedBox(height: 20),
//                 const Text(
//                   "Recipe Categories",
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 _buildCategoryGrid(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//  Widget _buildSearchBar() {
//   return GestureDetector(
//     onTap: () => Get.to(() => RecipeScreen(savedRecipes: widget.savedRecipes)),
//     child: Container(
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       margin: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.search, color: Colors.grey),
//           SizedBox(width: 10),
//           Text(
//             "Search for recipes...",
//             style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
//           ),
//         ],
//       ),
//     ),
//   );
// }


//   Widget _buildCategoryGrid() {
//     return GridView.builder(
//       shrinkWrap: true, // ✅ Ensures GridView doesn't expand infinitely
//       physics:
//           const NeverScrollableScrollPhysics(), // ✅ Disables GridView's own scroll
//       padding: const EdgeInsets.only(top: 10),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         childAspectRatio: 1,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 10,
//       ),
//       itemCount: categories.length,
//       itemBuilder: (context, index) {
//         return GestureDetector(
//           onTap:
//               () => Get.to(
//                 () =>
//                     RecipeDetailScreen(recipeTitle: categories[index]['title']),
//               ),
//           child: Container(
//             decoration: BoxDecoration(
//               color: categories[index]['color'],
//               borderRadius: BorderRadius.circular(15),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.3),
//                   blurRadius: 5,
//                   spreadRadius: 2,
//                   offset: const Offset(0, 3),
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(categories[index]['icon'], size: 50, color: Colors.white),
//                 const SizedBox(height: 10),
//                 Text(
//                   categories[index]['title'],
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }