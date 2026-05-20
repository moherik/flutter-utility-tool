import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bento_card.dart';

class UnitConverterWidget extends StatefulWidget {
  const UnitConverterWidget({Key? key}) : super(key: key);

  @override
  State<UnitConverterWidget> createState() => _UnitConverterWidgetState();
}

class _UnitConverterWidgetState extends State<UnitConverterWidget> {
  String _selectedCategory = 'Panjang'; // Default category (Indonesian)
  String _inputUnit = 'Meter';
  double _inputValue = 1.0;
  final TextEditingController _controller = TextEditingController(text: '1.0');

  // Categories & Units
  final Map<String, List<String>> _categories = {
    'Panjang': [
      'Meter',
      'Kilometer',
      'Sentimeter',
      'Milimeter',
      'Mil',
      'Yard',
      'Kaki',
      'Inci',
    ],
    'Berat': [
      'Kilogram',
      'Gram',
      'Miligram',
      'Pound (lbs)',
      'Ounce (oz)',
      'Ton',
    ],
    'Luas': ['Meter Persegi', 'Hektar', 'Are', 'Kilometer Persegi', 'Ekar'],
    'Volume': ['Liter', 'Mililiter', 'Galon (US)', 'Cup', 'Meter Kubik'],
    'Suhu': ['Celsius', 'Fahrenheit', 'Kelvin', 'Reamur'],
    'Kecepatan': ['M/S', 'KM/H', 'Mil/H (mph)', 'Knot'],
    'Waktu': ['Detik', 'Menit', 'Jam', 'Hari', 'Minggu', 'Bulan', 'Tahun'],
  };

  final Map<String, String> _categoryEn = {
    'Panjang': 'Length',
    'Berat': 'Weight',
    'Luas': 'Area',
    'Volume': 'Volume',
    'Suhu': 'Temperature',
    'Kecepatan': 'Speed',
    'Waktu': 'Time',
  };

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final val = double.tryParse(_controller.text);
      if (val != null) {
        setState(() {
          _inputValue = val;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Unit Conversion Logic
  double _convertToBase(double val, String unit, String cat) {
    switch (cat) {
      case 'Panjang':
        switch (unit) {
          case 'Meter':
            return val;
          case 'Kilometer':
            return val * 1000.0;
          case 'Sentimeter':
            return val / 100.0;
          case 'Milimeter':
            return val / 1000.0;
          case 'Mil':
            return val * 1609.344;
          case 'Yard':
            return val * 0.9144;
          case 'Kaki':
            return val * 0.3048;
          case 'Inci':
            return val * 0.0254;
        }
        break;
      case 'Berat':
        switch (unit) {
          case 'Kilogram':
            return val;
          case 'Gram':
            return val / 1000.0;
          case 'Miligram':
            return val / 1000000.0;
          case 'Pound (lbs)':
            return val * 0.45359237;
          case 'Ounce (oz)':
            return val * 0.028349523;
          case 'Ton':
            return val * 1000.0;
        }
        break;
      case 'Luas':
        switch (unit) {
          case 'Meter Persegi':
            return val;
          case 'Hektar':
            return val * 10000.0;
          case 'Are':
            return val * 100.0;
          case 'Kilometer Persegi':
            return val * 1000000.0;
          case 'Ekar':
            return val * 4046.856;
        }
        break;
      case 'Volume':
        switch (unit) {
          case 'Liter':
            return val;
          case 'Mililiter':
            return val / 1000.0;
          case 'Galon (US)':
            return val * 3.78541;
          case 'Cup':
            return val * 0.236588;
          case 'Meter Kubik':
            return val * 1000.0;
        }
        break;
      case 'Suhu':
        // Base is Celsius
        switch (unit) {
          case 'Celsius':
            return val;
          case 'Fahrenheit':
            return (val - 32) * 5 / 9;
          case 'Kelvin':
            return val - 273.15;
          case 'Reamur':
            return val * 5 / 4;
        }
        break;
      case 'Kecepatan':
        // Base is m/s
        switch (unit) {
          case 'M/S':
            return val;
          case 'KM/H':
            return val / 3.6;
          case 'Mil/H (mph)':
            return val * 0.44704;
          case 'Knot':
            return val * 0.514444;
        }
        break;
      case 'Waktu':
        // Base is seconds
        switch (unit) {
          case 'Detik':
            return val;
          case 'Menit':
            return val * 60.0;
          case 'Jam':
            return val * 3600.0;
          case 'Hari':
            return val * 86400.0;
          case 'Minggu':
            return val * 604800.0;
          case 'Bulan':
            return val * 2629743.0; // average
          case 'Tahun':
            return val * 31556926.0; // average
        }
        break;
    }
    return val;
  }

  double _convertFromBase(double val, String unit, String cat) {
    switch (cat) {
      case 'Panjang':
        switch (unit) {
          case 'Meter':
            return val;
          case 'Kilometer':
            return val / 1000.0;
          case 'Sentimeter':
            return val * 100.0;
          case 'Milimeter':
            return val * 1000.0;
          case 'Mil':
            return val / 1609.344;
          case 'Yard':
            return val / 0.9144;
          case 'Kaki':
            return val / 0.3048;
          case 'Inci':
            return val / 0.0254;
        }
        break;
      case 'Berat':
        switch (unit) {
          case 'Kilogram':
            return val;
          case 'Gram':
            return val * 1000.0;
          case 'Miligram':
            return val * 1000000.0;
          case 'Pound (lbs)':
            return val / 0.45359237;
          case 'Ounce (oz)':
            return val / 0.028349523;
          case 'Ton':
            return val / 1000.0;
        }
        break;
      case 'Luas':
        switch (unit) {
          case 'Meter Persegi':
            return val;
          case 'Hektar':
            return val / 10000.0;
          case 'Are':
            return val / 100.0;
          case 'Kilometer Persegi':
            return val / 1000000.0;
          case 'Ekar':
            return val / 4046.856;
        }
        break;
      case 'Volume':
        switch (unit) {
          case 'Liter':
            return val;
          case 'Mililiter':
            return val * 1000.0;
          case 'Galon (US)':
            return val / 3.78541;
          case 'Cup':
            return val / 0.236588;
          case 'Meter Kubik':
            return val / 1000.0;
        }
        break;
      case 'Suhu':
        switch (unit) {
          case 'Celsius':
            return val;
          case 'Fahrenheit':
            return val * 9 / 5 + 32;
          case 'Kelvin':
            return val + 273.15;
          case 'Reamur':
            return val * 4 / 5;
        }
        break;
      case 'Kecepatan':
        switch (unit) {
          case 'M/S':
            return val;
          case 'KM/H':
            return val * 3.6;
          case 'Mil/H (mph)':
            return val / 0.44704;
          case 'Knot':
            return val / 0.514444;
        }
        break;
      case 'Waktu':
        switch (unit) {
          case 'Detik':
            return val;
          case 'Menit':
            return val / 60.0;
          case 'Jam':
            return val / 3600.0;
          case 'Hari':
            return val / 86400.0;
          case 'Minggu':
            return val / 604800.0;
          case 'Bulan':
            return val / 2629743.0;
          case 'Tahun':
            return val / 31556926.0;
        }
        break;
    }
    return val;
  }

  String _formatResult(double val) {
    if (val == 0) return '0';
    if (val.abs() < 0.0001 || val.abs() > 1000000) {
      return val.toStringAsExponential(4);
    }
    if (val == val.toInt()) {
      return val.toInt().toString();
    }
    String s = val.toStringAsFixed(4);
    while (s.endsWith('0')) {
      s = s.substring(0, s.length - 1);
    }
    if (s.endsWith('.')) {
      s = s.substring(0, s.length - 1);
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final categoriesList = _categories.keys.toList();
    final currentUnits = _categories[_selectedCategory]!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Category Selector (horizontal list)
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categoriesList.length,
              itemBuilder: (context, index) {
                final cat = categoriesList[index];
                final isSelected = cat == _selectedCategory;
                final localizedName = provider.translate(
                  cat,
                  _categoryEn[cat] ?? cat,
                );

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(
                      localizedName,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: theme.primaryColor,
                    checkmarkColor: Colors.white,
                    backgroundColor: AppTheme.cardColor(isDark),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: BorderSide(
                        color: isSelected
                            ? theme.primaryColor
                            : AppTheme.borderColor(isDark),
                        width: 1.5,
                      ),
                    ),
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedCategory = cat;
                          _inputUnit = _categories[cat]![0];
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Input Box & Unit Selector
          BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.translate('Masukkan Nilai', 'Enter Value'),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _controller,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.cardAltColor(isDark),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: currentUnits.contains(_inputUnit)
                                ? _inputUnit
                                : currentUnits[0],
                            isExpanded: true,
                            items: currentUnits.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _inputUnit = val;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Output Bento List (Converts to all other units!)
          Text(
            provider.translate('Hasil Konversi', 'Conversion Results'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: currentUnits.length,
            itemBuilder: (context, index) {
              final targetUnit = currentUnits[index];
              if (targetUnit == _inputUnit) return const SizedBox.shrink();

              // Calculate conversion
              final baseVal = _convertToBase(
                _inputValue,
                _inputUnit,
                _selectedCategory,
              );
              final outputVal = _convertFromBase(
                baseVal,
                targetUnit,
                _selectedCategory,
              );
              final formattedOutput = _formatResult(outputVal);

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: BentoCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        targetUnit,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        formattedOutput,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
