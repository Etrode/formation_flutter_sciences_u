import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:my_app/app/modules/scan/data/repository/scan_repository.dart';

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  //controlleur de la camera ( nous permet d'appeler des méthodes ( takePicture))
  CameraController? controller;

  // liste des cameras dans le device
  List<CameraDescription> cameras = [];

  //type de variable permettant de sauvegarder les données d'un image capturée
  XFile? capturedImage;

  List<XFile> capturedImagesList = [];

  // Repository cache
  ScanRepository scanRepository = ScanRepository();

  // Last scan
  String last_scan_stored_result = '';

  //fonction appelée à la création d'un statefulWidget
  @override
  void initState() {
    super.initState();
    loadCameras();
  }

  saveToCache() async {
    scanRepository.saveScan(last_scan_stored_result);
    setState(() {});
  }

  retrieveFromCache() async {
    last_scan_stored_result = (await scanRepository.retrieveScan()) ?? '';
    setState(() {});
  }

  loadCameras() async {
    cameras = await availableCameras();

    if (cameras.length > 0) {
      print(cameras);

      controller = CameraController(cameras[0], ResolutionPreset.low);
      controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  capturePicture() async {
    if (!controller!.value.isTakingPicture) {
      capturedImage = await controller!.takePicture();
      print(capturedImage);
      last_scan_stored_result = capturedImage!.path;
      addPictureToList();
      saveToCache();
      setState(() {});
    }
  }

  addPictureToList() {
    //add new captured image to the list (capturedImagesList)
    if (capturedImage != null) {
      capturedImagesList.add(capturedImage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: controller == null
          ? Container()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(50),
                child: Column(
                  children: [
                    Card(child: CameraPreview(controller!)),
                    OutlinedButton(
                      onPressed: () {
                        capturePicture();
                      },
                      child: Text('capturer une image'),
                    ),
                    capturedImage == null
                        ? Container()
                        : GridView.count(
                            shrinkWrap: true,
                            primary: false,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            crossAxisCount: 3,
                            children: capturedImagesList
                                .map((e) => Container(
                                      child: Image.file(File(e.path)),
                                    ))
                                .toList())
                  ],
                ),
              ),
            ),
    );
  }
}
