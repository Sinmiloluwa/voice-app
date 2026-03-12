import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:voiceapp/models/user.dart';
import 'package:voiceapp/services/location_service.dart';
import 'package:voiceapp/services/user_service.dart';

class LocationProvider extends ChangeNotifier {
  final _locationService = LocationService();
  final _userService = UserService();

  List<UserModel> _nearbyUsers = [];
  bool _isLoading = false;
  String? _error;
  Position? _currentPosition;
  bool _locationDenied = false;
  bool _locationServiceDisabled = false;

  List<UserModel> get nearbyUsers => _nearbyUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Position? get currentPosition => _currentPosition;
  bool get locationDenied => _locationDenied;
  bool get locationServiceDisabled => _locationServiceDisabled;

  Future<void> loadNearbyUsers() async {
    _isLoading = true;
    _error = null;
    _locationDenied = false;
    _locationServiceDisabled = false;
    notifyListeners();

    try {
      final serviceEnabled = await _locationService.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _locationServiceDisabled = true;
        _isLoading = false;
        notifyListeners();
        return;
      }

      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        _locationDenied = true;
        _isLoading = false;
        notifyListeners();
        return;
      }

      _currentPosition = position;

      // Update location in background — don't let failure block the fetch
      try {
        await _userService.updateLocation(position.latitude, position.longitude);
      } catch (_) {}

      final result = await _userService.getNearbyUsers(
        position.latitude,
        position.longitude,
      );
      _nearbyUsers = result ?? [];
    } catch (e) {
      print('loadNearbyUsers error: $e');
      _error = 'Failed to load nearby users';
    }

    _isLoading = false;
    notifyListeners();
  }
}
