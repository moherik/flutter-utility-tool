import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/bento_card.dart';

class TipCalculatorWidget extends StatefulWidget {
  const TipCalculatorWidget({Key? key}) : super(key: key);

  @override
  State<TipCalculatorWidget> createState() => _TipCalculatorWidgetState();
}

class _TipCalculatorWidgetState extends State<TipCalculatorWidget> {
  double _billAmount = 150000;
  double _tipPercent = 10;
  int _peopleCount = 2;

  final TextEditingController _billController = TextEditingController(
    text: '150000',
  );

  @override
  void initState() {
    super.initState();
    _billController.addListener(() {
      setState(() {
        _billAmount = double.tryParse(_billController.text) ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _billController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculations
    final totalTip = _billAmount * (_tipPercent / 100);
    final totalBill = _billAmount + totalTip;
    final tipPerPerson = totalTip / _peopleCount;
    final totalPerPerson = totalBill / _peopleCount;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Input Bill Card
          BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.translate('Jumlah Tagihan (Rp)', 'Bill Amount (Rp)'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.receipt_long_rounded, color: theme.primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _billController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tip & People Card
          BentoCard(
            child: Column(
              children: [
                // Tip percentage
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      provider.translate('Persentase Tip', 'Tip Percentage'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${_tipPercent.round()}%",
                      style: TextStyle(
                        fontSize: 18,
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _tipPercent,
                  min: 0,
                  max: 40,
                  divisions: 8,
                  activeColor: theme.primaryColor,
                  onChanged: (val) => setState(() => _tipPercent = val),
                ),

                const Divider(height: 24),

                // People Split
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      provider.translate('Jumlah Orang', 'Number of People'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline_rounded),
                          onPressed: () {
                            if (_peopleCount > 1)
                              setState(() => _peopleCount--);
                          },
                        ),
                        Text(
                          "$_peopleCount",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline_rounded),
                          onPressed: () {
                            if (_peopleCount < 50)
                              setState(() => _peopleCount++);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Results Section
          Text(
            provider.translate('Rincian Pembagian', 'Split Details'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          // Total Per Person Bento Card
          BentoCard(
            color: theme.primaryColor.withOpacity(0.08),
            borderColor: theme.primaryColor,
            child: Column(
              children: [
                Text(
                  provider.translate('Total Per Orang', 'Total Per Person'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey[300] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Rp ${totalPerPerson.toStringAsFixed(0)}",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                Text(
                  "${provider.translate('Uang tip:', 'Tip portion:')} Rp ${tipPerPerson.toStringAsFixed(0)}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Summary details
          Row(
            children: [
              Expanded(
                child: BentoCard(
                  child: Column(
                    children: [
                      Text(
                        provider.translate('Total Tip', 'Total Tip'),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Rp ${totalTip.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: BentoCard(
                  child: Column(
                    children: [
                      Text(
                        provider.translate('Total Bayar', 'Total Bill'),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Rp ${totalBill.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
