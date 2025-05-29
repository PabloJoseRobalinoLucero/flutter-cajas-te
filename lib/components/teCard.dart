import 'package:flutter/material.dart';

class TeCard extends StatelessWidget {
  final String id;
  final String sabor;
  final int cantidad;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TeCard({
    super.key,
    required this.id,
    required this.sabor,
    required this.cantidad,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      margin: EdgeInsets.all(10.0),
      color: cantidad > 5 ? Color(0xFF1B5E20) : Color(0xffd32f2f),
      child: Padding(
        padding: EdgeInsets.all(5.0),
        child: Column(
          children: [
            Title(
              color: Theme.of(context).primaryColor,
              child: Text(
                sabor,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Text('Cantidad: $cantidad'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(onPressed: onEdit, icon: Icon(Icons.edit)),
                IconButton(onPressed: onDelete, icon: Icon(Icons.delete)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
