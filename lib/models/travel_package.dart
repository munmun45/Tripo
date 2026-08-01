class TravelPackage {
  final String id;
  final String title;
  final String city;
  final String country;
  final String imageUrl;
  final double price;
  final int durationDays;
  final double rating;
  final int reviews;
  final String description;
  final List<String> highlights;
  final List<String> includes;
  final String category;

  const TravelPackage({
    required this.id,
    required this.title,
    required this.city,
    required this.country,
    required this.imageUrl,
    required this.price,
    required this.durationDays,
    required this.rating,
    required this.reviews,
    required this.description,
    required this.highlights,
    required this.includes,
    required this.category,
  });

  /// Nights in package (days − 1). Day trips show 0 nights.
  int get nights => durationDays <= 1 ? 0 : durationDays - 1;

  /// Short label for cards: `5N / 6D`
  String get stayShort {
    if (nights <= 0) return '${durationDays}D';
    return '${nights}N / ${durationDays}D';
  }

  /// Longer label for detail: `5 nights · 6 days`
  String get stayLong {
    if (nights <= 0) {
      return '$durationDays day${durationDays == 1 ? '' : 's'}';
    }
    final n = '$nights night${nights == 1 ? '' : 's'}';
    final d = '$durationDays day${durationDays == 1 ? '' : 's'}';
    return '$n · $d';
  }
}
