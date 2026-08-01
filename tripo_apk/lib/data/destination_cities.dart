class DestinationCity {
  final String name;
  final String country;
  final String imageUrl;
  final String tagline;

  const DestinationCity({
    required this.name,
    required this.country,
    required this.imageUrl,
    required this.tagline,
  });
}

class DestinationCities {
  static const featured = <String>[
    'Goa',
    'Dubai',
    'Paris',
    'Bali',
    'Mumbai',
  ];

  static const all = <DestinationCity>[
    DestinationCity(
      name: 'Goa',
      country: 'India',
      imageUrl:
          'https://images.unsplash.com/photo-1512343879784-a9602f3c5d45?w=400&q=80',
      tagline: 'Beaches & nightlife',
    ),
    DestinationCity(
      name: 'Dubai',
      country: 'UAE',
      imageUrl:
          'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=400&q=80',
      tagline: 'Luxury skyline',
    ),
    DestinationCity(
      name: 'Paris',
      country: 'France',
      imageUrl:
          'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=400&q=80',
      tagline: 'Romance & culture',
    ),
    DestinationCity(
      name: 'Bali',
      country: 'Indonesia',
      imageUrl:
          'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=400&q=80',
      tagline: 'Temples & calm',
    ),
    DestinationCity(
      name: 'Mumbai',
      country: 'India',
      imageUrl:
          'https://images.unsplash.com/photo-1529253355930-ddbe423a2ac7?w=400&q=80',
      tagline: 'City of dreams',
    ),
    DestinationCity(
      name: 'Delhi',
      country: 'India',
      imageUrl:
          'https://images.unsplash.com/photo-1587474260584-136574528ed5?w=400&q=80',
      tagline: 'Heritage capital',
    ),
    DestinationCity(
      name: 'Bengaluru',
      country: 'India',
      imageUrl:
          'https://images.unsplash.com/photo-1596176538476-4cf8c2f6f8f2?w=400&q=80',
      tagline: 'Garden city',
    ),
    DestinationCity(
      name: 'Tokyo',
      country: 'Japan',
      imageUrl:
          'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=400&q=80',
      tagline: 'Neon & tradition',
    ),
    DestinationCity(
      name: 'New York',
      country: 'USA',
      imageUrl:
          'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=400&q=80',
      tagline: 'The big apple',
    ),
    DestinationCity(
      name: 'London',
      country: 'UK',
      imageUrl:
          'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=400&q=80',
      tagline: 'History & style',
    ),
    DestinationCity(
      name: 'Singapore',
      country: 'Singapore',
      imageUrl:
          'https://images.unsplash.com/photo-1525625293386-3f8f99389edd?w=400&q=80',
      tagline: 'Garden metropolis',
    ),
    DestinationCity(
      name: 'Santorini',
      country: 'Greece',
      imageUrl:
          'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=400&q=80',
      tagline: 'Sunset cliffs',
    ),
    DestinationCity(
      name: 'Kyoto',
      country: 'Japan',
      imageUrl:
          'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=400&q=80',
      tagline: 'Temples & tea',
    ),
    DestinationCity(
      name: 'Ubud',
      country: 'Indonesia',
      imageUrl:
          'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=400&q=80',
      tagline: 'Rice terraces',
    ),
    DestinationCity(
      name: 'Interlaken',
      country: 'Switzerland',
      imageUrl:
          'https://images.unsplash.com/photo-1527004013197-933c4bb611b3?w=400&q=80',
      tagline: 'Alpine adventure',
    ),
  ];

  static List<DestinationCity> get featuredCities => all
      .where((c) => featured.contains(c.name))
      .toList();
}
