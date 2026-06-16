import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/drive.appdata',
      'https://www.googleapis.com/auth/drive.file',
    ],
  );

  static Future<GoogleSignInAccount?> signIn() async {
    try {
      // ❌ disconnect remove করা হয়েছে (important fix)

      // optional: silent sign-in first (smooth UX)
      final silentUser = await _googleSignIn.signInSilently();
      if (silentUser != null) return silentUser;

      final user = await _googleSignIn.signIn();

      print("Google User: $user");

      return user;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}