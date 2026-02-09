# Placeholder TFLite Model Files

This directory contains placeholder files for TensorFlow Lite models.

## Required Models

For production, replace these with trained models:

1. **tb_cough.tflite** - TB cough classification model
   - Input: Audio spectrogram features
   - Output: TB risk probability

2. **skin_disease.tflite** - Skin disease classifier
   - Input: 224x224 RGB image
   - Output: Disease class probabilities

3. **anemia_screen.tflite** - Anemia pallor detection
   - Input: 224x224 palm/eye image
   - Output: Pallor level score

4. **maternal_risk.tflite** - Maternal risk calculator
   - Input: Feature vector from questionnaire
   - Output: Risk score

## Training Resources

- [TensorFlow Lite Model Training](https://www.tensorflow.org/lite/models/modify/model_maker)
- [Audio Classification](https://www.tensorflow.org/tutorials/audio/simple_audio)
- [Image Classification](https://www.tensorflow.org/tutorials/images/classification)

## Demo Mode

The app includes mock predictions when real models are not available.
This is suitable for hackathon demos and prototyping.
