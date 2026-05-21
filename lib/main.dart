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
      theme: ThemeData.dark(), // Utiliza el tema oscuro por defecto
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

  @override
  void initState() {
    super.initState();
    teModel = TeModel(id: "", sabor: '', cantidad: 0);
  }

  Future<void> _refreshTes() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cantidad de bolsas de té')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: teModel.loadTes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No hay datos disponibles'));
                } else {
                  List<TeModel> tes = snapshot.data!;
                  return ListView.builder(
                    itemCount: tes.length,
                    itemBuilder: (context, index) {
                      final te = tes[index];
                      return TeCard(
                        id: te.id,
                        sabor: te.sabor,
                        cantidad: te.cantidad,
                        onDelete: () async {
                          await teModel.deleteTe(te.id);
                          await _refreshTes();

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Té eliminado')),
                          );
                        },
                        onEdit: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditarTe(te: te),
                            ),
                          );
                          _refreshTes();
                        },
                        onSumOne: () async {
                          await teModel.sumOneTe(te.id);
                          _refreshTes();
                        },
                        onRestOne: () async {
                          await teModel.restOneTe(te.id);
                          _refreshTes();
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      teModel.importTes().then((_) => _refreshTes()).catchError(
                        (e) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('$e')));
                        },
                      );
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
                                  'Datos descargados correctamente en la carpeta de descargas',
                                ),
                              ),
                            );
                            _refreshTes();
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
                      teModel.eliminarTodosTes().then((_) => _refreshTes());
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
              _refreshTes();
            },
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
