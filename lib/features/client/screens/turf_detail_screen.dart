import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:turf_booking/core/data/mock_data.dart';
import 'package:turf_booking/core/theme/app_theme.dart';

final turfDetailsProvider =
    FutureProvider.family<TurfModel?, String>((ref, id) async {
  final service = ref.watch(mockDataServiceProvider);
  return service.getTurfById(id);
});

final bookedSlotsProvider =
    FutureProvider.family<List<String>, ({String turfId, DateTime date})>(
        (ref, arg) async {
  final service = ref.watch(mockDataServiceProvider);
  return service.getBookedSlots(arg.turfId, arg.date);
});

class TurfDetailScreen extends ConsumerStatefulWidget {
  final String turfId;

  const TurfDetailScreen({super.key, required this.turfId});

  @override
  ConsumerState<TurfDetailScreen> createState() => _TurfDetailScreenState();
}

class _TurfDetailScreenState extends ConsumerState<TurfDetailScreen> {
  DateTime _selectedDate = DateTime.now();
  final List<String> _selectedSlots = [];

  // Generate next 7 days
  List<DateTime> get _nextDays =>
      List.generate(7, (index) => DateTime.now().add(Duration(days: index)));

  // Generate time slots 06:00 to 23:00
  List<String> get _timeSlots => List.generate(
      18, (index) => '${(index + 6).toString().padLeft(2, '0')}:00');

  void _toggleSlot(String slot, bool isBooked) {
    if (isBooked) return;
    setState(() {
      if (_selectedSlots.contains(slot)) {
        _selectedSlots.remove(slot);
      } else {
        _selectedSlots.add(slot);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final turfAsync = ref.watch(turfDetailsProvider(widget.turfId));
    final bookedSlotsAsync = ref.watch(
        bookedSlotsProvider((turfId: widget.turfId, date: _selectedDate)));

    return Scaffold(
      body: turfAsync.when(
        data: (turf) {
          if (turf == null) return const Center(child: Text('Turf not found'));
          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 250,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Hero(
                        tag: 'turf-img-${turf.id}',
                        child: Image.network(
                          turf.imageUrl,
                          fit: BoxFit.cover,
                          color: Colors.black.withValues(alpha: 0.3),
                          colorBlendMode: BlendMode.darken,
                        ),
                      ),
                    ),
                    leading: IconButton(
                      icon: const Icon(LucideIcons.arrowLeft,
                          color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(turf.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(LucideIcons.mapPin,
                                  size: 16, color: AppColors.clientPrimary),
                              const SizedBox(width: 8),
                              Text(turf.location,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            children: turf.amenities
                                .map((a) => Chip(
                                      label: Text(a),
                                      backgroundColor: AppColors.surface,
                                      labelStyle: const TextStyle(
                                          fontSize: 12, color: Colors.white),
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 24),
                          const Text("Select Date",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 70,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _nextDays.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final date = _nextDays[index];
                                final isSelected =
                                    date.day == _selectedDate.day &&
                                        date.month == _selectedDate.month;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedDate = date;
                                      _selectedSlots.clear();
                                    });
                                  },
                                  child: Container(
                                    width: 60,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.clientPrimary
                                          : AppColors.surface,
                                      borderRadius: BorderRadius.circular(16),
                                      border: isSelected
                                          ? null
                                          : Border.all(color: Colors.white10),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(DateFormat('E').format(date),
                                            style: TextStyle(
                                                color: isSelected
                                                    ? Colors.black
                                                    : Colors.grey,
                                                fontSize: 12)),
                                        const SizedBox(height: 4),
                                        Text(date.day.toString(),
                                            style: TextStyle(
                                                color: isSelected
                                                    ? Colors.black
                                                    : Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text("Available Slots",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          bookedSlotsAsync.when(
                            data: (booked) => GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 2.5,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: _timeSlots.length,
                              itemBuilder: (context, index) {
                                final slot = _timeSlots[index];
                                final isBooked = booked.contains(slot);
                                final isSelected =
                                    _selectedSlots.contains(slot);

                                return GestureDetector(
                                  onTap: () => _toggleSlot(slot, isBooked),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isBooked
                                          ? AppColors.surface
                                              .withValues(alpha: 0.5)
                                          : isSelected
                                              ? AppColors.clientPrimary
                                              : AppColors.surface,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: isBooked
                                              ? Colors.transparent
                                              : isSelected
                                                  ? AppColors.clientPrimary
                                                  : Colors.white24),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      slot,
                                      style: TextStyle(
                                        color: isBooked
                                            ? Colors.white10
                                            : isSelected
                                                ? Colors.black
                                                : Colors.white,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        decoration: isBooked
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            loading: () => const Center(
                                child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: CircularProgressIndicator())),
                            error: (e, s) => Text("Error loading slots: $e"),
                          ),
                          const SizedBox(height: 100), // Spacing for bottom bar
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    border: Border(top: BorderSide(color: Colors.white10)),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("₹${_selectedSlots.length * turf.pricePerHour}",
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          Text("${_selectedSlots.length} slots selected",
                              style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _selectedSlots.isEmpty
                            ? null
                            : () {
                                // Pass details to checkout
                                context.push(
                                  '/client/checkout',
                                  extra: {
                                    'turf': turf,
                                    'date': _selectedDate,
                                    'slots': _selectedSlots,
                                  },
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(150, 50),
                          backgroundColor: _selectedSlots.isEmpty
                              ? Colors.grey[800]
                              : AppColors.clientPrimary,
                        ),
                        child: const Text("Book Now"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
