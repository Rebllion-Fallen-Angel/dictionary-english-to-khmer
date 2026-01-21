import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FavoriteController favController = Get.put(FavoriteController());

  List<Map<String, dynamic>> wordData = [];
  List<Map<String, dynamic>> _allWords = [];
  // String? _userEmail;
  bool _isLoading = true;

  final String url = "https://nubbdictapi.kode4u.tech";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      Get.offAllNamed('/login');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("$url/api/auth/me"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        // final userData = jsonDecode(response.body);
        setState(() {
          // _userEmail = userData['user']['name'];
          _isLoading = false;
          _loadWords();
        });
      } else {
        // Token might be expired or invalid
        // _logout();
      }
    } catch (e) {
      print("Error loading user data: $e");
      // _logout();
    }
  }

  Future<void> _loadWords() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    try {
      final response = await http.get(
        Uri.parse("$url/api/dictionary"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      final decodedBody = utf8.decode(response.bodyBytes);
      final jsonResponse = jsonDecode(decodedBody);
      if (jsonResponse is Map && jsonResponse.containsKey('words')) {
        final words = jsonResponse['words'] as List;
        setState(() {
          _allWords = words.cast<Map<String, dynamic>>();
          wordData = List.from(_allWords);
          _isLoading = false;
        });
      } else {
        var errorData = jsonDecode(response.body);
        print('Error: ${errorData['error']}');
      }
    } catch (e) {
      print("Error fetching word: $e");
    }
  }

  void _filterWords(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() {
        wordData = List.from(_allWords);
      });
      return;
    }

    setState(() {
      wordData =
          _allWords
              .where(
                (w) => (w['englishWord'] ?? '')
                    .toString()
                    .toLowerCase()
                    .contains(q),
              )
              .cast<Map<String, dynamic>>()
              .toList();
    });
  }

  // void _logout() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.remove("token");
  //   Get.offAllNamed('/login');
  // }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "វចនានុក្រម អង់គ្លេស-ខ្មេរ",
          style: TextStyle(color: Colors.white, fontSize: 26),
        ),
        toolbarHeight: 70,
        centerTitle: true,
        backgroundColor: Colors.indigo,
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.logout, color: Colors.white),
        //     onPressed: _logout,
        //   ),
        // ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.indigo,
            padding: EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => _filterWords(v),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "ស្វែងរកពាក្យ...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.search),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterWords('');
                            },
                          )
                          : null,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: wordData.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, index) {
                final item = wordData[index];
                return GestureDetector(
                  onTap: () {
                    Get.toNamed('/wordDetail', arguments: wordData[index]);
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
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
                                item['englishWord'] ?? '—',
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
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class FavoriteController extends GetxController {
  // Reactive list storing favorite word maps
  var favoriteList = <dynamic>[].obs;

  static const String _prefsKey = 'favorites';

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  // Load favorites from SharedPreferences
  Future<void> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_prefsKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final decoded = jsonDecode(jsonStr) as List;
        favoriteList.assignAll(decoded.cast<dynamic>());
      }
    } catch (e) {
      print('Failed loading favorites: $e');
    }
  }

  // Save favorites to SharedPreferences
  Future<void> saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(favoriteList.toList()));
    } catch (e) {
      print('Failed saving favorites: $e');
    }
  }

  // Toggle favorite by a stable key (englishWord)
  void toggleFavorite(dynamic item) {
    final key = item['englishWord']?.toString();
    if (key == null) return;

    final existingIndex = favoriteList.indexWhere(
      (i) => i['englishWord']?.toString() == key,
    );
    if (existingIndex >= 0) {
      favoriteList.removeAt(existingIndex);
    } else {
      favoriteList.add(item);
    }

    saveFavorites();
  }

  // Check if an item is favorited by englishWord
  bool isFavorite(dynamic item) {
    final key = item['englishWord']?.toString();
    if (key == null) return false;
    return favoriteList.any((i) => i['englishWord']?.toString() == key);
  }
}
