import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:directionay_english_khmer/home.dart';

class Favorite extends StatefulWidget {
  const Favorite({super.key});

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  final FavoriteController favController =
      Get.isRegistered<FavoriteController>()
          ? Get.find<FavoriteController>()
          : Get.put(FavoriteController());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "ពាក្យចូលចិត្ត",
          style: TextStyle(color: Colors.white, fontSize: 26),
        ),
        toolbarHeight: 70,
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: Obx(() {
        if (favController.favoriteList.isEmpty) {
          return const Center(child: Text("No favorites yet!"));
        }
        return ListView.builder(
          itemCount: favController.favoriteList.length,
          itemBuilder: (context, index) {
            final item = favController.favoriteList[index];
            return GestureDetector(
              onTap: () => Get.toNamed('/wordDetail', arguments: item),
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['englishWord'] ?? '',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['partOfSpeech'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Obx(
                            () => IconButton(
                              icon: Icon(
                                favController.isFavorite(item)
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color:
                                    favController.isFavorite(item)
                                        ? Colors.indigo
                                        : null,
                              ),
                              onPressed:
                                  () => favController.toggleFavorite(item),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.indigo,
                            size: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
