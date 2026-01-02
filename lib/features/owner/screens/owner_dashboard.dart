import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:turf_booking/core/theme/app_theme.dart';

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vendor Dashboard"),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(LucideIcons.user, color: AppColors.ownerPrimary))
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HUD
            const Row(
              children: [
                Expanded(
                    child: _StatCard(
                        title: "Today's Bookings",
                        value: "8",
                        color: AppColors.ownerPrimary)),
                SizedBox(width: 16),
                Expanded(
                    child: _StatCard(
                        title: "Revenue",
                        value: "₹12,400",
                        color: Colors.green)),
              ],
            ),
            const SizedBox(height: 24),

            // Inventory / Schedule
            const Text("Schedule",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 12),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 5,
                separatorBuilder: (_, __) =>
                    const Divider(color: Colors.white10),
                itemBuilder: (context, index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("1${index + 6}:00 - 1${index + 7}:00",
                          style: const TextStyle(color: Colors.white)),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: index % 2 == 0
                                    ? Colors.red.withValues(alpha: 0.2)
                                    : Colors.green.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4)),
                            child: Text(index % 2 == 0 ? "Booked" : "Available",
                                style: TextStyle(
                                    color: index % 2 == 0
                                        ? Colors.red
                                        : Colors.green,
                                    fontSize: 12)),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                              icon: const Icon(LucideIcons.moreVertical,
                                  size: 16),
                              onPressed: () {}),
                        ],
                      )
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 24),
            // Quick Actions
            const Text("My Turf",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: "Price per Hour (₹)",
                suffixText: "Update",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard(
      {required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
