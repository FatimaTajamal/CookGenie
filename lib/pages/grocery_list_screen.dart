import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GroceryController extends GetxController {
  var groceryList = <Map<String, dynamic>>[].obs;

  void addItem(String item) {
    if (item.isNotEmpty) {
      groceryList.add({"name": item, "checked": false});
    }
  }

  void toggleCheck(int index) {
    groceryList[index]["checked"] = !groceryList[index]["checked"];
    groceryList.refresh();
  }

  void removeItem(int index) {
    groceryList.removeAt(index);
  }
}

class GroceryListScreen extends StatelessWidget {
  final GroceryController controller = Get.put(GroceryController());

  GroceryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController itemController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Grocery List"),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInputField(itemController),
            const SizedBox(height: 16),
            _buildGroceryList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController itemController) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: itemController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                hintText: "Add grocery item...",
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.add_circle,
              color: Colors.deepOrange,
              size: 28,
            ),
            onPressed: () {
              controller.addItem(itemController.text);
              itemController.clear();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGroceryList() {
    return Expanded(
      child: Obx(
        () =>
            controller.groceryList.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                  itemCount: controller.groceryList.length,
                  itemBuilder: (context, index) {
                    return _buildGroceryItem(index);
                  },
                ),
      ),
    );
  }

  Widget _buildGroceryItem(int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Checkbox(
          value: controller.groceryList[index]["checked"],
          onChanged: (value) => controller.toggleCheck(index),
        ),
        title: Text(
          controller.groceryList[index]["name"],
          style: TextStyle(
            fontSize: 18,
            decoration:
                controller.groceryList[index]["checked"]
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
            color:
                controller.groceryList[index]["checked"]
                    ? Colors.grey
                    : Colors.black87,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _showDeleteConfirmation(index),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.shopping_cart, size: 80, color: Colors.grey),
        const SizedBox(height: 10),
        const Text(
          "No items added yet!",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(int index) {
    Get.defaultDialog(
      title: "Delete Item?",
      middleText: "Are you sure you want to remove this item?",
      textConfirm: "Yes",
      textCancel: "No",
      confirmTextColor: Colors.white,
      onConfirm: () {
        controller.removeItem(index);
        Get.back();
      },
    );
  }
}
