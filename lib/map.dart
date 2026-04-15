import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xml/xml.dart';

// --- SPATIAL REGISTRY ---
class SpatialMetadata {
  final String assetPath;
  final List<String> targetRooms;

  const SpatialMetadata({required this.assetPath, required this.targetRooms});
}

class LocationRegistry {
  static const String unionMapAsset = 'assets/maps/union_3rd_floor.svg';
  static const String campusMapAsset = 'assets/maps/campus_map.svg';
  static const String firstFloorUnion = 'assets/maps/union_1rst_floor.svg';
  static const String secondFloorUnion = 'assets/maps/union_2nd_floor.svg';

  static const Map<String, SpatialMetadata> directory = {
    // --- UNION 1RST FLOOR ---
    'Hinde Auditorium (1st Floor)': SpatialMetadata(
      assetPath: firstFloorUnion,
      targetRooms: ['hinde_auditorium'],
    ),
    'Ballroom 1 (1st Floor)': SpatialMetadata(
      assetPath: firstFloorUnion,
      targetRooms: ['ballroom_one'],
    ),
    'Ballroom 2 (1st Floor)': SpatialMetadata(
      assetPath: firstFloorUnion,
      targetRooms: ['ballroom_two'],
    ),
    'Ballroom 3 (1st Floor)': SpatialMetadata(
      assetPath: firstFloorUnion,
      targetRooms: ['ballroom_three'],
    ),
    'Union Ballroom (1st Floor)': SpatialMetadata(
      assetPath: firstFloorUnion,
      targetRooms: ['ballroom_one', 'ballroom_two', 'ballroom_three'],
    ),
    'Sequoia Room (1st Floor)': SpatialMetadata(
      assetPath: firstFloorUnion,
      targetRooms: ['sequoia_1001a'],
    ),
    'Cypress Room (1st Floor)': SpatialMetadata(
      assetPath: firstFloorUnion,
      targetRooms: ['cypress_1001b'],
    ),
    'Lobby Suite (1st Floor)': SpatialMetadata(
      assetPath: firstFloorUnion,
      targetRooms: ['sequoia_1001a', 'cypress_1001b'],
    ),
    'Redwood Room (1st Floor)': SpatialMetadata(
      assetPath: firstFloorUnion,
      targetRooms: ['redwood_1030'],
    ),
    'Serna Plaza (1st Floor)': SpatialMetadata(
      assetPath: firstFloorUnion,
      targetRooms: ['stage_serna'],
    ),
    'Outdoor Stage (Union)': SpatialMetadata(
      assetPath: firstFloorUnion,
      targetRooms: ['stage_serna'],
    ),
    'Games Room (1st Floor)': SpatialMetadata(
      assetPath: firstFloorUnion,
      targetRooms: ['games_1235'],
    ),
    // --- UNION 2ND FLOOR ---
    'Orchard Suite (2nd Floor)': SpatialMetadata(
      assetPath: secondFloorUnion,
      targetRooms: ['orchard_2011'],
    ),
    'Orchard Room 1 (2nd Floor)': SpatialMetadata(
      assetPath: secondFloorUnion,
      targetRooms: ['orchard_2011'],
    ),
    'Orchard Room 2 (2nd Floor)': SpatialMetadata(
      assetPath: secondFloorUnion,
      targetRooms: ['orchard_2011'],
    ),
    'Orchard Room 3 (2nd Floor)': SpatialMetadata(
      assetPath: secondFloorUnion,
      targetRooms: ['orchard_2011'],
    ),
    'Cottonwood Suite (2nd Floor)': SpatialMetadata(
      assetPath: secondFloorUnion,
      targetRooms: ['cottonwood_2290'],
    ),
    'Cottonwood Room 1 (2nd Floor)': SpatialMetadata(
      assetPath: secondFloorUnion,
      targetRooms: ['cottonwood_2290'],
    ),
    'Cottonwood Room 2 (2nd Floor)': SpatialMetadata(
      assetPath: secondFloorUnion,
      targetRooms: ['cottonwood_2290'],
    ),
    'Cottonwood Room 3 (2nd Floor)': SpatialMetadata(
      assetPath: secondFloorUnion,
      targetRooms: ['cottonwood_2290'],
    ),
    'Forest Suite (2nd Floor)': SpatialMetadata(
      assetPath: secondFloorUnion,
      targetRooms: ['walnut_2013a', 'oak_2013b'],
    ),
    'Walnut Room (2nd Floor)': SpatialMetadata(
      assetPath: secondFloorUnion,
      targetRooms: ['walnut_2013a'],
    ),
    'Oak Room (2nd Floor)': SpatialMetadata(
      assetPath: secondFloorUnion,
      targetRooms: ['oak_2013b'],
    ),
    'Computer Lounge (2nd Floor)': SpatialMetadata(
      assetPath: secondFloorUnion,
      targetRooms: ['computer_lounge_2060'],
    ),
    'Fireplace Lounge (2nd Floor)': SpatialMetadata(
      assetPath: secondFloorUnion,
      targetRooms: ['fireplace_lounge_2050'],
    ),
    'North Lounge (2nd Floor)': SpatialMetadata(
      assetPath: secondFloorUnion,
      targetRooms: ['north_lounge_2201'],
    ),
    // --- UNION 3RD FLOOR ---
    'Pacific Room 1 (3rd Floor)': SpatialMetadata(
      assetPath: unionMapAsset,
      targetRooms: ['3290_pacific'],
    ),
    'Pacific Room 2&3 (3rd Floor)': SpatialMetadata(
      assetPath: unionMapAsset,
      targetRooms: ['3290_pacific'],
    ),
    'Folsom Room (3rd Floor)': SpatialMetadata(
      assetPath: unionMapAsset,
      targetRooms: ['3011b_folsom'],
    ),
    'Miwok Room (3rd Floor)': SpatialMetadata(
      assetPath: unionMapAsset,
      targetRooms: ['3017b_miwok'],
    ),
    'Maidu Room (3rd Floor)': SpatialMetadata(
      assetPath: unionMapAsset,
      targetRooms: ['3017a_maidu'],
    ),
    'Foothill Suite (3rd Floor)': SpatialMetadata(
      assetPath: unionMapAsset,
      targetRooms: ['3011a_auburn', '3011b_folsom'],
    ),
    'Auburn Room (3rd Floor)': SpatialMetadata(
      assetPath: unionMapAsset,
      targetRooms: ['3011a_auburn'],
    ),
    'Green and Gold Room (3rd Floor)': SpatialMetadata(
      assetPath: unionMapAsset,
      targetRooms: ['3201_green_and_gold'],
    ),

    'Library Breezeway': SpatialMetadata(
      assetPath: campusMapAsset,
      targetRooms: ['library'],
    ),
    'Library Quad': SpatialMetadata(
      assetPath: campusMapAsset,
      targetRooms: ['library_quad'],
    ),
    "Donald & Beverly Gerth Special Collections & University Archives":
        SpatialMetadata(assetPath: campusMapAsset, targetRooms: ["library"]),
    'West Entrance (between AIRC and the Union)': SpatialMetadata(
      assetPath: campusMapAsset,
      targetRooms: ['airc'],
    ),
    "Sacramento Hall": SpatialMetadata(
      assetPath: campusMapAsset,
      targetRooms: ['sacramento'],
    ),
    "Yosemite Hall": SpatialMetadata(
      assetPath: campusMapAsset,
      targetRooms: ['yosemite'],
    ),
    "Solano Hall": SpatialMetadata(
      assetPath: campusMapAsset,
      targetRooms: ['solano'],
    ),
    "Kadema Hall": SpatialMetadata(
      assetPath: campusMapAsset,
      targetRooms: ['kadema'],
    ),
    "Lassen Hall": SpatialMetadata(
      assetPath: campusMapAsset,
      targetRooms: ['lassen'],
    ),
    "Mariposa Hall": SpatialMetadata(
      assetPath: campusMapAsset,
      targetRooms: ['mariposa'],
    ),
    "Eureka Hall": SpatialMetadata(
      assetPath: campusMapAsset,
      targetRooms: ['eureka'],
    ),
    "Douglass Hall": SpatialMetadata(
      assetPath: campusMapAsset,
      targetRooms: ['douglass'],
    ),
    "Calaveras Hall": SpatialMetadata(
      assetPath: campusMapAsset,
      targetRooms: ['calaveras'],
    ),
    "Alpine Hall": SpatialMetadata(
      assetPath: campusMapAsset,
      targetRooms: ['alpine'],
    ),
    "Brighton Hall": SpatialMetadata(
      assetPath: campusMapAsset,
      targetRooms: ['brighton'],
    ),
    "Shasta Hall": SpatialMetadata(
      assetPath: campusMapAsset,
      targetRooms: ['shasta'],
    ),
    "Riverfont": SpatialMetadata(
      assetPath: campusMapAsset,
      targetRooms: ['riverfront_del_norte'],
    ),
    "Del Norte Hall": SpatialMetadata(
      assetPath: campusMapAsset,
      targetRooms: ['riverfront_del_norte'],
    ),
    "Mendocino Hall": SpatialMetadata(
      assetPath: campusMapAsset,
      targetRooms: ['mendocino'],
    ),
    "Placer Hall": SpatialMetadata(
      assetPath: campusMapAsset,
      targetRooms: ['placer'],
    ),
    "Sequoia Hall": SpatialMetadata(
      assetPath: campusMapAsset,
      targetRooms: ['sequoia_humboldt'],
    ),
    "Humboldt Hall": SpatialMetadata(
      assetPath: campusMapAsset,
      targetRooms: ['sequoia_humboldt'],
    ),
    "Riverside Hall": SpatialMetadata(
      assetPath: campusMapAsset,
      targetRooms: ['riversite'],
    ),
    "Santa Clara Hall": SpatialMetadata(
      assetPath: campusMapAsset,
      targetRooms: ['santa_clara'],
    ),
    "Capistrano Hall": SpatialMetadata(
      assetPath: campusMapAsset,
      targetRooms: ['capistrano'],
    ),
    "Amador Hall": SpatialMetadata(
      assetPath: campusMapAsset,
      targetRooms: ['amador'],
    ),
    "Tahoe Hall": SpatialMetadata(
      assetPath: campusMapAsset,
      targetRooms: ['tahoe'],
    ),
    "Benicia Hall": SpatialMetadata(
      assetPath: campusMapAsset,
      targetRooms: ['benicia'],
    ),
    "AIRC": SpatialMetadata(assetPath: campusMapAsset, targetRooms: ['airc']),
    "University Union": SpatialMetadata(
      assetPath: campusMapAsset,
      targetRooms: ['union'],
    ),
  };

  static SpatialMetadata? lookup(String locationName) {
    return directory[locationName];
  }
}

// --- DOM MANIPULATION ENGINE ---
class MapParser {
  static Future<String> injectHighlight(SpatialMetadata metadata) async {
    // THE PIVOT: Dynamically load the correct asset based on the metadata
    final String rawSvg = await rootBundle.loadString(metadata.assetPath);
    final XmlDocument document = XmlDocument.parse(rawSvg);

    // CRITICAL: Strip physical dimensions to prevent layout collapse
    final Iterable<XmlElement> svgRootNodes = document.findAllElements('svg');
    if (svgRootNodes.isNotEmpty) {
      final XmlElement rootNode = svgRootNodes.first;
      rootNode.removeAttribute('width');
      rootNode.removeAttribute('height');
    }

    final Iterable<XmlElement> allElements = document.descendantElements;

    for (final XmlElement element in allElements) {
      final String? roomAttr = element.getAttribute('room');

      if (roomAttr != null && metadata.targetRooms.contains(roomAttr)) {
        // High-visibility yellow injection
        element.setAttribute('fill', '#FFDE00');
        element.setAttribute('fill-opacity', '0.9');
        element.setAttribute('stroke', '#222222');
        element.setAttribute('stroke-width', '4');
      }
    }

    return document.toXmlString();
  }
}

class DynamicMapViewer extends StatefulWidget {
  final String eventLocation;

  const DynamicMapViewer({Key? key, required this.eventLocation})
    : super(key: key);

  @override
  State<DynamicMapViewer> createState() => _DynamicMapViewerState();
}

class _DynamicMapViewerState extends State<DynamicMapViewer> {
  late Future<String?> _processedSvgFuture;

  @override
  void initState() {
    super.initState();
    _processedSvgFuture = _prepareMapData();
  }

  Future<String?> _prepareMapData() async {
    final SpatialMetadata? metadata = LocationRegistry.lookup(
      widget.eventLocation,
    );
    if (metadata == null) {
      return null;
    }
    return await MapParser.injectHighlight(metadata);
  }

  @override
  Widget build(BuildContext context) {
    // Grab the screen height to dramatically scale up the base vector
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0x00000000),
      appBar: AppBar(
        title: Text(widget.eventLocation, style: const TextStyle(fontSize: 16)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF043927),
        centerTitle: true,
      ),
      body: FutureBuilder<String?>(
        future: _processedSvgFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFC4B581)),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_off_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Detailed spatial data is currently unavailable for ${widget.eventLocation}.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Stack(
            children: [
              //Map Layer
              InteractiveViewer(
                minScale:
                    0.5, // Allow zooming out to see the entire massive map
                maxScale: 6.0, // Allow deep zooming into specific rooms
                constrained: false,
                // Adds a virtual buffer around the map so the user can pan past the edges comfortably
                boundaryMargin: const EdgeInsets.all(200),
                child: SvgPicture.string(
                  snapshot.data!,
                  // Base the initial dimensions on the screen HEIGHT.
                  // This blows the map up, pushing the edges off-screen to invite panning.
                  width: screenHeight * 1.2,
                  height: screenHeight * 1.2,
                  fit: BoxFit.contain,
                ),
              ),

              //  Floating UI Overlay
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Center(
                  // IgnorePointer ensures tapping the pill doesn't block panning the map underneath it
                  child: IgnorePointer(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFF043927,
                        ).withOpacity(0.85), // Translucent Hornet Green
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.open_with,
                            color: Color(0xFFC4B581),
                            size: 18,
                          ), // Hornet Gold
                          SizedBox(width: 8),
                          Text(
                            "Pinch to zoom, drag to pan",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
