import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/user_model.dart';

/// Thrown for any auth failure so ViewModels can show a friendly message
/// without depending on `firebase_auth`'s exception types directly.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

/// Abstraction over "however we authenticate users" so ViewModels never
/// import `firebase_auth` directly. This is the seam Module 6 (testing)
/// uses to swap in a fake repository for unit tests without touching any
/// View or ViewModel code.
abstract class AuthRepository {
  /// Emits the current user (or null when signed out) whenever auth state
  /// changes — used by the router/splash screen to decide where to land.
  Stream<UserModel?> authStateChanges();

  UserModel? get currentUser;

  Future<UserModel> signIn({required String email, required String password});

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();
}

/// Firebase Authentication implementation of [AuthRepository].
///
/// Requires `Firebase.initializeApp()` to have already run (see
/// `main.dart`) and a `firebase_options.dart` generated for this project
/// via `flutterfire configure` — see README § "Connecting Firebase".
class FirebaseAuthRepository implements AuthRepository {
  final fb.FirebaseAuth _auth;

  FirebaseAuthRepository({fb.FirebaseAuth? firebaseAuth})
      : _auth = firebaseAuth ?? fb.FirebaseAuth.instance;

  UserModel? _toUserModel(fb.User? user) {
    if (user == null) return null;
    return UserModel.fromFirebaseUser(
      uid: user.uid,
      displayName: user.displayName,
      email: user.email,
      photoUrl: user.photoURL,
    );
  }

  @override
  Stream<UserModel?> authStateChanges() {
    return _auth.authStateChanges().map(_toUserModel);
  }

  @override
  UserModel? get currentUser => _toUserModel(_auth.currentUser);

  @override
  Future<UserModel> signIn({required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = _toUserModel(credential.user);
      if (user == null) {
        throw const AuthException('Sign in failed. Please try again.');
      }
      return user;
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_messageForCode(e.code));
    }
  }

  @override
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(fullName.trim());
      await credential.user?.reload();

      final user = _toUserModel(_auth.currentUser);
      if (user == null) {
        throw const AuthException('Account creation failed. Please try again.');
      }
      return user;
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_messageForCode(e.code));
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_messageForCode(e.code));
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  String _messageForCode(String code) {
    switch (code) {
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with that email.';
      case 'weak-password':
        return 'Please choose a stronger password.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
