import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/destination_cities.dart';
import '../theme/admin_theme.dart';

class PackageFormDialog extends StatefulWidget {
  final Map<String, dynamic>? package;

  const PackageFormDialog({super.key, this.package});

  @override
  State<PackageFormDialog> createState() => _PackageFormDialogState();
}

class _PackageFormDialogState extends State<PackageFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _imageUrl;
  late final TextEditingController _price;
  late final TextEditingController _days;
  late final TextEditingController _rating;
  late final TextEditingController _reviews;
  late final TextEditingController _description;
  late final TextEditingController _highlights;
  late final TextEditingController _includes;

  String? _city;
  String _country = '';
  String _category = DestinationCities.categories.first;
  bool _active = true;

  bool get _editing => widget.package != null;

  static final _fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: Color(0xFFB8C7DA), width: 1.2),
  );
  static final _focusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: AdminTheme.ocean, width: 1.6),
  );
  static final _errorBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: AdminTheme.rose, width: 1.4),
  );

  InputDecoration _dec(String hint, {String? helper, int? maxLines}) {
    return InputDecoration(
      hintText: hint,
      helperText: helper,
      filled: true,
      fillColor: const Color(0xFFF7FAFD),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: maxLines != null && maxLines > 1 ? 14 : 14,
      ),
      hintStyle: TextStyle(
        color: AdminTheme.slate.withValues(alpha: 0.65),
        fontWeight: FontWeight.w500,
      ),
      helperStyle: const TextStyle(
        color: AdminTheme.slate,
        fontWeight: FontWeight.w500,
      ),
      border: _fieldBorder,
      enabledBorder: _fieldBorder,
      focusedBorder: _focusedBorder,
      errorBorder: _errorBorder,
      focusedErrorBorder: _errorBorder,
    );
  }

  @override
  void initState() {
    super.initState();
    final p = widget.package;
    _title = TextEditingController(text: '${p?['title'] ?? ''}');
    _imageUrl = TextEditingController(text: '${p?['image_url'] ?? ''}');
    _price = TextEditingController(
      text: p?['price'] == null ? '' : '${p!['price']}',
    );
    _days = TextEditingController(text: '${p?['duration_days'] ?? 4}');
    _rating = TextEditingController(text: '${p?['rating'] ?? 4.5}');
    _reviews = TextEditingController(text: '${p?['reviews'] ?? 0}');
    _description = TextEditingController(text: '${p?['description'] ?? ''}');
    _highlights = TextEditingController(
      text: ((p?['highlights'] as List?) ?? []).join('\n'),
    );
    _includes = TextEditingController(
      text: ((p?['includes'] as List?) ?? []).join('\n'),
    );
    _category = '${p?['category'] ?? DestinationCities.categories.first}';
    if (!DestinationCities.categories.contains(_category)) {
      _category = DestinationCities.categories.first;
    }
    _active = p?['active'] != false;
    final cityName = '${p?['city'] ?? ''}';
    final match = DestinationCities.all.where((c) => c.name == cityName);
    if (match.isNotEmpty) {
      _city = match.first.name;
      _country = match.first.country;
    } else if (cityName.isNotEmpty) {
      _city = cityName;
      _country = '${p?['country'] ?? ''}';
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _imageUrl.dispose();
    _price.dispose();
    _days.dispose();
    _rating.dispose();
    _reviews.dispose();
    _description.dispose();
    _highlights.dispose();
    _includes.dispose();
    super.dispose();
  }

  List<String> _lines(String raw) => raw
      .split(RegExp(r'[\r\n]+'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_city == null || _city!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a city')),
      );
      return;
    }
    Navigator.of(context).pop(<String, dynamic>{
      if (_editing) 'id': widget.package!['id'],
      'title': _title.text.trim(),
      'city': _city,
      'country': _country,
      'image_url': _imageUrl.text.trim(),
      'price': double.tryParse(_price.text.trim()) ?? 0,
      'duration_days': int.tryParse(_days.text.trim()) ?? 1,
      'rating': double.tryParse(_rating.text.trim()) ?? 0,
      'reviews': int.tryParse(_reviews.text.trim()) ?? 0,
      'category': _category,
      'description': _description.text.trim(),
      'highlights': _lines(_highlights.text),
      'includes': _lines(_includes.text),
      'active': _active,
    });
  }

  @override
  Widget build(BuildContext context) {
    final cities = [...DestinationCities.all];
    if (_city != null && !cities.any((c) => c.name == _city)) {
      cities.insert(0, DestinationCity(name: _city!, country: _country));
    }

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 12,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 740),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _editing ? 'Edit package' : 'Create new package',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Clear form · same fields as Tripo app detail page',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                          ),
                        ),
                      ],
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
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 10),
                  children: [
                    const _Section('Basic info'),
                    _Label('Title *'),
                    TextFormField(
                      controller: _title,
                      style: const TextStyle(
                        color: AdminTheme.ink,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: _dec('e.g. Banff Lakeside Escape'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Label('City *'),
                              DropdownButtonFormField<String>(
                                // ignore: deprecated_member_use
                                value: _city,
                                dropdownColor: Colors.white,
                                style: const TextStyle(
                                  color: AdminTheme.ink,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: _dec('Select city'),
                                items: cities
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c.name,
                                        child: Text('${c.name}, ${c.country}'),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  final city =
                                      cities.firstWhere((c) => c.name == v);
                                  setState(() {
                                    _city = city.name;
                                    _country = city.country;
                                  });
                                },
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'Select city' : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Label('Country'),
                              TextFormField(
                                key: ValueKey('country-$_country'),
                                initialValue:
                                    _country.isEmpty ? '—' : _country,
                                readOnly: true,
                                style: const TextStyle(
                                  color: AdminTheme.ink,
                                  fontWeight: FontWeight.w700,
                                ),
                                decoration: _dec(
                                  'Auto',
                                  helper: 'From city',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Label('Category'),
                              DropdownButtonFormField<String>(
                                // ignore: deprecated_member_use
                                value: _category,
                                dropdownColor: Colors.white,
                                style: const TextStyle(
                                  color: AdminTheme.ink,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: _dec('Category'),
                                items: DestinationCities.categories
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(c),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _category = v ?? _category),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Label('Image URL'),
                              TextFormField(
                                controller: _imageUrl,
                                style: const TextStyle(
                                  color: AdminTheme.ink,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                                decoration: _dec('https://...'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const _Section('Budget & stay'),
                    _Label('Average budget per head (₹)'),
                    TextFormField(
                      controller: _price,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9.]'),
                        ),
                      ],
                      style: const TextStyle(
                        color: AdminTheme.ink,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: _dec('e.g. 134999'),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Label('Duration days'),
                              TextFormField(
                                controller: _days,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  color: AdminTheme.ink,
                                  fontWeight: FontWeight.w700,
                                ),
                                decoration: _dec('6'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Label('Rating'),
                              TextFormField(
                                controller: _rating,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  color: AdminTheme.ink,
                                  fontWeight: FontWeight.w700,
                                ),
                                decoration: _dec('4.9'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Label('Reviews'),
                              TextFormField(
                                controller: _reviews,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  color: AdminTheme.ink,
                                  fontWeight: FontWeight.w700,
                                ),
                                decoration: _dec('210'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const _Section('Content'),
                    _Label('Description (About)'),
                    TextFormField(
                      controller: _description,
                      maxLines: 3,
                      style: const TextStyle(
                        color: AdminTheme.ink,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                      decoration: _dec('Short about text for detail page'),
                    ),
                    const SizedBox(height: 14),
                    _Label('Highlights (one per line)'),
                    TextFormField(
                      controller: _highlights,
                      maxLines: 3,
                      style: const TextStyle(
                        color: AdminTheme.ink,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                      decoration: _dec('Lake Louise\nMoraine Lake hike'),
                    ),
                    const SizedBox(height: 14),
                    _Label('Includes (one per line)'),
                    TextFormField(
                      controller: _includes,
                      maxLines: 3,
                      style: const TextStyle(
                        color: AdminTheme.ink,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                      decoration: _dec('Hotel\nBreakfast\nTransfers'),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF6FB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFB8C7DA)),
                      ),
                      child: SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Active in app catalog',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AdminTheme.ink,
                          ),
                        ),
                        subtitle: Text(
                          _active
                              ? 'Users can see this package'
                              : 'Hidden from users',
                          style: const TextStyle(color: AdminTheme.slate),
                        ),
                        value: _active,
                        activeTrackColor: AdminTheme.teal,
                        onChanged: (v) => setState(() => _active = v),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
              decoration: const BoxDecoration(
                color: Color(0xFFF3F7FB),
                border: Border(top: BorderSide(color: Color(0xFFD5E0EE))),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
              ),
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AdminTheme.ink,
                      side: const BorderSide(color: Color(0xFFB8C7DA)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AdminTheme.ocean,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      _editing ? 'Save changes' : 'Create package',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String text;
  const _Section(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
          color: AdminTheme.ocean,
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: AdminTheme.ink,
        ),
      ),
    );
  }
}
