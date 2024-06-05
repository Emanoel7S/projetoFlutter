import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  late String _path;

  @override
  void initState() {
    super.initState();
    _path = ''; // Inicializa _path com uma string vazia
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Solicita permissão para câmera e armazenamento externo
    await [
      Permission.camera,
      Permission.manageExternalStorage,
    ].request();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('Nenhuma imagem selecionada.');
      }
    });
  }

  Future<void> _createPdf() async {
    if (_image == null) return;

    final pdf = pw.Document();
    final image = pw.MemoryImage(_image!.readAsBytesSync());

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image),
          ); // Center
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    print("Diretório do documento: ${directory.path}"); // Adicionado para imprimir o diretório

    final file = File('${directory.path}/document.pdf');
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF salvo em ${file.path}')),
    );
    setState(() {
      _path = file.path;
    });

    // Abrir ou compartilhar o PDF
  }

  Future<void> _openPdf(String path) async {
    if (path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nenhum PDF disponível para abrir.')),
      );
      return;
    }

    final result = await OpenFile.open(path);
    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao abrir o PDF: ${result.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Scanner App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null
                ? Text('Nenhuma imagem selecionada.')
                : Image.file(_image!),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Capturar Foto'),
            ),
            ElevatedButton(
              onPressed: _createPdf,
              child: Text('Criar PDF'),
            ),
            ElevatedButton(
              onPressed: () {
                _openPdf(_path);
              },
              child: Text('Abrir PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
