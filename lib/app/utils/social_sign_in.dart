import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../data/providers.dart';

/// "Continue with Google / Apple". Each returns the API path and body for the
/// sign-in call, or null when the customer closed the provider's sheet. The
/// API creates a customer account on first use, so this is also the sign-up.
class SocialSignIn {
  /// Web OAuth client of SafarPlus's Google Cloud project. Google issues the
  /// token for it and the API checks tokens against it
  /// (Authentication:Google:ClientId). Empty = Google button hidden.
  static const googleServerClientId =
      '930604107418-9bdkqp6924q86m34h3sci963pq63mb4c.apps.googleusercontent.com';

  /// iOS OAuth client. Its reversed id must also be a URL scheme in
  /// ios/Runner/Info.plist, or Google sign-in crashes the app on iPhone.
  static const googleIosClientId =
      '930604107418-kshk7svqsghi3qp8mmul864kglvee00k.apps.googleusercontent.com';

  static bool get googleReady =>
      !kIsWeb &&
      googleServerClientId.isNotEmpty &&
      (!Platform.isIOS || googleIosClientId.isNotEmpty);

  /// Apple requires Sign in with Apple next to Google on iPhone (guideline 4.8).
  static bool get appleReady => !kIsWeb && Platform.isIOS;

  static Future<(String, Map<String, dynamic>)?> google() async {
    final google = GoogleSignIn(
      clientId: Platform.isIOS ? googleIosClientId : null,
      serverClientId: googleServerClientId,
      scopes: const ['email', 'profile'],
    );
    // Forget the last pick so the account chooser always shows.
    await google.signOut();
    final account = await google.signIn();
    if (account == null) return null;
    final token = (await account.authentication).idToken;
    if (token == null) throw StateError('Google returned no id token');
    return (
      'api/Authenticator/Google/LoginUser',
      {'idToken': token, 'microSiteClientId': GetProviders.clientId},
    );
  }

  static Future<(String, Map<String, dynamic>)?> apple() async {
    try {
      final c = await SignInWithApple.getAppleIDCredential(scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ]);
      return (
        'api/Authenticator/Apple/LoginUser',
        {
          'idToken': c.identityToken,
          // Apple shares the name on the first sign-in only.
          'firstName': c.givenName,
          'lastName': c.familyName,
          'microSiteClientId': GetProviders.clientId,
        },
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return null;
      rethrow;
    }
  }
}
