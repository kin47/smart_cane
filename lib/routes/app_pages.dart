import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_cane/features/domain/entity/user_entity.dart';
import 'package:smart_cane/features/presentation/home_admin/page/home_admin_page.dart';
import 'package:smart_cane/features/presentation/home_user/page/home_user_page.dart';
import 'package:smart_cane/features/presentation/login/page/login_page.dart';
import 'package:smart_cane/features/presentation/register/page/register_page.dart';
import 'package:smart_cane/features/presentation/splash/page/splash_page.dart';
import 'package:smart_cane/routes/app_routes.dart';

part 'app_pages.gr.dart';

@singleton
@AutoRouterConfig()
class AppPages extends _$AppPages {
  @override
  RouteType get defaultRouteType => const RouteType.material();
  @override
  List<AutoRoute> routes = [
    AutoRoute(path: AppRoutes.initial, page: SplashRoute.page),
    AutoRoute(path: AppRoutes.login, page: LoginRoute.page),
    AutoRoute(path: AppRoutes.register, page: RegisterRoute.page),
    AutoRoute(
      path: AppRoutes.homeAdmin,
      page: HomeAdminRoute.page,
    ),
    AutoRoute(
      path: AppRoutes.homeUser,
      page: HomeUserRoute.page,
    ),
  ];
}
