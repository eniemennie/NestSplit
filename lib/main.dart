import 'package:flutter/material.dart';
import 'app.dart';
import 'data/repositories/mock_app_repository.dart';
import 'state/app_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final services = AppServices(MockAppRepository());
  await services.loadAll();
  runApp(NestSplitApp(services: services));
   }