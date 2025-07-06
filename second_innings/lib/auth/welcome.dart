import 'package:flutter/material.dart';
import 'package:second_innings/auth/register.dart';

import 'package:second_innings/auth/feedback_query_help_page.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // Logo Animations.
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  // Text Animations.
  late Animation<double> _welcomeFade;
  late Animation<double> _titleFade;
  late Animation<double> _subtitleFade;
  // Description Animation.
  late Animation<double> _descFade;
  late Animation<double> _descSlide;
  // Bottom Sheet Animation.
  late Animation<Offset> _bottomSheetSlide;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _controller.forward();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Logo.
    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
    );
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.elasticOut),
      ),
    );

    // Texts.
    _welcomeFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.22, 0.38, curve: Curves.easeIn),
    );
    _titleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.32, 0.48, curve: Curves.easeIn),
    );
    _subtitleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.42, 0.58, curve: Curves.easeIn),
    );

    // Description.
    _descFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 0.75, curve: Curves.easeIn),
    );
    _descSlide = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.75, curve: Curves.easeOut),
      ),
    );

    // Bottom Sheet.
    _bottomSheetSlide =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
          ),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const FeedbackQueryHelpPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _logoScale,
                  child: FadeTransition(
                    opacity: _logoFade,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        "assets/logo.png",
                        width: MediaQuery.of(context).size.width * 0.3,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeTransition(
                  opacity: _welcomeFade,
                  child: Text(
                    "Welcome to",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),
                FadeTransition(
                  opacity: _titleFade,
                  child: Text(
                    "2nd Innings",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
                FadeTransition(
                  opacity: _subtitleFade,
                  child: Text(
                    "For the old, by the young.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 24),
                // Description container
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) => Opacity(
                    opacity: _descFade.value,
                    child: Transform.translate(
                      offset: Offset(0, _descSlide.value),
                      child: child,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 64),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withValues(alpha: 0.64),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).shadowColor.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      "Join a local group, stay in touch with loved ones, or find a helping hand. Your 2nd Innings starts here.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // BottomSheet with only the button
          SlideTransition(
            position: _bottomSheetSlide,
            child: BottomSheet(
              onClosing: () {},
              enableDrag: false,
              showDragHandle: false,
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(48)),
              ),
              backgroundColor: Theme.of(
                context,
              ).colorScheme.secondaryContainer.withValues(alpha: 0.96),
              builder: (context) => Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
                child: FilledButton.tonalIcon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(
                          googleAccountId: 'user@gmail.com',
                        ),
                      ),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.white),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                  ),
                  icon: Image.asset(
                    "assets/google_logo.png",
                    width: 28,
                    height: 28,
                  ),
                  iconAlignment: IconAlignment.start,
                  label: Text(
                    "Continue With Google",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
