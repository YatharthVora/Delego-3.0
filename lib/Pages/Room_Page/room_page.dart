import 'package:flutter/material.dart';
import 'package:delego/constants/backend.dart';
import 'package:http/http.dart' as http; // Real HTTP package
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async'; // For Future/async operations

// --- BACKEND AND CLIENT SETUP ---

// 1. Real HTTP Client
final http.Client httpClient = http.Client();

// 2. Real SharedPreferences Instance Getter
Future<SharedPreferences> getSharedPreferencesInstance() => SharedPreferences.getInstance();

// Mock implementations removed

// --- DATA MODEL (remains the same) ---

class Room {
  final String id;
  final String committeeName;
  final String roomCode;
  final String floor;

  Room({
    required this.id,
    required this.committeeName,
    required this.roomCode,
    required this.floor,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as String,
      committeeName: json['committee_name'] as String,
      roomCode: json['room_code'] as String,
      floor: json['floor'] as String,
    );
  }
}

// --- STATEFUL WIDGET ---

class RoomPage extends StatefulWidget {
  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  List<Room> _rooms = [];
  bool _isLoading = true;
  String? _error;

  // Constants for Caching
  static const String _cacheKey = 'allotedRoomsData';
  static const String _timestampKey = 'allotedRoomsTimestamp';
  // 90 minutes in milliseconds
  static const int _cacheDurationMs = 120 * 60 * 1000;

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  // --- CORE DATA FETCHING AND CACHING LOGIC ---

  Future<void> _fetchRooms() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final prefs = await getSharedPreferencesInstance();

    // 1. ATTEMPT TO LOAD FROM CACHE
    final cachedData = prefs.getString(_cacheKey);
    final cacheTimestamp = prefs.getString(_timestampKey);
    final now = DateTime.now().millisecondsSinceEpoch;

    bool cacheValid = false;
    if (cachedData != null && cacheTimestamp != null) {
      final lastFetched = int.tryParse(cacheTimestamp) ?? 0;
      // Check if cache is less than 90 minutes old
      if (now - lastFetched < _cacheDurationMs) {
        _rooms = _parseRooms(cachedData);
        cacheValid = true;
        setState(() { _isLoading = false; }); // Display cached data immediately
        print('Loaded rooms from valid cache.');

        // Return early if cache is valid AND we don't need to refresh yet.
        return;
      }
    }

    // 2. FETCH FROM NETWORK
    print('Cache is invalid or missing. Fetching from network...');
    try {
      final url = Uri.parse('${Backend.baseUrl}/rooms'); // Using /rooms endpoint
      final response = await httpClient.get(url);

      if (response.statusCode == 200) {
        // Parse, update state, and cache the new data
        final responseBody = response.body;
        _rooms = _parseRooms(responseBody);

        // Cache the new data and timestamp
        await prefs.setString(_cacheKey, responseBody);
        await prefs.setString(_timestampKey, now.toString());
        print('Successfully fetched and cached new rooms data.');
      } else {
        // Handle non-200 status codes (e.g., 404, 500)
        final responseData = json.decode(response.body);
        final errorMessage = responseData['message'] ?? 'Server error: Status Code ${response.statusCode}';

        throw Exception(errorMessage); // Throw an exception to be caught below
      }
    } catch (e) {
      print('Network fetch failed: $e');
      // 3. HANDLE NETWORK ERROR

      if (_rooms.isEmpty) {
        // If network failed AND we have no rooms (not even expired cache), show error
        _error = 'Data not available: ${e.toString().contains('Exception:') ? e.toString().replaceFirst('Exception: ', '') : 'Please check your connection.'}';
        print('Error: Data not available, no cache fallback.');
      } else {
        // Network failed, but we still have expired cache data displayed.
        // The error indicates the **update failed**, not that *no data* is available.
        _error = 'Could not update data. Displaying cached information. Error: ${e.toString().contains('Exception:') ? e.toString().replaceFirst('Exception: ', '') : 'Network failed.'}';
        print('Warning: Network failed, using expired cache data.');
      }
    }

    // Final state update
    setState(() {
      _isLoading = false;
    });
  }

  // Helper function to safely parse the JSON response (remains the same)
  List<Room> _parseRooms(String jsonString) {
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Room.fromJson(json)).toList();
    } catch (e) {
      print('Error parsing rooms data: $e');
      return [];
    }
  }

  // --- UI HELPER ---

  Widget _buildRoomCard(Room room) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      padding: const EdgeInsets.all(25),
      // Using flexible sizing (width: double.infinity) is usually better than fixed
      width: double.infinity,
      decoration: ShapeDecoration(
        color: Color(0xFF114C90),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.92),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Committee Name
              Text(
                room.committeeName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  height: 1.2, // Use standard height instead of 0.09
                ),
              ),
              const SizedBox(height: 6),
              // Room Code
              Text(
                room.roomCode,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              // Floor
              Text(
                room.floor,
                style: const TextStyle(
                  color: Colors.white70, // Slightly lighter for contrast
                  fontSize: 16.0,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ],
          ),
          // Using a standard Flutter Icon as a fallback for the local asset
          const Icon(
            Icons.location_on,
            size: 40.0,
            color: Colors.white,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_isLoading && _rooms.isEmpty) {
      // Show loading indicator only if we have NO data to show (first load)
      content = const Center(child: CircularProgressIndicator(color: Colors.blue));
    } else if (_rooms.isEmpty && _error != null) {
      // Show error when fetching failed AND there is no cache
      content = Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchRooms,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry Fetch'),
              ),
            ],
          ),
        ),
      );
    } else {
      // Display the dynamic list of rooms (from network or cache)
      content = ListView.builder(
        itemCount: _rooms.length,
        itemBuilder: (context, index) {
          return _buildRoomCard(_rooms[index]);
        },
      );
    }

    // Conditionally show a snackbar or small message if there's an error
    // but we are still displaying cached data.
    if (_error != null && !_isLoading && _rooms.isNotEmpty) {
      // Use a subtle banner to inform the user about the stale data
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Allotted Rooms',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: content,
    );
  }
}
