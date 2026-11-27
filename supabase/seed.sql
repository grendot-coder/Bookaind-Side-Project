-- ============================================================================
-- BOOKAIND CULTURAL SEED DATA
-- Contributors: To add or propose a new destination or cultural story,
-- append an INSERT statement below and submit a Pull Request!
-- ============================================================================

-- PROVINCES (Examples)
INSERT INTO provinces (id, name, local_name, capital, tagline, hero_image_url, latitude, longitude)
VALUES 
  ('yogyakarta', 'D.I. Yogyakarta', 'Daerah Istimewa Yogyakarta', 'Yogyakarta', 'The Cradle of Javanese High Culture & Ancient Mataram', 'https://images.unsplash.com/photo-1596402184320-417e7178b2cd', -7.797068, 110.370529),
  ('central_java', 'Central Java', 'Jawa Tengah', 'Semarang', 'Land of Royal Candi & Volcanic Highlands', 'https://images.unsplash.com/photo-1588668214407-6ea9a6d8c272', -7.150975, 110.140259),
  ('east_java', 'East Java', 'Jawa Timur', 'Surabaya', 'Majapahit Heritage & Mystic Volcanic Landscapes', 'https://images.unsplash.com/photo-1589802829985-817e51171b92', -7.536064, 112.238402),
  ('north_sumatra', 'North Sumatra', 'Sumatera Utara', 'Medan', 'Ancient Batak Kingdoms & Volcanic Lake Toba', 'https://images.unsplash.com/photo-1563281577-a7be47e20db9', 2.115355, 99.545097)
ON CONFLICT (id) DO UPDATE SET 
  name = EXCLUDED.name,
  tagline = EXCLUDED.tagline,
  hero_image_url = EXCLUDED.hero_image_url;

-- CULTURAL CATEGORIES
INSERT INTO cultural_categories (id, name, slug, icon_name, accent_color_key)
VALUES
  ('architecture', 'Monuments & Temples', 'architecture', 'temple_buddhist', 'coral'),
  ('culinary', 'Traditional Culinary', 'culinary', 'restaurant', 'saffron'),
  ('textile', 'Textiles & Batik', 'textile', 'palette', 'teal'),
  ('performing_arts', 'Performing Arts & Wayang', 'performing-arts', 'theater_comedy', 'blue')
ON CONFLICT (id) DO NOTHING;

-- DESTINATIONS
-- Format: (id, title, province_id, city_or_regency, tagline, description, image_url, rating, entry_fee_range, is_featured, latitude, longitude, type)
INSERT INTO destinations (id, title, province_id, city_or_regency, tagline, description, image_url, rating, entry_fee_range, is_featured, latitude, longitude, type)
VALUES
  ('borobudur', 'Candi Borobudur', 'central_java', 'Magelang', 'The World''s Largest Buddhist Sanctuary', 'A monumental 8th-century Mahayana Buddhist temple built during the reign of the Sailendra Dynasty. Comprising nine stacked platforms crowned by a central dome, it features 2,672 relief panels.', 'https://images.unsplash.com/photo-1596402184320-417e7178b2cd', 4.9, 'Rp 50.000 - Rp 375.000', true, -7.607874, 110.203751, 'structure'),
  ('prambanan', 'Candi Prambanan', 'yogyakarta', 'Sleman', 'The Soaring Spires of Trimurti', 'The largest Hindu temple compound in Indonesia, dedicated to the Trimurti (Brahma, Vishnu, Shiva). Characterized by its tall, pointed architecture reaching 47 meters.', 'https://images.unsplash.com/photo-1588668214407-6ea9a6d8c272', 4.8, 'Rp 50.000 - Rp 350.000', true, -7.752021, 110.491467, 'structure'),
  ('sibea_bea', 'Bukit Sibea-Bea', 'north_sumatra', 'Samosir', 'Spiritual Landmark of Lake Toba', 'A breathtaking cultural and religious landmark in Samosir Regency, North Sumatra. Features the towering 61-meter statue of Jesus Christ overlooking Lake Toba with an iconic winding roadway.', 'https://images.unsplash.com/photo-1563281577-a7be47e20db9', 4.8, 'Rp 5.000 - Rp 50.000', true, 2.5833, 98.7167, 'structure'),
  ('baluran', 'Taman Nasional Baluran', 'east_java', 'Situbondo', 'The Savanna of Java', 'Known as the "Africa van Java", Baluran is a preservation of seasonal dry forest and vast acacia savannas, home to wild Javan water buffalo (banteng), peacocks, and deer.', 'https://images.unsplash.com/photo-1544735716-392fe2489ffa', 4.7, 'Rp 16.000 - Rp 165.000', true, -7.8389, 114.3917, 'nature')
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  tagline = EXCLUDED.tagline,
  description = EXCLUDED.description,
  image_url = EXCLUDED.image_url,
  type = EXCLUDED.type;
