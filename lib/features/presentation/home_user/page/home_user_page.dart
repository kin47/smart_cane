import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_cane/base/base_widget.dart';
import 'package:smart_cane/base/bloc/bloc_status.dart';
import 'package:smart_cane/common/constants/location_constants.dart';
import 'package:smart_cane/common/index.dart';
import 'package:smart_cane/common/widgets/buttons/app_button.dart';
import 'package:smart_cane/di/di_setup.dart';
import 'package:smart_cane/features/domain/entity/user_entity.dart';
import 'package:smart_cane/features/domain/events/event_bus_event.dart';
import 'package:smart_cane/features/presentation/home_user/bloc/home_user_bloc.dart';
import 'package:smart_cane/gen/assets.gen.dart';
import 'package:smart_cane/routes/app_pages.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class HomeUserPage extends StatefulWidget {
  final UserEntity user;

  const HomeUserPage({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<HomeUserPage> createState() => _HomeUserPageState();
}

class _HomeUserPageState extends BaseState<HomeUserPage, HomeUserEvent,
    HomeUserState, HomeUserBloc> {
  late StreamSubscription _eventBusSubscription;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    bloc.add(HomeUserEvent.init(userEntity: widget.user));
    _eventBusSubscription =
        getIt<EventBus>().on<OpenLoginPageEvent>().listen((event) {
      context.router.replaceAll([
        const LoginRoute(),
      ]);
    });
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (timer) {
        bloc.add(
          HomeUserEvent.sendLocation(
            isPressSend: false,
            time: DateTime.now(),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _eventBusSubscription.cancel();
    _timer.cancel();
  }

  @override
  void listener(BuildContext context, HomeUserState state) {
    super.listener(context, state);
    switch (state.status) {
      case BaseStateStatus.logout:
        context.router.replaceAll([
          const LoginRoute(),
        ]);
        break;
      case BaseStateStatus.failed:
        DialogService.showInformationDialog(
          context,
          title: 'error'.tr(),
          description: state.message ?? 'error_system'.tr(),
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget renderUI(BuildContext context) {
    return BaseScaffold(
      appBar: BaseAppBar(
        title: 'home'.tr(),
        hasBack: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            SizedBox(height: 24.h),
            Row(
              children: [
                Text(
                  'email'.tr(),
                  style: AppTextStyles.s16w400,
                ),
                SizedBox(width: 16.w),
                blocBuilder(
                  buildWhen: (previous, current) =>
                      previous.userEntity != current.userEntity,
                  (context, state) => Text(
                    state.userEntity?.email ?? '',
                    style: AppTextStyles.s16w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Text(
                  'role'.tr(),
                  style: AppTextStyles.s16w400,
                ),
                SizedBox(width: 16.w),
                blocBuilder(
                  buildWhen: (previous, current) =>
                      previous.userEntity != current.userEntity,
                  (context, state) => Text(
                    state.userEntity?.role.value ?? '',
                    style: AppTextStyles.s16w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            _buildSendLocationButton(),
            SizedBox(height: 24.h),
            _callPhoneButton(),
            SizedBox(height: 24.h),
            AppButton(
              title: 'logout'.tr(),
              backgroundColor: AppColors.red,
              height: 56.h,
              borderRadius: 28.r,
              onPressed: () {
                bloc.add(const HomeUserEvent.signOut());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendLocationButton() {
    return AppButton(
      title: '',
      backgroundColor: AppColors.white,
      height: 56.h,
      borderRadius: 28.r,
      elevation: 2,
      trailingIcon: Assets.svg.icGoogleMap.svg(
        width: 24.w,
      ),
      textColor: AppColors.black,
      onPressed: () {
        bloc.add(
          HomeUserEvent.sendLocation(
            isPressSend: true,
            time: DateTime.now(),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Text(
                'send_location'.tr(),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.s16w600.copyWith(
                  color: AppColors.primary500,
                ),
              ),
            ),
            Assets.svg.icGoogleMap.svg(
              width: 24.w,
            ),
          ],
        ),
      ),
    );
  }

  Widget _callPhoneButton() {
    return AppButton(
      title: '',
      backgroundColor: AppColors.green,
      height: 56.h,
      borderRadius: 28.r,
      trailingIcon: Assets.svg.icPhone.svg(
        width: 24.w,
        colorFilter: const ColorFilter.mode(
          AppColors.white,
          BlendMode.srcIn,
        ),
      ),
      onPressed: () async {
        await FlutterPhoneDirectCaller.callNumber(widget.user.phoneNumber);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Text(
                'call_relative'.tr(),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.s16w600.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
            Assets.svg.icGoogleMap.svg(
              width: 24.w,
            ),
          ],
        ),
      ),
    );
  }
}
