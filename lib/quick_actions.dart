import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

import 'l10n/app_localizations.dart';
import 'preferences.dart';

class QuickActionsInitializer extends StatefulWidget {
  const QuickActionsInitializer({super.key});

  @override
  State<QuickActionsInitializer> createState() => _QuickActionsInitializerState();
}

class _QuickActionsInitializerState extends State<QuickActionsInitializer> {
  final QuickActions quickActions = QuickActions();

  @override
  void initState() {
    super.initState();
    quickActions.initialize((shortcutType) async {
      switch (shortcutType) {
        case 'start':
          bg.BackgroundGeolocation.start();
        case 'stop':
          bg.BackgroundGeolocation.stop();
        case 'sos':
          try {
            await bg.BackgroundGeolocation.getCurrentPosition(
              samples: 1, 
              persist: true, 
              extras: {
                'alarm': 'sos',
                'task': Preferences.instance.getString(Preferences.currentTask) ?? '',
              },
            );
          } catch (error) {
            developer.log('Failed to send alert', error: error);
          }
      }
      if (mounted) {
        SystemNavigator.pop();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localizations = AppLocalizations.of(context)!;
    quickActions.setShortcutItems(<ShortcutItem>[
      ShortcutItem(type: 'start', localizedTitle: localizations.startAction, icon: 'play'),
      ShortcutItem(type: 'stop', localizedTitle: localizations.stopAction, icon: 'stop'),
      ShortcutItem(type: 'sos', localizedTitle: localizations.sosAction, icon: 'exclamation'),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
