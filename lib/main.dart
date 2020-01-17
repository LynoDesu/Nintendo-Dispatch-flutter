
import 'package:flutter/material.dart';
import 'package:nintendo_dispatch/models/dispatch_model.dart';
import 'package:nintendo_dispatch/widgets/homepage.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  GlobalKey<AnimatedListState> animatedListKey = GlobalKey<AnimatedListState>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Dispatch Podcast',
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.red,
          backgroundColor: Colors.grey.shade200
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.red,
        ),
        debugShowCheckedModeBanner: false,
        home: ChangeNotifierProvider(
          create: (_) => DispatchModel(animatedListKey),
          child: MyHomePage(title: 'Dispatch Podcast'),
        )
    );
  }
}
