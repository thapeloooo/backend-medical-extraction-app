import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Handles all authentication logic for the Medibrief app.
/// Wraps Firebase Auth and creates a matching Firestore user profile.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns the currently logged-in user (null if nobody is logged in).
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes - useful for auto-login on app start.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Register a new user with email + password.
  /// Also creates a document in the 'Users' collection with role info.
  Future<User?> register({
    required String email,
    required String password,
    required String username,
    String role = 'healthcare_staff',
  }) async {
    try {
      // Create the user in Firebase Authentication
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Save user profile to Firestore 'Users' collection
      await _firestore.collection('Users').doc(cred.user!.uid).set({
        'userId': cred.user!.uid,
        'username': username.trim(),
        'email': email.trim(),
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e.code));
    }
  }

  /// Log in an existing user.
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e.code));
    }
  }

  /// Sign the current user out.
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Send a password reset email.
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e.code));
    }
  }

  /// Convert Firebase error codes into human-readable messages.
  String _mapAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication error: $code';
    }
  }
}