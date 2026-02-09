import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Image capture service for skin and anemia screening
class ImageService {
  final ImagePicker _picker = ImagePicker();
  
  /// Capture image from camera
  Future<String?> captureImage({
    required ImageCategory category,
    double quality = 85,
  }) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: quality.round(),
        preferredCameraDevice: CameraDevice.rear,
      );
      
      if (photo == null) return null;
      
      // Save to app directory with category folder
      final directory = await getApplicationDocumentsDirectory();
      final categoryFolder = category.folderName;
      final fileName = '${category.prefix}_${const Uuid().v4()}.jpg';
      final targetPath = '${directory.path}/$categoryFolder/$fileName';
      
      // Create category directory if not exists
      final categoryDir = Directory('${directory.path}/$categoryFolder');
      if (!await categoryDir.exists()) {
        await categoryDir.create(recursive: true);
      }
      
      // Copy image to target path
      final savedFile = await File(photo.path).copy(targetPath);
      return savedFile.path;
    } catch (e) {
      return null;
    }
  }
  
  /// Pick image from gallery (for testing)
  Future<String?> pickFromGallery({
    required ImageCategory category,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (image == null) return null;
      
      final directory = await getApplicationDocumentsDirectory();
      final categoryFolder = category.folderName;
      final fileName = '${category.prefix}_${const Uuid().v4()}.jpg';
      final targetPath = '${directory.path}/$categoryFolder/$fileName';
      
      final categoryDir = Directory('${directory.path}/$categoryFolder');
      if (!await categoryDir.exists()) {
        await categoryDir.create(recursive: true);
      }
      
      final savedFile = await File(image.path).copy(targetPath);
      return savedFile.path;
    } catch (e) {
      return null;
    }
  }
  
  /// Delete an image file
  Future<void> deleteImage(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignore errors
    }
  }
}

/// Image category for organized storage
enum ImageCategory {
  skin,
  anemia,
  other,
}

extension ImageCategoryExtension on ImageCategory {
  String get folderName {
    switch (this) {
      case ImageCategory.skin:
        return 'skin_images';
      case ImageCategory.anemia:
        return 'anemia_images';
      case ImageCategory.other:
        return 'other_images';
    }
  }
  
  String get prefix {
    switch (this) {
      case ImageCategory.skin:
        return 'skin';
      case ImageCategory.anemia:
        return 'anemia';
      case ImageCategory.other:
        return 'img';
    }
  }
}
