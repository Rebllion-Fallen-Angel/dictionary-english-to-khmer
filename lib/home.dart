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

  List<Map<String, dynamic>> wordData = [];
  String? _userEmail;
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
        final userData = jsonDecode(response.body);
        setState(() {
          _userEmail = userData['user']['name'];
          _isLoading = false;
          _loadWords();
        });
      } else {
        // Token might be expired or invalid
        _logout();
      }
    } catch (e) {
      print("Error loading user data: $e");
      _logout();
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

      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse is Map && jsonResponse.containsKey('words')) {
        final words = jsonResponse['words'] as List;
        setState(() {
          wordData = words.cast<Map<String, dynamic>>();
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

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    Get.offAllNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "វចនានុក្រម អង់គ្លេស-ខ្មេរ",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 30, 99, 156),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "ស្វែងរកពាក្យ...",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: wordData.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, index) {
                final item = wordData[index];
                return Card(
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
                                fontSize: 14,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.arrow_forward_ios)
                      ],
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
}
