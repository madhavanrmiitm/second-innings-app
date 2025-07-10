import 'package:flutter/material.dart';
import 'package:second_innings/auth/welcome.dart';
import 'package:second_innings/dashboard/senior_citizen/senior_citizen_home.dart';
import 'package:second_innings/dashboard/family/family_home.dart';
import 'package:second_innings/dashboard/caregiver/caregiver_home.dart';
import 'user_service.dart';

class SessionManager {
  // Check if user is logged in and return initial route
  static Future<Widget> getInitialRoute() async {
    final isLoggedIn = await UserService.isLoggedIn();
    if (!isLoggedIn) {
      return const WelcomeScreen();
    }

    final userData = await UserService.getUserData();
    if (userData == null) {
      // Clear invalid session
      await UserService.clearUserData();
      return const WelcomeScreen();
    }

    // Navigate to appropriate dashboard based on user type
    return _getAppropriateHome(userData);
  }

  // Get appropriate home screen based on user type
  static Widget _getAppropriateHome(Map<String, dynamic> userData) {
    final userType = userData['user_type']?.toString().toLowerCase();

    switch (userType) {
      case 'senior_citizen':
        return const SeniorCitizenHomePage();
      case 'family':
        return const FamilyHomePage();
      case 'caregiver':
        return const CaregiverHomePage();
      default:
        return const WelcomeScreen();
    }
  }

  // Get user display name with fallback
  static Future<String> getUserDisplayName() async {
    final userData = await UserService.getUserData();
    if (userData == null) {
      return 'User';
    }

    // Try different possible name fields
    final fullName = userData['full_name']?.toString();
    final firstName = userData['first_name']?.toString();
    final name = userData['name']?.toString();

    return fullName ?? firstName ?? name ?? 'User';
  }

  // Validate session and redirect if invalid
  static Future<bool> validateSessionForWidget(BuildContext context) async {
    final isLoggedIn = await UserService.isLoggedIn();
    final userData = await UserService.getUserData();

    if (!isLoggedIn || userData == null) {
      // Session is invalid, redirect to welcome screen
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (route) => false,
        );
      }
      return false;
    }
    return true;
  }

  // Handle logout
  static Future<void> logout(BuildContext context) async {
    await UserService.clearUserData();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  // Get user type
  static Future<String?> getUserType() async {
    final userData = await UserService.getUserData();
    return userData?['user_type']?.toString();
  }

  // Get all user data safely
  static Future<Map<String, dynamic>?> getUserData() async {
    return await UserService.getUserData();
  }
}
