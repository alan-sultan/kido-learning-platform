import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim();
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } on TypeError catch (typeError) {
      final recoveredCredential = await _recoverFromMalformedPigeonPayload(
        typeError: typeError,
        email: normalizedEmail,
        password: password,
        actionLabel: 'sign-in',
      );

      if (recoveredCredential != null) {
        return recoveredCredential;
      }

      final fallbackUser = _auth.currentUser;
      if (fallbackUser != null) {
        debugPrint(
          'Sign-in recovered using cached Firebase session after malformed payload.',
        );
        await _initializeUserProfile(fallbackUser);
        return null;
      }

      throw Exception(
        'We could not complete the sign-in due to a Firebase sync issue. Please try again.',
      );
    }
  }

  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim();
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      await _initializeUserProfile(credential.user);

      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } on TypeError catch (typeError) {
      final recoveredCredential = await _recoverFromMalformedPigeonPayload(
        typeError: typeError,
        email: normalizedEmail,
        password: password,
        actionLabel: 'sign-up',
      );
      if (recoveredCredential != null) {
        return recoveredCredential;
      }

      final fallbackUser = _auth.currentUser;
      if (fallbackUser != null) {
        debugPrint(
          'Sign-up recovered using cached Firebase session after malformed payload.',
        );
        await _initializeUserProfile(fallbackUser);
        return null;
      }

      throw Exception(
        'Your account was created, but we need you to sign in again to finish setup.',
      );
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      await _initializeUserProfile(userCredential.user);

      return userCredential;
    } catch (e) {
      throw Exception('Google sign-in failed: ${e.toString()}');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> _createUserDocument(User user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'email': user.email,
      'displayName': user.displayName ?? '',
      'photoURL': user.photoURL ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<UserCredential?> _recoverFromMalformedPigeonPayload({
    required TypeError typeError,
    required String email,
    required String password,
    required String actionLabel,
  }) async {
    if (!_isMalformedPigeonPayload(typeError)) {
      throw typeError;
    }

    debugPrint(
      'FirebaseAuth returned malformed PigeonUserDetails payload during $actionLabel. '
      'Attempting recovery by re-establishing the session.',
    );

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _initializeUserProfile(credential.user);
      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } on TypeError catch (innerError) {
      if (!_isMalformedPigeonPayload(innerError)) {
        rethrow;
      }

      debugPrint(
        'Recovery sign-in also hit malformed Pigeon payload during $actionLabel. '
        'Falling back to cached Firebase user if available.',
      );
      return null;
    }
  }

  Future<void> _initializeUserProfile(User? user) async {
    if (user == null) return;
    try {
      await _createUserDocument(user);
    } catch (e) {
      debugPrint('Firestore error creating user document: $e');
    }
  }

  bool _isMalformedPigeonPayload(Object error) {
    return error.toString().contains('PigeonUserDetails');
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}
