import 'package:dartz/dartz.dart';
import 'package:smart_cane/base/network/errors/error.dart';
import 'package:smart_cane/features/data/request/register_request/register_request.dart';
import 'package:smart_cane/features/domain/entity/user_entity.dart';

abstract class UserRepository {
  Future<Either<BaseError, bool>> createUser({
    required RegisterRequest request,
  });

  Future<Either<BaseError, UserEntity>> getUserInfo({
    required String email,
  });
}
