import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class TeModel {
  final String id;
  final String sabor;
  final int cantidad;

  TeModel({required this.id, required this.sabor, required this.cantidad});

  factory TeModel.fromJson(Map<String, dynamic> json) {
    return TeModel(
      id: json['id'],
      sabor: json['sabor'],
      cantidad: json['cantidad'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'sabor': sabor, 'cantidad': cantidad};
  }

  List<TeModel> parseTes(String jsonStr) {
    final List<dynamic> jsonList = json.decode(jsonStr);
    return jsonList.map((json) => TeModel.fromJson(json)).toList();
  }

  Future<void> saveTes(List<TeModel> tes) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonStr = json.encode(tes.map((te) => te.toJson()).toList());
    await prefs.setString('tes', jsonStr);
  }

  Future<List<TeModel>> loadTes() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonStr = prefs.getString('tes');
    if (jsonStr != null) {
      return parseTes(jsonStr);
    } else {
      return [];
    }
  }

  Future<void> addTe(String sabor, int cantidad) async {
    if (sabor.isEmpty || cantidad <= 0) {
      throw ArgumentError('Los campos no pueden estar vacios.');
    }

    TeModel nuevoTe = TeModel(
      id: Uuid().v4(),
      sabor: sabor,
      cantidad: cantidad,
    );

    List<TeModel> tes = await loadTes();
    tes.add(nuevoTe);
    await saveTes(tes);
  }

  Future<void> deleteTe(String id) async {
    List<TeModel> tes = await loadTes();
    tes.removeWhere((te) => te.id == id);
    await saveTes(tes);
  }

  Future<void> updateTe(String id, String sabor, int cantidad) async {
    List<TeModel> tes = await loadTes();
    int index = tes.indexWhere((te) => te.id == id);
    if (index != -1) {
      tes[index] = TeModel(id: id, sabor: sabor, cantidad: cantidad);
      await saveTes(tes);
    }
  }

  Future<void> sumOneTe(String id) async {
    List<TeModel> tes = await loadTes();
    int index = tes.indexWhere((te) => te.id == id);
    if (index != -1) {
      TeModel te = tes[index];
      tes[index] = TeModel(
        id: te.id,
        sabor: te.sabor,
        cantidad: te.cantidad + 1,
      );
      await saveTes(tes);
    }
  }

  Future<void> restOneTe(String id) async {
    List<TeModel> tes = await loadTes();
    int index = tes.indexWhere((te) => te.id == id);
    if (index != -1) {
      TeModel te = tes[index];
      if (te.cantidad > 0) {
        tes[index] = TeModel(
          id: te.id,
          sabor: te.sabor,
          cantidad: te.cantidad - 1,
        );
        await saveTes(tes);
      } else {
        throw Exception('Ya no hay más bolsas de té para restar.');
      }
    }
  }

  Future<void> importTes() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );
      if (result == null) {
        throw Exception('No se seleccionó ningún archivo.');
      } else {
        final file = result.files.first;
        if (file.extension?.toLowerCase() != 'json') {
          throw Exception('El archivo seleccionado no es un archivo JSON.');
        }
        final fileBytes = result.files.single.bytes;
        String contenido;
        if (fileBytes == null) {
          final path = result.files.first.path!;
          contenido = await File(path).readAsString();
        } else {
          contenido = utf8.decode(fileBytes);
        }

        if (contenido.isEmpty) {
          throw Exception('El archivo está vacío.');
        } else {
          List<TeModel> listaTes = parseTes(contenido);
          await saveTes(listaTes);
        }
      }
    } catch (e) {
      throw Exception('Error al importar los datos: $e');
    }
  }

  Future<void> descargarTes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? jsonStr = prefs.getString('tes');

      if (jsonStr == null || jsonStr.isEmpty) {
        throw Exception('No hay datos para descargar.');
      } else {
        final directory =
            Platform.isAndroid
                ? Directory('/storage/emulated/0/Download')
                : await getApplicationDocumentsDirectory();

        final file = File('${directory.path}/mis_tes.json');
        await file.writeAsString(jsonStr);
      }
    } catch (e) {
      throw Exception('Error al descargar los datos: $e');
    }
  }

  Future<void> eliminarTodosTes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tes');
  }
}
