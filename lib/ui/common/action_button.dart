import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ActionButton extends StatefulWidget {
  final AsyncCallback onClick;
  final VoidCallback? onComplete;
  final Widget child;
  const ActionButton({super.key, required this.onClick, this.onComplete, required this.child});

  @override
  State<StatefulWidget> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool isRunning = false;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () async {
      setState(() {
        isRunning = true;
      });
      await widget.onClick();
      setState(() {
        isRunning = false;
      });
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    }, child: isRunning ? SizedBox(height: 20, width: 20, child: const CircularProgressIndicator()) : widget.child);
  }
}