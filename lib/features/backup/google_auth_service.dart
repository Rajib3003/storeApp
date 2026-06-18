import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
 static final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    'profile',
    'https://www.googleapis.com/auth/drive.file',
  ],
  serverClientId: null,
);

  static Future<GoogleSignInAccount?> signIn() async {
    try {
      final user = await _googleSignIn.signIn();

      print("USER: $user");

      return user;
    } catch (e) {
      print("SIGNIN ERROR: $e");
      return null;
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  static Future<GoogleSignInAccount?> signInSilently() async {
    return await _googleSignIn.signInSilently();
  }
}