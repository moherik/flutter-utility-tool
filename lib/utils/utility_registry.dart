import 'package:flutter/material.dart';
import '../models/utility_item.dart';

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

class UtilityRegistry {
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
        accentColor: Colors.orange,
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
        accentColor: Colors.deepOrange,
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
        accentColor: Colors.amber,
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
        accentColor: Colors.green,
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
        accentColor: Colors.teal,
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
        accentColor: Colors.blue,
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
        accentColor: Colors.red,
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
        accentColor: Colors.blueGrey,
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
        accentColor: Colors.purple,
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
        accentColor: Colors.pink,
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
        accentColor: Colors.lightGreen,
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
        accentColor: Colors.cyan,
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
        accentColor: Colors.indigo,
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
        accentColor: Colors.brown,
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
        accentColor: Colors.deepPurple,
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
        accentColor: Colors.redAccent,
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
        accentColor: Colors.lightBlue,
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
        accentColor: Colors.blueAccent,
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
        accentColor: Colors.tealAccent,
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
        accentColor: Colors.yellowAccent,
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
        accentColor: Colors.lightGreenAccent,
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
        accentColor: Colors.purpleAccent,
        gridWidth: 1,
        gridHeight: 1,
        pageBuilder: (context) => const QrScannerWidget(),
      ),
    ];
  }
}
