import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:turf_booking/core/data/mock_data.dart';
import 'package:turf_booking/core/theme/app_theme.dart';

class ClientCheckoutScreen extends ConsumerStatefulWidget {
  final TurfModel turf;
  final DateTime date;
  final List<String> slots;

  const ClientCheckoutScreen({
    super.key,
    required this.turf,
    required this.date,
    required this.slots,
  });

  @override
  ConsumerState<ClientCheckoutScreen> createState() =>
      _ClientCheckoutScreenState();
}

class _ClientCheckoutScreenState extends ConsumerState<ClientCheckoutScreen> {
  bool _splitPayment = false;
  bool _payWithPoints = false;
  bool _isProcessing = false;

  double get _totalAmount => widget.slots.length * widget.turf.pricePerHour;
  double get _finalAmount => _payWithPoints
      ? (_totalAmount - 50 < 0 ? 0 : _totalAmount - 50)
      : _totalAmount; // Assuming 50rs discount for points

  void _processBooking() async {
    setState(() => _isProcessing = true);

    // Simulate API call
    final service = ref.read(mockDataServiceProvider);
    await service.createBooking(BookingModel(
      id: 'mock_booking_${DateTime.now().millisecondsSinceEpoch}',
      turfName: widget.turf.name,
      date: widget.date,
      timeSlot: widget.slots.join(', '),
      price: _finalAmount,
      status: 'Confirmed',
    ));

    setState(() => _isProcessing = false);

    if (mounted) {
      // Success Dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.checkCircle,
                  color: AppColors.clientPrimary, size: 60),
              const SizedBox(height: 20),
              const Text("Booking Confirmed!",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("Your slot has been successfully booked.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  context.go('/client/home');
                },
                child: const Text("Back to Home"),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(widget.turf.imageUrl,
                            height: 60, width: 60, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.turf.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white)),
                            const SizedBox(height: 4),
                            Text(DateFormat('EEE, d MMM').format(widget.date),
                                style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Slots", style: TextStyle(color: Colors.grey)),
                      Text(widget.slots.join(", "),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Price per hour",
                          style: TextStyle(color: Colors.grey)),
                      Text("₹${widget.turf.pricePerHour.toInt()}",
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Amount",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Text("₹${_totalAmount.toInt()}",
                          style: const TextStyle(
                              color: AppColors.clientPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Split Payment
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                value: _splitPayment,
                onChanged: (v) => setState(() => _splitPayment = v),
                title: const Text("Split Payment?",
                    style: TextStyle(color: Colors.white)),
                subtitle: const Text("Share a link to split the bill",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                activeTrackColor: AppColors.clientPrimary,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            if (_splitPayment)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text("turf.link/pay/xyz123",
                            style: TextStyle(color: Colors.white54)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(LucideIcons.copy,
                          color: AppColors.clientPrimary),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Link copied!")));
                      },
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Pay with Points
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                value: _payWithPoints,
                onChanged: (v) => setState(() => _payWithPoints = v!),
                title: const Text("Pay with Points",
                    style: TextStyle(color: Colors.white)),
                subtitle: const Text("Use 500 pts to save ₹50",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                activeColor: AppColors.clientPrimary,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          onPressed: _isProcessing ? null : _processBooking,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
          ),
          child: _isProcessing
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.black))
              : Text("Pay ₹${_finalAmount.toInt()}",
                  style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
