import 'package:flutter/material.dart';

class DeleteButton extends StatelessWidget {
  final VoidCallback onDelete;
  const DeleteButton({super.key, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: () {
      if (true) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Точно удалить?"),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                onPressed: () {
                  onDelete();
                  Navigator.of(context).pop();
                },
                child: const Text('Да'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Нет'),
              ),
            ],
          ),
        );
      }
    }, icon: const Icon(Icons.delete_forever, color: Colors.red,),);
  }
}