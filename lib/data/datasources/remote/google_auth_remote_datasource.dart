import 'package:e_commerce/core/config/google_config.dart';
import 'package:e_commerce/data/datasources/remote/auth_remote_datasource.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Handles Google SDK sign-in and exchanges the ID token with Django.
class GoogleAuthService {
  final AuthRemoteDatasource authRemote;
  bool _initialized = false;

  GoogleAuthService(this.authRemote);

  Future<void> signIn() async {
    await _ensureInitialized();

    try {
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw Exception(
          'Google did not return an ID token. '
          'Ensure GOOGLE_WEB_CLIENT_ID is set to your Web OAuth client ID.',
        );
      }

      await authRemote.signInWithGoogle(idToken: idToken);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw Exception('Sign-in cancelled');
      }
      throw Exception(e.description ?? 'Google sign-in failed');
    }
  }

  Future<void> signOut() async {
    await _ensureInitialized();
    await GoogleSignIn.instance.signOut();
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    if (!GoogleConfig.isConfigured) {
      throw Exception(
        'Google Sign-In is not configured. Run with:\n'
        '--dart-define=GOOGLE_WEB_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
      );
    }

    await GoogleSignIn.instance.initialize(
      clientId: GoogleConfig.platformClientId,
      serverClientId: GoogleConfig.serverClientId,
    );
    _initialized = true;
  }
}