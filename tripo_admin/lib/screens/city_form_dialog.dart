import 'package:flutter/material.dart';

import '../theme/admin_theme.dart';

class CityFormDialog extends StatefulWidget {
  final Map<String, dynamic>? city;
  final List<Map<String, dynamic>> countries;
  final List<Map<String, dynamic>> states;

  const CityFormDialog({
    super.key,
    this.city,
    required this.countries,
    required this.states,
  });

  @override
  State<CityFormDialog> createState() => _CityFormDialogState();
}

class _CityFormDialogState extends State<CityFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _imageUrl;
  late final TextEditingController _tagline;
  int? _countryId;
  int? _stateId;
  bool _active = true;

  bool get _editing => widget.city != null;

  static final _border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: Color(0xFFB8C7DA), width: 1.2),
  );

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF7FAFD),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: _border,
        enabledBorder: _border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AdminTheme.ocean, width: 1.6),
        ),
      );

  @override
  void initState() {
    super.initState();
    final c = widget.city;
    _name = TextEditingController(text: '${c?['name'] ?? ''}');
    _imageUrl = TextEditingController(text: '${c?['image_url'] ?? ''}');
    _tagline = TextEditingController(text: '${c?['tagline'] ?? ''}');
    _countryId = (c?['country_id'] as num?)?.toInt();
    _stateId = (c?['state_id'] as num?)?.toInt();
    _active = c?['active'] != false;
  }

  @override
  void dispose() {
    _name.dispose();
    _imageUrl.dispose();
    _tagline.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _statesForCountry {
    if (_countryId == null) return const [];
    return widget.states
        .where((s) => (s['country_id'] as num?)?.toInt() == _countryId)
        .toList();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_countryId == null || _stateId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select country and state')),
      );
      return;
    }
    Navigator.pop(context, <String, dynamic>{
      if (_editing) 'id': widget.city!['id'],
      'name': _name.text.trim(),
      'country_id': _countryId,
      'state_id': _stateId,
      'image_url': _imageUrl.text.trim(),
      'tagline': _tagline.text.trim(),
      'active': _active,
    });
  }

  @override
  Widget build(BuildContext context) {
    final states = _statesForCountry;

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 12,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
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
                    child: Text(
                      _editing ? 'Edit city' : 'Create city',
                      style: const TextStyle(
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
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 10),
                  children: [
                    const _Label('City name *'),
                    TextFormField(
                      controller: _name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AdminTheme.ink,
                      ),
                      decoration: _dec('e.g. Goa'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    const _Label('Country *'),
                    DropdownButtonFormField<int>(
                      // ignore: deprecated_member_use
                      value: _countryId,
                      dropdownColor: Colors.white,
                      decoration: _dec('Select country'),
                      items: widget.countries
                          .map(
                            (c) => DropdownMenuItem(
                              value: (c['id'] as num).toInt(),
                              child: Text('${c['name']}'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          _countryId = v;
                          _stateId = null;
                        });
                      },
                      validator: (v) => v == null ? 'Select country' : null,
                    ),
                    const SizedBox(height: 14),
                    const _Label('State *'),
                    DropdownButtonFormField<int>(
                      // ignore: deprecated_member_use
                      value: _stateId,
                      dropdownColor: Colors.white,
                      decoration: _dec(
                        _countryId == null
                            ? 'Select country first'
                            : 'Select state',
                      ),
                      items: states
                          .map(
                            (s) => DropdownMenuItem(
                              value: (s['id'] as num).toInt(),
                              child: Text('${s['name']}'),
                            ),
                          )
                          .toList(),
                      onChanged: _countryId == null
                          ? null
                          : (v) => setState(() => _stateId = v),
                      validator: (v) => v == null ? 'Select state' : null,
                    ),
                    const SizedBox(height: 14),
                    const _Label('Image URL *'),
                    TextFormField(
                      controller: _imageUrl,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AdminTheme.ink,
                        fontSize: 13,
                      ),
                      decoration: _dec('https://...'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    const _Label('Tagline'),
                    TextFormField(
                      controller: _tagline,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AdminTheme.ink,
                      ),
                      decoration: _dec('e.g. Beaches & nightlife'),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Active',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      value: _active,
                      activeTrackColor: AdminTheme.teal,
                      onChanged: (v) => setState(() => _active = v),
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
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(18)),
              ),
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AdminTheme.ocean,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    child: Text(
                      _editing ? 'Save changes' : 'Create city',
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
