# Aasha.AI - Web Application

## 🚀 Quick Start

Simply open `index.html` in a modern browser, or use a local server:

```bash
# Option 1: Using Python
cd webapp
python -m http.server 8000
# Open http://localhost:8000

# Option 2: Using VS Code Live Server extension
# Right-click index.html → "Open with Live Server"
```

## ✨ Features

- **5 Disease Modules**: TB, Skin, Anemia, Maternal, Triage
- **100% Offline**: Uses IndexedDB for local storage
- **PWA Ready**: Installable on mobile devices  
- **Audio Recording**: For TB cough analysis
- **Camera Capture**: For skin and anemia scans
- **Mock AI**: Simulates AI inference with animations

## 📁 Structure

```
webapp/
├── index.html          # All screens in single page
├── manifest.json       # PWA configuration
├── css/
│   └── styles.css      # Premium styling
├── js/
│   ├── db.js           # IndexedDB operations
│   ├── app.js          # Main app logic
│   └── modules.js      # Disease module logic
└── assets/             # Icons and images
```

## 🔒 Permissions

The app requires:
- **Microphone**: For TB cough recording
- **Camera**: For skin and anemia scans
- **Geolocation**: For PHC finder (optional)

## 📱 Mobile Support

Works on any modern mobile browser. For best experience:
1. Open in Chrome/Safari
2. Click "Add to Home Screen" for app-like experience
