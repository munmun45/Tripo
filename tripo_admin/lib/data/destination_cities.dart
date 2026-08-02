/// Same destination list as Tripo app (`tripo_apk` all_cities_screen).
class DestinationCity {
  final String name;
  final String country;

  const DestinationCity({required this.name, required this.country});
}

class DestinationCities {
  static const categories = <String>[
    'Romantic',
    'Culture',
    'Wellness',
    'Adventure',
    'Luxury',
    'Beach',
    'Mountain',
  ];

  static const all = <DestinationCity>[
    DestinationCity(name: 'Goa', country: 'India'),
    DestinationCity(name: 'Dubai', country: 'UAE'),
    DestinationCity(name: 'Paris', country: 'France'),
    DestinationCity(name: 'Bali', country: 'Indonesia'),
    DestinationCity(name: 'Mumbai', country: 'India'),
    DestinationCity(name: 'Delhi', country: 'India'),
    DestinationCity(name: 'Bengaluru', country: 'India'),
    DestinationCity(name: 'Tokyo', country: 'Japan'),
    DestinationCity(name: 'New York', country: 'USA'),
    DestinationCity(name: 'London', country: 'UK'),
    DestinationCity(name: 'Singapore', country: 'Singapore'),
    DestinationCity(name: 'Santorini', country: 'Greece'),
    DestinationCity(name: 'Kyoto', country: 'Japan'),
    DestinationCity(name: 'Ubud', country: 'Indonesia'),
    DestinationCity(name: 'Interlaken', country: 'Switzerland'),
    DestinationCity(name: 'Male', country: 'Maldives'),
    DestinationCity(name: 'Reykjavik', country: 'Iceland'),
    DestinationCity(name: 'Manali', country: 'India'),
    DestinationCity(name: 'Banff', country: 'Canada'),
    DestinationCity(name: 'Jasper', country: 'Canada'),
    DestinationCity(name: 'Calgary', country: 'Canada'),
  ];
}
