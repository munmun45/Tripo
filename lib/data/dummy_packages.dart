import '../models/travel_package.dart';

class DummyPackages {
  static const List<TravelPackage> all = [
    TravelPackage(
      id: '1',
      title: 'Santorini Sunset Escape',
      city: 'Santorini',
      country: 'Greece',
      imageUrl:
          'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=800&q=80',
      price: 89999,
      durationDays: 6,
      rating: 4.9,
      reviews: 312,
      description:
          'Drift through whitewashed alleys, private caldera views, and golden Aegean evenings. A curated island escape with cliffside dining and yacht sunset sails.',
      highlights: [
        'Private caldera suite',
        'Sunset catamaran cruise',
        'Oia village walk',
        'Wine tasting in Pyrgos',
      ],
      includes: ['Flights', 'Boutique stay', 'Breakfast', 'Airport transfers'],
      category: 'Romantic',
    ),
    TravelPackage(
      id: '2',
      title: 'Kyoto Temple Trail',
      city: 'Kyoto',
      country: 'Japan',
      imageUrl:
          'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=800&q=80',
      price: 124999,
      durationDays: 6,
      rating: 4.8,
      reviews: 248,
      description:
          'Walk ancient paths, tea houses, and bamboo groves with a local guide. Slow mornings in Gion and quiet evenings by the Kamo River.',
      highlights: [
        'Arashiyama bamboo forest',
        'Private tea ceremony',
        'Fushimi Inari at dawn',
        'Kaiseki dinner',
      ],
      includes: ['Hotels', 'JR Pass days', 'Guided walks', 'Selected meals'],
      category: 'Culture',
    ),
    TravelPackage(
      id: '3',
      title: 'Bali Wellness Retreat',
      city: 'Ubud',
      country: 'Indonesia',
      imageUrl:
          'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=800&q=80',
      price: 67999,
      durationDays: 3,
      rating: 4.7,
      reviews: 189,
      description:
          'Rice terraces, spa rituals, and jungle villas. Reset with yoga at sunrise and a sacred water temple blessing.',
      highlights: [
        'Jungle villa stay',
        'Daily yoga & spa',
        'Tirta Empul purification',
        'Tegalalang terraces',
      ],
      includes: ['Villa', 'Spa credits', 'Airport pickup', 'Breakfast'],
      category: 'Wellness',
    ),
    TravelPackage(
      id: '4',
      title: 'Swiss Alps Adventure',
      city: 'Interlaken',
      country: 'Switzerland',
      imageUrl:
          'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=800&q=80',
      price: 149999,
      durationDays: 9,
      rating: 4.9,
      reviews: 156,
      description:
          'Peaks, trains, and glacial lakes. Ride the Jungfraujoch, hike alpine meadows, and unwind in lakeside Interlaken.',
      highlights: [
        'Jungfraujoch excursion',
        'Harder Kulm views',
        'Lake Brienz cruise',
        'Scenic train day',
      ],
      includes: ['Swiss Travel Pass', 'Hotels', 'Breakfast', 'Transfers'],
      category: 'Adventure',
    ),
    TravelPackage(
      id: '5',
      title: 'Dubai Desert Luxury',
      city: 'Dubai',
      country: 'UAE',
      imageUrl:
          'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=800&q=80',
      price: 95999,
      durationDays: 3,
      rating: 4.6,
      reviews: 421,
      description:
          'Skyline nights, desert dunes, and marina mornings. A polished city-and-desert blend with premium stays.',
      highlights: [
        'Desert safari & dinner',
        'Burj Khalifa tickets',
        'Marina yacht hour',
        'Old Dubai souk tour',
      ],
      includes: ['5★ hotel', 'Safari', 'City tour', 'Airport transfers'],
      category: 'Luxury',
    ),
    TravelPackage(
      id: '6',
      title: 'Paris Heritage Walk',
      city: 'Paris',
      country: 'France',
      imageUrl:
          'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800&q=80',
      price: 112999,
      durationDays: 6,
      rating: 4.8,
      reviews: 367,
      description:
          'Museums, cafés, and Seine evenings. Skip-the-line icons with intimate Left Bank stays.',
      highlights: [
        'Louvre priority entry',
        'Seine dinner cruise',
        'Montmartre walk',
        'Versailles day trip',
      ],
      includes: ['Boutique hotel', 'Museum passes', 'Breakfast', 'Metro card'],
      category: 'Culture',
    ),
    TravelPackage(
      id: '7',
      title: 'Maldives Overwater Bliss',
      city: 'Malé',
      country: 'Maldives',
      imageUrl:
          'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?w=800&q=80',
      price: 189999,
      durationDays: 9,
      rating: 5.0,
      reviews: 98,
      description:
          'Turquoise lagoons and overwater villas. Snorkel house reefs and dine under the stars.',
      highlights: [
        'Overwater villa',
        'House reef snorkel',
        'Sunset dolphin cruise',
        'Private beach dinner',
      ],
      includes: ['Seaplane', 'All meals', 'Spa credit', 'Water sports'],
      category: 'Romantic',
    ),
    TravelPackage(
      id: '8',
      title: 'Goa Coastal Escape',
      city: 'Goa',
      country: 'India',
      imageUrl:
          'https://images.unsplash.com/photo-1512343879784-a9602f3c5d45?w=800&q=80',
      price: 24999,
      durationDays: 4,
      rating: 4.5,
      reviews: 512,
      description:
          'Golden beaches, Portuguese lanes, and spice-laced evenings. Soft adventure with beach clubs and fort views.',
      highlights: [
        'Beachfront resort',
        'Old Goa heritage',
        'Spice plantation lunch',
        'Sunset at Chapora',
      ],
      includes: ['Resort stay', 'Breakfast', 'Airport transfer', 'One tour'],
      category: 'Beach',
    ),
    TravelPackage(
      id: '9',
      title: 'Iceland Northern Lights',
      city: 'Reykjavik',
      country: 'Iceland',
      imageUrl:
          'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=800&q=80',
      price: 159999,
      durationDays: 6,
      rating: 4.9,
      reviews: 134,
      description:
          'Chase auroras, soak in lagoons, and cross volcanic landscapes on a carefully paced winter route.',
      highlights: [
        'Aurora hunt nights',
        'Blue Lagoon soak',
        'Golden Circle tour',
        'Reynisfjara black beach',
      ],
      includes: ['Hotels', 'Guided tours', 'Breakfast', 'Airport transfer'],
      category: 'Adventure',
    ),
    TravelPackage(
      id: '10',
      title: 'Manali Mountain Getaway',
      city: 'Manali',
      country: 'India',
      imageUrl:
          'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?w=800&q=80',
      price: 18999,
      durationDays: 5,
      rating: 4.4,
      reviews: 278,
      description:
          'Pine forests, river valleys, and Himalayan air. Ideal for couples and families seeking cool altitude.',
      highlights: [
        'Solang Valley',
        'Hadimba Temple',
        'River rafting option',
        'Local Himachali feast',
      ],
      includes: ['Hotel', 'Breakfast & dinner', 'Sightseeing', 'Transfers'],
      category: 'Mountain',
    ),
    TravelPackage(
      id: '11',
      title: 'Banff Lakeside Escape',
      city: 'Banff',
      country: 'Alberta, Canada',
      imageUrl:
          'https://images.unsplash.com/photo-1503614472-8c00d9009f2c?w=800&q=80',
      price: 134999,
      durationDays: 6,
      rating: 4.9,
      reviews: 221,
      description:
          'Turquoise lakes, mountain air, and quiet evenings in Banff. Perfect for nature lovers and photographers.',
      highlights: [
        'Lake Louise visit',
        'Moraine Lake viewpoints',
        'Banff Gondola',
        'Bow River walk',
      ],
      includes: ['Lodge stay', 'Breakfast', 'Park fees', 'Transfers'],
      category: 'Mountain',
    ),
    TravelPackage(
      id: '12',
      title: 'Jasper Wilderness Trail',
      city: 'Jasper',
      country: 'Alberta, Canada',
      imageUrl:
          'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800&q=80',
      price: 118999,
      durationDays: 9,
      rating: 4.8,
      reviews: 164,
      description:
          'Deep Rockies wilderness — glaciers, wildlife spotting, and starry Alberta nights on a paced 9-day route.',
      highlights: [
        'Athabasca Glacier',
        'Maligne Lake cruise',
        'Wildlife viewing',
        'Icefields Parkway',
      ],
      includes: ['Cabins', 'Guided day', 'Breakfast', 'Park passes'],
      category: 'Adventure',
    ),
    TravelPackage(
      id: '13',
      title: 'Calgary City Break',
      city: 'Calgary',
      country: 'Alberta, Canada',
      imageUrl:
          'https://images.unsplash.com/photo-1519834785169-98be25ec3f84?w=800&q=80',
      price: 54999,
      durationDays: 3,
      rating: 4.5,
      reviews: 98,
      description:
          'A quick 3-day Alberta city break — skyline views, local food, and easy access to the Rockies.',
      highlights: [
        'Calgary Tower',
        'Stephen Avenue walk',
        'Heritage Park',
        'Local steakhouse dinner',
      ],
      includes: ['Hotel', 'Breakfast', 'City pass', 'Airport transfer'],
      category: 'Culture',
    ),
  ];

  static TravelPackage? byId(String id) {
    try {
      return all.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<TravelPackage> featured() => all.take(9).toList();
}
