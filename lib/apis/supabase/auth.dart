import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthApi {
  final SupabaseClient _client;
  SupabaseAuthApi(this._client);

  User? currentUser() {
    return _client.auth.currentUser;
  }

  Session? currentSession() {
    return _client.auth.currentSession;
  }

  Future<Either<String, User>> signIn(
    String email,
    String password,
  ) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        return Right(response.user!);
      } else {
        return Left('Unknown error occurred');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, User>> signUp(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': fullName},
      );
      if (response.user != null) {
        return Right(response.user!);
      } else {
        return Left('Unknown error occurred');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, Null>> signOut() async {
    await _client.auth.signOut();
    return Right(null);
  }
}