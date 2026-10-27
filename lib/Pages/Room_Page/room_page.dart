import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:delego/constants/backend.dart';
import 'package:delego/widgets/neon.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// 1. Real HTTP Client
final http.Client httpClient = http.Client();

// 2. Real SharedPreferences Instance Getter
Future<SharedPreferences> getSharedPreferencesInstance() =>
    SharedPreferences.getInstance();

// --- DATA MODELS (100% Backend-Driven) ---

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
      id: (json['id'] ?? '').toString(),
      committeeName: (json['committee_name'] ?? '').toString(),
      roomCode: (json['room_code'] ?? '').toString(),
      floor: (json['floor'] ?? '').toString(),
    );
  }
}

class FloorBlock {
  final double x;
  final double y;
  final double w;
  final double h;
  final String type;
  final String label;
  final String? roomCode;

  const FloorBlock({
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    required this.type,
    required this.label,
    this.roomCode,
  });

  factory FloorBlock.fromJson(Map<String, dynamic> json) {
    return FloorBlock(
      x: (json['x'] as num?)?.toDouble() ?? 0,
      y: (json['y'] as num?)?.toDouble() ?? 0,
      w: (json['w'] as num?)?.toDouble() ?? 100,
      h: (json['h'] as num?)?.toDouble() ?? 100,
      type: (json['type'] ?? 'room').toString(),
      label: (json['label'] ?? '').toString(),
      roomCode: json['room_code']?.toString(),
    );
  }
}

class FloorPlanData {
  final String id;
  final String name;
  final String shortName;
  final Color backgroundColor;
  final Color fillColor;
  final Color centerColor;
  final Color borderColor;
  final Color textColor;
  final Color accentTextColor;
  final String topEntrance;
  final String bottomEntrance;
  final String? imageUrl;
  final bool useImage;
  final List<FloorBlock> blocks;

  const FloorPlanData({
    required this.id,
    required this.name,
    required this.shortName,
    required this.backgroundColor,
    required this.fillColor,
    required this.centerColor,
    required this.borderColor,
    required this.textColor,
    required this.accentTextColor,
    required this.topEntrance,
    required this.bottomEntrance,
    required this.imageUrl,
    required this.useImage,
    required this.blocks,
  });

  static Color _parseHex(String? raw, Color fallback) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final clean = raw.trim().replaceAll('#', '');
    final hex = clean.length == 6 ? 'FF$clean' : clean;
    final val = int.tryParse(hex, radix: 16);
    return val != null ? Color(val) : fallback;
  }

  factory FloorPlanData.fromJson(Map<String, dynamic> json) {
    final rawBlocks = (json['blocks'] as List<dynamic>?) ?? const [];
    return FloorPlanData(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      shortName: (json['short_name'] ?? json['name'] ?? '').toString(),
      backgroundColor:
          _parseHex(json['background_color']?.toString(), Colors.black),
      fillColor:
          _parseHex(json['fill_color']?.toString(), const Color(0xFF153275)),
      centerColor:
          _parseHex(json['center_color']?.toString(), const Color(0xFF005CFF)),
      borderColor:
          _parseHex(json['border_color']?.toString(), const Color(0xFFBFFF00)),
      textColor: _parseHex(json['text_color']?.toString(), Colors.white),
      accentTextColor: _parseHex(
          json['accent_text_color']?.toString(), const Color(0xFFBFFF00)),
      topEntrance: (json['top_entrance'] ?? '').toString(),
      bottomEntrance: (json['bottom_entrance'] ?? '').toString(),
      imageUrl: json['image_url']?.toString(),
      useImage: json['use_image'] == true,
      blocks: rawBlocks
          .whereType<Map<String, dynamic>>()
          .map(FloorBlock.fromJson)
          .toList(),
    );
  }
}

class BuildingFloorPlans {
  final double canvasWidth;
  final double canvasHeight;
  final List<FloorPlanData> floors;

  const BuildingFloorPlans({
    this.canvasWidth = 1000,
    this.canvasHeight = 1000,
    this.floors = const [],
  });

  factory BuildingFloorPlans.fromJson(Map<String, dynamic> json) {
    final rawFloors = (json['floors'] as List<dynamic>?) ?? const [];
    return BuildingFloorPlans(
      canvasWidth: (json['canvas_width'] as num?)?.toDouble() ?? 1000,
      canvasHeight: (json['canvas_height'] as num?)?.toDouble() ?? 1000,
      floors: rawFloors
          .whereType<Map<String, dynamic>>()
          .map(FloorPlanData.fromJson)
          .toList(),
    );
  }
}

/// Normalizes room codes so backend entries like "CR 408" and "E. CR 408" match
/// dynamically without any hardcoded room tables.
String normalizeRoomCode(String raw) {
  var s = raw.toUpperCase().trim();
  s = s.replaceFirst(RegExp(r'^E\.?\s*'), '');
  s = s.replaceAll(RegExp(r'[^A-Z0-9]'), '');
  return s;
}

class RoomPage extends StatefulWidget {
  const RoomPage({super.key});
  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage>
    with SingleTickerProviderStateMixin {
  List<Room> _rooms = [];
  BuildingFloorPlans _floorPlans = const BuildingFloorPlans();
  bool _isLoading = true;
  String? _error;

  int _activeTab = 0; // 0 = Allotted Rooms, 1 = Floor Plan
  int _selectedFloorIndex = 0;
  String? _highlightedRoomNorm;
  FloorBlock? _selectedBlock;

  static const String _roomsCacheKey = 'allotedRoomsData_v5';
  static const String _roomsTimestampKey = 'allotedRoomsTimestamp_v5';
  static const String _floorsCacheKey = 'buildingFloorPlans_v1';

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedRooms = prefs.getString(_roomsCacheKey);
    final cachedFloors = prefs.getString(_floorsCacheKey);
    final now = DateTime.now().millisecondsSinceEpoch;

    if (cachedRooms != null) {
      final parsed = _parseRooms(cachedRooms);
      if (parsed.isNotEmpty && mounted) {
        setState(() {
          _rooms = parsed;
          _isLoading = false;
          _error = null;
        });
      }
    }
    if (cachedFloors != null) {
      final parsedFloors = _parseFloorPlans(cachedFloors);
      if (parsedFloors.floors.isNotEmpty && mounted) {
        setState(() {
          _floorPlans = parsedFloors;
          if (_selectedFloorIndex >= _floorPlans.floors.length) {
            _selectedFloorIndex = 0;
          }
        });
      }
    }

    if (_rooms.isEmpty && mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    await Future.wait([
      _fetchRoomsFromServer(prefs, now),
      _fetchFloorPlansFromServer(prefs),
    ]);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchRoomsFromServer(
      SharedPreferences prefs, int nowMs) async {
    try {
      final url = Uri.parse('${Backend.baseUrl}/rooms');
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final responseBody = response.body;
        final freshRooms = _parseRooms(responseBody);
        if (freshRooms.isNotEmpty) {
          _rooms = freshRooms;
          await prefs.setString(_roomsCacheKey, responseBody);
          await prefs.setString(_roomsTimestampKey, nowMs.toString());
          if (mounted) setState(() => _error = null);
        }
      } else {
        final responseData = json.decode(response.body);
        final errorMessage = responseData['message'] ??
            'Server error: Status Code ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (_rooms.isEmpty) {
        _error =
            'Data not available: ${e.toString().contains('Exception:') ? e.toString().replaceFirst('Exception: ', '') : 'Please check your connection.'}';
      }
    }
  }

  Future<void> _fetchFloorPlansFromServer(SharedPreferences prefs) async {
    try {
      final url = Uri.parse('${Backend.baseUrl}/floor_plans');
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final parsed = _parseFloorPlans(response.body);
        if (parsed.floors.isNotEmpty) {
          await prefs.setString(_floorsCacheKey, response.body);
          if (mounted) {
            setState(() {
              _floorPlans = parsed;
              if (_selectedFloorIndex >= _floorPlans.floors.length) {
                _selectedFloorIndex = 0;
              }
            });
          }
        }
      }
    } catch (_) {
      // Offline or not yet deployed: cached floor plans (if any) stay on screen.
    }
  }

  /// Parses rooms directly from backend JSON with zero hardcoded committees or rooms.
  List<Room> _parseRooms(String jsonString) {
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .whereType<Map<String, dynamic>>()
          .map(Room.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  BuildingFloorPlans _parseFloorPlans(String jsonString) {
    try {
      final Map<String, dynamic> data =
          jsonDecode(jsonString) as Map<String, dynamic>;
      return BuildingFloorPlans.fromJson(data);
    } catch (_) {
      return const BuildingFloorPlans();
    }
  }

  /// Finds all committees assigned to a floor block via normalized room code matching.
  List<Room> _committeesForBlock(FloorPlanData floor, FloorBlock block) {
    final targetNorm = normalizeRoomCode(block.roomCode ?? block.label);
    if (targetNorm.isEmpty ||
        targetNorm == 'TBA' ||
        targetNorm == 'NA' ||
        block.type != 'room') {
      return const [];
    }
    return _rooms.where((r) {
      final rNorm = normalizeRoomCode(r.roomCode);
      if (rNorm.isEmpty || rNorm == 'TBA') return false;
      return rNorm == targetNorm;
    }).toList();
  }

  /// Jumps from a committee room card directly to its floor and highlights the room on the map.
  void _locateRoomOnMap(Room room) {
    final roomNorm = normalizeRoomCode(room.roomCode);
    final floorNorm = room.floor.trim().toLowerCase();

    int targetFloorIdx = -1;
    FloorBlock? matchedBlock;

    if (_floorPlans.floors.isNotEmpty) {
      // 1. Try matching by room code across floors
      if (roomNorm.isNotEmpty && roomNorm != 'TBA') {
        for (var i = 0; i < _floorPlans.floors.length; i++) {
          final f = _floorPlans.floors[i];
          for (final b in f.blocks) {
            if (b.type == 'room' &&
                normalizeRoomCode(b.roomCode ?? b.label) == roomNorm) {
              targetFloorIdx = i;
              matchedBlock = b;
              break;
            }
          }
          if (targetFloorIdx != -1) break;
        }
      }

      // 2. Fallback: match by floor name (e.g. "Floor 4")
      if (targetFloorIdx == -1 && floorNorm.isNotEmpty && floorNorm != 'tba') {
        targetFloorIdx = _floorPlans.floors.indexWhere(
          (f) =>
              f.name.toLowerCase() == floorNorm ||
              f.shortName.toLowerCase() == floorNorm,
        );
      }
    }

    setState(() {
      _activeTab = 1;
      if (targetFloorIdx != -1) {
        _selectedFloorIndex = targetFloorIdx;
      }
      _highlightedRoomNorm =
          (roomNorm.isNotEmpty && roomNorm != 'TBA') ? roomNorm : null;
      _selectedBlock = matchedBlock;
    });
  }

  static const List<({List<Color> colors, Color fg, Color accent})> _palettes =
      [
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
    final isDarkFg = fg.computeLuminance() < 0.3;
    final pillBg = isDarkFg
        ? Colors.black.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.24);
    final pillBorder = fg.withValues(alpha: 0.35);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: p.colors,
        ),
        border: Border.all(
          color: fg.withValues(alpha: 0.22),
          width: 1.2,
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _locateRoomOnMap(room),
            splashColor: fg.withValues(alpha: 0.18),
            highlightColor: fg.withValues(alpha: 0.10),
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
                MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.noScaling),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final contentWidth = constraints.maxWidth - 28;
                      final contentHeight = constraints.maxHeight - 28;
                      final scale = math.min(
                        (contentWidth / 190).clamp(0.4, 1.0),
                        (contentHeight / 120).clamp(0.4, 1.0),
                      );
                      final badgeScale = scale.clamp(0.75, 1.0);
                      return Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      room.committeeName,
                                      maxLines: 1,
                                      softWrap: false,
                                      style: TextStyle(
                                        fontFamily: Neon.font,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 22 * scale,
                                        color: fg,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 7.5 * badgeScale,
                                    vertical: 3.5 * badgeScale,
                                  ),
                                  decoration: BoxDecoration(
                                    color: pillBg,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: pillBorder,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.location_on_rounded,
                                        size: 11.5 * badgeScale,
                                        color: fg,
                                      ),
                                      SizedBox(width: 3 * badgeScale),
                                      Text(
                                        'MAP',
                                        style: Neon.label(
                                          fg,
                                          size: 9 * badgeScale,
                                          spacing: 0.8,
                                        ),
                                      ),
                                      SizedBox(width: 1.5 * badgeScale),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        size: 13 * badgeScale,
                                        color: fg,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              'ROOM',
                              style: Neon.label(fg.withValues(alpha: 0.75),
                                  size: 10 * scale, spacing: 2 * scale),
                            ),
                            SizedBox(height: 2 * scale),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                room.roomCode,
                                maxLines: 1,
                                softWrap: false,
                                style: TextStyle(
                                  fontFamily: Neon.font,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 34 * scale,
                                  height: 1.05,
                                  color: fg,
                                ),
                              ),
                            ),
                            SizedBox(height: 4 * scale),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    floor.isNotEmpty ? floor : 'Tap to locate',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: Neon.font,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12 * scale,
                                      color: fg.withValues(alpha: 0.88),
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.touch_app_rounded,
                                  size: 13.5 * badgeScale,
                                  color: fg.withValues(alpha: 0.85),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoomsGrid(ColorScheme scheme, TextTheme textTheme) {
    if (_isLoading && _rooms.isEmpty) {
      return Center(child: CircularProgressIndicator(color: scheme.primary));
    }
    if (_rooms.isEmpty && _error != null) {
      return Center(
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
                onPressed: _fetchAll,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry Fetch'),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(builder: (context, c) {
      const pad = 14.0, gap = 12.0;
      final rows = (_rooms.length / 2).ceil().clamp(1, 100);
      final tileW = (c.maxWidth - pad * 2 - gap) / 2;
      final fitH = (c.maxHeight - pad * 2 - gap * (rows - 1)) / rows;
      final tileH = fitH.clamp(110.0, 220.0);
      return GridView.builder(
        padding: const EdgeInsets.all(pad),
        physics: const BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: gap,
          crossAxisSpacing: gap,
          childAspectRatio: tileW / tileH,
        ),
        itemCount: _rooms.length,
        itemBuilder: (context, index) => _buildRoomCard(_rooms[index], index),
      );
    });
  }

  Widget _buildFloorPlanView(ColorScheme scheme, TextTheme textTheme) {
    final floors = _floorPlans.floors;
    if (floors.isEmpty) {
      if (_isLoading) {
        return Center(child: CircularProgressIndicator(color: scheme.primary));
      }
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.map_outlined, size: 54, color: Neon.pink),
              const SizedBox(height: 12),
              Text(
                'Floor plans are loaded dynamically from the server.',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(color: scheme.onSurface),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchAll,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Floor Plans'),
              ),
            ],
          ),
        ),
      );
    }

    final idx = _selectedFloorIndex.clamp(0, floors.length - 1);
    final floor = floors[idx];
    final selectedCommittees = _selectedBlock == null
        ? const <Room>[]
        : _committeesForBlock(floor, _selectedBlock!);

    return Column(
      children: [
        // Floor selector pills (dynamically built from backend floors array)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < floors.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  _FloorSelectorChip(
                    label: floors[i].shortName,
                    selected: i == idx,
                    activeColor: floors[i].centerColor,
                    borderColor: floors[i].borderColor,
                    onTap: () => setState(() {
                      _selectedFloorIndex = i;
                      _selectedBlock = null;
                    }),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Selected classroom / committee callout bar
        if (_selectedBlock != null && _selectedBlock!.label.trim().isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFF141622),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: floor.borderColor, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(Icons.meeting_room_rounded,
                    size: 18, color: floor.borderColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedCommittees.isNotEmpty
                        ? '${selectedCommittees.map((c) => c.committeeName).join(' / ')}  ·  ${_selectedBlock!.label.replaceAll('\n', ' ')} (${floor.name})'
                        : '${_selectedBlock!.label.replaceAll('\n', ' ')}  ·  ${floor.name}',
                    style: const TextStyle(
                      fontFamily: Neon.font,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() {
                    _selectedBlock = null;
                    _highlightedRoomNorm = null;
                  }),
                  child: const Icon(Icons.close_rounded,
                      size: 18, color: Colors.white70),
                ),
              ],
            ),
          ),

        // Interactive zoomable floor plan canvas (or backend image if use_image == true)
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            decoration: BoxDecoration(
              color: floor.backgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: floor.borderColor.withValues(alpha: 0.45),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: InteractiveViewer(
                minScale: 1.0,
                maxScale: 3.5,
                child: Center(
                  child: floor.useImage &&
                          floor.imageUrl != null &&
                          floor.imageUrl!.trim().isNotEmpty
                      ? Image.network(
                          floor.imageUrl!.startsWith('http')
                              ? floor.imageUrl!
                              : '${Backend.baseUrl}${floor.imageUrl}',
                          fit: BoxFit.contain,
                        )
                      : AspectRatio(
                          aspectRatio: _floorPlans.canvasWidth /
                              _floorPlans.canvasHeight,
                          child: LayoutBuilder(
                            builder: (context, box) {
                              final sx =
                                  box.maxWidth / _floorPlans.canvasWidth;
                              final sy =
                                  box.maxHeight / _floorPlans.canvasHeight;
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // Top Lift Entrance callout + arrow
                                  if (floor.topEntrance.isNotEmpty)
                                    Positioned(
                                      left: 200 * sx,
                                      right: 200 * sx,
                                      top: 156 * sy,
                                      height: 58 * sy,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              floor.topEntrance,
                                              style: TextStyle(
                                                fontFamily: Neon.font,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                                color: floor.accentTextColor,
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_downward_rounded,
                                              size: 22,
                                              color: floor.accentTextColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                  // Bottom Lift Entrance arrow + callout
                                  if (floor.bottomEntrance.isNotEmpty)
                                    Positioned(
                                      left: 200 * sx,
                                      right: 200 * sx,
                                      top: 766 * sy,
                                      height: 62 * sy,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.arrow_upward_rounded,
                                              size: 22,
                                              color: floor.accentTextColor,
                                            ),
                                            Text(
                                              floor.bottomEntrance,
                                              style: TextStyle(
                                                fontFamily: Neon.font,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                                color: floor.accentTextColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                  // Dynamic blocks from backend floor_plans.json
                                  for (final b in floor.blocks)
                                    Positioned(
                                      left: b.x * sx,
                                      top: b.y * sy,
                                      width: b.w * sx,
                                      height: b.h * sy,
                                      child: _FloorBlockWidget(
                                        floor: floor,
                                        block: b,
                                        committees:
                                            _committeesForBlock(floor, b),
                                        highlighted: _highlightedRoomNorm !=
                                                null &&
                                            _highlightedRoomNorm ==
                                                normalizeRoomCode(
                                                    b.roomCode ?? b.label),
                                        onTap: () => setState(() {
                                          _selectedBlock = b;
                                          _highlightedRoomNorm =
                                              normalizeRoomCode(
                                                  b.roomCode ?? b.label);
                                        }),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          'Allotted Rooms',
          style: textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0.0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            child: Row(
              children: [
                Expanded(
                  child: _ModeTabButton(
                    label: 'ROOMS',
                    icon: Icons.grid_view_rounded,
                    selected: _activeTab == 0,
                    onTap: () => setState(() => _activeTab = 0),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ModeTabButton(
                    label: 'FLOOR PLAN',
                    icon: Icons.map_rounded,
                    selected: _activeTab == 1,
                    onTap: () => setState(() => _activeTab = 1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _activeTab == 0
          ? _buildRoomsGrid(scheme, textTheme)
          : _buildFloorPlanView(scheme, textTheme),
    );
  }
}

class _ModeTabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeTabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 36,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFBFFF00) : Colors.black26,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFFBFFF00) : Colors.white38,
            width: 1.4,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? const Color(0xFF111111) : Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: Neon.font,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 1.1,
                color: selected ? const Color(0xFF111111) : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloorSelectorChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color activeColor;
  final Color borderColor;
  final VoidCallback onTap;

  const _FloorSelectorChip({
    required this.label,
    required this.selected,
    required this.activeColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? activeColor : const Color(0xFF151722),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? borderColor : Colors.white24,
            width: selected ? 2.0 : 1.2,
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: Neon.font,
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _FloorBlockWidget extends StatelessWidget {
  final FloorPlanData floor;
  final FloorBlock block;
  final List<Room> committees;
  final bool highlighted;
  final VoidCallback onTap;

  const _FloorBlockWidget({
    required this.floor,
    required this.block,
    required this.committees,
    required this.highlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCenter = block.type == 'center';
    final hasCommittee = committees.isNotEmpty;
    final fill = isCenter
        ? floor.centerColor
        : (highlighted
            ? const Color(0xFFEE1C9C)
            : (hasCommittee
                ? Color.lerp(floor.fillColor, floor.centerColor, 0.38)!
                : floor.fillColor));
    final borderCol = highlighted ? Colors.white : floor.borderColor;

    Widget child;
    switch (block.type) {
      case 'wc':
        child = Padding(
          padding: const EdgeInsets.all(3),
          child: FittedBox(
            fit: BoxFit.contain,
            child: Icon(Icons.wc_rounded, color: floor.borderColor),
          ),
        );
        break;
      case 'exit_left':
        child = Padding(
          padding: const EdgeInsets.all(2),
          child: FittedBox(
            fit: BoxFit.contain,
            child: Transform.flip(
              flipX: true,
              child:
                  Icon(Icons.directions_run_rounded, color: floor.borderColor),
            ),
          ),
        );
        break;
      case 'exit_right':
        child = Padding(
          padding: const EdgeInsets.all(2),
          child: FittedBox(
            fit: BoxFit.contain,
            child: Icon(Icons.directions_run_rounded, color: floor.borderColor),
          ),
        );
        break;
      case 'center':
        child = Padding(
          padding: const EdgeInsets.all(8),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              block.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: Neon.font,
                fontWeight: FontWeight.w700,
                fontSize: 32,
                color: floor.textColor,
              ),
            ),
          ),
        );
        break;
      default:
        final committeeLabel =
            committees.map((c) => c.committeeName).join(' / ');
        child = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasCommittee) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: floor.borderColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      committeeLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: Neon.font,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                ],
                Text(
                  block.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: Neon.font,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    height: 1.15,
                    color: highlighted ? Colors.white : floor.textColor,
                  ),
                ),
              ],
            ),
          ),
        );
    }

    return GestureDetector(
      onTap: isCenter ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(isCenter ? 10 : 7),
          border: Border.all(
            color: borderCol,
            width: highlighted ? 2.6 : 1.7,
          ),
          boxShadow: highlighted
              ? [
                  BoxShadow(
                    color: floor.borderColor.withValues(alpha: 0.7),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
