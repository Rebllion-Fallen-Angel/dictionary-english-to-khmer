import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final String _baseUrl = 'https://nubbdictapi.kode4u.tech';

  bool _loadingProfile = false;
  bool _loadingPlans = false;
  bool _loadingCurrent = false;
  bool _loadingRate = false;
  bool _loadingSubscribe = false;

  String _username = '';
  String _email = '';

  List<Map<String, dynamic>> _plans = [];
  Map<String, dynamic>? _currentSubscription;
  Map<String, dynamic>? _rateData;

  // raw response strings for display
  String _plansResponse = '';
  String _currentResponse = '';
  String _rateResponse = '';
  String _subscribeResponse = '';

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await _fetchProfile();
    await _fetchPlans();
    await _fetchCurrent();
    await _fetchRateLimit();
  }

  Future<void> _fetchProfile() async {
    setState(() => _loadingProfile = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      setState(() {
        _username = '';
        _email = '';
        _loadingProfile = false;
      });
      return;
    }

    try {
      final resp = await http.get(
        Uri.parse('$_baseUrl/api/auth/me'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (resp.statusCode == 200) {
        final parsed = jsonDecode(resp.body);
        final user = parsed['user'] ?? {};
        setState(() {
          _username = (user['name'] ?? '').toString();
          _email = (user['email'] ?? '').toString();
        });
      } else {
        setState(() {
          _username = '';
          _email = '';
        });
      }
    } catch (e) {
      setState(() {
        _username = '';
        _email = '';
      });
    } finally {
      setState(() => _loadingProfile = false);
    }
  }

  Future<void> _fetchPlans() async {
    setState(() => _loadingPlans = true);
    try {
      final resp = await http.get(
        Uri.parse('$_baseUrl/api/subscription/plans'),
      );
      if (resp.statusCode == 200) {
        final parsed = jsonDecode(resp.body);
        final plans = parsed['plans'] as List? ?? [];
        setState(() => _plans = plans.cast<Map<String, dynamic>>());
      } else {
        setState(() => _plans = []);
      }
    } catch (e) {
      setState(() => _plans = []);
    } finally {
      setState(() => _loadingPlans = false);
    }
  }

  Future<void> _fetchCurrent() async {
    setState(() => _loadingCurrent = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      setState(() {
        _currentSubscription = null;
        _loadingCurrent = false;
      });
      return;
    }

    try {
      final resp = await http.get(
        Uri.parse('$_baseUrl/api/subscription/current'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (resp.statusCode == 200) {
        final parsed = jsonDecode(resp.body);
        setState(() {
          _currentSubscription =
              parsed['subscription'] is Map
                  ? Map<String, dynamic>.from(parsed['subscription'])
                  : null;
        });
      } else {
        setState(() => _currentSubscription = null);
      }
    } catch (e) {
      setState(() => _currentSubscription = null);
    } finally {
      setState(() => _loadingCurrent = false);
    }
  }

  Future<void> _fetchRateLimit() async {
    setState(() => _loadingRate = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      setState(() {
        _rateData = null;
        _loadingRate = false;
      });
      return;
    }

    try {
      final resp = await http.get(
        Uri.parse('$_baseUrl/api/subscription/rate-limit'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (resp.statusCode == 200) {
        final parsed = jsonDecode(resp.body);
        setState(
          () =>
              _rateData =
                  parsed is Map ? Map<String, dynamic>.from(parsed) : null,
        );
      } else {
        setState(() => _rateData = null);
      }
    } catch (e) {
      setState(() => _rateData = null);
    } finally {
      setState(() => _loadingRate = false);
    }
  }

  bool _isCurrentPlan(Map<String, dynamic> plan) {
    if (_currentSubscription == null) return false;
    final planId = plan['id']?.toString().toLowerCase();
    final currentPlan =
        (_currentSubscription!['plan_name'] ??
                _currentSubscription!['planName'] ??
                _currentSubscription!['plan'])
            ?.toString()
            .toLowerCase();
    if (currentPlan == null) return false;
    // try match by id or name
    return planId == currentPlan ||
        plan['name']?.toString().toLowerCase() == currentPlan;
  }

  Future<void> _subscribe(String planId) async {
    setState(() => _loadingSubscribe = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login first')));
      setState(() => _loadingSubscribe = false);
      return;
    }

    try {
      final resp = await http.post(
        Uri.parse('$_baseUrl/api/subscription/subscribe'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'planId': planId}),
      );
      if (resp.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subscription successful')),
        );
        await _fetchCurrent();
        await _fetchRateLimit();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error ${resp.statusCode}: ${resp.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loadingSubscribe = false);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Get.offAllNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontSize: 26),
        ),
        toolbarHeight: 70,
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.indigo,
                      child: Text(
                        _username.isNotEmpty ? _username[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _username.isNotEmpty ? _username : 'Not logged in',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _email.isNotEmpty ? _email : '',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _loadingProfile ? null : _fetchProfile,
                      icon:
                          _loadingProfile
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.refresh),
                      color: Colors.indigo,
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: _buildCurrentSubscriptionCard()),
                const SizedBox(width: 12),
                Expanded(child: _buildRateCard()),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              'Available Plans',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            _loadingPlans
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children:
                      _plans
                          .map(
                            (p) => Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                title: Text(p['name']?.toString() ?? ''),
                                subtitle: Text(
                                  'Rate limit: ${p['rateLimit']?.toString() ?? '-'}  •  Price: ${p['price']?.toString() ?? '-'}',
                                ),
                                trailing: ElevatedButton(
                                  onPressed:
                                      _isCurrentPlan(p) || _loadingSubscribe
                                          ? null
                                          : () =>
                                              _subscribe(p['id'].toString()),
                                  child:
                                      _isCurrentPlan(p)
                                          ? const Text('Current')
                                          : _loadingSubscribe
                                          ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                          : const Text('Buy'),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
            if (_plansResponse.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                width: double.infinity,
                color: Colors.grey[100],
                child: SelectableText(
                  _plansResponse,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ],
            if (_subscribeResponse.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                width: double.infinity,
                color: Colors.grey[50],
                child: SelectableText(
                  _subscribeResponse,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ],

            const SizedBox(height: 24),
            Text(
              'Status messages:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            SelectableText(_buildStatusText()),
          ],
        ),
      ),
    );
  }

  String _buildStatusText() {
    final plan =
        _currentSubscription != null
            ? (_currentSubscription!['plan_name'] ??
                _currentSubscription!['planName'] ??
                _currentSubscription!['plan'])
            : 'free';
    final rate =
        _rateData != null
            ? (_rateData!['rateLimit'] ?? _rateData!['rate_limit'] ?? '-')
            : '-';
    final remaining =
        _rateData != null ? (_rateData!['remaining'] ?? '-') : '-';
    return 'Plan: $plan\nRate limit: $rate\nRemaining: $remaining';
  }

  Widget _buildCurrentSubscriptionCard() {
    final sub = _currentSubscription;
    final planName =
        sub != null
            ? (sub['plan_name'] ?? sub['planName'] ?? sub['plan'] ?? 'Free')
            : 'Free';
    final expires =
        sub != null ? (sub['expires_at'] ?? sub['expiresAt'] ?? '') : '';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Subscription',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Plan: $planName', style: const TextStyle(fontSize: 14)),
            if (expires.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Expires: $expires',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _loadingCurrent ? null : _fetchCurrent,
                  child:
                      _loadingCurrent
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Refresh'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed:
                      () => setState(() {
                        _currentSubscription = null;
                        _currentResponse = '';
                      }),
                  child: const Text('Clear'),
                ),
              ],
            ),
            if (_currentResponse.isNotEmpty) ...[
              const Divider(),
              SelectableText(
                _currentResponse,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRateCard() {
    final r = _rateData;
    final rateLimit =
        r != null
            ? (r['rateLimit']?.toString() ?? r['rate_limit']?.toString() ?? '-')
            : '-';
    final remaining = r != null ? (r['remaining']?.toString() ?? '-') : '-';
    final resetAt = r != null ? (r['resetAt'] ?? r['reset_at'] ?? '') : '';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rate Limit',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Limit: $rateLimit'),
            const SizedBox(height: 4),
            Text(
              'Remaining: $remaining',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            if (resetAt.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Resets at: $resetAt',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _loadingRate ? null : _fetchRateLimit,
                  child:
                      _loadingRate
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Refresh'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed:
                      () => setState(() {
                        _rateData = null;
                        _rateResponse = '';
                      }),
                  child: const Text('Clear'),
                ),
              ],
            ),
            if (_rateResponse.isNotEmpty) ...[
              const Divider(),
              SelectableText(
                _rateResponse,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
