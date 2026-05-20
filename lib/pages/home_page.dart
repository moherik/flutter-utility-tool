import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/utility_item.dart';
import '../providers/app_provider.dart';
import '../utils/utility_registry.dart';
import '../theme/app_theme.dart';
import '../widgets/bento_card.dart';
import 'utility_detail_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _searchQuery = '';
  String _selectedCategory = 'all';

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final allItems = UtilityRegistry.getItems();
    final filteredItems = allItems.where((item) {
      final matchesCategory = _selectedCategory == 'all' || item.category == _selectedCategory;
      final name = item.nameGetter(provider.languageCode).toLowerCase();
      final desc = item.descGetter(provider.languageCode).toLowerCase();
      final matchesSearch = name.contains(_searchQuery.toLowerCase()) || desc.contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top App Bar Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    color: AppTheme.textSecondary(isDark),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsPage()),
                      );
                    },
                  ),
                  Text(
                    'UTILITYTOOL',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryColor,
                      letterSpacing: 1.5,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline_rounded),
                    color: AppTheme.textSecondary(isDark),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            Divider(height: 1, thickness: 1, color: AppTheme.borderColor(isDark)),

            // Search Bar Area
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor(isDark),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppTheme.borderColor(isDark), width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: AppTheme.textSecondary(isDark), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: TextStyle(fontSize: 14, color: AppTheme.textPrimary(isDark)),
                        decoration: InputDecoration(
                          hintText: provider.translate('Cari alat...', 'Search tools...'),
                          hintStyle: TextStyle(color: AppTheme.textSecondary(isDark)),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 16),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      ),
                  ],
                ),
              ),
            ),

            // Category Tab selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildCategoryChip('all', provider.translate('Semua', 'All'), isDark),
                  _buildCategoryChip('math_calc', provider.translate('Matematika', 'Math/Calc'), isDark),
                  _buildCategoryChip('measure_sensor', provider.translate('Alat Ukur', 'Measure'), isDark),
                  _buildCategoryChip('graphic_text', provider.translate('Grafis & Teks', 'Text/Graphic'), isDark),
                  _buildCategoryChip('device_time', provider.translate('Sistem', 'System'), isDark),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                provider.translate('SYSTEM CONTROL GRID', 'SYSTEM CONTROL GRID'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: AppTheme.textSecondary(isDark),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Grid View
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  return _buildGridItemCard(filteredItems[index], provider, isDark);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String code, String label, bool isDark) {
    final isSelected = _selectedCategory == code;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = code),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : AppTheme.cardColor(isDark),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor(isDark),
            ),
          ),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppTheme.textSecondary(isDark),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridItemCard(UtilityItem item, AppProvider provider, bool isDark) {
    return BentoCard(
      padding: const EdgeInsets.all(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UtilityDetailPage(item: item)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, size: 28, color: AppTheme.textPrimary(isDark)),
          const SizedBox(height: 12),
          Text(
            item.nameGetter(provider.languageCode).toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 0.5,
              color: AppTheme.textPrimary(isDark),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              item.descGetter(provider.languageCode),
              style: TextStyle(
                color: AppTheme.textSecondary(isDark),
                fontSize: 10,
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
