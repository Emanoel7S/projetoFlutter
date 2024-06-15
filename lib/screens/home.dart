
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ImagePicker _picker = ImagePicker();
  List<File> _images = [];
  late String _path;
  bool _isCreatingPdf = false;
  XFile? _pickedFile;
  CroppedFile? _croppedFile;

  @override
  void initState() {
    super.initState();
    _path = '';
    preferecnias();

    _requestPermissions();
  }
  // Future<void> _pickAndCropImage() async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  //
  //   if (pickedFile != null) {
  //     CroppedFile? croppedFile = await ImageCropper().cropImage(
  //       sourcePath: pickedFile.path,
  //
  //       aspectRatioPresets: [
  //
  //         CropAspectRatioPreset.square,
  //         CropAspectRatioPreset.ratio3x2,
  //         CropAspectRatioPreset.original,
  //         CropAspectRatioPreset.ratio4x3,
  //         CropAspectRatioPreset.ratio16x9
  //       ],
  //
  //
  //     );
  //
  //     if (croppedFile != null) {
  //       // Faça algo com a imagem cortada, como exibição ou salvamento
  //       // Neste exemplo, apenas imprimimos o caminho da imagem
  //       print('Caminho da imagem cortada: ${croppedFile.path}');
  //     }
  //   }
  // }

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.manageExternalStorage,
    ].request();
  }

  Future<void> _pickImage() async {
    try{
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);

      setState(() {
        if (pickedFile != null) {
          _pickedFile = pickedFile;
          // _images.add(File(pickedFile.path));
        } else {
          return;
        }
      });
      // print('print nao chega  se for null');
      await _cropImage();

    }catch(e){
      print('erro ao tirar foto $e');
    }


  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _createPdf() async {
    try {
      if (_images.isEmpty || _isCreatingPdf) return;

      setState(() {
        _isCreatingPdf = true;
      });

      final pdf = pw.Document();

      for (var imageFile in _images) {
        final image = pw.MemoryImage(imageFile.readAsBytesSync());

        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(image),
              );
            },
          ),
        );
      }

      final directory = await getDownloadsDirectory();
      final file = File('${directory?.path}/document.pdf');
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF salvo em ${file.path}')),
      );

      setState(() {
        _path = file.path;
        _isCreatingPdf = false;
      });
      print("Caminho do arquivo PDF: ${file.path}"); // Adicionado para imprimir o caminho do arquivo PDF
      await file.writeAsBytes(await pdf.save());
    } catch (e) {
      print(e);
    }
  }




  Future<void> _openPdf(String path) async {
    if (path.isEmpty) {
      if(!mounted) return; // nao faz nada quase contexto nao esdteja montado
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum PDF disponível para abrir.')),
      );
      return;
    }

    final result = await OpenFile.open(path);
    if (result.type != ResultType.done) {
      if(!mounted) return; // nao faz nada quase contexto nao esdteja montado

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao abrir o PDF: ${result.message}')),
      );
    }
  }
  Future<void> _cropImage() async {
    if (_pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _pickedFile!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,

          ),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          _images.add(File(croppedFile.path));
          _pickedFile=null;
          _croppedFile = croppedFile;

        });
      }
    }
  }
  Future<void> _uploadImage() async {
    try{
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
      });
      await _cropImage();


    }}catch(e){
      print('erro ao selecionar imagem $e');
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
            _images.isEmpty
                ? GestureDetector(
              onTap: _pickImage,

              child: const Text('+',style: TextStyle(fontSize: 40),),
            )
                : SizedBox(
              height: 120,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _images
                      .asMap()
                      .entries
                      .map(
                        (entry) => Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          Image.file(entry.value),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _removeImage(entry.key),
                              child: Container(
                                padding: EdgeInsets.all(4),
                                color: Colors.red,
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadImage,
              child: const Text('Selecionar fotos'),
            ),ElevatedButton(
              onPressed: _pickImage,
              child: const Text('tirar foto'),
            ),

            Visibility(
              visible: _images.isNotEmpty,
              child: ElevatedButton(
                onPressed: _createPdf,
                child: _isCreatingPdf
                    ? const CircularProgressIndicator() // Feedback visual de criação
                    : const Text('Criar PDF'),
              ),
            ),
            // ElevatedButton(
            //   onPressed: _cropImage ,
            //   child: _isCreatingPdf
            //       ? CircularProgressIndicator() // Feedback visual de criação
            //       : const Text('teste'),
            // ),
            ElevatedButton(
              onPressed: () {
                _openPdf(_path);
              },
              child: const Text('Abrir PDF'),
            ),
          ],
        ),
      ),
    );
  }

  void preferecnias() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.getString('email'));
    print(prefs.getString('password'));
  }
}

