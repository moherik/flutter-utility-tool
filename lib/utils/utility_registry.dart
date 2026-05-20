import 'package:flutter/material.dart';
import '../models/utility_item.dart';
import '../theme/app_theme.dart';

// Import all utility widgets
import '../utilities/calculator.dart';
import '../utilities/unit_converter.dart';
import '../utilities/flashlight.dart';
import '../utilities/bubble_level.dart';
import '../utilities/compass.dart';
import '../utilities/screen_ruler.dart';
import '../utilities/discount_calculator.dart';
import '../utilities/bmi_calculator.dart';
import '../utilities/age_calculator.dart';
import '../utilities/tip_calculator.dart';
import '../utilities/sketchpad.dart';
import '../utilities/password_generator.dart';
import '../utilities/text_converter.dart';
import '../utilities/morse_code.dart';
import '../utilities/qr_generator.dart';
import '../utilities/dice_coin.dart';
import '../utilities/stopwatch_timer.dart';
import '../utilities/world_clock.dart';
import '../utilities/device_info.dart';
import '../utilities/metronome.dart';
import '../utilities/sound_meter.dart';
import '../utilities/qr_scanner.dart';
import '../utilities/random_number.dart';
import '../utilities/percentage_calculator.dart';
import '../utilities/color_converter.dart';
import '../utilities/loan_calculator.dart';
import '../utilities/number_to_words.dart';
import '../utilities/quick_notes.dart';
import '../utilities/speed_test.dart';
import '../utilities/date_calculator.dart';
import '../utilities/compound_interest.dart';
import '../utilities/fuel_calculator.dart';
import '../utilities/gcd_lcm.dart';
import '../utilities/roman_numerals.dart';
import '../utilities/uuid_generator.dart';
import '../utilities/json_formatter.dart';
import '../utilities/text_counter.dart';
import '../utilities/lorem_ipsum.dart';
import '../utilities/pomodoro.dart';

/// Utilities grouped under a single category for the home screen.
class UtilityCategoryGroup {
  const UtilityCategoryGroup({required this.id, required this.items});

  final String id;
  final List<UtilityItem> items;
}

class UtilityRegistry {
  /// Display order of categories on the home screen.
  static const List<String> categoryOrder = [
    'math_calc',
    'measure_sensor',
    'graphic_text',
    'device_time',
  ];

  static List<UtilityItem> getItems() {
    return [
      // 1. Calculator
      UtilityItem(
        id: 'calculator',
        nameGetter: (lang) => lang == 'id' ? 'Kalkulator' : 'Calculator',
        descGetter: (lang) => lang == 'id'
            ? 'Hitung matematika dasar dan ilmiah luring'
            : 'Perform basic and scientific math offline',
        icon: Icons.calculate_rounded,
        category: 'math_calc',
        accentColor: AppTheme.primaryColor,
        gridWidth: 2,
        gridHeight: 1,
        pageBuilder: (context) => const CalculatorWidget(),
      ),
      // 2. Unit Converter
      UtilityItem(
        id: 'unit_converter',
        nameGetter: (lang) =>
            lang == 'id' ? 'Konverter Satuan' : 'Unit Converter',
        descGetter: (lang) => lang == 'id'
            ? 'Konversi satuan panjang, berat, suhu, dll'
            : 'Convert length, weight, temperature, etc.',
        icon: Icons.swap_horiz_rounded,
        category: 'math_calc',
        accentColor: AppTheme.tertiaryColor,
        gridWidth: 1,
        gridHeight: 1,
        pageBuilder: (context) => const UnitConverterWidget(),
      ),
      // 3. Flashlight
      UtilityItem(
        id: 'flashlight',
        nameGetter: (lang) => lang == 'id' ? 'Senter' : 'Flashlight',
        descGetter: (lang) => lang == 'id'
            ? 'Senter fisik dengan mode SOS dan layar warna'
            : 'Physical flashlight with SOS mode & color screen',
        icon: Icons.flashlight_on_rounded,
        category: 'device_time',
        accentColor: AppTheme.primaryColor,
        gridWidth: 1,
        gridHeight: 1,
        pageBuilder: (context) => const FlashlightWidget(),
      ),
      // 4. Bubble Level
      UtilityItem(
        id: 'bubble_level',
        nameGetter: (lang) => lang == 'id' ? 'Waterpas' : 'Bubble Level',
        descGetter: (lang) => lang == 'id'
            ? 'Ukur kemiringan bidang secara presisi'
            : 'Measure surface levelness and tilt precisely',
        icon: Icons.compass_calibration_rounded,
        category: 'measure_sensor',
        accentColor: AppTheme.tertiaryColor,
        gridWidth: 1,
        gridHeight: 1,
        pageBuilder: (context) => const BubbleLevelWidget(),
      ),
      // 5. Compass
      UtilityItem(
        id: 'compass',
        nameGetter: (lang) => lang == 'id' ? 'Kompas' : 'Compass',
        descGetter: (lang) => lang == 'id'
            ? 'Navigasi arah mata angin luring'
            : 'Offline magnetic navigation compass',
        icon: Icons.explore_rounded,
        category: 'measure_sensor',
        accentColor: AppTheme.tertiaryColor,
        gridWidth: 1,
        gridHeight: 1,
        pageBuilder: (context) => const CompassWidget(),
      ),
      // 6. Screen Ruler
      UtilityItem(
        id: 'screen_ruler',
        nameGetter: (lang) => lang == 'id' ? 'Penggaris Layar' : 'Screen Ruler',
        descGetter: (lang) => lang == 'id'
            ? 'Ukur benda kecil langsung di layar HP'
            : 'Measure small items directly on your screen',
        icon: Icons.straighten_rounded,
        category: 'measure_sensor',
        accentColor: AppTheme.tertiaryColor,
        gridWidth: 1,
        gridHeight: 1,
        pageBuilder: (context) => const ScreenRulerWidget(),
      ),
      // 7. Discount Calculator
      UtilityItem(
        id: 'discount_calculator',
        nameGetter: (lang) =>
            lang == 'id' ? 'Kalkulator Diskon' : 'Discount Calculator',
        descGetter: (lang) => lang == 'id'
            ? 'Hitung harga diskon dan pajak belanja'
            : 'Calculate shopping discounts and taxes',
        icon: Icons.local_offer_rounded,
        category: 'math_calc',
        accentColor: AppTheme.primaryColor,
        gridWidth: 1,
        gridHeight: 1,
        pageBuilder: (context) => const DiscountCalculatorWidget(),
      ),
      // 8. BMI Calculator
      UtilityItem(
        id: 'bmi_calculator',
        nameGetter: (lang) =>
            lang == 'id' ? 'Kalkulator BMI' : 'BMI Calculator',
        descGetter: (lang) => lang == 'id'
            ? 'Cek indeks massa tubuh ideal Anda'
            : 'Check your ideal body mass index score',
        icon: Icons.monitor_weight_rounded,
        category: 'math_calc',
        accentColor: AppTheme.neutralColor,
        gridWidth: 1,
        gridHeight: 1,
        pageBuilder: (context) => const BmiCalculatorWidget(),
      ),
      // 9. Age Calculator
      UtilityItem(
        id: 'age_calculator',
        nameGetter: (lang) =>
            lang == 'id' ? 'Kalkulator Umur' : 'Age Calculator',
        descGetter: (lang) => lang == 'id'
            ? 'Hitung umur detail dan ultah berikutnya'
            : 'Calculate detailed age & next birthday info',
        icon: Icons.cake_rounded,
        category: 'math_calc',
        accentColor: AppTheme.primaryColor,
        gridWidth: 1,
        gridHeight: 1,
        pageBuilder: (context) => const AgeCalculatorWidget(),
      ),
      // 10. Tip Calculator
      UtilityItem(
        id: 'tip_calculator',
        nameGetter: (lang) =>
            lang == 'id' ? 'Kalkulator Tip' : 'Tip Calculator',
        descGetter: (lang) => lang == 'id'
            ? 'Bagi tagihan makan dan hitung tip'
            : 'Split restaurant bills and calculate tips',
        icon: Icons.monetization_on_rounded,
        category: 'math_calc',
        accentColor: AppTheme.primaryColor,
        gridWidth: 1,
        gridHeight: 1,
        pageBuilder: (context) => const TipCalculatorWidget(),
      ),
      // 11. Sketchpad
      UtilityItem(
        id: 'sketchpad',
        nameGetter: (lang) => lang == 'id' ? 'Papan Sketsa' : 'Sketchpad',
        descGetter: (lang) => lang == 'id'
            ? 'Menggambar coretan tangan bebas luring'
            : 'Draw freehand sketches and notes offline',
        icon: Icons.gesture_rounded,
        category: 'graphic_text',
        accentColor: AppTheme.tertiaryColor,
        gridWidth: 2,
        gridHeight: 1,
        pageBuilder: (context) => const SketchpadWidget(),
      ),
      // 12. Password Generator
      UtilityItem(
        id: 'password_generator',
        nameGetter: (lang) =>
            lang == 'id' ? 'Pembuat Sandi' : 'Password Generator',
        descGetter: (lang) => lang == 'id'
            ? 'Buat kata sandi acak dan aman luring'
            : 'Create strong random passwords offline',
        icon: Icons.password_rounded,
        category: 'graphic_text',
        accentColor: AppTheme.tertiaryColor,
        gridWidth: 1,
        gridHeight: 1,
        pageBuilder: (context) => const PasswordGeneratorWidget(),
      ),
      // 13. Text Converter
      UtilityItem(
        id: 'text_converter',
        nameGetter: (lang) =>
            lang == 'id' ? 'Konverter Teks' : 'Text Converter',
        descGetter: (lang) => lang == 'id'
            ? 'Koreksi case, encoding base64, hash dll'
            : 'Change case, encode/decode, and generate hashes',
        icon: Icons.text_fields_rounded,
        category: 'graphic_text',
        accentColor: AppTheme.secondaryColor,
        gridWidth: 1,
        gridHeight: 1,
        pageBuilder: (context) => const TextConverterWidget(),
      ),
      // 14. Morse Code
      UtilityItem(
        id: 'morse_code',
        nameGetter: (lang) => lang == 'id' ? 'Kode Morse' : 'Morse Code',
        descGetter: (lang) => lang == 'id'
            ? 'Terjemahkan teks ke kode morse dan flash'
            : 'Translate plain text to morse code & back',
        icon: Icons.graphic_eq_rounded,
        category: 'graphic_text',
        accentColor: AppTheme.neutralColor,
        gridWidth: 1,
        gridHeight: 1,
        pageBuilder: (context) => const MorseCodeWidget(),
      ),
      // 15. QR Generator
      UtilityItem(
        id: 'qr_generator',
        nameGetter: (lang) => lang == 'id' ? 'Pembuat QR' : 'QR Generator',
        descGetter: (lang) => lang == 'id'
            ? 'Buat kode QR dari teks atau link luring'
            : 'Generate QR Codes from text/links offline',
        icon: Icons.qr_code_rounded,
        category: 'graphic_text',
        accentColor: AppTheme.primaryColor,
        gridWidth: 1,
        gridHeight: 1,
        pageBuilder: (context) => const QrGeneratorWidget(),
      ),
      // 16. Dice & Coin
      UtilityItem(
        id: 'dice_coin',
        nameGetter: (lang) => lang == 'id' ? 'Dadu & Koin' : 'Dice & Coin',
        descGetter: (lang) => lang == 'id'
            ? 'Kocok dadu acak atau lempar koin'
            : 'Roll multiple random dice or flip a coin',
        icon: Icons.casino_rounded,
        category: 'device_time',
        accentColor: AppTheme.primaryColor,
        gridWidth: 1,
        gridHeight: 1,
        pageBuilder: (context) => const DiceCoinWidget(),
      ),
      // 17. Stopwatch & Timer
      UtilityItem(
        id: 'stopwatch_timer',
        nameGetter: (lang) =>
            lang == 'id' ? 'Stopwatch & Timer' : 'Stopwatch & Timer',
        descGetter: (lang) => lang == 'id'
            ? 'Penghitung waktu lap dan hitung mundur'
            : 'Lap-timer and countdown alarm clock',
        icon: Icons.timer_rounded,
        category: 'device_time',
        accentColor: AppTheme.tertiaryColor,
        gridWidth: 2,
        gridHeight: 1,
        pageBuilder: (context) => const StopwatchTimerWidget(),
      ),
      // 18. World Clock
      UtilityItem(
        id: 'world_clock',
        nameGetter: (lang) => lang == 'id' ? 'Jam Dunia' : 'World Clock',
        descGetter: (lang) => lang == 'id'
            ? 'Pantau waktu berbagai zona kota dunia'
            : 'Monitor time across global zones',
        icon: Icons.public_rounded,
        category: 'device_time',
        accentColor: AppTheme.tertiaryColor,
        gridWidth: 1,
        gridHeight: 1,
        pageBuilder: (context) => const WorldClockWidget(),
      ),
      // 19. Device Info
      UtilityItem(
        id: 'device_info',
        nameGetter: (lang) =>
            lang == 'id' ? 'Informasi Perangkat' : 'Device Specifications',
        descGetter: (lang) => lang == 'id'
            ? 'Spesifikasi HP, SDK, hardware dan baterai'
            : 'Detailed phone hardware & battery status',
        icon: Icons.info_rounded,
        category: 'device_time',
        accentColor: AppTheme.tertiaryColor,
        gridWidth: 1,
        gridHeight: 1,
        pageBuilder: (context) => const DeviceInfoWidget(),
      ),
      // 20. Metronome
      UtilityItem(
        id: 'metronome',
        nameGetter: (lang) => lang == 'id' ? 'Metronom' : 'Metronome',
        descGetter: (lang) => lang == 'id'
            ? 'Alat bantu tempo ketukan bermusik'
            : 'Musical tempo click track assistance',
        icon: Icons.slow_motion_video_rounded,
        category: 'measure_sensor',
        accentColor: AppTheme.neutralColor,
        gridWidth: 1,
        gridHeight: 1,
        pageBuilder: (context) => const MetronomeWidget(),
      ),
      // 21. Sound Meter
      UtilityItem(
        id: 'sound_meter',
        nameGetter: (lang) =>
            lang == 'id' ? 'Pengukur Kebisingan' : 'Sound Meter',
        descGetter: (lang) => lang == 'id'
            ? 'Ukur tingkat desibel suara sekitar'
            : 'Measure environmental noise in decibels',
        icon: Icons.volume_up_rounded,
        category: 'measure_sensor',
        accentColor: AppTheme.tertiaryColor,
        gridWidth: 1,
        gridHeight: 1,
        pageBuilder: (context) => const SoundMeterWidget(),
      ),
      // 22. QR Scanner
      UtilityItem(
        id: 'qr_scanner',
        nameGetter: (lang) =>
            lang == 'id' ? 'Scan QR / Barcode' : 'Scan QR / Barcode',
        descGetter: (lang) => lang == 'id'
            ? 'Pindai kode QR atau barcode dengan kamera'
            : 'Scan QR Codes or barcodes using camera',
        icon: Icons.qr_code_scanner_rounded,
        category: 'graphic_text',
        accentColor: AppTheme.primaryColor,
        gridWidth: 1,
        gridHeight: 1,
        pageBuilder: (context) => const QrScannerWidget(),
      ),
      // 23. Random Number
      UtilityItem(
        id: 'random_number',
        nameGetter: (lang) =>
            lang == 'id' ? 'Angka Acak' : 'Random Number',
        descGetter: (lang) => lang == 'id'
            ? 'Buat angka acak dalam rentang yang Anda tentukan'
            : 'Generate random numbers within a custom range',
        icon: Icons.shuffle_rounded,
        category: 'math_calc',
        accentColor: AppTheme.accentViolet,
        pageBuilder: (context) => const RandomNumberWidget(),
      ),
      // 24. Percentage Calculator
      UtilityItem(
        id: 'percentage_calculator',
        nameGetter: (lang) =>
            lang == 'id' ? 'Kalkulator Persen' : 'Percentage Calculator',
        descGetter: (lang) => lang == 'id'
            ? 'Hitung persentase, proporsi, dan kenaikan nilai'
            : 'Calculate percentages, ratios, and value increases',
        icon: Icons.percent_rounded,
        category: 'math_calc',
        accentColor: AppTheme.primaryColor,
        pageBuilder: (context) => const PercentageCalculatorWidget(),
      ),
      // 25. Loan Calculator
      UtilityItem(
        id: 'loan_calculator',
        nameGetter: (lang) =>
            lang == 'id' ? 'Kalkulator Cicilan' : 'Loan Calculator',
        descGetter: (lang) => lang == 'id'
            ? 'Perkirakan cicilan bulanan pinjaman dan total bunga'
            : 'Estimate monthly loan payments and total interest',
        icon: Icons.account_balance_rounded,
        category: 'math_calc',
        accentColor: AppTheme.primaryColor,
        pageBuilder: (context) => const LoanCalculatorWidget(),
      ),
      // 26. Number to Words
      UtilityItem(
        id: 'number_to_words',
        nameGetter: (lang) =>
            lang == 'id' ? 'Angka ke Kata' : 'Number to Words',
        descGetter: (lang) => lang == 'id'
            ? 'Ubah angka menjadi terbilang bahasa Indonesia atau Inggris'
            : 'Spell numbers out in Indonesian or English',
        icon: Icons.spellcheck_rounded,
        category: 'graphic_text',
        accentColor: AppTheme.accentViolet,
        pageBuilder: (context) => const NumberToWordsWidget(),
      ),
      // 27. Color Converter
      UtilityItem(
        id: 'color_converter',
        nameGetter: (lang) =>
            lang == 'id' ? 'Konverter Warna' : 'Color Converter',
        descGetter: (lang) => lang == 'id'
            ? 'Konversi kode warna HEX ke RGB dan format Flutter'
            : 'Convert HEX color codes to RGB and Flutter format',
        icon: Icons.palette_rounded,
        category: 'graphic_text',
        accentColor: AppTheme.accentViolet,
        pageBuilder: (context) => const ColorConverterWidget(),
      ),
      // 28. Quick Notes
      UtilityItem(
        id: 'quick_notes',
        nameGetter: (lang) =>
            lang == 'id' ? 'Catatan Cepat' : 'Quick Notes',
        descGetter: (lang) => lang == 'id'
            ? 'Tulis dan simpan catatan singkat secara lokal'
            : 'Write and save short notes locally on your device',
        icon: Icons.note_alt_rounded,
        category: 'graphic_text',
        accentColor: AppTheme.accentAmber,
        pageBuilder: (context) => const QuickNotesWidget(),
      ),
      // 29. Reaction Speed Test
      UtilityItem(
        id: 'speed_test',
        nameGetter: (lang) =>
            lang == 'id' ? 'Tes Refleks' : 'Reaction Speed Test',
        descGetter: (lang) => lang == 'id'
            ? 'Uji kecepatan reaksi — ketuk saat layar berubah hijau'
            : 'Test your reaction speed — tap when the screen turns green',
        icon: Icons.speed_rounded,
        category: 'device_time',
        accentColor: AppTheme.accentBlue,
        pageBuilder: (context) => const SpeedTestWidget(),
      ),
      // 30. Date Calculator
      UtilityItem(
        id: 'date_calculator',
        nameGetter: (lang) =>
            lang == 'id' ? 'Kalkulator Tanggal' : 'Date Calculator',
        descGetter: (lang) => lang == 'id'
            ? 'Hitung selisih hari dan tambah/kurangi tanggal'
            : 'Calculate day differences and add or subtract dates',
        icon: Icons.date_range_rounded,
        category: 'math_calc',
        accentColor: AppTheme.primaryColor,
        pageBuilder: (context) => const DateCalculatorWidget(),
      ),
      // 31. Compound Interest
      UtilityItem(
        id: 'compound_interest',
        nameGetter: (lang) =>
            lang == 'id' ? 'Bunga Majemuk' : 'Compound Interest',
        descGetter: (lang) => lang == 'id'
            ? 'Hitung pertumbuhan investasi dengan bunga majemuk'
            : 'Calculate investment growth with compound interest',
        icon: Icons.trending_up_rounded,
        category: 'math_calc',
        accentColor: AppTheme.primaryColor,
        pageBuilder: (context) => const CompoundInterestWidget(),
      ),
      // 32. Fuel Calculator
      UtilityItem(
        id: 'fuel_calculator',
        nameGetter: (lang) =>
            lang == 'id' ? 'Kalkulator BBM' : 'Fuel Cost Calculator',
        descGetter: (lang) => lang == 'id'
            ? 'Estimasi liter dan biaya bahan bakar per perjalanan'
            : 'Estimate fuel liters and trip cost for your journey',
        icon: Icons.local_gas_station_rounded,
        category: 'math_calc',
        accentColor: AppTheme.tertiaryColor,
        pageBuilder: (context) => const FuelCalculatorWidget(),
      ),
      // 33. GCD & LCM
      UtilityItem(
        id: 'gcd_lcm',
        nameGetter: (lang) => lang == 'id' ? 'FPB & KPK' : 'GCD & LCM',
        descGetter: (lang) => lang == 'id'
            ? 'Hitung faktor persekutuan terbesar dan kelipatan persekutuan terkecil'
            : 'Find greatest common divisor and least common multiple',
        icon: Icons.functions_rounded,
        category: 'math_calc',
        accentColor: AppTheme.primaryColor,
        pageBuilder: (context) => const GcdLcmWidget(),
      ),
      // 34. Roman Numerals
      UtilityItem(
        id: 'roman_numerals',
        nameGetter: (lang) =>
            lang == 'id' ? 'Angka Romawi' : 'Roman Numerals',
        descGetter: (lang) => lang == 'id'
            ? 'Konversi angka Arab dan notasi Romawi (I–MMMCMXCIX)'
            : 'Convert between Arabic numbers and Roman numerals',
        icon: Icons.looks_one_rounded,
        category: 'graphic_text',
        accentColor: AppTheme.accentViolet,
        pageBuilder: (context) => const RomanNumeralsWidget(),
      ),
      // 35. UUID Generator
      UtilityItem(
        id: 'uuid_generator',
        nameGetter: (lang) =>
            lang == 'id' ? 'Pembuat UUID' : 'UUID Generator',
        descGetter: (lang) => lang == 'id'
            ? 'Buat UUID v4 acak untuk ID unik'
            : 'Generate random UUID v4 identifiers',
        icon: Icons.fingerprint_rounded,
        category: 'graphic_text',
        accentColor: AppTheme.accentViolet,
        pageBuilder: (context) => const UuidGeneratorWidget(),
      ),
      // 36. JSON Formatter
      UtilityItem(
        id: 'json_formatter',
        nameGetter: (lang) =>
            lang == 'id' ? 'Format JSON' : 'JSON Formatter',
        descGetter: (lang) => lang == 'id'
            ? 'Rapikan atau minify teks JSON dengan validasi'
            : 'Pretty-print or minify JSON with validation',
        icon: Icons.data_object_rounded,
        category: 'graphic_text',
        accentColor: AppTheme.accentViolet,
        pageBuilder: (context) => const JsonFormatterWidget(),
      ),
      // 37. Text Counter
      UtilityItem(
        id: 'text_counter',
        nameGetter: (lang) =>
            lang == 'id' ? 'Penghitung Teks' : 'Text Counter',
        descGetter: (lang) => lang == 'id'
            ? 'Hitung karakter, kata, baris, dan paragraf secara langsung'
            : 'Count characters, words, lines, and paragraphs live',
        icon: Icons.format_list_numbered_rounded,
        category: 'graphic_text',
        accentColor: AppTheme.accentViolet,
        pageBuilder: (context) => const TextCounterWidget(),
      ),
      // 38. Lorem Ipsum
      UtilityItem(
        id: 'lorem_ipsum',
        nameGetter: (lang) => lang == 'id' ? 'Lorem Ipsum' : 'Lorem Ipsum',
        descGetter: (lang) => lang == 'id'
            ? 'Buat teks placeholder untuk desain dan mockup'
            : 'Generate placeholder text for design and mockups',
        icon: Icons.article_outlined,
        category: 'graphic_text',
        accentColor: AppTheme.accentAmber,
        pageBuilder: (context) => const LoremIpsumWidget(),
      ),
      // 39. Pomodoro
      UtilityItem(
        id: 'pomodoro',
        nameGetter: (lang) => lang == 'id' ? 'Pomodoro' : 'Pomodoro',
        descGetter: (lang) => lang == 'id'
            ? 'Teknik Pomodoro dengan durasi kustom, preset, dan siklus otomatis'
            : 'Pomodoro technique with custom durations, presets, and auto cycles',
        icon: Icons.hourglass_bottom_rounded,
        category: 'device_time',
        accentColor: AppTheme.accentBlue,
        pageBuilder: (context) => const PomodoroWidget(),
      ),
    ];
  }

  /// Returns utilities grouped by category in [categoryOrder].
  static List<UtilityCategoryGroup> getGroupedItems() {
    final byCategory = <String, List<UtilityItem>>{};
    for (final item in getItems()) {
      byCategory.putIfAbsent(item.category, () => []).add(item);
    }

    return [
      for (final id in categoryOrder)
        if (byCategory.containsKey(id))
          UtilityCategoryGroup(id: id, items: byCategory[id]!),
      for (final entry in byCategory.entries)
        if (!categoryOrder.contains(entry.key))
          UtilityCategoryGroup(id: entry.key, items: entry.value),
    ];
  }
}
