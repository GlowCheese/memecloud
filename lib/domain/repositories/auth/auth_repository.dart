import 'package:dartz/dartz.dart';
import 'package:memecloud/data/models/auth/create_user_request.dart';
import 'package:memecloud/data/models/auth/sign_in_request.dart';

abstract class AuthRepository {
  Future<Either> signIn(SignInRequest signInRequest);
  Future<Either> signUp(CreateUserRequest createUserRequest);
  Future<void> signOut();
}
