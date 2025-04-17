import 'package:dartz/dartz.dart';
import 'package:memecloud/data/models/auth/create_user_request.dart';
import 'package:memecloud/data/models/auth/sign_in_request.dart';
import 'package:memecloud/core/service_locator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthSupabaseService {
  final SupabaseClient _supabaseClient = serviceLocator<SupabaseClient>();

  AuthSupabaseService();

  Future<User?> getCurrentUser() async {
    return _supabaseClient.auth.currentUser;
  }

  Future<Either> signInWithEmail(SignInRequest signInReq) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: signInReq.email,
        password: signInReq.password,
      );
      if (response.user != null) {
        return Right(response.user);
      } else {
        return Left('Unknown error occurred');
      }
    } on AuthException catch (e) {
      return Left(e);
    }
  }

  Future<Either> signUpWithEmail(CreateUserRequest createUserReq) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: createUserReq.email,
        password: createUserReq.password,
        data: {
          'display_name': createUserReq.fullName,
        },
      );
      if (response.user != null) {
        return Right(response.user);
      } else {
        return Left('Unknown error occurred');
      }
    } on AuthException catch (e) {
      return Left(e.toString());
    }
  }

  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  Stream<AuthState> authStateChanges() {
    return _supabaseClient.auth.onAuthStateChange;
  }
}