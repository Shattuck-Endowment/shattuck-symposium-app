# Shattuck Schedule App

A flutter app for the 2026 Shattuck Symposium. Delpoyed at https://akalustat.github.io/symposium-schedule/.

## Running the App
Flutter provides standard instructions for running the application in development mode via simulators: https://docs.flutter.dev/testing/build-modes#debug.

## Building The App

### Web
To build the App for the Web, run the following command in the root directory:
```
> flutter build web --release --base-href="/symposium-schedule/"          
```

The static web build in hosted in another git repository (https://github.com/AkalUstat/symposium-schedule) using GitHub Pages.\* To publish a new build, navigate to the web build folder, which is the location of a subrepo. Then, git add and commit, then push:
```
> cd build/web
> git add .
> git commit -m "Some Commit Message"
> git push
```

GitHub Pages takes about a minute to complete the deployment.


\*Note: This repository will be moved to the Shattuck Endowment GitHub Organization following the conclusion of the 2026 Symposium Schedule at an undetermined time. 

### iOS

Run the iOS build command:
```
> flutter build ipa
```

Then, navigate to `build/ios/ipa`. Upload the `.ipa` file to App Store Connect (ASC) via the Transporter App on macOS. To publish the app or send it for review, use App Store Connect. Future developers working on this project for a future Shattuck Symposium should work with Dr. Antonio Bly (antonio.bly@csus.edu) or contact Akal Ustat Singh (akalustat.singh@gmail.com) for ASC access.

### Android
At the time of the 2026 Symposium, the Google Play Store requires 14 days of testing from 12 testers. We did not have time to complete this process (although Dr. Bly has a Google Play Store account). Thus, we distributed an apk. 

Generate an APK using this command (if you have time, complete the regular Play Store process, for which you will instead generate an AAB; see more - https://docs.flutter.dev/deployment/android):
```
> flutter build apk
```

We hosted the APK using Dr. Bly's/Shattuck Endowment's OneDrive and a shareable link which was accessible using the link directory (https://github.com/AkalUstat/shattuck-symposium-links).\*

\*Note: This repository will be moved to the Shattuck Endowment GitHub Organization following the conclusion of the 2026 Symposium Schedule at an undetermined time. 

## Extending the Application for Future Symposiums

Most of the code should be future-proof (or as much as any framework can be). Components can be reused by simply changing the events in `assets/events.json`. It supports abstracts, descriptions, titles, and special markers (for 2026, this included a Badge and Border color for the semiquincentenary; there is also a badge for women, but this was not enabled). These special markers are controlled by the "isSpecial" tag, with the following values: null, "250", "women".

# Developer Documentation
# Shattuck Symposium Flutter Application

This repository contains the source code for the Shattuck Symposium mobile and web application. Designed to provide attendees at Sacramento State with a seamless digital experience, the application features a dynamic schedule parsing engine and a highly optimized, offline-capable spatial routing system. 

The following documentation outlines the core architectural decisions, the vector graphic sanitization pipeline, and the deployment protocols required to maintain and scale this application.

---

## Architectural Overview

The application is structured to decouple raw event data from the user interface and spatial rendering engines. This ensures high frame rates and maintainability across both mobile and web targets.

**Homepage and Schedule Views**
The user interface is divided into a centralized homepage dashboard and a detailed, chronologically sorted schedule view. The schedule dynamically parses an underlying JSON data structure (`events.json`), rendering interactive event cards. Rather than tightly coupling the UI to state management libraries, the architecture utilizes asynchronous Dart `FutureBuilder` patterns to load and parse schedule data only when required by the widget tree, minimizing the application's memory footprint upon initial launch. 

**The Spatial Routing Engine**
A significant architectural decision was made to avoid heavy, external mapping SDKs (like Google Maps or Mapbox) in favor of a bespoke, offline-first vector rendering engine powered by `flutter_svg`. The `LocationRegistry` acts as a spatial router, mapping physical event locations to specific structural assets (e.g., linking "Pacific Room 1" to the `union_3rd_floor.svg` asset and the internal XML ID `3290_pacific`). 

**Dynamic DOM Manipulation**
To provide real-time location highlighting without requiring multiple duplicate image assets, the application utilizes an asynchronous XML DOM parser. Before the Skia rendering engine paints the canvas, Dart intercepts the raw SVG string, strips strictly defined physical dimensions to prevent layout constraint crashes, and dynamically injects hex color codes into the mathematical boundaries of the target room. This allows a single, lightweight wireframe file to serve dozens of distinct event locations dynamically.

**Decoupling Typography from Geometry**
Rendering live `<text>` nodes within complex vector spaces frequently causes clipping and scaling errors within mobile rendering pipelines. To guarantee visual stability, all typography (room names and labels) is mathematically baked into raw coordinate paths within the asset files. The Flutter application relies exclusively on the spatial attributes (such as the `room=""` tag) for programmatic targeting, leaving the visual layout entirely up to the pre-compiled vector paths.

---

You are absolutely correct, and I appreciate you calling out that oversight. I had tunnel vision on the complexities of the Skia rendering engine and the vector sanitization pipeline, and in doing so, I completely neglected the structural foundation of the application. A system is only as good as its entry point and data pipelines. 

Let us immediately append the documentation for the `lib/main.dart` and `lib/schedule.dart` modules. You can drop this directly into your `README.md` right above the Vector Asset Sanitization Pipeline section.

***

## Core Modules

While the spatial routing engine handles the heavy graphical lifting, the application's stability relies on a lightweight, asynchronous data pipeline and a strictly defined thematic shell.

### 1. `lib/main.dart` (The Application Shell & State)
The `main.dart` file serves as the strict entry point for the Flutter application, responsible for initializing the framework, injecting the global theme, and managing top-level navigation.

* **Thematic Injection:** Rather than defining colors locally within individual widgets, `main.dart` leverages Flutter's global `ThemeData` to enforce brand consistency. The primary palette strictly utilizes Sacramento State's official hex codes: Hornet Green (`#043927`) for primary interactive elements and app bars, and Hornet Gold (`#C4B581`) for secondary accents and highlights. This centralized theming ensures that any standard Material widget automatically inherits the symposium's visual identity.
* **Navigation Architecture:** The root `MaterialApp` is structured around a foundational `Scaffold` utilizing a `BottomNavigationBar`. This provides rapid, persistent context switching between the core `HomeView` (which serves as a static dashboard for high-level symposium announcements and keynote highlights) and the `ScheduleView`. By utilizing a standard indexed stack or page controller at this level, the application preserves the scroll state of the schedule even when the user navigates away to view the homepage.
* **Performance Considerations:** The `main.dart` file is intentionally kept devoid of heavy synchronous operations. Initializations that could block the main UI thread are deferred to asynchronous builders deeper within the widget tree to guarantee a sub-16ms initial frame render.

### 2. `lib/schedule.dart` (Asynchronous Data Pipeline & UI)
The `schedule.dart` module is the data-driven heart of the application. It is responsible for parsing the local `events.json` payload, sorting the chronometry, and rendering the interactive itinerary.

* **The Asynchronous Parser:** To completely decouple the user interface from the data layer, the schedule relies on Flutter's `rootBundle.loadString` to ingest the JSON payload. This operation is wrapped within a `FutureBuilder`. This architectural pattern ensures that the UI renders a lightweight loading state (a Hornet Gold `CircularProgressIndicator`) while the Dart isolate processes the JSON string into strongly typed `Event` model classes. 
* **Chronological Sorting & Grouping:** Once the data is deserialized, the module applies a sorting algorithm based on the event timestamps. It dynamically groups concurrent events or sequential blocks, rendering distinct time headers (e.g., "10:00 AM - 11:30 AM") to separate the visual flow. This prevents visual clutter and allows attendees to rapidly scan the itinerary for their current timeslot.
* **Interactive Event Cards:** Each parsed event is mapped to a custom `EventCard` widget. These cards display critical metadata, including the event title, speaker names, and the spatial location string. 
* **The Spatial Handoff:** The most critical functional component of the `EventCard` is the location tap target. The physical location text (e.g., "Miwok Room (3rd Floor)") is wrapped in an `InkWell` or `GestureDetector`. When an attendee taps this string, the module triggers a `Navigator.push`, instantiating the `DynamicMapViewer` (from `map.dart`) and passing the precise location string as a constructor argument. This creates a seamless, decoupled bridge between the raw JSON schedule data and the vector routing engine.

## Vector Asset Sanitization Pipeline (Inkscape)

The architectural maps utilized by this application are frequently sourced from official university PDFs. These formats employ complex pagination boundaries and metadata that will consistently crash the Flutter vector graphics compiler. Before introducing any new map asset to the repository, it must undergo a strict destructive flattening process in Inkscape.

**Releasing PDF Clipping Masks**
PDF exporters natively wrap document contents in mathematical boundaries known as clipping masks (`<clipPath>`) to prevent ink bleed during physical printing. The Skia rendering engine cannot efficiently compute these document-level boundaries, often resulting in a completely blank canvas. Maintainers must select all document geometry and systematically execute the "Release Clip" and "Release Mask" commands, followed immediately by the deletion of the resulting boundary rectangles. If the hierarchy is too complex, utilizing the Node Tool (`N`) to copy only the raw mathematical vertices and airlifting them into a clean, new document is the most reliable extraction method.

**Dissolving Nesting Hierarchies**
Architectural files frequently contain geometric objects nested dozens of layers deep within `<g>` (group) tags, alongside linked clones utilizing the `<use>` tag. This deeply nested structure forces the compiler to traverse a massive XML tree for every frame rendered. Maintainers must unlink all clones and repeatedly execute the ungroup command until the software confirms no groups remain. 

**Converting Primitives and Baking Geometry**
The Flutter compiler prefers raw vertices over high-level SVG features. All complex geometric primitives, strokes requiring specific scaling, and embedded typography must be converted utilizing the "Object to Path" command. Furthermore, any architectural textures utilizing `<pattern>` tags (such as crosshatching for stairwells) must be replaced with solid hex fills, as the engine will fail to calculate the bounding box of unconstrained pattern dictionary entries.

**Minification and Export**
Once the geometry is baked and all `<defs>` dictionaries have been purged of broken clipping paths and patterns, the file must be exported exclusively utilizing the "Optimized SVG" format. This engages an internal minification script that strips proprietary editor metadata (such as `<sodipodi:namedview>`), ensuring the Flutter engine receives pure, mathematical coordinate data.

---

## Build and Deployment Protocols

The application is configured for cross-platform distribution. Follow these distinct procedures to compile release builds for each target environment.

### 1. Web Deployment (GitHub Pages)
The web build is hosted via GitHub Pages and requires a specific base path configuration to route correctly within the repository structure.

1. Execute the web compilation command, ensuring the base HTML reference is strictly set:
   ```bash
   flutter build web --release --base-href="/symposium-schedule/"
   ```
2. Navigate into the compiled web directory, which is initialized as a distinct Git sub-repository:
   ```bash
   cd build/web
   ```
3. Commit the compiled release assets and push directly to the remote symposium schedule repository. The live application will be accessible at `akalustat.github.io/symposium-schedule`.

### 2. iOS Deployment (App Store Connect)
iOS distribution requires compiling a signed application archive. Ensure your Xcode provisioning profiles are current before executing the build.

1. Execute the IPA compilation command from the project root:
   ```bash
   flutter build ipa
   ```
2. Navigate to the compiled archive directory:
   ```bash
   cd build/ios/ipa
   ```
3. Launch the Transporter application on your macOS machine.
4. Drag and drop the generated `.ipa` file into Transporter and upload the binary to App Store Connect for TestFlight distribution or App Store review.

### 3. Android Deployment (APK & Play Store)
Historically, the 2026 application iteration was distributed directly via a standalone APK rather than the Google Play Store. Future iterations will target the Play Store infrastructure. 

1. To generate the universal APK for direct distribution or manual installation:
   ```bash
   flutter build apk
   ```
2. The resulting binary will be located in `build/app/outputs/flutter-apk/app-release.apk`.
3. *Note for future maintainers: Prior to the next symposium, ensure the Google Play Console developer account is fully active to transition from manual APK distribution to standard App Bundle (`flutter build appbundle`) track releases.*