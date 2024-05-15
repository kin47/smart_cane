import 'dart:async';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_cane/base/bloc/base_bloc.dart';
import 'package:smart_cane/base/bloc/base_bloc_state.dart';
import 'package:smart_cane/base/bloc/bloc_status.dart';
import 'package:smart_cane/base/network/errors/extension.dart';
import 'package:smart_cane/features/domain/entity/user_entity.dart';
import 'package:smart_cane/features/domain/repository/auth_repository.dart';
import 'package:smart_cane/features/domain/repository/location_repository.dart';
import 'package:geolocator/geolocator.dart';

part 'home_user_event.dart';

part 'home_user_state.dart';

part 'home_user_bloc.freezed.dart';

part 'home_user_bloc.g.dart';

@injectable
class HomeUserBloc extends BaseBloc<HomeUserEvent, HomeUserState> {
  HomeUserBloc(
    this._authRepository,
    this._locationRepository,
  ) : super(HomeUserState.init()) {
    on<HomeUserEvent>((event, emit) async {
      await event.when(
        init: (userEntity) => init(emit, userEntity),
        sendLocation: (isPressSend, time) =>
            sendLocation(emit, isPressSend, time),
        signOut: () => signOut(emit),
      );
    });
  }

  final AuthRepository _authRepository;
  final LocationRepository _locationRepository;

  Future init(Emitter<HomeUserState> emit, UserEntity userEntity) async {
    emit(
      state.copyWith(
        userEntity: userEntity,
        status: BaseStateStatus.idle,
      ),
    );
  }

  Future sendLocation(
      Emitter<HomeUserState> emit, bool isPressSend, DateTime time) async {
    final Position position = await _determinePosition();
    if (isPressSend) {
      emit(state.copyWith(status: BaseStateStatus.loading));
    }
    final result = await _locationRepository.sendLocation(
      userEmail: state.userEntity!.email,
      time: time,
      latitude: position.latitude,
      longitude: position.longitude,
    );
    result.fold(
      (l) {
        if (isPressSend) {
          emit(
            state.copyWith(
              status: BaseStateStatus.failed,
              message: l.getError,
            ),
          );
        }
      },
      (r) {
        if (r == true) {
          emit(
            state.copyWith(
              status: BaseStateStatus.idle,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: BaseStateStatus.failed,
              message: 'error_system'.tr(),
            ),
          );
        }
      },
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future signOut(Emitter<HomeUserState> emit) async {
    emit(state.copyWith(status: BaseStateStatus.loading));
    final result = await _authRepository.signOut();
    result.fold(
      (l) => emit(state.copyWith(status: BaseStateStatus.failed)),
      (r) {
        if (r == true) {
          emit(state.copyWith(status: BaseStateStatus.logout));
        } else {
          emit(state.copyWith(status: BaseStateStatus.failed));
        }
      },
    );
  }
}
