import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  Future<String> extractText(File image) async {
    final inputImage = InputImage.fromFile(image);

    final RecognizedText recognizedText =
        await _textRecognizer.processImage(inputImage);

    return recognizedText.text;
  }

  Future<void> dispose() async {
    await _textRecognizer.close();
  }
}