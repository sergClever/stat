import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;


class ImageAndCameraService extends ChangeNotifier {
  final FirebaseStorage _storage = FirebaseStorage(storageBucket: "stat-41ef7.appspot.com");
   
  File _imageFile;
  StorageUploadTask _uploadTask;
  bool _isProfileUpdated = false;
  String _image;

  bool get isProfileUpdated => _isProfileUpdated;
  String get image => _image;

  // To make isProfileUpdated false again
  void makeFalse() {
    _isProfileUpdated = false;

    notifyListeners();
  }

  // To make isProfileUpdated false again
  void makeTrue() {
    _isProfileUpdated = true;

    notifyListeners();
  }

  // Fire function when camera or gallery is choses
  Future<void> pickImage(ImageSource source) async {
    try {
      File selected = await ImagePicker.pickImage(source: source);
     
      _imageFile = selected;
     
      startUpload();

      notifyListeners();

    } catch (err) {
        return null;
    }
  }

 // Bootstrap the upload for the chosen photo
  Future<void> startUpload() async {
    try {
      String filePath = "profilePhotos/${Path.basename(_imageFile.path)}";
      
      _uploadTask = _storage.ref().child(filePath).putFile(_imageFile);
      
      if (await _uploadTask.onComplete != null) {
        final ref = _storage.ref().child(filePath);
        
        var url = await ref.getDownloadURL();
    
        _isProfileUpdated = !_isProfileUpdated;

        _image = url;

        notifyListeners();

        }
      } catch (err) {
          return null;
      }
    }
  }
