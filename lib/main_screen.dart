import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traccar_client/main.dart';
import 'package:traccar_client/password_service.dart';
import 'package:traccar_client/preferences.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

import 'l10n/app_localizations.dart';
// import 'status_screen.dart';
import 'settings_screen.dart';
import 'widgets/info_card.dart';
import 'widgets/task_dropdown.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  bool trackingEnabled = false;
  bool? isMoving;
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the status indicator
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Scale animation for the card
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.98, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    _initState();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _initState() async {
    final state = await bg.BackgroundGeolocation.state;
    setState(() {
      trackingEnabled = state.enabled;
      isMoving = state.isMoving;
    });

    // Start animations if tracking is enabled
    if (trackingEnabled) {
      _pulseController.repeat(reverse: true);
      _scaleController.forward();
    }

    bg.BackgroundGeolocation.onEnabledChange((bool enabled) {
      setState(() {
        trackingEnabled = enabled;
      });

      // Control animations based on tracking state
      if (enabled) {
        _pulseController.repeat(reverse: true);
        _scaleController.forward();
      } else {
        _pulseController.stop();
        _scaleController.reverse();
      }
    });
    bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
      setState(() {
        isMoving = location.isMoving;
      });
    });
  }

  Future<void> _checkBatteryOptimizations(BuildContext context) async {
    try {
      if (!await bg.DeviceSettings.isIgnoringBatteryOptimizations) {
        final request =
            await bg.DeviceSettings.showIgnoreBatteryOptimizations();
        if (!request.seen && context.mounted) {
          showDialog(
            context: context,
            builder:
                (_) => AlertDialog(
                  scrollable: true,
                  content: Text(
                    AppLocalizations.of(context)!.optimizationMessage,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        bg.DeviceSettings.show(request);
                      },
                      child: Text(AppLocalizations.of(context)!.okButton),
                    ),
                  ],
                ),
          );
        }
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Widget _buildTrackingCard() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.trackingTitle,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                trackingEnabled
                                    ? (isMoving == true
                                        ? const Color(0xFF0d9488).withAlpha(70)
                                        : Colors.orange.withAlpha(70))
                                    : Colors.grey.withAlpha(50),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow:
                                trackingEnabled
                                    ? [
                                      BoxShadow(
                                        color: (isMoving == true
                                                ? const Color(0xFF0d9488)
                                                : Colors.orange)
                                            .withAlpha(20),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                    : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale:
                                        trackingEnabled
                                            ? _pulseAnimation.value
                                            : 1.0,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color:
                                            trackingEnabled
                                                ? (isMoving == true
                                                    ? const Color(0xFF0d9488)
                                                    : Colors.orange)
                                                : Colors.grey,
                                        shape: BoxShape.circle,
                                        boxShadow:
                                            trackingEnabled
                                                ? [
                                                  BoxShadow(
                                                    color: (isMoving == true
                                                            ? const Color(
                                                              0xFF0d9488,
                                                            )
                                                            : Colors.orange)
                                                        .withAlpha(50),
                                                    blurRadius: 4,
                                                    spreadRadius: 1,
                                                  ),
                                                ]
                                                : null,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 6),
                              Text(
                                trackingEnabled
                                    ? (isMoving == true ? 'Active' : 'Idle')
                                    : 'Inactive',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      trackingEnabled
                                          ? (isMoving == true
                                              ? const Color(0xFF0d9488)
                                              : Colors.orange)
                                          : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    iconSize: 28,
                    onPressed: () async {
                      if (await PasswordService.authenticate(context) &&
                          mounted) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                        setState(() {});
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              InfoCard(
                label: AppLocalizations.of(context)!.idLabel,
                value: Preferences.instance.getString(Preferences.id) ?? '',
                icon: Icons.fingerprint,
              ),
              const SizedBox(height: 8),
              InfoCard(
                label: AppLocalizations.of(context)!.urlLabel,
                value: Preferences.instance.getString(Preferences.url) ?? '',
                icon: Icons.route,
                primaryColor: Colors.teal,
              ),
              const Spacer(),
              TaskDropdown(
                isDisabled: trackingEnabled,
                onTaskSelected: (taskId) {
                  Preferences.instance.setString(Preferences.currentTask, taskId ?? '');
                },
                initialValue: Preferences.instance.getString(Preferences.currentTask) ?? '',
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 64,
                child: FilledButton(
                  onPressed: () async {
                    if (await PasswordService.authenticate(context) &&
                        mounted) {
                      if (!trackingEnabled) {
                        try {
                          await bg.BackgroundGeolocation.start();
                          if (mounted) {
                            _checkBatteryOptimizations(context);
                          }
                        } on PlatformException catch (error) {
                          messengerKey.currentState?.showSnackBar(
                            SnackBar(
                              content: Text(error.message ?? error.code),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      } else {
                        bg.BackgroundGeolocation.stop();
                      }
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        trackingEnabled
                            ? Theme.of(context).colorScheme.error
                            : const Color(0xFF0d9488),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        trackingEnabled
                            ? Icons.stop_circle_outlined
                            : Icons.play_circle_outline,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        trackingEnabled ? 'Stop Tracking' : 'Start Tracking',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildSettingsCard() {
  //   return Card(
  //     child: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           ListTile(
  //             contentPadding: EdgeInsets.zero,
  //             title: Text(AppLocalizations.of(context)!.settingsTitle),
  //             titleTextStyle: Theme.of(context).textTheme.headlineMedium,
  //           ),
  //           ListTile(
  //             contentPadding: EdgeInsets.zero,
  //             title: Text(AppLocalizations.of(context)!.urlLabel),
  //             subtitle: Text(Preferences.instance.getString(Preferences.url) ?? ''),
  //           ),
  //           const SizedBox(height: 8),
  //           OverflowBar(
  //             spacing: 8,
  //             children: [
  //               FilledButton.tonal(
  //                 onPressed: () async {
  //                   if (await PasswordService.authenticate(context) && mounted) {
  //                     await Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
  //                     setState(() {});
  //                   }
  //                 },
  //                 child: Text(AppLocalizations.of(context)!.settingsButton),
  //               ),
  //             ],
  //           ),
  //         ]
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: ListTile(
      //     title: Text('Zoneatlas', style: Theme.of(context).textTheme.titleLarge),
      //     subtitle: Text('Traccar client', style: Theme.of(context).textTheme.bodyMedium),
      //   ),
      // ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(children: [Expanded(child: _buildTrackingCard())]),
        ),
      ),
    );
  }
}
