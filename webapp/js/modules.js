// Disease module implementations

// ========== TB COUGH MODULE ==========
let mediaRecorder = null;
let audioChunks = [];
let recordingTimer = null;
let recordingTime = 0;
let waveformBars = [];
let isRecording = false;
let audioAnalyser = null;
let audioContext = null;

function initTBModule() {
    showScreen('tb-screen');
    resetTBModule();
    createWaveform();

    // Remove old listeners and add new
    const recordBtn = document.getElementById('record-btn');
    const analyzeBtn = document.getElementById('analyze-cough-btn');

    recordBtn.replaceWith(recordBtn.cloneNode(true));
    analyzeBtn.replaceWith(analyzeBtn.cloneNode(true));

    document.getElementById('record-btn').addEventListener('click', toggleRecording);
    document.getElementById('analyze-cough-btn').addEventListener('click', () => runAIAnalysis('tb'));
}

function resetTBModule() {
    recordingTime = 0;
    audioChunks = [];
    isRecording = false;

    if (recordingTimer) clearInterval(recordingTimer);
    if (mediaRecorder && mediaRecorder.state !== 'inactive') {
        mediaRecorder.stop();
    }

    const timer = document.getElementById('timer');
    const status = document.getElementById('recording-status');
    const analyzeBtn = document.getElementById('analyze-cough-btn');
    const pulse = document.getElementById('record-pulse');
    const recordBtn = document.getElementById('record-btn');

    if (timer) timer.textContent = '00:00';
    if (status) status.textContent = 'Tap to start recording';
    if (analyzeBtn) analyzeBtn.disabled = true;
    if (pulse) pulse.classList.remove('active');
    if (recordBtn) {
        recordBtn.classList.remove('recording');
        const icon = recordBtn.querySelector('i');
        if (icon) icon.className = 'fas fa-microphone';
    }
}

function createWaveform() {
    const container = document.getElementById('waveform');
    if (!container) return;

    container.innerHTML = '';
    waveformBars = [];
    for (let i = 0; i < 40; i++) {
        const bar = document.createElement('div');
        bar.className = 'waveform-bar';
        bar.style.height = '8px';
        container.appendChild(bar);
        waveformBars.push(bar);
    }
}

async function toggleRecording() {
    const btn = document.getElementById('record-btn');
    const icon = btn.querySelector('i');

    if (!isRecording) {
        // Start recording
        try {
            const stream = await navigator.mediaDevices.getUserMedia({ audio: true });

            // Set up audio context for visualization
            audioContext = new (window.AudioContext || window.webkitAudioContext)();
            const source = audioContext.createMediaStreamSource(stream);
            audioAnalyser = audioContext.createAnalyser();
            audioAnalyser.fftSize = 128;
            source.connect(audioAnalyser);

            mediaRecorder = new MediaRecorder(stream);
            audioChunks = [];

            mediaRecorder.ondataavailable = (e) => {
                if (e.data.size > 0) audioChunks.push(e.data);
            };

            mediaRecorder.onstop = () => {
                stream.getTracks().forEach(t => t.stop());
                if (audioContext) {
                    audioContext.close();
                    audioContext = null;
                }
                document.getElementById('analyze-cough-btn').disabled = false;
            };

            mediaRecorder.start(100); // Collect data every 100ms
            isRecording = true;
            btn.classList.add('recording');
            icon.className = 'fas fa-stop';
            document.getElementById('record-pulse').classList.add('active');
            document.getElementById('recording-status').textContent = 'Recording... Cough clearly';

            recordingTime = 0;
            recordingTimer = setInterval(() => {
                recordingTime++;
                const mins = Math.floor(recordingTime / 60).toString().padStart(2, '0');
                const secs = (recordingTime % 60).toString().padStart(2, '0');
                document.getElementById('timer').textContent = `${mins}:${secs}`;
                animateWaveformFromAudio();
            }, 1000);

            // Start real-time waveform animation
            animateRealTimeWaveform();

        } catch (err) {
            console.error('Microphone error:', err);
            alert('Microphone access denied. Please allow microphone access and try again.');
        }
    } else {
        // Stop recording
        isRecording = false;
        if (mediaRecorder && mediaRecorder.state !== 'inactive') {
            mediaRecorder.stop();
        }
        clearInterval(recordingTimer);
        btn.classList.remove('recording');
        icon.className = 'fas fa-microphone';
        document.getElementById('record-pulse').classList.remove('active');
        document.getElementById('recording-status').textContent = 'Recording complete! ✓';
        resetWaveform();
    }
}

function animateRealTimeWaveform() {
    if (!isRecording || !audioAnalyser) return;

    const dataArray = new Uint8Array(audioAnalyser.frequencyBinCount);
    audioAnalyser.getByteFrequencyData(dataArray);

    waveformBars.forEach((bar, i) => {
        const value = dataArray[i % dataArray.length] || 0;
        const height = Math.max(8, (value / 255) * 80);
        bar.style.height = height + 'px';
    });

    if (isRecording) {
        requestAnimationFrame(animateRealTimeWaveform);
    }
}

function animateWaveformFromAudio() {
    if (!isRecording) return;
    waveformBars.forEach(bar => {
        bar.style.height = (Math.random() * 60 + 10) + 'px';
    });
}

function resetWaveform() {
    waveformBars.forEach(bar => bar.style.height = '8px');
}

// ========== CAMERA MODULES (Skin/Anemia) ==========
let videoStream = null;
let capturedImage = null;

async function initCameraModule(type) {
    showScreen(`${type}-screen`);
    capturedImage = null;

    const video = document.getElementById(`${type}-video`);
    const canvas = document.getElementById(`${type}-canvas`);
    const capturedImg = document.getElementById(`${type}-captured`);
    const captureBtn = document.getElementById(`${type}-capture-btn`);
    const analyzeBtn = document.getElementById(`analyze-${type}-btn`);

    if (!video || !captureBtn || !analyzeBtn) return;

    video.style.display = 'block';
    capturedImg.style.display = 'none';
    analyzeBtn.disabled = true;

    // Stop any existing stream
    if (videoStream) {
        videoStream.getTracks().forEach(t => t.stop());
    }

    try {
        videoStream = await navigator.mediaDevices.getUserMedia({
            video: { facingMode: 'environment', width: { ideal: 1280 }, height: { ideal: 720 } }
        });
        video.srcObject = videoStream;
    } catch (err) {
        console.error('Camera error:', err);
        alert('Camera access denied. Please allow camera access and try again.');
        return;
    }

    // Clone buttons to remove old listeners
    captureBtn.replaceWith(captureBtn.cloneNode(true));
    analyzeBtn.replaceWith(analyzeBtn.cloneNode(true));

    const newCaptureBtn = document.getElementById(`${type}-capture-btn`);
    const newAnalyzeBtn = document.getElementById(`analyze-${type}-btn`);

    newCaptureBtn.onclick = () => {
        canvas.width = video.videoWidth || 640;
        canvas.height = video.videoHeight || 480;
        canvas.getContext('2d').drawImage(video, 0, 0);
        capturedImage = canvas.toDataURL('image/jpeg');
        capturedImg.src = capturedImage;

        video.style.display = 'none';
        capturedImg.style.display = 'block';
        newAnalyzeBtn.disabled = false;

        videoStream.getTracks().forEach(t => t.stop());
    };

    newAnalyzeBtn.onclick = () => runAIAnalysis(type);

    // Anemia toggle
    if (type === 'anemia') {
        document.querySelectorAll('.toggle-btn').forEach(btn => {
            btn.onclick = () => {
                document.querySelectorAll('.toggle-btn').forEach(b => b.classList.remove('active'));
                btn.classList.add('active');
                document.getElementById('anemia-instruction').textContent =
                    btn.dataset.type === 'palm' ? 'Show inner palm' : 'Show lower eyelid';
            };
        });
    }
}

// ========== MATERNAL HEALTH MODULE ==========
const MATERNAL_QUESTIONS = [
    { key: 'highBP', text: 'High blood pressure / dizziness?', icon: 'fa-heart', severity: 'high' },
    { key: 'bleeding', text: 'Vaginal bleeding?', icon: 'fa-tint', severity: 'critical' },
    { key: 'swelling', text: 'Swelling in hands/feet/face?', icon: 'fa-hand-paper', severity: 'medium' },
    { key: 'headache', text: 'Severe headache / blurred vision?', icon: 'fa-brain', severity: 'high' },
    { key: 'movement', text: 'Reduced baby movement?', icon: 'fa-baby', severity: 'high' },
    { key: 'weakness', text: 'Extreme weakness?', icon: 'fa-battery-quarter', severity: 'medium' },
    { key: 'fever', text: 'Fever or chills?', icon: 'fa-thermometer-half', severity: 'medium' },
    { key: 'convulsions', text: 'Convulsions or fits?', icon: 'fa-bolt', severity: 'critical' }
];
let maternalAnswers = {};

function initMaternalModule() {
    showScreen('maternal-screen');
    maternalAnswers = {};

    const container = document.getElementById('maternal-questions');
    container.innerHTML = MATERNAL_QUESTIONS.map(q => `
        <div class="question-card" data-key="${q.key}">
            <div class="question-icon"><i class="fas ${q.icon}"></i></div>
            <span class="question-text">${q.text}</span>
            <div class="question-check"><i class="fas fa-check"></i></div>
        </div>
    `).join('');

    container.querySelectorAll('.question-card').forEach(card => {
        card.addEventListener('click', () => {
            card.classList.toggle('selected');
            maternalAnswers[card.dataset.key] = card.classList.contains('selected');
            updateMaternalCount();
        });
    });

    const analyzeBtn = document.getElementById('analyze-maternal-btn');
    analyzeBtn.replaceWith(analyzeBtn.cloneNode(true));
    document.getElementById('analyze-maternal-btn').onclick = () => runAIAnalysis('maternal');
}

function updateMaternalCount() {
    const count = Object.values(maternalAnswers).filter(v => v).length;
    document.getElementById('maternal-count').textContent = `${count} warning sign${count !== 1 ? 's' : ''} selected`;
}

// ========== SYMPTOM TRIAGE MODULE ==========
const TRIAGE_CATEGORIES = [
    { name: 'Respiratory', color: '#2196F3', icon: 'fa-lungs', symptoms: ['Difficulty breathing', 'Persistent cough', 'Chest pain', 'Wheezing'] },
    { name: 'General', color: '#FF9800', icon: 'fa-thermometer-half', symptoms: ['High fever (>102°F)', 'Severe headache', 'Body aches', 'Fatigue'] },
    { name: 'Digestive', color: '#4CAF50', icon: 'fa-capsules', symptoms: ['Severe diarrhea', 'Vomiting', 'Abdominal pain', 'Blood in stool'] },
    { name: 'Child Health', color: '#E91E63', icon: 'fa-baby', symptoms: ['Not eating/drinking', 'Lethargy', 'Rash with fever', 'Convulsions'] }
];
let triageSymptoms = [];

function initTriageModule() {
    showScreen('triage-screen');
    triageSymptoms = [];

    const container = document.getElementById('triage-symptoms');
    container.innerHTML = TRIAGE_CATEGORIES.map(cat => `
        <div class="symptom-category">
            <div class="category-header" style="color: ${cat.color}">
                <i class="fas ${cat.icon}"></i>
                ${cat.name}
            </div>
            <div class="category-symptoms">
                ${cat.symptoms.map(s => `
                    <div class="triage-symptom" data-symptom="${s}">
                        <div class="symptom-checkbox"><i class="fas fa-check"></i></div>
                        <span class="symptom-name">${s}</span>
                    </div>
                `).join('')}
            </div>
        </div>
    `).join('');

    container.querySelectorAll('.triage-symptom').forEach(item => {
        item.addEventListener('click', () => {
            item.classList.toggle('selected');
            const symptom = item.dataset.symptom;
            if (item.classList.contains('selected')) {
                triageSymptoms.push(symptom);
            } else {
                triageSymptoms = triageSymptoms.filter(s => s !== symptom);
            }
            document.getElementById('triage-count').textContent = `${triageSymptoms.length} selected`;
        });
    });

    const analyzeBtn = document.getElementById('analyze-triage-btn');
    analyzeBtn.replaceWith(analyzeBtn.cloneNode(true));
    document.getElementById('analyze-triage-btn').onclick = () => runAIAnalysis('triage');
}

// ========== AI ANALYSIS (Mock) ==========
async function runAIAnalysis(moduleType) {
    showScreen('processing-screen');

    const steps = [
        { text: 'Preparing data...', icon: 'fa-database' },
        { text: 'Loading AI model...', icon: 'fa-brain' },
        { text: 'Running inference...', icon: 'fa-cogs' },
        { text: 'Generating result...', icon: 'fa-chart-line' }
    ];

    const stepsContainer = document.getElementById('processing-steps');
    stepsContainer.innerHTML = steps.map((s, i) => `
        <div class="step" id="step-${i}">
            <i class="fas ${s.icon}"></i>
            <span>${s.text}</span>
        </div>
    `).join('');

    // Animate steps
    for (let i = 0; i < steps.length; i++) {
        document.getElementById(`step-${i}`).classList.add('active');
        await sleep(800);
        document.getElementById(`step-${i}`).classList.remove('active');
        document.getElementById(`step-${i}`).classList.add('done');
    }

    // Generate mock result
    const result = generateMockResult(moduleType);

    // Save screening
    const screening = {
        patientId: currentPatient?.id,
        moduleType,
        riskLevel: result.risk,
        confidence: result.confidence,
        recommendation: result.recommendation,
        createdAt: new Date().toISOString()
    };
    await saveScreening(screening);

    // Show result
    showResult(result);
}

function generateMockResult(moduleType) {
    let risk, confidence, recommendation;

    // Weighted random (more likely to be low/medium)
    const rand = Math.random();
    if (rand < 0.5) risk = 'low';
    else if (rand < 0.85) risk = 'medium';
    else risk = 'high';

    confidence = Math.floor(Math.random() * 20 + 75); // 75-95%

    const recommendations = {
        low: {
            tb: 'No TB indicators detected. Continue monitoring, maintain good ventilation.',
            skin: 'Skin appears healthy. Continue hygiene practices.',
            anemia: 'Pallor levels normal. Encourage iron-rich foods.',
            maternal: 'Pregnancy appears normal. Continue regular checkups.',
            triage: 'Minor symptoms. Rest and home remedies recommended.'
        },
        medium: {
            tb: 'Some indicators present. Visit PHC for sputum test.',
            skin: 'Possible skin condition. Recommend PHC visit.',
            anemia: 'Mild pallor detected. Blood test recommended.',
            maternal: 'Warning signs present. PHC visit within 24-48 hours.',
            triage: 'Moderate symptoms. Visit PHC within 24 hours.'
        },
        high: {
            tb: 'High TB risk. Urgent referral for chest X-ray and testing.',
            skin: 'Significant skin condition. Dermatology referral needed.',
            anemia: 'Severe pallor. Urgent blood test required.',
            maternal: 'DANGER SIGNS. Immediate hospital transport needed.',
            triage: 'URGENT: Serious symptoms. Immediate medical attention.'
        }
    };

    recommendation = recommendations[risk][moduleType];

    return { risk, confidence, recommendation };
}

function showResult(result) {
    showScreen('result-screen');

    const display = document.getElementById('risk-display');
    display.className = `risk-display ${result.risk}`;

    const icon = display.querySelector('.risk-icon-large i');
    if (result.risk === 'low') icon.className = 'fas fa-check-circle';
    else if (result.risk === 'medium') icon.className = 'fas fa-exclamation-circle';
    else icon.className = 'fas fa-times-circle';

    display.querySelector('.risk-level').textContent = result.risk.toUpperCase() + ' RISK';
    display.querySelector('.confidence').textContent = result.confidence + '% Confidence';

    document.getElementById('recommendation-text').textContent = result.recommendation;

    // Patient info
    if (currentPatient) {
        document.getElementById('result-patient-info').innerHTML = `
            <div class="patient-avatar">${currentPatient.name[0]}</div>
            <div>
                <h4>${currentPatient.name}</h4>
                <p style="font-size: 0.85rem; color: var(--text-light)">${currentPatient.age}y • ${currentPatient.gender}</p>
            </div>
        `;
    }

    // Show PHC for medium/high risk
    const phcCard = document.getElementById('phc-card');
    const referBtn = document.getElementById('refer-btn');
    if (result.risk !== 'low') {
        phcCard.style.display = 'block';
        referBtn.style.display = 'flex';
        document.getElementById('phc-info').innerHTML = `
            <p><strong>Primary Health Center - Demo</strong></p>
            <p>Village PHC, 3.2 km away</p>
        `;
        document.getElementById('open-maps-btn').onclick = () => {
            window.open('https://maps.google.com', '_blank');
        };
    } else {
        phcCard.style.display = 'none';
        referBtn.style.display = 'none';
    }
}

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}
