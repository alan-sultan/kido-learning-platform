import 'package:flutter/material.dart';

/// Provides global navigator and messenger access for auth-driven flows.
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void popToRoot() {
    navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  static void showSnackBar(SnackBar snackBar) {
    final messenger = messengerKey.currentState;
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(snackBar);
  }
}
