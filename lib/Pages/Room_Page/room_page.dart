import 'package:delego/widgets/neon.dart';
import 'package:flutter/material.dart';
import 'package:delego/constants/backend.dart';
import 'package:http/http.dart' as http;
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

class RoomPage extends StatefulWidget {
  const RoomPage({super.key});
  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  List<Room> _rooms = [];
  bool _isLoading = true;
  String? _error;

  static const String _cacheKey = 'allotedRoomsData_v4';
  static const String _timestampKey = 'allotedRoomsTimestamp_v4';

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_cacheKey);
    final now = DateTime.now().millisecondsSinceEpoch;

    if (cachedData != null) {
      final cachedRooms = _parseRooms(cachedData);
      if (cachedRooms.isNotEmpty && mounted) {
        setState(() {
          _rooms = cachedRooms;
          _isLoading = false;
          _error = null;
        });
      }
    } else if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final url = Uri.parse('${Backend.baseUrl}/rooms');
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final responseBody = response.body;
        final freshRooms = _parseRooms(responseBody);
        if (freshRooms.isNotEmpty) {
          _rooms = freshRooms;
          await prefs.setString(_cacheKey, responseBody);
          await prefs.setString(_timestampKey, now.toString());
        }
      } else {
        final responseData = json.decode(response.body);
        final errorMessage = responseData['message'] ?? 'Server error: Status Code ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (_rooms.isEmpty) {
        _error = 'Data not available: ${e.toString().contains('Exception:') ? e.toString().replaceFirst('Exception: ', '') : 'Please check your connection.'}';
      }
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Room> _parseRooms(String jsonString) {
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      var parsedRooms = jsonList.map((json) => Room.fromJson(json)).toList();
      if (!parsedRooms.any((r) => r.committeeName.toUpperCase() == 'DISEC')) {
        parsedRooms.add(Room(
          id: 'disec_9',
          committeeName: 'DISEC',
          roomCode: 'TBA',
          floor: 'TBA',
        ));
      }
      const order = ['UNSC', 'CCC', 'PSC', 'WTO', 'UNODC', 'UNICEF', 'ECOSOC', 'IPC', 'DISEC'];
      parsedRooms.sort((a, b) {
        int indexA = order.indexOf(a.committeeName.toUpperCase());
        int indexB = order.indexOf(b.committeeName.toUpperCase());
        if (indexA == -1) indexA = 999;
        if (indexB == -1) indexB = 999;
        return indexA.compareTo(indexB);
      });
      return parsedRooms;
    } catch (_) { return []; }
  }

  static const List<({List<Color> colors, Color fg, Color accent})> _palettes = [
    (
      colors: [Color(0xFFBFFF00), Color(0xFFBFFF00)],
      fg: Color(0xFF111111),
      accent: Neon.orange,
    ),
    (
      colors: [Color(0xFF005CFF), Color(0xFF005CFF)],
      fg: Colors.white,
      accent: Neon.lime,
    ),
    (
      colors: [Color(0xFF159555), Color(0xFF159555)],
      fg: Colors.white,
      accent: Neon.cyan,
    ),
    (
      colors: [Color(0xFFEE1C9C), Color(0xFFEE1C9C)],
      fg: Colors.white,
      accent: Neon.yellow,
    ),
  ];

  Widget _buildRoomCard(Room room, int index) {
    final p = _palettes[index % _palettes.length];
    final fg = p.fg;
    final floor = room.floor.trim();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: p.colors,
        ),
        boxShadow: [
          BoxShadow(
            color: p.colors.last.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: GridPainter(
                    color: Colors.black.withValues(alpha: 0.10), step: 10),
              ),
            ),
            Positioned(
              right: 6,
              bottom: 6,
              width: 72,
              height: 64,
              child: CustomPaint(
                painter: RingsPainter(
                    color: p.accent.withValues(alpha: 0.45),
                    count: 6,
                    seed: index + 3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      room.committeeName,
                      style: TextStyle(
                        fontFamily: Neon.font,
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        color: fg,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text('ROOM',
                      style: Neon.label(fg.withValues(alpha: 0.75),
                          size: 10, spacing: 2)),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      room.roomCode,
                      style: TextStyle(
                        fontFamily: Neon.font,
                        fontWeight: FontWeight.w700,
                        fontSize: 34,
                        height: 1.05,
                        color: fg,
                      ),
                    ),
                  ),
                  if (floor.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      floor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: Neon.font,
                        fontWeight: FontWeight.w500,
                        fontSize: 12.5,
                        color: fg.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget content;
    if (_isLoading && _rooms.isEmpty) {
      content = Center(child: CircularProgressIndicator(color: scheme.primary));
    } else if (_rooms.isEmpty && _error != null) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: scheme.error),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(color: scheme.error),
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
      content = LayoutBuilder(builder: (context, c) {
        const pad = 14.0, gap = 12.0;
        final rows = (_rooms.length / 2).ceil().clamp(1, 100);
        final tileW = (c.maxWidth - pad * 2 - gap) / 2;
        final fitH = (c.maxHeight - pad * 2 - gap * (rows - 1)) / rows;
        final tileH = fitH.clamp(130.0, 260.0);
        return GridView.builder(
          padding: const EdgeInsets.all(pad),
          physics: const ClampingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: gap,
            crossAxisSpacing: gap,
            childAspectRatio: tileW / tileH,
          ),
          itemCount: _rooms.length,
          itemBuilder: (context, index) =>
              _buildRoomCard(_rooms[index], index),
        );
      });
    }

    // Show snackBar for stale cache after widget build
    if (_error != null && !_isLoading && _rooms.isNotEmpty) {
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
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: const Color(0xFFEE1C9C),
        foregroundColor: scheme.onPrimary,
        iconTheme: IconThemeData(color: scheme.onPrimary),
        centerTitle: true,
        title: Text(
          'Allotted Rooms',
          style: textTheme.titleLarge?.copyWith(
            color: scheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0.0,
      ),
      body: content,
    );
  }
}





