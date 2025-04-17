import 'package:memecloud/core/use_case.dart';
import 'package:memecloud/domain/repositories/auth/auth_repository.dart';
import 'package:memecloud/core/service_locator.dart';

class SignOutUseCase implements UseCaseNoParam<void> {
  @override
  Future<void> call() async {
    // Gọi thằng AuthRepository để sign out
    return await serviceLocator<AuthRepository>().signOut();
  }
}