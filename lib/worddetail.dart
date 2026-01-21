import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:directionay_english_khmer/home.dart';
import 'package:flutter_html/flutter_html.dart';

class WordDetail extends StatelessWidget {
  final word = Get.arguments as Map<String, dynamic>? ?? {};
  final FavoriteController favController =
      Get.isRegistered<FavoriteController>()
          ? Get.find<FavoriteController>()
          : Get.put(FavoriteController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          word['englishWord'],
          style: TextStyle(color: Colors.white, fontSize: 26),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        toolbarHeight: 70,
        centerTitle: true,
        backgroundColor: Colors.indigo,
        actions: [
          Obx(
            () => IconButton(
              onPressed: () => favController.toggleFavorite(word),
              icon: Icon(
                favController.isFavorite(word)
                    ? Icons.bookmark
                    : Icons.bookmark_border,
                size: 25,
                color: favController.isFavorite(word) ? Colors.red : null,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            word['englishWord'],
                            style: TextStyle(
                              fontSize: 32,
                              color: Colors.indigo,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.indigo[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey, width: 1),
                            ),
                            child: Text(
                              word['partOfSpeech'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.indigo,
                              ),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.volume_up,
                          size: 30,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Container(
                  padding: EdgeInsets.only(
                    left: 32,
                    top: 8,
                    right: 8,
                    bottom: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Html(
                    data: word['khmerDef'].toString(),
                    style: {
                      "body": Style(
                        fontFamily: 'Battambang',
                        fontSize: FontSize(16),
                      ),
                      // "p": Style(
                      //   fontFamily: 'Battambang',
                      //   fontSize: FontSize(14),
                      // ),
                      // "div": Style(
                      //   fontFamily: 'Battambang',
                      //   fontSize: FontSize(14),
                      // ),

                      // "*": Style(
                      //   fontFamily: 'Battambang',
                      //   fontSize: FontSize(14),
                      // ),
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
