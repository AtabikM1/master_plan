// lib/main.dart

import 'package:flutter/material.dart';
import './provider/plan_provider.dart';
import './models/data_layer.dart';
import './views/plan_creator_screen.dart'; // Screen baru

void main() => runApp(const MasterPlanApp());

class MasterPlanApp extends StatelessWidget {
  const MasterPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Diedit sesuai Langkah 2
    return PlanProvider(
      notifier: ValueNotifier<List<Plan>>(const []),
      child: MaterialApp(
        title: 'State management app',
        theme: ThemeData(primarySwatch: Colors.blue),
        // Diedit sesuai Langkah 9
        home: const PlanCreatorScreen(),
      ),
    );
  }
}
