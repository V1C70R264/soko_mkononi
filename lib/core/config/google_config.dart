import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Google OAuth configuration.
///
/// Pass values at build/run time:
/// ```bash
/// flutter run \
///   --dart-define=GOOGLE_WEB_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com \
///   --dart-define=GOOGLE_CLIENT_ID=YOUR_PLATFORM_CLIENT_ID.apps.googleusercontent.com
/// ```
///
/// - [webClientId]: **Web application** OAuth client ID from Google Cloud Console.
///   Used as `serverClientId` on Android/iOS so Google returns an `id_token`
///   your Django backend can verify.
/// - [clientId]: Platform-specific client ID. Required on **Web**; on Android/iOS
///   you can omit it if configured via `google-services.json` / `Info.plist`.
class GoogleConfig {
  static const String webClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '821400102452-ant80gc52j50thdpcu7776d40t0sh240.apps.googleusercontent.com',
  );

  static const String clientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: '821400102452-8noje1u00udfgjr1e4uaodp4qcj9qs8u.apps.googleusercontent.com',
  );

  static bool get isConfigured => webClientId.isNotEmpty;

  /// Client ID passed to [GoogleSignIn.initialize] for the current platform.
  static String? get platformClientId {
    if (clientId.isNotEmpty) return clientId;
    if (kIsWeb && webClientId.isNotEmpty) return webClientId;
    return null;
  }

  /// Server-side client ID for id_token verification (Web client on mobile).
  static String? get serverClientId {
    if (webClientId.isEmpty) return null;
    if (kIsWeb) return null;
    return webClientId;
  }

  static String get platformLabel {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    return 'Desktop';
  }
}
