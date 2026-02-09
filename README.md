# 🌍 Aasha.AI - Offline Multi-Disease AI Health Screening Platform

<div align="center">

![Aasha.AI Logo](assets/images/logo.png)

**Empowering ASHA Workers with AI-Powered Health Screening**

*Offline-First • Multi-Disease • Rural India*

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev)
[![TensorFlow Lite](https://img.shields.io/badge/TFLite-Offline%20AI-orange.svg)](https://www.tensorflow.org/lite)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

</div>

---

## 🎯 Problem Statement

Rural India faces critical healthcare challenges:
- **Doctor Shortage**: 1 doctor per 10,000+ people in villages
- **Poor Connectivity**: Limited internet access for telemedicine
- **Late Diagnosis**: Preventable diseases detected too late
- **High Costs**: Expensive diagnostic tests unavailable locally

## 💡 Our Solution

**Aasha.AI** brings AI-powered health screening directly to villages through ASHA workers' smartphones:

- ✅ **Works 100% Offline** - No internet required
- ✅ **Multi-Disease Screening** - TB, Skin, Anemia, Maternal Health
- ✅ **Instant Results** - AI analysis in seconds
- ✅ **Smart Referrals** - Nearest PHC recommendations
- ✅ **Patient Records** - Offline-first with cloud sync

---

## 🏥 Screening Modules

| Module | Input | AI Model | Risk Detection |
|--------|-------|----------|----------------|
| **TB Screening** | 🎤 Cough Audio | Audio Classification | TB risk indicators |
| **Skin Disease** | 📷 Photo | Image Classification | Fungal, Eczema, Ringworm |
| **Anemia Check** | 📷 Palm/Eye Photo | Pallor Analysis | Hemoglobin estimation |
| **Maternal Health** | 📋 Questionnaire | Risk Scoring | Pregnancy danger signs |
| **Symptom Triage** | 📋 Symptoms List | Urgency Scoring | Care urgency level |

---

## 🚀 Quick Start

### Prerequisites

- Flutter 3.0+ installed
- Android Studio / VS Code
- Android device or emulator

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/aasha-ai.git
cd aasha-ai

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Build APK

```bash
flutter build apk --release
```

---

## 📱 App Flow

```
Splash Screen
     │
     ▼
ASHA Dashboard
     │
     ├── New Screening ──► Patient Registration ──► Select Module
     │                                                   │
     │                    ┌──────────────────────────────┼──────────────────────────────┐
     │                    │                              │                              │
     │                    ▼                              ▼                              ▼
     │               TB Module                    Skin Module                   Anemia Module
     │            (Record Cough)              (Capture Photo)              (Capture Palm/Eye)
     │                    │                              │                              │
     │                    └──────────────┬───────────────┘                              │
     │                                   ▼                                              │
     │                          AI Processing ◄─────────────────────────────────────────┘
     │                                   │
     │                                   ▼
     │                           Result Screen
     │                      (Risk + Recommendation)
     │                                   │
     │                                   ▼
     │                          Nearest PHC Map
     │
     └── Patient History ──► Filter by Risk ──► View Past Results
```

---

## 🏗️ Project Structure

```
aasha_ai/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── models/
│   │   ├── patient.dart             # Patient data model
│   │   └── screening_result.dart    # Screening result model
│   ├── screens/
│   │   ├── splash_screen.dart       # Animated splash
│   │   ├── login_screen.dart        # ASHA worker login
│   │   ├── home_screen.dart         # Dashboard with modules
│   │   ├── patient_registration_screen.dart
│   │   ├── cough_recording_screen.dart
│   │   ├── skin_scan_screen.dart
│   │   ├── anemia_scan_screen.dart
│   │   ├── maternal_health_screen.dart
│   │   ├── symptom_triage_screen.dart
│   │   ├── ai_processing_screen.dart
│   │   ├── result_screen.dart
│   │   └── patient_history_screen.dart
│   ├── services/
│   │   ├── storage_service.dart     # Hive local database
│   │   ├── tflite_service.dart      # AI inference
│   │   ├── audio_service.dart       # Audio recording
│   │   ├── image_service.dart       # Camera capture
│   │   └── location_service.dart    # PHC finder
│   ├── widgets/
│   │   ├── risk_indicator.dart      # Risk level badges
│   │   ├── module_card.dart         # Dashboard cards
│   │   ├── patient_card.dart        # Patient list items
│   │   ├── action_button.dart       # CTA buttons
│   │   └── symptom_checkbox.dart    # Touch-friendly checkboxes
│   └── utils/
│       ├── constants.dart           # Colors, styles, config
│       └── routes.dart              # Navigation routes
├── assets/
│   ├── models/                      # TFLite model files
│   ├── icons/                       # App icons
│   └── images/                      # Logos and illustrations
└── README.md
```

---

## 🧠 AI Models

The app uses TensorFlow Lite for offline inference:

| Model | Size | Input | Output |
|-------|------|-------|--------|
| TB Cough | ~2MB | Audio spectrogram | Risk probability |
| Skin Disease | ~3MB | 224x224 image | Disease class + confidence |
| Anemia | ~2MB | 224x224 palm/eye | Pallor level |
| Maternal Risk | ~500KB | Feature vector | Risk score |

### Model Placement

Place your trained `.tflite` models in:
```
assets/models/
├── tb_cough.tflite
├── skin_disease.tflite
├── anemia_screen.tflite
└── maternal_risk.tflite
```

> **Note**: The app includes mock predictions for demo purposes. Replace with real models for production.

---

## 🔧 Key Technologies

- **Flutter** - Cross-platform mobile framework
- **TensorFlow Lite** - On-device ML inference
- **Hive** - Fast, lightweight local database
- **Firebase** - Optional cloud sync (when online)
- **Geolocator** - GPS for nearest PHC

---

## 🌐 Offline-First Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      ASHA Worker Device                      │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Flutter   │  │   TFLite    │  │     Hive DB         │  │
│  │     UI      │◄─┤   Models    │  │  (Patients, Results)│  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
│         │                                    │               │
│         └────────────────┬───────────────────┘               │
│                          │                                   │
│                    ┌─────▼─────┐                             │
│                    │   Sync    │                             │
│                    │  Service  │                             │
│                    └─────┬─────┘                             │
└──────────────────────────┼───────────────────────────────────┘
                           │ When Online
                    ┌──────▼──────┐
                    │  Firebase   │
                    │  Firestore  │
                    └─────────────┘
```

---

## 📋 Permissions Required

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

---

## 🎨 Design Principles

1. **Rural-Friendly UI** - Large buttons, high contrast, simple navigation
2. **Minimal Text** - Icon-based interface, easy for low-literacy users
3. **Multi-Language Ready** - String resources extracted for i18n
4. **Low Resource** - Optimized for low-end Android devices

---

## 🏆 Hackathon Features

- ✅ Complete multi-disease screening platform
- ✅ Offline AI inference
- ✅ Animated recording with waveform
- ✅ Step-by-step AI processing visualization
- ✅ Color-coded risk levels
- ✅ Nearest PHC with maps integration
- ✅ Patient history with filters
- ✅ Premium UI with gradients and animations

---

## 🔮 Future Roadmap

- [ ] Hindi/Odia voice guidance
- [ ] Emergency SMS alerts
- [ ] High-risk zone heatmap
- [ ] Government PHC API integration
- [ ] Diabetes screening module
- [ ] Eye disease detection
- [ ] Dental health screening

---

## 👥 Team

Built with ❤️ for rural India

---

## 📄 License

MIT License - See [LICENSE](LICENSE) for details

---

<div align="center">

**🌟 Star this repo if Aasha.AI helps rural healthcare! 🌟**

</div>
