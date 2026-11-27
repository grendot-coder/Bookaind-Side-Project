# 🗺️ Bookaind Development Roadmap & Feature Plan
**A Comprehensive Plan for the Next Evolution of Bookaind**

---

## 1. Executive Summary & Vision

* **App Name**: **Bookaind**
* **Mission**: A modern, editorial mobile application celebrating the living cultural heritage, ancient architectures, natural sanctuaries, and authentic culinary traditions of the Indonesian Archipelago (Nusantara).
* **Design Philosophy**: **Nature-Editorial**
  * Nusantara Earth Palette: Coral (`#FF704F`), Saffron (`#FFC857`), Teal (`#39A9A2`), Charcoal (`#292B2A`), Cream (`#F5EBD8`), Warm White (`#FFFDF8`).
  * Anti-Pill, tactile card surfaces (12–14px radius), golden hairline dividers, high-contrast typography, and generous imagery.
* **Core Tech Stack**: Flutter 3.x (Android-focused), Riverpod, Local-First JSON Catalog (`assets/data/cultural_catalog.json`), `SharedPreferences` + `FlutterSecureStorage` (BYOK Groq/Gemini AI), Flutter Map / OpenStreetMap, optional self-hosted Supabase.

---

## 2. Completed Milestones (Current Baseline)

- [x] **Nature-Editorial Design System**: Refactored cards, navigation shell, section headers, discovery catalogs, and hero destinations.
- [x] **Open-Source Hybrid & Local-First Foundation**:
  - `assets/data/cultural_catalog.json` bundled with 17 provinces, 4 categories, 18 destinations, and 5 cultural entries.
  - `SupabaseConfig` makes Supabase strictly opt-in (`--dart-define`) with zero hardcoded personal credentials.
  - Persistent local storage for Bookmarks, Saved Itineraries, Cultural Passions, and Android Keystore-encrypted BYOK API keys (`Groq` / `Gemini`).
- [x] **Revamped Explorer Dossier (`ProfileScreen`)**:
  - Anti-Pill editorial identity header, metrics strip, tabbed *Saved Heritage* & *Saved Journeys*, interactive passions, and *Settings & AI Key* sheet.
- [x] **Smart Cultural Itinerary Planner**:
  - Step-based wizard, budget tier selection, connected vertical timeline, BYOK AI generation + curated offline fallback, and local itinerary saving.
- [x] **Curated Welcome & Auth Flow**:
  - `WonderousIntroScreen` featuring dual heritage landmarks (Masjid Istiqlal & Bukit Sibea-Bea).
  - Editorial Borobudur `WelcomeScreen` with one-tap Guest Explorer bypass.
  - Optional Supabase Login & Register screens when self-hosted cloud sync is configured.
- [x] **Universal Search System** (`/search`):
  - Categorized exploration tabs (*All*, *Destinations*, *Culinary & Arts*, *Provinces*).
  - Instant live filter and popular tag exploration chips.
- [x] **Interactive Heritage Map**:
  - Custom Flutter Map with province markers and destination pins.

---

## 3. Phase 1: High-Impact User Engagement & Utility

### 3.1 Persistent & Cloud-Synced Bookmarks
* **Problem**: Currently, bookmarks are held in memory (`BookmarksNotifier`); quitting or restarting the app wipes saved items.
* **Architecture**:
  * **Guest Explorers**: Store bookmarks locally using `shared_preferences` (persists offline without requiring login).
  * **Authenticated Explorers**: Sync to a Supabase table `user_bookmarks` (`id`, `user_id`, `item_id`, `item_type`, `created_at`).
  * **Auto-Migration**: When a guest logs in, automatically import their local bookmarks into Supabase.
* **User Experience**:
  * Persistent bookmark counter and collection list on `ProfileScreen`.
  * Haptic feedback when tapping the bookmark button in `DestinationDetailScreen` and `CulturalDetailScreen`.

### 3.2 Smart AI Cultural Itinerary Planner
* **Concept**: Transform Bookaind from a passive guidebook into an active cultural trip assistant.
* **Features**:
  * **Planner Wizard**:
    1. Select Province or City (e.g., Yogyakarta & Solo, Bali, North Sumatra).
    2. Select Duration (1 Day, 3 Days, 5 Days).
    3. Choose Style (Deep Heritage & Temples, Family Cultural, Arts & Culinary, Nature & Village).
  * **Edge Function Generation**:
    * Prompt the Supabase Edge Function with structured itinerary output format.
    * Returns morning, afternoon, and evening recommendations, local culinary pairings, and etiquette warnings.
  * **Interactive Schedule View**:
    * Accordion timeline card where each suggested spot links directly to its in-app detail page.

### 3.3 Audio Cultural Narration ("Dengarkan Kisah")
* **Concept**: Hands-free storytelling for tourists standing right at the monument or cultural site.
* **Features**:
  * In-app audio player / TTS (`flutter_tts`) widget placed on prominent landmark detail screens.
  * Curated story summaries (e.g., "The Secret Reliefs of Karmawibhangga", "Architectural Symbiosis of Istiqlal & Cathedral").
  * Floating minimal audio bar with Play, Pause, and 15s Rewind.

---

## 4. Phase 2: Location-Based & Map Enhancements

### 4.1 "Cagar Budaya di Sekitarku" (Nearby Geolocation)
* **Concept**: Enable travelers on the road to immediately discover hidden heritage sites around them.
* **Features**:
  * Secure location permission request via `geolocator`.
  * Haversine distance formula to calculate proximity (in km) to all destinations in Supabase.
  * "Near Me" chip in the Search screen and a "Nearest First" sort toggle on the Discovery screen.
  * Distance pill (e.g., `📍 3.2 km from you`) displayed on cards.

### 4.2 Turn-by-Turn Navigation Launch
* **Concept**: Bridge the gap between reading about a site and actually arriving there.
* **Features**:
  * "Petunjuk Arah" (Get Directions) button in `DestinationDetailScreen`.
  * Opens native Google Maps, Apple Maps, or Waze using deep-link URLs via `url_launcher`:
    `https://www.google.com/maps/search/?api=1&query={latitude},{longitude}`

---

## 5. Phase 3: Offline Experience & Production Readiness

### 5.1 Offline Heritage Guide (Cache-First)
* **Concept**: Heritage sites (such as Baluran Savannah, Komodo, or remote Toraja villages) frequently suffer from spotty mobile cellular connections.
* **Features**:
  * Cache visited destinations and cultural entries into a local store (e.g., Hive or SQLite).
  * Fallback to cached content with a discrete "Offline Reading Mode" indicator banner if network requests fail.
  * Ensure all hero images use persistent disk caching via `cached_network_image`.

### 5.2 Cultural Etiquette & Do's & Don'ts Cheat-Sheet
* **Concept**: Respectful tourism is core to preserving Indonesian culture.
* **Features**:
  * Visual etiquette cards for each destination category:
    * *Candi/Temples*: Sarong and sash requirements, sacred area boundaries.
    * *Keraton/Royal Palaces*: Dress codes, banned colors (e.g., Parang motif in certain court chambers).
    * *Traditional Villages*: Photo consent rules, village elder greetings.
  * Accessible from the destination detail screen and AI assistant quick-prompts.

### 5.3 Automated Testing & Quality Assurance
* **Features**:
  * **Unit Tests**:
    * Test `SupabaseCulturalRepository` query parsers and error mappers.
    * Test `BookmarksNotifier` persistence logic.
  * **Widget Tests**:
    * Test `SearchScreen` tab switching and query filtering.
    * Test `DestinationDetailScreen` data state rendering (loading, error, success).

---

## 6. Implementation Matrix & Priority

| Priority | Feature | Phase | Est. Effort | Dependencies | Target Impact |
| :---: | :--- | :---: | :---: | :--- | :--- |
| **P0** | **Persistent Bookmarks (Local + Supabase)** | Phase 1 | 1-2 days | `shared_preferences`, Supabase Auth | High user retention & satisfaction |
| **P0** | **Open in Google Maps / Directions** | Phase 2 | Half-day | `url_launcher` | Practical utility for tourists |
| **P1** | **Smart Cultural Itinerary Planner** | Phase 1 | 2-3 days | Supabase Edge Function (`smooth-processor`) | Key differentiator / "Wow" feature |
| **P1** | **Nearby Exploration (GPS Geolocation)** | Phase 2 | 1-2 days | `geolocator` | Contextual discovery on-site |
| **P2** | **Audio Cultural Narration ("Dengarkan Kisah")** | Phase 1 | 2 days | `flutter_tts` or audio edge | Immersive storytelling |
| **P2** | **Offline Reading Cache** | Phase 3 | 2 days | `hive` or `shared_preferences` | Reliability in remote areas |
| **P3** | **Automated Tests Suite** | Phase 3 | 1-2 days | `flutter_test`, `mocktail` | Code stability & prevent regressions |

---

## 7. Recommended Next Step

**Recommended Kickoff: Persistent Bookmarks + Directions (P0)**
1. Wire `shared_preferences` into `BookmarksNotifier` so guest bookmarks never get erased on app restart.
2. Add "Petunjuk Arah" (Get Directions) button with `url_launcher` on `DestinationDetailScreen` using the destination's latitude and longitude.
