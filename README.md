<div align="center">

# Bookaind

**A pocket cultural field guide to the Indonesian Archipelago — built for offline trails, curious minds, and zero cloud bills.**

[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?style=flat-square&logo=android&logoColor=white)](#installation)
[![Built With](https://img.shields.io/badge/Built%20with-Flutter-02569B?style=flat-square&logo=flutter&logoColor=white)](#tech-stack)
[![Mode](https://img.shields.io/badge/Mode-Offline%20%2B%20BYOK%20AI-FF704F?style=flat-square)](#how-it-works)
[![Catalog](https://img.shields.io/badge/Heritage%20Catalog-18%20Sites%20%E2%80%A2%2017%20Provinces-39A9A2?style=flat-square)](#whats-inside)
[![License: MIT](https://img.shields.io/badge/License-MIT-FFC857?style=flat-square)](LICENSE)

</div>

---

Most travel apps lock basic guides behind sign-up screens, drain your battery pinging servers, and go completely blank the moment you lose signal on a mountain road in Flores.

**Bookaind flips that.** The entire cultural catalog lives right on your Android device. Explore 9th-century *Candi*, royal *Keraton* etiquette, hand-drawn *Batik* philosophy, and regional warungs—completely offline, with optional Bring-Your-Own-Key (BYOK) AI when you want a custom route built on the fly.

---

## Screenshots

> *Pre-release preview — Android screenshots coming soon.*

<!-- Drop screenshots into docs/screenshots/ and uncomment when ready:
| Discovery | Heritage Map | Itinerary Architect | Explorer Dossier |
| :---: | :---: | :---: | :---: |
| ![Discovery](docs/screenshots/discover.png) | ![Map](docs/screenshots/map.png) | ![Itinerary](docs/screenshots/itinerary.png) | ![Dossier](docs/screenshots/dossier.png) |
-->

---

## What's Inside

- **17 Provinces, 18 Landmarks, 5 Living Traditions** — Bundled directly inside [`assets/data/cultural_catalog.json`](assets/data/cultural_catalog.json) (from Borobudur, Prambanan, and Mount Bromo to Wae Rebo, Lake Sentani, Fort Belgica, and Bukit Sibea-Bea).
- **Smart Itinerary Architect** — Pick a corridor (or type your own island), choose 1 to 14 days, pick your travel pace and budget tier, and get a vertical **Morning / Afternoon / Evening** timeline complete with cultural etiquette notes and local dish pairings.
- **Interactive Archipelago Map** — Browse provinces and color-coded heritage pins via OpenStreetMap (`flutter_map`).
- **Explorer Dossier (Zero Login Walls)** — Save your favorite landmarks (*Saved Heritage*), keep generated trips (*Saved Journeys*), and customize your *Cultural Passions* locally on your phone.
- **Universal Search** — Jump straight into destinations, culinary & arts entries, or provinces from one bar.

---

## How It Works (Choose Your Mode)

```text
                     +----------------------------------+
                     |         BOOKAIND ANDROID         |
                     +----------------------------------+
                                       |
           +---------------------------+---------------------------+
           v                                                       v
  [ Offline First ]                                       [ Bring Your Own Key ]
  Bundled JSON Catalog                                    Free Groq or Gemini Key
  + Curated Itineraries                                   Stored via Keystore
  + Local Bookmarks                                       Direct Device -> AI API
```

| Mode | What You Need | What You Get |
| :--- | :--- | :--- |
| **Offline Explorer** *(Default)* | Nothing. Just install and open. | All 18 sites, 17 provinces, map pins, local bookmarks, and curated baseline itineraries. |
| **BYOK AI Traveler** | Paste a free **Groq** or **Gemini** key in *Settings & AI Key*. | Live custom AI itinerary planning, conversational cultural guide, and automatic model discovery. |
| **Self-Hoster** | Your own Supabase URL & anon key at build time. | Optional cloud auth and remote catalog sync. |

> [!TIP]
> **Why BYOK?** Both Groq and Google Gemini offer free developer tiers. Storing your own key on-device (`flutter_secure_storage`) means Bookaind stays 100% free and open-source with zero server bills or rate-limit bottlenecks.

---

## Installation

### Download the Pre-Release APK (Android)

Grab `app-release.apk` from the [GitHub Releases](https://github.com/grendot-coder/Bookaind-Side-Project/releases) page.

<details>
<summary><strong>Installation options (Limited Distribution & ADB)</strong></summary>

* **Standard Android Install**: Use the Android Developer Verification Limited Distribution invite link included in the release notes.
* **Via USB (ADB)**:
  ```bash
  adb install app-release.apk
  ```

</details>

### Build from Source

```bash
git clone https://github.com/grendot-coder/Bookaind-Side-Project.git
cd Bookaind-Side-Project
flutter pub get
flutter run
```

<details>
<summary><strong>Optional: Run with your own Supabase instance</strong></summary>

See [`supabase/schema.sql`](supabase/schema.sql) for table definitions, then launch with:
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

</details>

---

## Tech Stack

| Area | Tools |
| :--- | :--- |
| **Core** | Flutter (Android-focused), `flutter_riverpod`, `go_router` |
| **Maps & Visuals** | `flutter_map`, `latlong2`, `cached_network_image`, `google_fonts`, `flutter_svg` |
| **Local Storage & Keys** | `shared_preferences`, `flutter_secure_storage`, `http`, `url_launcher` |
| **Optional Sync** | `supabase_flutter` |

---

## Want to Put Your Hometown on the Map?

Know a hidden *candi*, a heritage village, or a legendary warung missing from the catalog? You don't need to touch Flutter code to contribute—just open a Pull Request adding an entry to [`assets/data/cultural_catalog.json`](assets/data/cultural_catalog.json).

Check out [CONTRIBUTING.md](CONTRIBUTING.md) for formatting tips and cultural sensitivity guidelines.

---

## Acknowledgements & License

* Map tiles and geographic rendering powered by [OpenStreetMap](https://www.openstreetmap.org/copyright) contributors and [`flutter_map`](https://pub.dev/packages/flutter_map).
* Distributed under the **MIT License**. See [`LICENSE`](LICENSE) for full details.
