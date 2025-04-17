abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

abstract class UseCaseNoParam<Type> {
  Future<Type> call();
}