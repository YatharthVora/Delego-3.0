import 'package:flutter/material.dart';
import 'package:delego/Pages/Schedule_Page/schedule_pagebody.dart';
import 'package:delego/models/schedule.dart';
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
  static const String _cacheKey = 'fullScheduleData';
  static const String _timestampKey = 'fullScheduleTimestamp';

  List<ConferenceDay> _days = [];
  List<Schedule> _allEvents = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchFullSchedule();
  }

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
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    final cachedData = prefs.getString(_cacheKey);

    if (cachedData != null) {
      try {
        _parseAndSetSchedule(cachedData);
        _error = null;
      } catch (_) {}
    } else if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final url = Uri.parse('${Backend.baseUrl}/schedule');
      final response = await http.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (mounted) {
          _parseAndSetSchedule(responseBody);
        }
        await prefs.setString(_cacheKey, responseBody);
        await prefs.setInt(_timestampKey, now);
      } else {
        final responseData = json.decode(response.body);
        throw Exception(responseData['detail'] ?? 'Server error: Status ${response.statusCode}');
      }
    } catch (e) {
      if (cachedData != null && _days.isEmpty && mounted) {
        _parseAndSetSchedule(cachedData);
      } else if (_days.isEmpty) {
        _error = 'Data not available: ${e.toString().contains('Exception:') ? e.toString().replaceFirst('Exception: ', '') : 'Please check your connection.'}';
      }
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Schedule',
            style: textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.black,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null && _days.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Schedule',
            style: textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.black,
        ),
        body: Center(
            child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, textAlign: TextAlign.center,
                          style: textTheme.bodyLarge?.copyWith(color: scheme.error)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _fetchFullSchedule,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ]
                )
            )
        ),
      );
    }

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

    return DefaultTabController(
      length: _days.length,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Text(
            "Schedule",
            style: textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
            tabs: _days.map((day) => Tab(text: day.dayKey)).toList(),
          ),
        ),
        body: TabBarView(
          children: _days.map((day) {
            final filteredEvents =
            _allEvents.where((event) => event.day == day.dayKey).toList();
            return Scaffold(
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  GradientAppBar(day.displayDate),
                  SchedulePageBody(
                      schedules: filteredEvents, dateText: day.displayDate),
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
  final double barHeight = 42.0;
  GradientAppBar(this.title);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      height: barHeight,
      decoration: const BoxDecoration(
        color: Color(0xFFEE1C9C),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(6),
        ),
      ),
      child: Center(
        child: Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 17.0,
          ),
        ),
      ),
    );
  }
}
