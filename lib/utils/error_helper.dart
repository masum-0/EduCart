import 'package:firebase_auth/firebase_auth.dart';

/// Converts a raw exception (typically a FirebaseAuthException, but also
/// handles our own plain Exceptions thrown from the service layer) into a
/// short message safe to show directly to the user, instead of a raw
/// "[firebase_auth/email-already-in-use] ..." string.
String friendlyErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'That email is already registered. Try logging in instead.';
      case 'invalid-email':
        return 'That email address doesn\'t look right.';
      case 'weak-password':
        return 'Please choose a stronger password (at least 6 characters).';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support for help.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      case 'requires-recent-login':
        return 'Please log out and log back in, then try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  // Our own service-layer Exceptions carry a clear, already-friendly message
  // (e.g. "Price must be greater than 0."), so just strip the Dart prefix.
  final text = error.toString();
  if (text.startsWith('Exception: ')) {
    return text.substring('Exception: '.length);
  }

  return 'Something went wrong. Please try again.';
}