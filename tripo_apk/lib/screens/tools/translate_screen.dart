import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';
import '../../widgets/page_scaffold.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  static const _phrases = <String, Map<String, String>>{
    'hello': {
      'hi': 'नमस्ते',
      'fr': 'Bonjour',
      'es': 'Hola',
      'ar': 'مرحبا',
      'ja': 'こんにちは',
    },
    'thank you': {
      'hi': 'धन्यवाद',
      'fr': 'Merci',
      'es': 'Gracias',
      'ar': 'شكرا',
      'ja': 'ありがとう',
    },
    'how much': {
      'hi': 'कितने का है?',
      'fr': 'Combien ça coûte ?',
      'es': '¿Cuánto cuesta?',
      'ar': 'بكم؟',
      'ja': 'いくらですか',
    },
    'where is the hotel': {
      'hi': 'होटल कहाँ है?',
      'fr': 'Où est l\'hôtel ?',
      'es': '¿Dónde está el hotel?',
      'ar': 'أين الفندق؟',
      'ja': 'ホテルはどこですか',
    },
    'help': {
      'hi': 'मदद कीजिए',
      'fr': 'Aidez-moi',
      'es': 'Ayuda',
      'ar': 'ساعدني',
      'ja': '助けて',
    },
    'water': {
      'hi': 'पानी',
      'fr': 'Eau',
      'es': 'Agua',
      'ar': 'ماء',
      'ja': '水',
    },
    'food': {
      'hi': 'खाना',
      'fr': 'Nourriture',
      'es': 'Comida',
      'ar': 'طعام',
      'ja': '食べ物',
    },
    'taxi': {
      'hi': 'टैक्सी',
      'fr': 'Taxi',
      'es': 'Taxi',
      'ar': 'تاكسي',
      'ja': 'タクシー',
    },
    'airport': {
      'hi': 'हवाई अड्डा',
      'fr': 'Aéroport',
      'es': 'Aeropuerto',
      'ar': 'المطار',
      'ja': '空港',
    },
    'good morning': {
      'hi': 'सुप्रभात',
      'fr': 'Bonjour',
      'es': 'Buenos días',
      'ar': 'صباح الخير',
      'ja': 'おはようございます',
    },
  };

  static const _langs = <(String, String)>[
    ('hi', 'Hindi'),
    ('fr', 'French'),
    ('es', 'Spanish'),
    ('ar', 'Arabic'),
    ('ja', 'Japanese'),
  ];

  final _input = TextEditingController();
  String _lang = 'hi';
  String _output = '';

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _translate() {
    final q = _input.text.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _output = '');
      return;
    }
    // Exact phrase match first.
    final exact = _phrases[q]?[_lang];
    if (exact != null) {
      setState(() => _output = exact);
      return;
    }
    // Partial contains match.
    for (final e in _phrases.entries) {
      if (q.contains(e.key) || e.key.contains(q)) {
        setState(() => _output = e.value[_lang] ?? '');
        return;
      }
    }
    setState(() => _output =
        'No offline match. Try: hello, thank you, how much, help, water, taxi, airport…');
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Translate',
      subtitle: 'Travel phrases (offline)',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          InputDecorator(
            decoration: InputDecoration(
              labelText: 'Translate to',
              filled: true,
              fillColor: AppColors.softBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _lang,
                isExpanded: true,
                items: _langs
                    .map((l) =>
                        DropdownMenuItem(value: l.$1, child: Text(l.$2)))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _lang = v);
                  _translate();
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _input,
            minLines: 3,
            maxLines: 5,
            onChanged: (_) => _translate(),
            decoration: InputDecoration(
              hintText: 'Type in English…',
              filled: true,
              fillColor: AppColors.softBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Result',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: AppColors.ocean)),
                    const Spacer(),
                    if (_output.isNotEmpty)
                      IconButton(
                        tooltip: 'Copy',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _output));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Copied'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded, size: 18),
                      ),
                  ],
                ),
                Text(
                  _output.isEmpty ? 'Translation appears here' : _output,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _output.isEmpty ? AppColors.slate : AppColors.ink,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Quick phrases',
              style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _phrases.keys.map((p) {
              return ActionChip(
                label: Text(p),
                onPressed: () {
                  _input.text = p;
                  _translate();
                },
                backgroundColor: AppColors.softSky,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
