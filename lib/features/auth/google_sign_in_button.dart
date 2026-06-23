/// Provides [buildGoogleSignInButton], which returns the official Google
/// Sign-In button on Web (via `google_sign_in_web`'s `renderButton`) and an
/// empty placeholder elsewhere (mobile/desktop use the native flow instead).
///
/// The correct implementation is selected at compile time via conditional
/// import so the web-only `dart:js_interop`-based code never reaches a mobile
/// build.
library;

export 'google_sign_in_button_stub.dart'
    if (dart.library.js_interop) 'google_sign_in_button_web.dart';
