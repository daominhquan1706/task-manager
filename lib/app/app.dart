import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/theme/app_theme.dart';
import 'app_bindings.dart';
import 'app_routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.home});

  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'KanbanPro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialBinding: home == null ? AppBindings() : null,
      getPages: AppRoutes.pages,
      initialRoute: home == null ? AppRouteNames.root : null,
      home: home,
      unknownRoute: AppRoutes.unknownRoute,
    );
  }
}
