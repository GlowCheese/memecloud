import 'package:dartz/dartz.dart';
import 'package:memecloud/data/models/auth/create_user_request.dart';
import 'package:memecloud/data/models/auth/sign_in_request.dart';
import 'package:memecloud/data/sources/auth/auth_supabase_service.dart';
import 'package:memecloud/domain/repositories/auth/auth_repository.dart';
import 'package:memecloud/core/service_locator.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Either> signIn(SignInRequest signInRequest) async {
    return await serviceLocator<AuthSupabaseService>().signInWithEmail(
      signInRequest,
    );
  }

  @override
  Future<void> signOut() async {
    return await serviceLocator<AuthSupabaseService>().signOut();
  }

  @override
  Future<Either> signUp(CreateUserRequest createUserRequest) async {
    return await serviceLocator<AuthSupabaseService>().signUpWithEmail(
      createUserRequest,
    );
  }
}
