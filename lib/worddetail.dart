import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';



class WordDetail extends StatelessWidget {
  final word = Get.arguments as Map<String, dynamic>? ?? {};
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
          IconButton(onPressed: () {}, icon: Icon(Icons.bookmark_border, size: 25,)),
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
                              fontWeight: FontWeight.bold
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
                              border: Border.all(
                                color: Colors.grey,
                                width: 1,
                              )
                            ),
                            child: Text(
                              word['partOfSpeech'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.indigo
                              ),
                            ),
                          ),
                        ],
                      ),
                      IconButton(onPressed: () {

                      }, 
                        icon: Icon(Icons.volume_up, 
                        size: 30,
                        color: Colors.indigo,)
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
                  child: HtmlWidget(
                    word['khmerDef'],
                    textStyle: TextStyle(
                      fontSize: 14,
                      fontFamily: 'NotoSansKhmer'
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
