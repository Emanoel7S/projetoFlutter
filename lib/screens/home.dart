

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
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

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.manageExternalStorage,
    ].request();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);

      setState(() {
        if (pickedFile != null) {
          _pickedFile = pickedFile;
        } else {
          return;
        }
      });
      await _cropImage();
    } catch (e) {
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
      await file.writeAsBytes(await pdf.save());
    } catch (e) {
      print(e);
    }
  }

  Future<void> _openPdf(String path) async {
    if (path.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum PDF disponível para abrir.')),
      );
      return;
    }

    final result = await OpenFile.open(path);
    if (result.type != ResultType.done) {
      if (!mounted) return;
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
            toolbarColor: Colors.blueAccent,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          _images.add(File(croppedFile.path));
          _pickedFile = null;
          _croppedFile = croppedFile;
        });
      }
    }
  }

  Future<void> _uploadImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _pickedFile = pickedFile;
        });
        await _cropImage();
      }
    } catch (e) {
      print('erro ao selecionar imagem $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Scanner App'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: _images.isEmpty
                    ? GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_a_photo,
                      size: 50,
                      color: Colors.blueAccent,
                    ),
                  ),
                )
                    : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _images
                        .asMap()
                        .entries
                        .map(
                          (entry) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Stack(
                          children: [
                            Image.file(
                              entry.value,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _removeImage(entry.key),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  color: Colors.red,
                                  child: const Icon(
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
              ElevatedButton.icon(
                onPressed: _uploadImage,
                icon: const Icon(Icons.photo_library),
                label: const Text('Selecionar fotos'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Tirar foto'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _images.isNotEmpty ? _createPdf : null,
                icon: _isCreatingPdf
                    ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                    : const Icon(Icons.picture_as_pdf),
                label: const Text('Criar PDF'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  _openPdf(_path);
                },
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Abrir PDF'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              // SpeedDial(
              //
              //
              //
              //   animatedIcon: AnimatedIcons.menu_close, // ícone animado
              //   children: [
              //     SpeedDialChild(
              //         foregroundColor:Colors.blueAccent,
              //         child: Icon(Icons.add_a_photo), // ícone para o botão adicional
              //         label: 'Capturar foto', // etiqueta opcional
              //         onTap: () async{
              //           await _pickImage();
              //           // Ação para o botão adicional
              //         }
              //     ),
              //
              //     SpeedDialChild(
              //         foregroundColor: Colors.blueAccent,
              //         child: Icon(Icons.photo_library), // ícone para o botão acima
              //         label: 'Selecionar fotos', // etiqueta opcional
              //         onTap: () async{
              //           await _uploadImage();
              //           // Ação para o botão acima
              //         }
              //     ),
              //   ],
              // ),


            ],
          ),
        ),
      ),
    );
  }

  void preferecnias() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.getString('email'));
    print(prefs.getString('password'));
  }
}
