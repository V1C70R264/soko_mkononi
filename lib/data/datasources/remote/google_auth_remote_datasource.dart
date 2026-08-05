import 'package:dio/dio.dart';
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

    String? idToken;

    try {
      final account = await GoogleSignIn.instance.authenticate();
      idToken = account.authentication.idToken;

      // TEMP DEBUG — remove after diagnosing
      print('=== GOOGLE SIGN-IN DEBUG ===');
      print('platformClientId: ${GoogleConfig.platformClientId}');
      print('serverClientId: ${GoogleConfig.serverClientId}');
      print('account.email: ${account.email}');
      print('idToken is null: ${idToken == null}');
      print('ID TOKEN: $idToken');
      print('=== END GOOGLE SIGN-IN DEBUG ===');

      if (idToken == null || idToken.isEmpty) {
        throw Exception(
          'Google did not return an ID token. '
          'Ensure GOOGLE_WEB_CLIENT_ID is set to your Web OAuth client ID.',
        );
      }
    } on GoogleSignInException catch (e) {
      // TEMP DEBUG — remove after diagnosing
      print('=== GOOGLE SIGN-IN EXCEPTION ===');
      print('code: ${e.code}');
      print('description: ${e.description}');
      print('=== END GOOGLE SIGN-IN EXCEPTION ===');

      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw Exception('Sign-in cancelled');
      }
      throw Exception(e.description ?? 'Google sign-in failed');
    }

    // Separate try/catch so we can clearly see backend/network failures
    // vs. Google SDK failures.
    try {
      await authRemote.signInWithGoogle(idToken: idToken);
    } on DioException catch (e) {
      // TEMP DEBUG — remove after diagnosing
      print('=== BACKEND SIGN-IN DIO EXCEPTION ===');
      print('type: ${e.type}');
      print('message: ${e.message}');
      print('requestUrl: ${e.requestOptions.uri}');
      print('statusCode: ${e.response?.statusCode}');
      print('responseData: ${e.response?.data}');
      print('=== END BACKEND SIGN-IN DIO EXCEPTION ===');
      rethrow;
    } catch (e) {
      // TEMP DEBUG — remove after diagnosing
      print('=== BACKEND SIGN-IN UNEXPECTED EXCEPTION ===');
      print(e.toString());
      print('=== END BACKEND SIGN-IN UNEXPECTED EXCEPTION ===');
      rethrow;
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

    // TEMP DEBUG — remove after diagnosing
    print('=== GOOGLE SIGN-IN INIT ===');
    print('platformClientId: ${GoogleConfig.platformClientId}');
    print('serverClientId: ${GoogleConfig.serverClientId}');
    print('=== END GOOGLE SIGN-IN INIT ===');

    await GoogleSignIn.instance.initialize(
      clientId: GoogleConfig.platformClientId,
      serverClientId: GoogleConfig.serverClientId,
    );
    _initialized = true;
  }
}