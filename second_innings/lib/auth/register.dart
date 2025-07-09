import 'package:flutter/material.dart';
import 'package:second_innings/dashboard/caregiver/caregiver_home.dart';
import 'package:second_innings/dashboard/family/family_home.dart';
import 'package:second_innings/dashboard/senior_citizen/senior_citizen_home.dart';
import 'package:second_innings/util/validate.dart';
import 'package:second_innings/services/registration_service.dart';

enum UserType { seniorCitizen, family, caregiver }

class RegisterScreen extends StatefulWidget {
  final String googleAccountId;
  final String? idToken;
  final String? googleDisplayName;

  const RegisterScreen({
    super.key,
    required this.googleAccountId,
    this.idToken,
    this.googleDisplayName,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  UserType _selectedUserType = UserType.seniorCitizen;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _youtubeController = TextEditingController();
  late final TextEditingController _googleAccountController;

  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    _googleAccountController = TextEditingController(
      text: widget.googleAccountId,
    );

    // Autofill name from Google display name if available
    if (widget.googleDisplayName != null &&
        widget.googleDisplayName!.isNotEmpty) {
      _nameController.text = widget.googleDisplayName!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _googleAccountController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar.large(
            pinned: true,
            floating: false,
            elevation: 0,
            backgroundColor: colorScheme.primaryContainer.withValues(
              alpha: 0.8,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Register',
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '2nd Innings',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              titlePadding: const EdgeInsets.only(bottom: 16),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _googleAccountController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Google Account',
                        prefixIcon: const Icon(Icons.badge_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Automatically extracted after Google Sign Up.',
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(height: 24),
                    SegmentedButton<UserType>(
                      style: SegmentedButton.styleFrom(
                        padding: EdgeInsetsGeometry.only(top: 24, bottom: 24),
                      ),
                      segments: const <ButtonSegment<UserType>>[
                        ButtonSegment<UserType>(
                          value: UserType.family,
                          label: Text('Family'),
                        ),
                        ButtonSegment<UserType>(
                          value: UserType.seniorCitizen,
                          label: Text('Senior Citizen'),
                        ),
                        ButtonSegment<UserType>(
                          value: UserType.caregiver,
                          label: Text('Caregiver'),
                        ),
                      ],
                      selected: <UserType>{_selectedUserType},
                      onSelectionChanged: (Set<UserType> newSelection) {
                        setState(() {
                          _selectedUserType = newSelection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        hintText: widget.googleDisplayName != null
                            ? 'Autofilled from Google (editable)'
                            : 'Please Enter your full name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: Validators.validateFullName,
                    ),
                    if (widget.googleDisplayName != null &&
                        widget.googleDisplayName!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Name autofilled from your Google account. You can edit if needed.',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dobController,
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          String formattedDate =
                              "${pickedDate.day.toString().padLeft(2, '0')} / ${pickedDate.month.toString().padLeft(2, '0')} / ${pickedDate.year}";
                          _dobController.text = formattedDate;
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Date Of Birth',
                        hintText: 'DD / MM / YYYY',
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: Validators.validateDOB,
                    ),
                    if (_selectedUserType == UserType.caregiver)
                      _buildCaregiverFields(context),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _isRegistering ? null : _handleRegistration,
                      icon: _isRegistering
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.navigate_next_rounded),
                      label: Text(
                        _isRegistering ? 'Registering...' : 'Register',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: colorScheme.secondaryContainer,
                        foregroundColor: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaregiverFields(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Record a short introduction about yourself, your experience as a caregiver (if any), why do you choose to be a caregiver, and what do you feel that you\'ll be good at?',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _youtubeController,
          decoration: InputDecoration(
            labelText: 'YouTube Video',
            hintText: 'https://youtube.com/share...',
            prefixIcon: const Icon(Icons.play_circle_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: Validators.validateYoutubeUrl,
        ),
        const SizedBox(height: 8),
        Text(
          "Upload the recording to YouTube, share the link here. Make sure the video is set to 'Public' Access.",
          style: textTheme.bodySmall,
        ),
      ],
    );
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.idToken == null) {
      _showErrorMessage(
        'Authentication token is missing. Please sign in again.',
      );
      return;
    }

    setState(() {
      _isRegistering = true;
    });

    try {
      // Parse date of birth
      final dateOfBirth = RegistrationService.parseDateFromForm(
        _dobController.text,
      );
      if (dateOfBirth == null) {
        _showErrorMessage('Invalid date format. Please select a valid date.');
        return;
      }

      // Map UI user type to service enum
      UserRole userRole;
      switch (_selectedUserType) {
        case UserType.seniorCitizen:
          userRole = UserRole.seniorCitizen;
          break;
        case UserType.family:
          userRole = UserRole.family;
          break;
        case UserType.caregiver:
          userRole = UserRole.caregiver;
          break;
      }

      // Prepare optional fields for caregivers
      String? description;
      String? tags;
      if (_selectedUserType == UserType.caregiver &&
          _youtubeController.text.isNotEmpty) {
        final extras = RegistrationService.generateCaregiverExtras(
          fullName: _nameController.text,
          youtubeUrl: _youtubeController.text,
        );
        description = extras['description'];
        tags = extras['tags'];
      }

      // Call registration service
      final result = await RegistrationService.handleRegistration(
        idToken: widget.idToken!,
        fullName: _nameController.text,
        userRole: userRole,
        dateOfBirth: dateOfBirth,
        youtubeUrl: _selectedUserType == UserType.caregiver
            ? _youtubeController.text
            : null,
        description: description,
        tags: tags,
      );

      if (mounted) {
        if (result.isSuccess) {
          // Registration successful - navigate to appropriate dashboard
          _showSuccessMessage(result.message ?? 'Registration successful!');
          await _navigateToUserDashboard();
        } else {
          // Registration failed - show error message
          _showErrorMessage(result.error ?? 'Registration failed');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Registration error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRegistering = false;
        });
      }
    }
  }

  Future<void> _navigateToUserDashboard() async {
    await Future.delayed(
      const Duration(seconds: 1),
    ); // Brief delay to show success message

    if (!mounted) return;

    switch (_selectedUserType) {
      case UserType.seniorCitizen:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SeniorCitizenHomePage(),
          ),
        );
        break;
      case UserType.family:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FamilyHomePage()),
        );
        break;
      case UserType.caregiver:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CaregiverHomePage()),
        );
        break;
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
