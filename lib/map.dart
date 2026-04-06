import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xml/xml.dart';

class SpatialMetadata {
  final List<String> targetRooms;
  const SpatialMetadata(this.targetRooms);
}

class LocationRegistry {
  static const String unionMapAsset = 'assets/maps/union_3rd_floor.svg';

  static const Map<String, SpatialMetadata> directory = {
    'Pacific Room 1 (3rd Floor)': SpatialMetadata(['3290_pacific']),
    'Pacific Room 2&3 (3rd Floor)': SpatialMetadata(['3290_pacific']),
    'Folsom Room (3rd Floor)': SpatialMetadata(['3011b_folsom']),
    'Miwok Room (3rd Floor)': SpatialMetadata(['3017b_miwok']),
    'Maidu Room (3rd Floor)': SpatialMetadata(['3017a_maidu']),
    'Foothill Suite (3rd Floor)': SpatialMetadata([
      '3011a_auburn',
      '3011b_folsom',
    ]),
    'Auburn Room (3rd Floor)': SpatialMetadata(['3011a_auburn']),
    'Green and Gold Room (3rd Floor)': SpatialMetadata(['3201_green_and_gold']),
  };

  static SpatialMetadata? lookup(String locationName) {
    return directory[locationName];
  }
}

class MapParser {
  static Future<String> injectHighlight(SpatialMetadata metadata) async {
    final String rawSvg = await rootBundle.loadString(
      LocationRegistry.unionMapAsset,
    );
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
        element.setAttribute('fill', '#FFDE00'); // Vibrant Gold/Yellow
        element.setAttribute('fill-opacity', '0.9');
        element.setAttribute(
          'stroke',
          '#222222',
        ); // Stark dark stroke for edge contrast
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
              // 1. The Map Layer
              InteractiveViewer(
                minScale:
                    0.5, // Allow zooming out to see the entire massive map
                maxScale: 6.0, // Allow deep zooming into specific rooms
                constrained: false,
                // Adds a virtual buffer around the map so the user can pan past the edges comfortably
                boundaryMargin: const EdgeInsets.all(200),
                child: SvgPicture.string(
                  snapshot.data!,
                  // THE FIX: Base the initial dimensions on the screen HEIGHT.
                  // This blows the map up, pushing the edges off-screen to invite panning.
                  width: screenHeight * 1.2,
                  height: screenHeight * 1.2,
                  fit: BoxFit.contain,
                ),
              ),

              // 2. The Floating UI Overlay
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
