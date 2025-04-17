import 'package:memecloud/core/configs/usecase/use_case.dart';
import 'package:memecloud/domain/repositories/auth/auth_repository.dart';
import 'package:memecloud/service_locator.dart';

class SignOutUseCase implements UseCaseNoParam<void> {
  @override
  Future<void> call() async {
    // Gọi thằng AuthRepository để sign out
    return await serviceLocator<AuthRepository>().signOut();
  }
}