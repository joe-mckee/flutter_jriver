import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import './settings.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

void main() {
  runApp(const MaterialApp(home: MainApp())); // use MaterialApp
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  var selectedIndex = 0; // ← Add this property.

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const SettingsScreen();
        break;
      case 1:
        page = const BrowseWindow();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return Scaffold(
        body: Row(children: [
      SafeArea(
        child: NavigationRail(
          extended: false,
          destinations: [
            NavigationRailDestination(
                icon: Icon(PlatformIcons(context).settings),
                label: const Text('Settings')),
            NavigationRailDestination(
                icon: Icon(PlatformIcons(context).musicNote),
                label: const Text('Music')),
          ],
          selectedIndex: selectedIndex, // ← Change to this.
          onDestinationSelected: (value) {
            // ↓ Replace print with this.
            setState(() {
              selectedIndex = value;
            });
          },
        ),
      ),
      Expanded(
        child: Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: SafeArea(
            child: page,
          ),
        ),
      )
    ]));
  }
}

class BrowseWindow extends StatelessWidget {
  const BrowseWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FJRAppState(),
      child: MaterialApp(
          title: 'Flutter JRiver Browser',
          theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue)),
          home: const MainScreen()),
    );
  }
}

class FJRAppState extends ChangeNotifier {
  String? serverAddress;
  int? port;
  String? userName;
  String? password;
  String? accessKey;

  void setAccessKey(String? newAccessKey) {
    accessKey = newAccessKey;
    notifyListeners();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Hello World!'),
      ),
    );
  }
}
