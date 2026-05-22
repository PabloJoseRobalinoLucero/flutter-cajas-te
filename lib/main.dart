import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'components/teCard.dart';
import 'models/teModel.dart';
import 'views/agregarTe.dart';
import 'views/editarTe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _requestPermissions();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(MyApp());
}

Future<void> _requestPermissions() async {
  if (await Permission.storage.isDenied) {
    await Permission.storage.request();
  }

  if (await Permission.manageExternalStorage.isDenied) {
    await Permission.manageExternalStorage.request();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cajas de Té App',
      theme: ThemeData.dark(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TeModel teModel;
  List<TeModel> _listaTes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    teModel = TeModel(id: "", sabor: '', cantidad: 0);
    _cargarDatosIniciales();
  }

  // Carga los datos desde SharedPreferences solo al iniciar la app
  Future<void> _cargarDatosIniciales() async {
    try {
      final datos = await teModel.loadTes();
      setState(() {
        _listaTes = datos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cantidad de bolsas de té')),
      body: Column(
        children: [
          Expanded(child: _buildBody()),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      teModel
                          .importTes()
                          .then((_) => _cargarDatosIniciales())
                          .catchError((e) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text('$e')));
                          });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.attach_file),
                        SizedBox(width: 10),
                        Text('Subir Datos'),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      teModel
                          .descargarTes()
                          .then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Datos descargados correctamente',
                                ),
                              ),
                            );
                          })
                          .catchError((e) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text('$e')));
                          });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.download),
                        SizedBox(width: 10),
                        Text('Descargar Datos'),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      teModel.eliminarTodosTes().then((_) {
                        setState(() {
                          _listaTes.clear();
                        });
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete),
                        SizedBox(width: 10),
                        Text('Eliminar Datos'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 150.0),
          child: FloatingActionButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AgregarTe()),
              );
              _cargarDatosIniciales(); // Recarga si se añade uno nuevo
            },
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(child: Text('Error: $_errorMessage'));
    }
    if (_listaTes.isEmpty) {
      return Center(child: Text('No hay datos disponibles'));
    }

    return ListView.builder(
      itemCount: _listaTes.length,
      itemBuilder: (context, index) {
        final te = _listaTes[index];
        return TeCard(
          id: te.id,
          sabor: te.sabor,
          cantidad: te.cantidad,
          onDelete: () async {
            await teModel.deleteTe(te.id);
            setState(() {
              _listaTes.removeAt(index);
            });
            if (!mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Té eliminado')));
          },
          onEdit: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EditarTe(te: te)),
            );
            _cargarDatosIniciales();
          },
          onSumOne: () async {
            await teModel.sumOneTe(te.id);
            setState(() {
              _listaTes[index] = TeModel(
                id: te.id,
                sabor: te.sabor,
                cantidad: te.cantidad + 1,
              );
            });
          },
          onRestOne: () async {
            if (te.cantidad > 0) {
              await teModel.restOneTe(te.id);
              setState(() {
                _listaTes[index] = TeModel(
                  id: te.id,
                  sabor: te.sabor,
                  cantidad: te.cantidad - 1,
                );
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ya no hay más bolsas de té para restar.'),
                ),
              );
            }
          },
        );
      },
    );
  }
}
