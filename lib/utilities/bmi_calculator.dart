import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/bento_card.dart';

class BmiCalculatorWidget extends StatefulWidget {
  const BmiCalculatorWidget({Key? key}) : super(key: key);

  @override
  State<BmiCalculatorWidget> createState() => _BmiCalculatorWidgetState();
}

class _BmiCalculatorWidgetState extends State<BmiCalculatorWidget> {
  bool _isMale = true;
  double _height = 170.0; // cm
  double _weight = 65.0; // kg
  int _age = 25;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate BMI
    // BMI = weight (kg) / height^2 (m^2)
    final heightInMeters = _height / 100.0;
    final bmi = _weight / (heightInMeters * heightInMeters);

    String classification = '';
    Color classificationColor = Colors.green;
    String description = '';

    if (bmi < 18.5) {
      classification = provider.translate(
        'Kekurangan Berat Badan',
        'Underweight',
      );
      classificationColor = Colors.blue;
      description = provider.translate(
        'Anda berada di kategori kurang berat badan. Cobalah konsumsi lebih banyak kalori sehat.',
        'You are in the underweight category. Consider consuming more nutrient-rich food.',
      );
    } else if (bmi >= 18.5 && bmi < 24.9) {
      classification = provider.translate('Normal (Ideal)', 'Normal (Healthy)');
      classificationColor = Colors.green;
      description = provider.translate(
        'Berat badan Anda ideal. Pertahankan pola makan sehat dan olahraga teratur!',
        'You have a healthy body weight. Maintain your lifestyle, diet, and regular exercise!',
      );
    } else if (bmi >= 24.9 && bmi < 29.9) {
      classification = provider.translate(
        'Kelebihan Berat Badan',
        'Overweight',
      );
      classificationColor = Colors.orange;
      description = provider.translate(
        'Anda berada di kategori kelebihan berat badan. Disarankan untuk berolahraga lebih aktif.',
        'You are in the overweight category. Regular aerobic exercise and diet monitoring are recommended.',
      );
    } else {
      classification = provider.translate('Obesitas', 'Obese');
      classificationColor = Colors.red;
      description = provider.translate(
        'Anda berada dalam kategori obesitas. Silakan berkonsultasi dengan ahli gizi/dokter.',
        'You are in the obese category. It is recommended to seek medical or dietary advice.',
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gender Selector Card
          Row(
            children: [
              Expanded(
                child: BentoCard(
                  color: _isMale ? theme.primaryColor.withOpacity(0.1) : null,
                  borderColor: _isMale ? theme.primaryColor : null,
                  onTap: () => setState(() => _isMale = true),
                  child: Column(
                    children: [
                      Icon(
                        Icons.male_rounded,
                        size: 40,
                        color: _isMale ? theme.primaryColor : Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        provider.translate('Pria', 'Male'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: BentoCard(
                  color: !_isMale ? theme.primaryColor.withOpacity(0.1) : null,
                  borderColor: !_isMale ? theme.primaryColor : null,
                  onTap: () => setState(() => _isMale = false),
                  child: Column(
                    children: [
                      Icon(
                        Icons.female_rounded,
                        size: 40,
                        color: !_isMale ? theme.primaryColor : Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        provider.translate('Wanita', 'Female'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sliders inside BentoCard
          BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      provider.translate('Tinggi Badan', 'Height'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${_height.round()} cm",
                      style: TextStyle(
                        fontSize: 18,
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _height,
                  min: 100,
                  max: 220,
                  activeColor: theme.primaryColor,
                  onChanged: (val) => setState(() => _height = val),
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      provider.translate('Berat Badan', 'Weight'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${_weight.round()} kg",
                      style: TextStyle(
                        fontSize: 18,
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _weight,
                  min: 30,
                  max: 180,
                  activeColor: theme.primaryColor,
                  onChanged: (val) => setState(() => _weight = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Age Control
          BentoCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  provider.translate('Umur', 'Age'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline_rounded),
                      onPressed: () {
                        if (_age > 1) setState(() => _age--);
                      },
                    ),
                    Text(
                      "$_age",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      onPressed: () {
                        if (_age < 120) setState(() => _age++);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Results Card
          BentoCard(
            color: classificationColor.withOpacity(0.08),
            borderColor: classificationColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    provider.translate(
                      'Indeks Massa Tubuh Anda',
                      'Your BMI Score',
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[300] : Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    bmi.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: classificationColor,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    classification.toUpperCase(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: classificationColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
