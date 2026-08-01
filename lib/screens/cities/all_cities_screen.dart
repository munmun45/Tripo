import 'package:flutter/material.dart';
import '../../data/destination_cities.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_scaffold.dart';

/// Full list of destination cities — not linked to weather.
class AllCitiesScreen extends StatefulWidget {
  const AllCitiesScreen({super.key});

  @override
  State<AllCitiesScreen> createState() => _AllCitiesScreenState();
}

class _AllCitiesScreenState extends State<AllCitiesScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<DestinationCity> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return DestinationCities.all;
    return DestinationCities.all
        .where(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              c.country.toLowerCase().contains(q) ||
              c.tagline.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final cities = _filtered;
    final width = MediaQuery.sizeOf(context).width;
    final cross = width >= 700 ? 4 : 3;

    return PageScaffold(
      title: 'All cities',
      subtitle: '${DestinationCities.all.length} destinations',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: TextField(
              controller: _search,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search city or country',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: AppColors.softBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
          ),
          Expanded(
            child: cities.isEmpty
                ? const Center(
                    child: Text(
                      'No cities found',
                      style: TextStyle(color: AppColors.slate),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cross,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: cities.length,
                    itemBuilder: (context, i) {
                      final c = cities[i];
                      return _CityGridTile(city: c);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CityGridTile extends StatelessWidget {
  final DestinationCity city;

  const _CityGridTile({required this.city});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: ClipOval(
              child: Image.network(
                city.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.softSky,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.location_city_rounded,
                    color: AppColors.teal,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          city.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            color: AppColors.ink,
          ),
        ),
        Text(
          city.country,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.slate,
          ),
        ),
      ],
    );
  }
}
