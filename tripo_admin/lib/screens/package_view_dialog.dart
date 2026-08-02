import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/admin_theme.dart';

class PackageViewDialog extends StatelessWidget {
  final Map<String, dynamic> package;

  const PackageViewDialog({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final title = '${package['title'] ?? ''}';
    final city = '${package['city'] ?? ''}';
    final country = '${package['country'] ?? ''}';
    final category = '${package['category'] ?? ''}';
    final image = '${package['image_url'] ?? ''}';
    final days = (package['duration_days'] as num?)?.toInt() ?? 0;
    final price = (package['price'] as num?)?.toDouble() ?? 0;
    final rating = (package['rating'] as num?)?.toDouble() ?? 0;
    final reviews = (package['reviews'] as num?)?.toInt() ?? 0;
    final description = '${package['description'] ?? ''}';
    final active = package['active'] != false;
    final highlights = ((package['highlights'] as List?) ?? [])
        .map((e) => '$e')
        .where((e) => e.trim().isNotEmpty)
        .toList();
    final includes = ((package['includes'] as List?) ?? [])
        .map((e) => '$e')
        .where((e) => e.trim().isNotEmpty)
        .toList();

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 12,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 700),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 18, 12, 16),
              decoration: const BoxDecoration(
                color: Color(0xFF0B3D66),
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Package details',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(22),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: image.isEmpty
                          ? Container(
                              color: const Color(0xFFE8EEF5),
                              child: const Icon(Icons.image_outlined, size: 40),
                            )
                          : Image.network(
                              image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                color: const Color(0xFFE8EEF5),
                                child: const Icon(
                                  Icons.broken_image_outlined,
                                  size: 40,
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      color: AdminTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$city, $country',
                    style: const TextStyle(
                      color: AdminTheme.slate,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Tag(category, AdminTheme.ocean),
                      _Tag('${days}D', AdminTheme.teal),
                      _Tag('★ $rating ($reviews)', AdminTheme.amber),
                      _Tag(
                        active ? 'Active' : 'Deactive',
                        active ? AdminTheme.teal : AdminTheme.rose,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Average budget per head',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AdminTheme.slate,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    money.format(price),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 26,
                      color: AdminTheme.ocean,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    const Text(
                      'About',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: AdminTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        height: 1.45,
                        color: AdminTheme.slate,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (highlights.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    const Text(
                      'Highlights',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: AdminTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...highlights.map(
                      (h) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: AdminTheme.teal,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                h,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AdminTheme.ink,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (includes.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Text(
                      'Includes',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: AdminTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: includes
                          .map((i) => _Tag(i, AdminTheme.ocean))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
              decoration: const BoxDecoration(
                color: Color(0xFFF3F7FB),
                border: Border(top: BorderSide(color: Color(0xFFD5E0EE))),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(18)),
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: AdminTheme.ocean,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 14,
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}
