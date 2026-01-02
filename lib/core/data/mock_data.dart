import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- SERVICE PROVIDER ---
final mockDataServiceProvider = Provider((ref) => MockDataService());

// --- MODELS ---

class TurfModel {
  final String id;
  final String name;
  final String location;
  final String imageUrl;
  final double rating;
  final double distanceKm;
  final double pricePerHour;
  final List<String> sports; // e.g., 'Cricket', 'Football'
  final List<String> amenities;

  TurfModel({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.rating,
    required this.distanceKm,
    required this.pricePerHour,
    required this.sports,
    required this.amenities,
  });
}

class BookingModel {
  final String id;
  final String turfName;
  final DateTime date;
  final String timeSlot; // e.g., "19:00"
  final double price;
  final String status; // 'Confirmed', 'Pending', 'Cancelled'

  BookingModel({
    required this.id,
    required this.turfName,
    required this.date,
    required this.timeSlot,
    required this.price,
    required this.status,
  });
}

class UserModel {
  final String id;
  final String name;
  final int points;

  UserModel({required this.id, required this.name, required this.points});
}

// --- MOCK SERVICE ---

class MockDataService {
  // Mock Data
  final List<TurfModel> _turfs = [
    TurfModel(
      id: 't1',
      name: 'Striker\'s Arena',
      location: 'Indrapuri, Bhopal',
      imageUrl: 'https://images.unsplash.com/photo-1529900748604-07564a03e7a6?auto=format&fit=crop&q=80&w=1000',
      rating: 4.5,
      distanceKm: 2.5,
      pricePerHour: 1200,
      sports: ['Cricket', 'Football'],
      amenities: ['Parking', 'Changing Room', 'Floodlights'],
    ),
    TurfModel(
      id: 't2',
      name: 'Goalazo Turf',
      location: 'Arera Colony, Bhopal',
      imageUrl: 'https://images.unsplash.com/photo-1551958219-acbc608c6377?auto=format&fit=crop&q=80&w=1000',
      rating: 4.8,
      distanceKm: 4.0,
      pricePerHour: 1500,
      sports: ['Football'],
      amenities: ['Water', 'Washroom', 'Cafe'],
    ),
    TurfModel(
      id: 't3',
      name: 'Smash Zone',
      location: 'Kolar Road, Bhopal',
      imageUrl: 'https://images.unsplash.com/photo-1626248801379-51a0748a5f96?auto=format&fit=crop&q=80&w=1000',
      rating: 4.2,
      distanceKm: 6.2,
      pricePerHour: 800,
      sports: ['Badminton', 'Tennis'],
      amenities: ['Parking', 'Equipment Rental'],
    ),
    TurfModel(
      id: 't4',
      name: 'Legends Pitch',
      location: 'Lalghati, Bhopal',
      imageUrl: 'https://images.unsplash.com/photo-1575361204480-aadea25e6e68?auto=format&fit=crop&q=80&w=1000',
      rating: 4.6,
      distanceKm: 8.5,
      pricePerHour: 1100,
      sports: ['Cricket'],
      amenities: ['Pavilion', 'First Aid'],
    ),
    TurfModel(
      id: 't5',
      name: 'Urban Sports Hub',
      location: 'MP Nagar, Bhopal',
      imageUrl: 'https://images.unsplash.com/photo-1596707328678-b1ad2c72b8d0?auto=format&fit=crop&q=80&w=1000',
      rating: 4.3,
      distanceKm: 1.2,
      pricePerHour: 1800,
      sports: ['Football', 'Cricket', 'Basketball'],
      amenities: ['Parking', 'Shower', 'Locker'],
    ),
  ];

  final UserModel _currentUser = UserModel(id: 'u1', name: 'Player One', points: 500);

  // Methods with artificial delay
  Future<List<TurfModel>> getTurfs() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _turfs;
  }

  Future<TurfModel?> getTurfById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _turfs.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<UserModel> getUser() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _currentUser;
  }
  
  // Mock booking slots logic
  Future<List<String>> getBookedSlots(String turfId, DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Determine some random booked slots based on date/turf for demo
    if (date.day % 2 == 0) {
      return ['18:00', '20:00'];
    } else {
      return ['17:00', '19:00', '21:00'];
    }
  }

  Future<void> createBooking(BookingModel booking) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    // Simulate booking creation
    return;
  }
}
