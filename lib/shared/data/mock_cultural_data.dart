import '../models/cultural_model.dart';

class MockCulturalData {
  static const List<Province> provinces = [
    Province(
      id: 'diy',
      name: 'DI Yogyakarta',
      localName: 'Daerah Istimewa Yogyakarta',
      capital: 'Yogyakarta',
      tagline: 'The Soul of Javanese Classical Arts & Heritage',
      heroImageUrl:
          'https://images.unsplash.com/photo-1584810359583-96fc3448beaa?q=80&w=1000&auto=format&fit=crop',
      latitude: -7.797068,
      longitude: 110.370529,
    ),
    Province(
      id: 'jateng',
      name: 'Central Java',
      localName: 'Jawa Tengah',
      capital: 'Semarang',
      tagline: 'Cradle of Ancient Temples & Majestic Empires',
      heroImageUrl:
          'https://images.unsplash.com/photo-1601058268499-e52658b8bb88?q=80&w=1000&auto=format&fit=crop',
      latitude: -7.150975,
      longitude: 110.140259,
    ),
    Province(
      id: 'jatim',
      name: 'East Java',
      localName: 'Jawa Timur',
      capital: 'Surabaya',
      tagline: 'Land of Volcanic Wonders & Majapahit History',
      heroImageUrl:
          'https://images.unsplash.com/photo-1588668214407-6ea9a6d8c272?q=80&w=1000&auto=format&fit=crop',
      latitude: -7.536064,
      longitude: 112.238402,
    ),
    Province(
      id: 'jabar',
      name: 'West Java',
      localName: 'Jawa Barat',
      capital: 'Bandung',
      tagline: 'Sundanese Melodies, Tea Highlands & Hospitality',
      heroImageUrl:
          'https://images.unsplash.com/photo-1596402184320-417e7178b2cd?q=80&w=1000&auto=format&fit=crop',
      latitude: -6.917464,
      longitude: 107.619123,
    ),
    Province(
      id: 'dki',
      name: 'DKI Jakarta',
      localName: 'Khusus Ibukota Jakarta',
      capital: 'Jakarta',
      tagline: 'Dynamic Epicenter of Betawi Culture & Modern Life',
      heroImageUrl:
          'https://images.unsplash.com/photo-1555899434-94d1368aa7af?q=80&w=1000&auto=format&fit=crop',
      latitude: -6.208763,
      longitude: 106.845599,
    ),
    Province(
      id: 'banten',
      name: 'Banten',
      localName: 'Banten',
      capital: 'Serang',
      tagline: 'Baduy Traditions & Ancient Maritime Sultanates',
      heroImageUrl:
          'https://images.unsplash.com/photo-1570789210967-2cac24afeb00?q=80&w=1000&auto=format&fit=crop',
      latitude: -6.405817,
      longitude: 106.064018,
    ),
  ];

  static const List<CulturalCategory> categories = [
    CulturalCategory(
      id: 'food',
      name: 'Traditional Culinary',
      slug: 'culinary',
      iconName: 'restaurant',
      accentColorKey: 'saffron',
    ),
    CulturalCategory(
      id: 'textile',
      name: 'Batik & Weaving',
      slug: 'textile',
      iconName: 'texture',
      accentColorKey: 'coral',
    ),
    CulturalCategory(
      id: 'dance_music',
      name: 'Dance & Gamelan',
      slug: 'performing_arts',
      iconName: 'music_note',
      accentColorKey: 'teal',
    ),
    CulturalCategory(
      id: 'architecture',
      name: 'Keraton & Candi',
      slug: 'architecture',
      iconName: 'account_balance',
      accentColorKey: 'blue',
    ),
  ];

  static const List<Destination> featuredDestinations = [
    Destination(
      id: 'borobudur',
      title: 'Borobudur Temple',
      provinceId: 'jateng',
      cityOrRegency: 'Magelang',
      tagline: 'The World\'s Largest Buddhist Monument',
      description:
          'A 9th-century Mahayana Buddhist temple decorated with 2,672 relief panels and 504 Buddha statues, surrounded by morning mist and volcanic peaks.',
      imageUrl:
          'https://images.unsplash.com/photo-1596402184320-417e7178b2cd?q=80&w=1000&auto=format&fit=crop',
      rating: 4.9,
      entryFeeRange: 'Rp 50.000 - Rp 350.000',
      isFeatured: true,
      latitude: -7.607874,
      longitude: 110.203751,
    ),
    Destination(
      id: 'bromo',
      title: 'Mount Bromo & Tengger',
      provinceId: 'jatim',
      cityOrRegency: 'Probolinggo',
      tagline: 'Active Volcanic Caldera & Sea of Sand',
      description:
          'An iconic active volcano situated inside the Tengger Caldera, revered by the local Tenggerese people who observe the Yadnya Kasada ceremony.',
      imageUrl:
          'https://images.unsplash.com/photo-1588668214407-6ea9a6d8c272?q=80&w=1000&auto=format&fit=crop',
      rating: 4.9,
      entryFeeRange: 'Rp 30.000 - Rp 220.000',
      isFeatured: true,
      latitude: -7.942494,
      longitude: 112.953012,
    ),
    Destination(
      id: 'prambanan',
      title: 'Prambanan Temple Compounds',
      provinceId: 'diy',
      cityOrRegency: 'Sleman',
      tagline: 'Soaring Trimurti Hindu Architecture',
      description:
          'The largest Hindu temple compound in Indonesia, dedicated to Brahma, Vishnu, and Shiva, famed for its towering spires and Ramayana stone carvings.',
      imageUrl:
          'https://images.unsplash.com/photo-1584810359583-96fc3448beaa?q=80&w=1000&auto=format&fit=crop',
      rating: 4.8,
      entryFeeRange: 'Rp 50.000 - Rp 350.000',
      isFeatured: true,
      latitude: -7.752020,
      longitude: 110.491467,
    ),
  ];

  static const List<CulturalEntry> culturalEntries = [
    CulturalEntry(
      id: 'gudeg',
      categoryId: 'food',
      title: 'Gudeg Jogja',
      localName: 'Gudeg Nangka Muda',
      summary:
          'Slow-cooked young jackfruit with palm sugar, coconut milk, and teak leaves.',
      description:
          'The signature royal delicacy of Yogyakarta, simmered for over 12 hours until deep mahogany, served with krecek (spicy beef skin) and areh coconut sauce.',
      provinceIds: ['diy', 'jateng'],
      imageUrl:
          'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?q=80&w=1000&auto=format&fit=crop',
      isUnescoRecognized: false,
    ),
    CulturalEntry(
      id: 'rawon',
      categoryId: 'food',
      title: 'Rawon Surabaya',
      localName: 'Rawon Daging Kluwek',
      summary: 'Rich black beef soup spiced with roasted keluak nuts.',
      description:
          'An ancient East Javanese beef soup characterized by its inky black broth flavored with fermented keluak nut, served with salted duck egg and bean sprouts.',
      provinceIds: ['jatim'],
      imageUrl:
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=1000&auto=format&fit=crop',
      isUnescoRecognized: false,
    ),
    CulturalEntry(
      id: 'batik_tulis',
      categoryId: 'textile',
      title: 'Batik Tulis Keraton',
      localName: 'Batik Tulis Tradisional',
      summary:
          'Intricate wax-resist hand-dyed textile embodying philosophical motifs.',
      description:
          'Traditional Indonesian wax-resist dyed cloth inscribed on UNESCO\'s Intangible Cultural Heritage list in 2009. Patterns like Parang Rusak and Kawung convey royal wisdom.',
      provinceIds: ['diy', 'jateng', 'jabar'],
      imageUrl:
          'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?q=80&w=1000&auto=format&fit=crop',
      isUnescoRecognized: true,
    ),
    CulturalEntry(
      id: 'wayang_kulit',
      categoryId: 'dance_music',
      title: 'Wayang Kulit Shadow Puppet',
      localName: 'Wayang Kulit Purwa',
      summary:
          'Mythological shadow play accompanied by live gamelan and the Dalang narrator.',
      description:
          'Masterpiece of Oral and Intangible Heritage of Humanity (UNESCO 2003). The puppet master (Dalang) breathes life into leather puppets retelling Mahabharata epics.',
      provinceIds: ['jateng', 'diy', 'jatim'],
      imageUrl:
          'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?q=80&w=1000&auto=format&fit=crop',
      isUnescoRecognized: true,
    ),
  ];
}
