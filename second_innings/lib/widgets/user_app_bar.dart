import 'package:flutter/material.dart';
import 'package:second_innings/services/session_manager.dart';

class UserAppBar extends StatefulWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? additionalActions;

  const UserAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.onBackPressed,
    this.additionalActions,
  });

  @override
  State<UserAppBar> createState() => _UserAppBarState();
}

class _UserAppBarState extends State<UserAppBar> {
  String _userName = 'User';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Validate session first
    final isValid = await SessionManager.validateSessionForWidget(context);
    if (!isValid) return;

    try {
      final userName = await SessionManager.getUserDisplayName();
      if (mounted) {
        setState(() {
          _userName = userName;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userName = 'User';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SliverAppBar.large(
      pinned: true,
      floating: true,
      snap: false,
      elevation: 0,
      backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      leading: widget.showBackButton
          ? Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed:
                    widget.onBackPressed ?? () => Navigator.of(context).pop(),
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Image.asset("assets/logo.png"),
                onPressed: () => debugPrint("Logo tapped"),
              ),
            ),
      actions: [
        ...?widget.additionalActions,
        IconButton(
          icon: const Icon(Icons.logout_rounded),
          onPressed: () => SessionManager.logout(context),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_isLoading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.onPrimaryContainer,
                  ),
                ),
              )
            else
              Text(
                'Welcome, $_userName',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
          ],
        ),
        titlePadding: const EdgeInsets.only(bottom: 16),
      ),
    );
  }
}
