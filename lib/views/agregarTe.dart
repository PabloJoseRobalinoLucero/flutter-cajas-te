import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/teModel.dart';

class AgregarTe extends StatefulWidget {
  const AgregarTe({super.key});

  @override
  _AgregarTeState createState() => _AgregarTeState();
}

class _AgregarTeState extends State<AgregarTe> {
  final TextEditingController _saborController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();

  @override
  void dispose() {
    _saborController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }

  Future<void> _agregarTe() async {
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
        await nuevoTe.addTe(sabor, cantidad);

        _saborController.clear();
        _cantidadController.clear();

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Té agregado con éxito')));
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error al agregar el té: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agregar Té')),
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
                  onPressed: _agregarTe,
                  child: Text('Agregar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
