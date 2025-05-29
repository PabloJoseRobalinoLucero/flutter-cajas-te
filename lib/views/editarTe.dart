import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/teModel.dart';

class EditarTe extends StatefulWidget {
  final TeModel te;

  const EditarTe({super.key, required this.te});

  @override
  State<EditarTe> createState() => _EditarTeState();
}

class _EditarTeState extends State<EditarTe> {
  late TextEditingController _saborController;
  late TextEditingController _cantidadController;

  @override
  void initState() {
    super.initState();
    _saborController = TextEditingController(text: widget.te.sabor);
    _cantidadController = TextEditingController(
      text: widget.te.cantidad.toString(),
    );
  }

  @override
  void dispose() {
    _saborController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }

  Future<void> _editarTe() async {
    String sabor = _saborController.text.trim();
    int cantidad = int.tryParse(_cantidadController.text.trim()) ?? 0;

    if (sabor.isEmpty || cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, ingrese un sabor y una cantidad válida.'),
        ),
      );
    } else {
      TeModel nuevoTe = TeModel(id: "", sabor: sabor, cantidad: cantidad);

      try {
        await nuevoTe.updateTe(widget.te.id, sabor, cantidad);
        _saborController.clear();
        _cantidadController.clear();

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Té actualizado con éxito')));
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar el té: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Actualizar Té')),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: _saborController,
                decoration: InputDecoration(
                  labelText: 'Sabor',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: _cantidadController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Cantidad',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _editarTe,
                  child: Text('Actualizar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
