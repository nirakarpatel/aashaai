# 📋 Aasha.AI — Requirements Document

## 1. Project Overview

Aasha.AI is an offline-first, AI-powered multi-disease health screening platform designed for ASHA (Accredited Social Health Activist) workers in rural India. The app enables community health workers to perform preliminary screenings for TB, skin diseases, anemia, maternal health risks, and general symptom triage — all without requiring internet connectivity.

---

## 2. Problem Statement

- **Doctor Shortage:** 1 doctor per 10,000+ people in rural villages.
- **Poor Connectivity:** Limited or no internet access, making telemedicine impractical.
- **Late Diagnosis:** Preventable diseases are detected too late due to lack of local screening.
- **High Costs:** Advanced diagnostic tests are unavailable or unaffordable locally.

---

## 3. Target Users

- **Primary:** ASHA workers operating in rural and semi-urban regions of India.
- **Secondary:** PHC (Primary Health Centre) staff, ANMs (Auxiliary Nurse Midwives), and district health administrators.

---

## 4. Functional Requirements

### 4.1 User Authentication
- ASHA worker login with name and phone number.
- Worker profile stored locally using Hive.
- First-launch onboarding flow.

### 4.2 Patient Registration
- Register new patients with: Full Name, Age, Gender, Phone Number, Village.
- Symptom selection during registration.
- Each patient assigned a unique UUID.

### 4.3 Screening Modules

#### 4.3.1 TB Cough Screening
- Record patient's cough audio (minimum 5 seconds).
- Display animated waveform during recording.
- Run on-device TFLite audio classification model.
- Output: TB risk probability (Low / Medium / High).

#### 4.3.2 Skin Disease Detection
- Capture photo of affected skin area via device camera.
- Run on-device TFLite image classification model.
- Detect: Fungal Infection, Eczema, Ringworm, Scabies, Contact Dermatitis, Normal Skin.
- Output: Condition + confidence score.

#### 4.3.3 Anemia Check
- Capture photo of patient's inner palm or lower eyelid.
- Toggle between palm and eye scan modes.
- Run on-device TFLite pallor analysis model.
- Output: Estimated hemoglobin / pallor level + risk score.

#### 4.3.4 Maternal Health Assessment
- Questionnaire-based screening for pregnancy danger signs.
- Danger signs include: High BP, Bleeding, Swelling, Severe Headache, Reduced Fetal Movement, Weakness.
- Weighted risk scoring algorithm.
- Output: Maternal risk level + recommendations.

#### 4.3.5 Symptom Triage
- Multi-select symptom checklist.
- Weighted urgency scoring (breathing/chest = high, fever/blood = medium, others = low).
- Output: Care urgency level + referral recommendation.

### 4.4 AI Processing
- Step-by-step animated processing visualization.
- All inference done on-device via TensorFlow Lite (no internet required).
- Mock predictions included for demo/hackathon purposes.

### 4.5 Result Display
- Color-coded risk indicators (Low = Green, Medium = Orange, High = Red).
- Confidence percentage shown for each prediction.
- Actionable medical recommendations per risk level.
- Nearest PHC recommendation with maps integration.
- Option to mark patient as "Referred."

### 4.6 Patient History
- View all past screenings sorted by date.
- Filter by risk level (All / High / Medium / Low).
- Search patients by name.
- Track screening counts (Today / Total).

### 4.7 Nearest PHC Finder
- GPS-based location for finding nearby Primary Health Centres.
- Open directions in external maps app.
- Works with cached PHC data when offline.

### 4.8 Data Sync (Optional)
- Offline-first storage via Hive.
- Sync patient records and screening results to Firebase Firestore when online.
- Track synced/unsynced status per record.

---

## 5. Non-Functional Requirements

### 5.1 Offline Capability
- The app MUST function 100% offline for all screening modules and patient management.
- Cloud sync is optional and only activated when internet is available.

### 5.2 Performance
- AI inference must complete within 2-3 seconds per screening.
- App must run smoothly on low-end Android devices (2GB RAM, Android 8+).
- TFLite models must be lightweight (≤3MB per model).

### 5.3 Usability
- Rural-friendly UI with large buttons and high-contrast colors.
- Icon-based interface for low-literacy users.
- Minimal text input required.
- Portrait-only orientation.

### 5.4 Privacy & Security
- All patient data stored locally on device.
- Firebase sync uses Firebase Authentication.
- No patient data sent to third-party services.

### 5.5 Localization
- Multi-language ready (string resources extracted for i18n).
- Future support planned for Hindi and Odia voice guidance.

### 5.6 Permissions Required
- `RECORD_AUDIO` — For TB cough recording.
- `CAMERA` — For skin and anemia photo capture.
- `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION` — For nearest PHC finder.
- `INTERNET` — For optional Firebase sync.

---

## 6. Platform Requirements

- **Mobile App:** Flutter (Dart SDK >=3.0.0 <4.0.0), targeting Android.
- **Web Demo:** Static HTML/CSS/JS webapp with PWA support, hosted on Netlify.

---

## 7. Future Requirements (Roadmap)

- Hindi/Odia voice guidance for low-literacy users.
- Emergency SMS alerts for high-risk patients.
- High-risk zone heatmap for district health officers.
- Government PHC API integration for real-time PHC data.
- Additional screening modules: Diabetes, Eye Disease, Dental Health.
