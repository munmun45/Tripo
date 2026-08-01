import 'dart:convert';

import 'package:http/http.dart' as http;

/// Live FX via Frankfurter (ECB) — free, no API key.
class CurrencyService {
  CurrencyService._();

  static const supported = <String>[
    'INR',
    'USD',
    'EUR',
    'GBP',
    'AED',
    'JPY',
    'SGD',
    'THB',
    'AUD',
    'CAD',
    'CHF',
    'CNY',
  ];

  /// Currencies Frankfurter/ECB actually returns (no AED).
  static const _apiCodes = <String>[
    'INR',
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'SGD',
    'THB',
    'AUD',
    'CAD',
    'CHF',
    'CNY',
  ];

  /// Fallback if network fails (approx).
  static const fallbackUsd = <String, double>{
    'USD': 1,
    'INR': 83.5,
    'EUR': 0.92,
    'GBP': 0.79,
    'AED': 3.67,
    'JPY': 150.0,
    'SGD': 1.34,
    'THB': 35.5,
    'AUD': 1.52,
    'CAD': 1.36,
    'CHF': 0.88,
    'CNY': 7.24,
  };

  /// Rates relative to [base] (1 base = rate[code] of that currency).
  static Future<CurrencyRates> fetch({String base = 'USD'}) async {
    final codes = _apiCodes.where((c) => c != base).join(',');
    final uri = Uri.parse(
      'https://api.frankfurter.app/latest?from=$base&to=$codes',
    );
    final res = await http.get(uri).timeout(const Duration(seconds: 8));
    if (res.statusCode != 200) {
      throw Exception('Rate fetch failed (${res.statusCode})');
    }
    final j = jsonDecode(res.body) as Map<String, dynamic>;
    final raw = Map<String, dynamic>.from(j['rates'] as Map? ?? {});
    final rates = <String, double>{base: 1};
    for (final e in raw.entries) {
      rates[e.key] = (e.value as num).toDouble();
    }
    // Fill missing codes (e.g. AED) from USD-based fallback.
    final usdToBase = rates['USD'] ?? (base == 'USD' ? 1.0 : null);
    for (final code in supported) {
      if (rates.containsKey(code)) continue;
      final codePerUsd = fallbackUsd[code] ?? 1;
      if (base == 'USD') {
        rates[code] = codePerUsd;
      } else if (usdToBase != null && usdToBase != 0) {
        // 1 base = usdToBase USD; 1 USD = codePerUsd code
        rates[code] = usdToBase * codePerUsd;
      } else {
        final basePerUsd = fallbackUsd[base] ?? 1;
        rates[code] = codePerUsd / basePerUsd;
      }
    }
    final date = j['date'] as String? ?? '';
    return CurrencyRates(
      base: base,
      rates: rates,
      date: date,
      live: true,
    );
  }

  static CurrencyRates offline({String base = 'USD'}) {
    final usd = fallbackUsd;
    final basePerUsd = usd[base] ?? 1;
    final rates = <String, double>{};
    for (final e in usd.entries) {
      // 1 base = (e.value / basePerUsd) of e.key
      rates[e.key] = e.value / basePerUsd;
    }
    return CurrencyRates(
      base: base,
      rates: rates,
      date: '',
      live: false,
    );
  }
}

class CurrencyRates {
  final String base;
  final Map<String, double> rates;
  final String date;
  final bool live;

  const CurrencyRates({
    required this.base,
    required this.rates,
    required this.date,
    required this.live,
  });

  double convert({
    required double amount,
    required String from,
    required String to,
  }) {
    final f = rates[from] ?? 1;
    final t = rates[to] ?? 1;
    if (f == 0) return 0;
    // amount from → base → to
    return amount / f * t;
  }

  double unitRate(String from, String to) =>
      convert(amount: 1, from: from, to: to);
}
