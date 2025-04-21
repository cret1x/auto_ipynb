import 'package:flutter/material.dart';

class ExceptionWidget extends StatelessWidget {
  final Object object;
  final StackTrace trace;

  const ExceptionWidget(this.object, this.trace, {super.key});

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: ExpansionTile(
        title: Text(object.toString()),
        children: [Text(trace.toString(), overflow: TextOverflow.fade,)],
      ),
    );
  }
}
