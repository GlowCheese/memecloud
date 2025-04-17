import 'package:dartz/dartz.dart';
import 'package:memecloud/core/configs/usecase/use_case.dart';
import 'package:memecloud/data/models/auth/sign_in_request.dart';
import 'package:memecloud/domain/repositories/auth/auth_repository.dart';
import 'package:memecloud/service_locator.dart';

class SignInUseCase implements UseCase<Either, SignInRequest> {
  @override
  Future<Either> call(SignInRequest params) async {
    // Implement the sign-in logic here
    // For example, you might want to call an authentication service
    // and handle the response accordingly.
    return await serviceLocator<AuthRepository>().signIn(
      params
    );
  }

}