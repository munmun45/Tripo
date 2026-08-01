import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/currency_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_scaffold.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final _amountCtrl = TextEditingController(text: '100');
  String _from = 'USD';
  String _to = 'INR';

  CurrencyRates _rates = CurrencyService.offline();
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRates() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final live = await CurrencyService.fetch(base: 'USD');
      if (!mounted) return;
      setState(() {
        _rates = live;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _rates = CurrencyService.offline();
        _loading = false;
        _error = 'Live rates unavailable — showing saved sample rates';
      });
    }
  }

  double get _amount => double.tryParse(_amountCtrl.text.trim()) ?? 0;

  double get _result => _rates.convert(
        amount: _amount,
        from: _from,
        to: _to,
      );

  void _swap() {
    setState(() {
      final t = _from;
      _from = _to;
      _to = t;
    });
  }

  @override
  Widget build(BuildContext context) {
    final codes = CurrencyService.supported;
    final unit = _rates.unitRate(_from, _to);
    final subtitle = _loading
        ? 'Fetching live rates…'
        : _rates.live
            ? (_rates.date.isEmpty
                ? 'Live market rates'
                : 'Live · ${_rates.date}')
            : 'Offline sample rates';

    return PageScaffold(
      title: 'Currency',
      subtitle: subtitle,
      actions: [
        IconButton(
          tooltip: 'Refresh rates',
          onPressed: _loading ? null : _loadRates,
          icon: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh_rounded, color: AppColors.ocean),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          if (_error != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F1FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD6E8FF)),
              ),
              child: Text(
                _error!,
                style: const TextStyle(fontSize: 12.5, color: AppColors.ink),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.ocean,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _rates.live ? 'LIVE CONVERTED' : 'CONVERTED',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const Spacer(),
                    if (_loading)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${_result.toStringAsFixed(2)} $_to',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Text(
                  '1 $_from = ${unit.toStringAsFixed(4)} $_to',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              labelText: 'Amount',
              filled: true,
              fillColor: AppColors.softBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _codeDropdown('From', _from, codes, (v) {
                  if (v != null) setState(() => _from = v);
                }),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: IconButton.filled(
                  onPressed: _swap,
                  style:
                      IconButton.styleFrom(backgroundColor: AppColors.ocean),
                  icon: const Icon(Icons.swap_horiz_rounded,
                      color: Colors.white),
                ),
              ),
              Expanded(
                child: _codeDropdown('To', _to, codes, (v) {
                  if (v != null) setState(() => _to = v);
                }),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            _rates.live
                ? 'Rates from Frankfurter (ECB). Refresh for latest values.'
                : 'Connect to the internet and tap refresh for live rates.',
            style: const TextStyle(color: AppColors.slate, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _codeDropdown(
    String label,
    String value,
    List<String> codes,
    ValueChanged<String?> onChanged,
  ) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.softBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: codes
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
