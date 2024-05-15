import 'package:dartz/dartz.dart';
import 'package:smart_cane/base/network/errors/error.dart';
import 'package:smart_cane/features/data/model/location_model/location_model.dart';

abstract class LocationRepository {
  Future<Either<BaseError, bool>> sendLocation({
    required String userEmail,
    required DateTime time,
    required double latitude,
    required double longitude,
  });

  Future<Either<BaseError, LocationModel>> getBlindPersonLocation({
    required String adminEmail,
  });
}
