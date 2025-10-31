// Path: lib/Pages/Schedule_Page/schedule_page.dart (Replace the old content)

import 'package:flutter/material.dart';
import 'package:delego/Pages/Schedule_Page/schedule_pagebody.dart';
import 'package:delego/models/schedule.dart'; // Import models
import 'package:delego/constants/backend.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  // Constants for Caching
  static const String _cacheKey = 'fullScheduleData';
  static const String _timestampKey = 'fullScheduleTimestamp';
  // 90 minutes in milliseconds
  static const int _cacheDurationMs = 90 * 60 * 1000;

  List<ConferenceDay> _days = [];
  List<Schedule> _allEvents = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchFullSchedule();
  }

  // Helper function to safely parse the JSON response
  void _parseAndSetSchedule(String responseBody) {
    final Map<String, dynamic> data = jsonDecode(responseBody);

    final List<ConferenceDay> daysList =
    (data['conference_days'] as List)
        .map((json) => ConferenceDay.fromJson(json))
        .toList();

    final List<Schedule> eventsList =
    (data['events'] as List)
        .map((json) => Schedule.fromJson(json))
        .toList();

    setState(() {
      _days = daysList;
      _allEvents = eventsList;
      _isLoading = false;
    });
  }

  Future<void> _fetchFullSchedule() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;

    // 1. ATTEMPT TO LOAD FROM CACHE
    final cachedData = prefs.getString(_cacheKey);
    final cacheTimestamp = prefs.getInt(_timestampKey);
    bool cacheValid = false;

    if (cachedData != null && cacheTimestamp != null) {
      if (now - cacheTimestamp < _cacheDurationMs) {
        // Cache is valid. Use it immediately.
        _parseAndSetSchedule(cachedData);
        cacheValid = true;
        print('Loaded schedule from valid cache.');
        return; // Return early if cache is valid
      } else {
        print('Cache expired. Attempting network fetch.');
      }
    }

    // 2. FETCH FROM NETWORK
    try {
      final url = Uri.parse('${Backend.baseUrl}/schedule');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseBody = response.body;

        // Parse, update state
        _parseAndSetSchedule(responseBody);

        // Cache the new data and timestamp
        await prefs.setString(_cacheKey, responseBody);
        await prefs.setInt(_timestampKey, now);
        print('Successfully fetched and cached new schedule data.');

      } else {
        final responseData = json.decode(response.body);
        throw Exception(responseData['detail'] ?? 'Server error: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Network fetch failed: $e');

      // 3. HANDLE NETWORK ERROR / FALLBACK TO EXPIRED CACHE
      if (cachedData != null && _days.isEmpty) {
        // If network failed but we have *expired* data, use it as a fallback
        _parseAndSetSchedule(cachedData);
        _error = 'Could not update data. Displaying cached schedule.';
        print('Network failed, falling back to expired cache.');
      } else if (_days.isEmpty) {
        // Network failed AND we have no data at all
        _error = 'Data not available: ${e.toString().contains('Exception:') ? e.toString().replaceFirst('Exception: ', '') : 'Please check your connection.'}';
      }
    }

    // Final state update (only necessary if network failed or error occurred)
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    // ... (UI code remains the same as before) ...
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Schedule', style: TextStyle(color: Colors.white)), backgroundColor: Colors.blue.shade900,),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null && _days.isEmpty) {
      // Show error only if there is no data to display (no valid or expired cache)
      return Scaffold(
        appBar: AppBar(title: const Text('Schedule', style: TextStyle(color: Colors.white)), backgroundColor: Colors.blue.shade900,),
        body: Center(
          child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_error!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, color: Colors.redAccent)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _fetchFullSchedule,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ]
              )
          ),
        ),
      );
    }

    // Conditionally show a snackbar if there's an error but we're showing data (expired cache fallback)
    if (_error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_error!),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      });
    }

    // Use DefaultTabController with the dynamic length
    return DefaultTabController(
      length: _days.length, // Dynamic length!
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white,),
          backgroundColor: Colors.blue.shade900,
          centerTitle: true,
          title: const Text(
            "Schedule",
            style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w600,),
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            // Dynamic Tabs!
            tabs: _days.map((day) => Tab(text: day.dayKey)).toList(),
          ),
        ),
        body: TabBarView(
          // Dynamic Tab Views!
          children: _days.map((day) {
            final filteredEvents = _allEvents
                .where((event) => event.day == day.dayKey)
                .toList();

            return Scaffold(
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Dynamic Date Header!
                  GradientAppBar(day.displayDate),
                  // Pass the filtered list directly to the body widget
                  SchedulePageBody(schedules: filteredEvents),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class GradientAppBar extends StatelessWidget {
  final String title;
  final double barHeight = 66.0;

  GradientAppBar(this.title);

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: statusBarHeight),
      height: statusBarHeight + barHeight,
      child: Center(
        child: Text(
          title,
          style: TextStyle(
              color: Colors.blue.shade800,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 24.0),
        ),
      ),
    );
  }
}