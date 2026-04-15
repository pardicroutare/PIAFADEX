import 'package:flutter/material.dart';

import '../features/analysis/analysis_loading_screen.dart';
import '../features/capture/capture_screen.dart';
import '../features/home/home_screen.dart';
import '../features/result/result_screen.dart';
import '../features/settings/settings_screen.dart';

class AnalysisLoadingArgs {
  const AnalysisLoadingArgs({required this.imagePath});

  final String imagePath;
}

class ResultArgs {
  const ResultArgs({
    required this.imagePath,
    required this.payload,
  });

  final String imagePath;
  final Map<String, dynamic> payload;
}

class PiafadexRouter {
  static const home = '/';
  static const settings = '/settings';
  static const capture = '/capture';
  static const analysisLoading = '/analysis-loading';
  static const result = '/result';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case PiafadexRouter.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case PiafadexRouter.capture:
        return MaterialPageRoute(builder: (_) => const CaptureScreen());
      case PiafadexRouter.analysisLoading:
        final args = settings.arguments;
        if (args is! AnalysisLoadingArgs) {
          return _errorRoute('Arguments invalides pour analysis-loading.');
        }
        return MaterialPageRoute(builder: (_) => AnalysisLoadingScreen(args: args));
      case PiafadexRouter.result:
        final args = settings.arguments;
        if (args is! ResultArgs) {
          return _errorRoute('Arguments invalides pour result.');
        }
        return MaterialPageRoute(builder: (_) => ResultScreen(args: args));
      case PiafadexRouter.home:
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }

  static MaterialPageRoute<void> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Erreur de navigation')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(message),
        ),
      ),
    );
  }
}
