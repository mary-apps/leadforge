import 'package:flutter/material.dart';
import '../../widgets/empty_state.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: EmptyState.noMessages(),
    );
  }
}
