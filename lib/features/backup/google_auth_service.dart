import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;

/// ================= GOOGLE AUTH SERVICE =================
class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/drive.file',
    ],
  );

  static GoogleSignInAccount? _currentUser;

  /// ================= SIGN IN =================
  static Future<GoogleSignInAccount?> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      return _currentUser;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  /// ================= SIGN OUT =================
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
  }

  static GoogleSignInAccount? get currentUser => _currentUser;

  /// ================= GET AUTH HEADERS =================
  /// 👉 THIS IS VERY IMPORTANT FOR DRIVE API
  static Future<Map<String, String>> getAuthHeaders() async {
    if (_currentUser == null) {
      throw Exception("User not signed in");
    }

    return await _currentUser!.authHeaders;
  }

  /// ================= GET AUTH CLIENT =================
  /// 👉 Used for Google Drive API
  static Future<auth.AuthClient> getAuthClient() async {
    final headers = await getAuthHeaders();

    return auth.authenticatedClient(
      http.Client(),
      auth.AccessCredentials(
        auth.AccessToken(
          'Bearer',
          headers['Authorization']!.replaceFirst('Bearer ', ''),
          DateTime.now().add(const Duration(hours: 1)),
        ),
        null,
        ['https://www.googleapis.com/auth/drive.file'],
      ),
    );
  }
}