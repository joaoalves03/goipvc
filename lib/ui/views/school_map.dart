import 'package:flutter/material.dart';
import 'package:goipvc/ui/views/coming_soon.dart';

class SchoolMapView extends StatelessWidget {
  const SchoolMapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Plantas"),
      ),
      body: const ComingSoonView(),
    );
  }
}