import 'package:flutter/widgets.dart';

/// Non-web placeholder. On mobile/desktop the native Google Sign-In flow is
/// triggered by a regular button, so nothing needs to be rendered here.
Widget buildGoogleSignInButton() => const SizedBox.shrink();
