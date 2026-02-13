# 🏗️ Aasha.AI — Design Document

## 1. System Architecture

Aasha.AI follows an **offline-first** architecture. All AI inference, data storage, and core functionality operate entirely on-device. Cloud connectivity is optional and used only for data backup/sync.

```
┌──────────────────────────────────────────────────────────┐
│                   ASHA Worker Device                     │
├──────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────────┐ │
│  │  Flutter UI  │  │ TFLite Models│  │    Hive DB      │ │
│  │  (Screens &  │◄─┤ (On-device   │  │ (Patients,      │ │
│  │   Widgets)   │  │  Inference)  │  │  Results, Sync) │ │
│  └──────┬───────┘  └──────────────┘  └────────┬────────┘ │
│         │                                      │         │
│         └──────────────┬───────────────────────┘         │
│                   ┌────▼────┐                            │
│                   │  Sync   │                            │
│                   │ Service │                            │
│                   └────┬────┘                            │
└────────────────────────┼─────────────────────────────────┘
                         │ When Online
                  ┌──────▼──────┐
                  │   Firebase  │
                  │  Firestore  │
                  └─────────────┘
```

---

## 2. Tech Stack

| Layer            | Technology                           |
|------------------|--------------------------------------|
| Framework        | Flutter (Dart SDK >=3.0.0)           |
| State Management | Provider                             |
| Local Database   | Hive + Hive Flutter                  |
| AI/ML Engine     | TensorFlow Lite (tflite_flutter)     |
| Cloud Backend    | Firebase (Auth, Firestore) — optional|
| Audio            | Record, Audioplayers                 |
| Camera           | Image Picker                         |
| Location         | Geolocator, Geocoding                |
| Web Demo         | Vanilla HTML / CSS / JavaScript      |
| Web Hosting      | Netlify                              |
| PWA Support      | manifest.json                        |

---

## 3. Project Structure

```
aasha_ai/
├── lib/
│   ├── main.dart                        # App entry point, theme, Provider setup
│   ├── models/
│   │   ├── patient.dart                 # Patient data model (Hive adapter)
│   │   └── screening_result.dart        # Screening result model (Hive adapter)
│   ├── screens/
│   │   ├── splash_screen.dart           # Animated splash with loader
│   │   ├── login_screen.dart            # ASHA worker login (name + phone)
│   │   ├── home_screen.dart             # Dashboard: stats, modules grid, nav
│   │   ├── patient_registration_screen.dart  # New patient form + symptoms
│   │   ├── cough_recording_screen.dart  # TB: audio recording + waveform
│   │   ├── skin_scan_screen.dart        # Skin: camera capture + analysis
│   │   ├── anemia_scan_screen.dart      # Anemia: palm/eye capture + analysis
│   │   ├── maternal_health_screen.dart  # Maternal: danger sign questionnaire
│   │   ├── symptom_triage_screen.dart   # Triage: symptom checklist + urgency
│   │   ├── ai_processing_screen.dart    # Animated AI processing steps
│   │   ├── result_screen.dart           # Risk display + recommendation + PHC
│   │   └── patient_history_screen.dart  # History list with search + filters
│   ├── services/
│   │   ├── storage_service.dart         # Hive CRUD for patients, results, settings
│   │   ├── tflite_service.dart          # TFLite model loading + inference
│   │   ├── audio_service.dart           # Microphone recording controls
│   │   ├── image_service.dart           # Camera capture and image processing
│   │   └── location_service.dart        # GPS location + nearest PHC lookup
│   ├── widgets/
│   │   ├── risk_indicator.dart          # Color-coded risk level badges
│   │   ├── module_card.dart             # Dashboard module cards
│   │   ├── patient_card.dart            # Patient list item cards
│   │   ├── action_button.dart           # Primary CTA buttons
│   │   └── symptom_checkbox.dart        # Touch-friendly large checkboxes
│   └── utils/
│       ├── constants.dart               # Colors, styles, thresholds, config
│       └── routes.dart                  # Named route definitions
├── assets/
│   ├── models/                          # TFLite model files (.tflite)
│   ├── icons/                           # App icons
│   └── images/                          # Logo and illustrations
├── webapp/                              # Static web demo (landing page + PWA)
│   ├── index.html                       # Multi-screen SPA
│   ├── css/styles.css                   # Full styling
│   ├── js/
│   │   ├── app.js                       # Core app logic
│   │   ├── db.js                        # IndexedDB / localStorage
│   │   └── modules.js                   # Screening module logic
│   └── manifest.json                    # PWA manifest
├── pubspec.yaml                         # Flutter dependencies
├── netlify.toml                         # Netlify deploy config
└── README.md                            # Project overview
```

---

## 4. Application Flow

```
Splash Screen → Login Screen → Home Dashboard
                                     │
               ┌─────────────────────┼─────────────────────┐
               │                     │                     │
         New Screening          Patient History       Settings
               │
        Patient Registration
               │
        Module Selection
               │
    ┌──────┬───┴───┬──────────┬──────────┐
    │      │       │          │          │
   TB    Skin   Anemia   Maternal   Triage
 (Audio) (Camera)(Camera)(Questions)(Symptoms)
    │      │       │          │          │
    └──────┴───┬───┴──────────┴──────────┘
               │
       AI Processing Screen
         (Step-by-step animation)
               │
         Result Screen
    (Risk Level + Recommendation
     + Nearest PHC + Refer Option)
```

---

## 5. Data Models

### 5.1 Patient
| Field             | Type     | Description                       |
|-------------------|----------|-----------------------------------|
| id                | String   | UUID - unique patient identifier  |
| name              | String   | Full name                         |
| age               | int      | Age in years                      |
| gender            | String   | Male / Female / Other             |
| phone             | String?  | Optional phone number             |
| village           | String?  | Village name                      |
| symptoms          | List     | Selected symptoms                 |
| createdAt         | DateTime | Registration timestamp            |
| latestScreeningId | String?  | ID of most recent screening       |
| isSynced          | bool     | Whether synced to Firebase        |

### 5.2 ScreeningResult
| Field          | Type     | Description                          |
|----------------|----------|--------------------------------------|
| id             | String   | UUID - unique result identifier      |
| patientId      | String   | FK to Patient                        |
| moduleType     | String   | TB / Skin / Anemia / Maternal / Triage |
| condition      | String   | Detected condition label             |
| probability    | double   | Risk probability (0.0 - 1.0)        |
| riskLevel      | RiskLevel| LOW / MEDIUM / HIGH                  |
| confidence     | double   | Model confidence (0.0 - 1.0)        |
| recommendation | String   | Medical recommendation text          |
| screenedAt     | DateTime | Screening timestamp                  |
| isSynced       | bool     | Whether synced to Firebase           |

---

## 6. AI / ML Design

### 6.1 On-Device Inference
All AI models run locally using **TensorFlow Lite** via the `tflite_flutter` package. No cloud API calls are made for predictions.

### 6.2 Model Specifications

| Model         | File                    | Size  | Input                 | Output                    |
|---------------|-------------------------|-------|-----------------------|---------------------------|
| TB Cough      | tb_cough.tflite         | ~2MB  | Audio spectrogram     | Risk probability          |
| Skin Disease  | skin_disease.tflite     | ~3MB  | 224×224 image         | Disease class + confidence|
| Anemia        | anemia_screen.tflite    | ~2MB  | 224×224 palm/eye image| Pallor level              |
| Maternal Risk | maternal_risk.tflite    | ~500KB| Feature vector        | Risk score                |

### 6.3 Risk Classification Thresholds
- **Low Risk:** probability < 0.35
- **Medium Risk:** 0.35 ≤ probability < 0.70
- **High Risk:** probability ≥ 0.70

### 6.4 Demo Mode
For hackathon demonstration, mock predictions are generated using weighted random values. The architecture is production-ready for swapping in real trained models.

---

## 7. Storage Design

### 7.1 Local Storage (Hive)
Three Hive boxes are used:
- **patientBox** — Stores `Patient` objects, keyed by UUID.
- **screeningBox** — Stores `ScreeningResult` objects, keyed by UUID.
- **settingsBox** — Stores app settings (worker info, first launch flag, etc.).

### 7.2 Cloud Sync (Firebase Firestore)
- Each record has an `isSynced` flag.
- When internet is detected, unsynced records are pushed to Firestore.
- Firebase Authentication secures the sync endpoint.
- Sync is **one-way** (device → cloud) in current design.

---

## 8. UI / UX Design Principles

1. **Rural-Friendly:** Large touch targets (min 48×48dp), high contrast colors, simple navigation.
2. **Icon-Driven:** Minimal reliance on text; icons convey meaning for low-literacy users.
3. **Color-Coded Risks:** Green (Low), Orange (Medium), Red (High) — universally understood.
4. **Material Design 3:** Uses `useMaterial3: true` with a green seed color scheme reflecting health.
5. **Portrait-Only:** Locked to portrait orientation for consistent experience.
6. **Animated Feedback:** Splash screen loader, recording waveform, AI processing steps — keep user engaged.

### 8.1 Color Palette
- **Primary:** Green (`#2E7D32`) — Health, trust, nature.
- **Accent:** Teal — Secondary actions.
- **Risk Low:** Green
- **Risk Medium:** Orange / Amber
- **Risk High:** Red

### 8.2 Typography
- Font Family: **Roboto** (Flutter) / **Inter** (Web)
- Large, readable font sizes for all labels and results.

---

## 9. Web App Design (Landing / Demo)

The `webapp/` directory contains a static single-page application that mirrors the mobile app's screens:
- Multi-screen SPA with screen transitions (no framework).
- Uses **IndexedDB / localStorage** for client-side data persistence.
- Camera and microphone access via Web APIs.
- PWA-ready with `manifest.json` for installability.
- Hosted on **Netlify** with routing configured via `netlify.toml`.

---

## 10. Security Considerations

- All patient data stored on-device only; never sent to third parties.
- Firebase Authentication required for cloud sync.
- No personally identifiable information logged or tracked externally.
- Device-level encryption relied upon for data-at-rest security.
