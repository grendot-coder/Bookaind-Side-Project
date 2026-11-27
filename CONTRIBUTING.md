# Contributing to Bookaind 🇮🇩

Thank you for your interest in contributing to **Bookaind**! We welcome contributions to our code, cultural research, design system, and documentation.

---

## 🏛️ How to Contribute Cultural Data

You don't need direct database access to contribute new heritage temples, royal culinary traditions, or regional crafts. All database changes are proposed through Git Pull Requests.

### Step 1: Fork & Clone
1. Fork this repository on GitHub.
2. Clone your fork locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/bookaind.git
   cd bookaind/just_move_id
   ```

### Step 2: Add Your Cultural Entry
Add your new destination or cultural story directly to the single-source JSON catalog:
* [`assets/data/cultural_catalog.json`](assets/data/cultural_catalog.json) (used natively by the offline-first Android app and optional Supabase seeders).

**Quality Guidelines**:
* **Accuracy**: Provide verified historical facts and proper local names (e.g., Sundanese, Javanese, Batak).
* **Photography**: Use high-resolution, publicly licensed images (e.g., Unsplash, Wikimedia Commons).
* **Cultural Sensitivity**: Include respectful etiquette notes (sarong requirements, sacred boundaries, photo permissions).

### Step 3: Submit a Pull Request
1. Commit your changes:
   ```bash
   git commit -m "feat(data): add Candi Sewu cultural destination"
   ```
2. Push to your fork and open a **Pull Request** targeting `main`.
3. The maintainers will review the cultural narrative and merge it. Merged changes will be automatically synced into the live Supabase database!

---

## 💻 Running the App Locally

### Quick Run (Zero Backend & Zero API Keys Required)
By default, Bookaind boots in **local-first mode** with the bundled cultural catalog (`assets/data/cultural_catalog.json`), local bookmark/itinerary persistence, and offline curated itineraries:
```bash
flutter pub get
flutter run
```

To test live AI trip architecting locally, paste your own free Groq or Gemini API key inside **Explorer Dossier -> Settings & AI Key** inside the app.

### Running with Your Own Self-Hosted Supabase Instance (Optional)
If you want to host your own optional cloud sync backend:
1. Create a free project on [Supabase](https://supabase.com).
2. Run the SQL script from [`supabase/schema.sql`](supabase/schema.sql) and [`supabase/seed.sql`](supabase/seed.sql) in your Supabase SQL Editor.
3. Launch Flutter with your credentials:
   ```bash
   flutter run \
     --dart-define=SUPABASE_URL=https://your-project.supabase.co \
     --dart-define=SUPABASE_ANON_KEY=your-anon-key
   ```

---

## 🎨 Design Philosophy: Nature-Editorial
* **Anti-Pill**: Avoid generic floating pill buttons. Use tactile cards (12–14px radius) and hairline dividers.
* **Palette**: Coral (`#FF704F`), Saffron (`#FFC857`), Teal (`#39A9A2`), Charcoal (`#292B2A`), Cream (`#F5EBD8`).
* Follow Effective Dart guidelines and run `flutter analyze` before opening a PR.
