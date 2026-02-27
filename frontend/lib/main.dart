import 'package:flutter/material.dart';
import 'package:frontend/bloc/user_data/user_data_bloc.dart';
import 'package:frontend/bloc/user_data/user_data_event.dart';
import 'package:frontend/configurations/routes/app_routes.dart';

void main() {
  UserDataBloc.instance.add(LoadUserData());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feel Chat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.initialRoute,
      routes: AppRoutes.routes,
    );
  }
}
