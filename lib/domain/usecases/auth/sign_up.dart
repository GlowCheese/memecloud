import 'package:memecloud/core/use_case.dart';
import 'package:memecloud/data/models/auth/create_user_request.dart';
import 'package:dartz/dartz.dart';
import 'package:memecloud/domain/repositories/auth/auth_repository.dart';
import 'package:memecloud/core/service_locator.dart';

class SignupUseCase implements UseCase<Either, CreateUserRequest> {
  @override
  Future<Either> call(CreateUserRequest params) {
    return serviceLocator<AuthRepository>().signUp(
      params
    );
  }
}
