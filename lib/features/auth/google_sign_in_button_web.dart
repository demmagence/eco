import 'package:flutter/widgets.dart';
import 'package:google_sign_in_web/web_only.dart' as gsi_web;

/// On Web, render the official Google Sign-In button. Clicking it runs the
/// Google Identity Services flow and emits a sign-in event on
/// `GoogleSignIn.authenticationEvents`, which `AuthRepository` exchanges for a
/// Supabase session.
Widget buildGoogleSignInButton() => gsi_web.renderButton();
