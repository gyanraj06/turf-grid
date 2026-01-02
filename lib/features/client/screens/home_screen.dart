import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:turf_booking/core/data/mock_data.dart';
import 'package:turf_booking/core/theme/app_theme.dart';
import 'package:turf_booking/shared/widgets/turf_card.dart';

final turfsProvider = FutureProvider<List<TurfModel>>((ref) async {
  final service = ref.watch(mockDataServiceProvider);
  return service.getTurfs();
});

final currentCityProvider = StateProvider<String>((ref) => 'Bhopal');

class ClientHomeScreen extends ConsumerStatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  ConsumerState<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends ConsumerState<ClientHomeScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Cricket',
    'Football',
    'Badminton',
    'Tennis'
  ];
  final List<String> _availableCities = ['Bhopal', 'Indore'];

  void _showCitySelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select City',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ..._availableCities.map((city) {
                final isSelected = ref.read(currentCityProvider) == city;
                return ListTile(
                  title: Text(city,
                      style: TextStyle(
                          color: isSelected
                              ? AppColors.clientPrimary
                              : Colors.white)),
                  trailing: isSelected
                      ? const Icon(LucideIcons.check,
                          color: AppColors.clientPrimary)
                      : null,
                  onTap: () {
                    ref.read(currentCityProvider.notifier).state = city;
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final turfsAsync = ref.watch(turfsProvider);
    final currentCity = ref.watch(currentCityProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(LucideIcons.mapPin,
                                    color: AppColors.clientPrimary, size: 16),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: _showCitySelector,
                                  child: Row(
                                    children: [
                                      Text(
                                        currentCity,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                                color: AppColors.textSecondary),
                                      ),
                                      const Icon(Icons.arrow_drop_down,
                                          color: AppColors.textSecondary),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Find your turf',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child:
                              const Icon(LucideIcons.bell, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Search Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Search arenas, sports...',
                          border: InputBorder.none,
                          icon: Icon(LucideIcons.search,
                              color: AppColors.textTertiary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Categories
            SliverToBoxAdapter(
              child: SizedBox(
                height: 50,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category == _selectedCategory;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = category),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.clientPrimary
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(top: 20)),
            // Turf List
            turfsAsync.when(
              data: (turfs) {
                final filtered = turfs
                    .where((t) => t.city == currentCity)
                    .where((t) =>
                        _selectedCategory == 'All' ||
                        t.sports.contains(_selectedCategory))
                    .toList();
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return TurfCard(
                          turf: filtered[index],
                          onTap: () => context
                              .push('/client/turf/${filtered[index].id}'),
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => SliverFillRemaining(
                child: Center(child: Text('Error: $err')),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
          ],
        ),
      ),
    );
  }
}
