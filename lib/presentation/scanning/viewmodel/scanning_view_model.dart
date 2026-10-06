import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final scanningViewModelProvider = ChangeNotifierProvider<ScanningViewModel>((ref) {
  return ScanningViewModel();
});

class ScanningViewModel extends ChangeNotifier{
  XFile? _image;
  XFile? get image => _image;

  void setImage(XFile? image) {
    _image = image;
    notifyListeners();
  }

  void clearImage() {
    _image = null;
    notifyListeners();
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? selectedImage = await picker.pickImage(
        source: ImageSource.gallery, 
      );
      setImage(selectedImage);
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image: $e');
      }
    }
  }

  Future<void> takePicture() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? capturedImage = await picker.pickImage(
        source: ImageSource.camera, 
      );
      setImage(capturedImage);
    } catch (e) {
      if (kDebugMode) {
        print('Error taking picture: $e');
      }
    }
  }
}