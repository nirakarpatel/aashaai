// Global state
let currentPatient = null;
let currentModule = null;

// Data constants
const MODULES = [
    { id: 'tb', name: 'TB Screening', desc: 'Cough-based detection', icon: 'fa-microphone', color: '#E53935' },
    { id: 'skin', name: 'Skin Disease', desc: 'Photo detection', icon: 'fa-camera', color: '#8E24AA' },
    { id: 'anemia', name: 'Anemia Check', desc: 'Palm/Eye analysis', icon: 'fa-eye', color: '#FF6F00' },
    { id: 'maternal', name: 'Maternal Health', desc: 'Pregnancy screening', icon: 'fa-baby', color: '#EC407A' },
    { id: 'triage', name: 'Symptom Triage', desc: 'General health', icon: 'fa-comment-medical', color: '#00897B' }
];

const SYMPTOMS = ['Cough > 2 weeks', 'Fever', 'Night sweats', 'Weight loss', 'Fatigue', 'Breathlessness', 'Chest pain', 'Loss of appetite'];

// Initialize app
document.addEventListener('DOMContentLoaded', async () => {
    await initDB();
    renderModulesGrid();
    renderSymptomsList();
    renderModuleSelectList();
    setupEventListeners();
    await updateDashboardStats();

    // Show splash then go to dashboard
    setTimeout(() => {
        showScreen('dashboard-screen');
    }, 2500);
});

// Screen navigation
function showScreen(screenId) {
    document.querySelectorAll('.screen').forEach(s => s.classList.remove('active'));
    document.getElementById(screenId).classList.add('active');
}

function setupEventListeners() {
    // Back buttons
    document.querySelectorAll('.back-btn').forEach(btn => {
        btn.addEventListener('click', () => showScreen(btn.dataset.back + '-screen'));
    });

    // Dashboard buttons
    document.getElementById('new-screening-btn').addEventListener('click', () => showScreen('registration-screen'));
    document.getElementById('history-btn').addEventListener('click', showHistory);

    // Bottom nav
    document.querySelectorAll('.nav-item').forEach(item => {
        item.addEventListener('click', () => {
            document.querySelectorAll('.nav-item').forEach(i => i.classList.remove('active'));
            item.classList.add('active');
            if (item.dataset.tab === 'patients') showHistory();
            else if (item.dataset.tab === 'home') showScreen('dashboard-screen');
        });
    });

    // Patient form
    document.getElementById('patient-form').addEventListener('submit', handlePatientSubmit);

    // Module selection from dashboard
    document.querySelectorAll('.module-card:not(.disabled)').forEach(card => {
        card.addEventListener('click', () => {
            currentModule = card.dataset.module;
            showScreen('registration-screen');
        });
    });

    // Module selection screen
    document.querySelectorAll('.module-select-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            currentModule = btn.dataset.module;
            startModule(currentModule);
        });
    });

    // Search toggle
    document.getElementById('search-toggle').addEventListener('click', () => {
        const bar = document.getElementById('search-bar');
        bar.style.display = bar.style.display === 'none' ? 'flex' : 'none';
    });

    // Filter chips
    document.querySelectorAll('.chip').forEach(chip => {
        chip.addEventListener('click', () => {
            document.querySelectorAll('.chip').forEach(c => c.classList.remove('active'));
            chip.classList.add('active');
            filterPatients(chip.dataset.filter);
        });
    });

    // Search input
    document.getElementById('search-input').addEventListener('input', (e) => {
        searchPatients(e.target.value);
    });

    // FAB
    document.getElementById('fab-new').addEventListener('click', () => showScreen('registration-screen'));

    // Result actions
    document.getElementById('back-home-btn').addEventListener('click', () => showScreen('dashboard-screen'));
}

// Render functions
function renderModulesGrid() {
    const grid = document.getElementById('modules-grid');
    if (!grid) return;

    grid.innerHTML = MODULES.map(m => `
        <div class="module-card" data-module="${m.id}">
            <div class="module-icon" style="background: linear-gradient(135deg, ${m.color}, ${adjustColor(m.color, -30)})">
                <i class="fas ${m.icon}"></i>
            </div>
            <h4>${m.name}</h4>
            <p>${m.desc}</p>
        </div>
    `).join('') + `
        <div class="module-card disabled">
            <div class="module-icon" style="background: linear-gradient(135deg, #9E9E9E, #757575)">
                <i class="fas fa-ellipsis-h"></i>
            </div>
            <h4>More Coming</h4>
            <p>Diabetes, Eye...</p>
            <span class="badge">Soon</span>
        </div>
    `;

    grid.querySelectorAll('.module-card:not(.disabled)').forEach(card => {
        card.addEventListener('click', () => {
            currentModule = card.dataset.module;
            showScreen('registration-screen');
        });
    });
}

function renderSymptomsList() {
    const list = document.getElementById('symptoms-list');
    if (!list) return;

    list.innerHTML = SYMPTOMS.map(s => `
        <button type="button" class="symptom-chip" data-symptom="${s}">${s}</button>
    `).join('');

    list.querySelectorAll('.symptom-chip').forEach(chip => {
        chip.addEventListener('click', () => chip.classList.toggle('selected'));
    });
}

function renderModuleSelectList() {
    const list = document.getElementById('module-list');
    if (!list) return;

    list.innerHTML = MODULES.map(m => `
        <button class="module-select-btn" data-module="${m.id}">
            <div class="module-icon-sm" style="background: ${m.color}"><i class="fas ${m.icon}"></i></div>
            <div class="module-details">
                <h4>${m.name}</h4>
                <p>${m.desc}</p>
            </div>
            <i class="fas fa-chevron-right"></i>
        </button>
    `).join('');

    list.querySelectorAll('.module-select-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            currentModule = btn.dataset.module;
            startModule(currentModule);
        });
    });
}

async function handlePatientSubmit(e) {
    e.preventDefault();

    const symptoms = [];
    document.querySelectorAll('.symptom-chip.selected').forEach(c => symptoms.push(c.dataset.symptom));

    const patient = {
        name: document.getElementById('patient-name').value,
        age: parseInt(document.getElementById('patient-age').value),
        gender: document.getElementById('patient-gender').value,
        phone: document.getElementById('patient-phone').value,
        village: document.getElementById('patient-village').value,
        symptoms: symptoms
    };

    await savePatient(patient);
    currentPatient = patient;

    // Show patient info and go to module select
    updateSelectedPatientInfo();
    showScreen('module-select-screen');

    // Clear form
    e.target.reset();
    document.querySelectorAll('.symptom-chip').forEach(c => c.classList.remove('selected'));

    await updateDashboardStats();
}

function updateSelectedPatientInfo() {
    const el = document.getElementById('selected-patient-info');
    if (el && currentPatient) {
        el.innerHTML = `
            <div class="patient-avatar">${currentPatient.name[0]}</div>
            <div>
                <h4>${currentPatient.name}</h4>
                <p style="font-size: 0.85rem; color: var(--text-light)">${currentPatient.age}y • ${currentPatient.gender}</p>
            </div>
        `;
    }

    // Update patient chips in module screens
    ['tb', 'skin', 'anemia'].forEach(m => {
        const chip = document.getElementById(`${m}-patient-chip`);
        if (chip && currentPatient) {
            chip.innerHTML = `<i class="fas fa-user"></i> ${currentPatient.name}`;
        }
    });
}

function startModule(moduleId) {
    switch (moduleId) {
        case 'tb': initTBModule(); break;
        case 'skin': initCameraModule('skin'); break;
        case 'anemia': initCameraModule('anemia'); break;
        case 'maternal': initMaternalModule(); break;
        case 'triage': initTriageModule(); break;
    }
}

async function updateDashboardStats() {
    const today = await getTodayPatients();
    const all = await getAllPatients();

    document.getElementById('today-count').textContent = today.length;
    document.getElementById('total-patients').textContent = all.length;
}

async function showHistory() {
    showScreen('history-screen');
    const patients = await getAllPatients();
    renderPatientList(patients);
}

async function renderPatientList(patients) {
    const list = document.getElementById('history-list');

    if (patients.length === 0) {
        list.innerHTML = `<div class="empty-state"><i class="fas fa-users"></i><p>No patients yet</p></div>`;
        return;
    }

    // Get screenings for each patient
    const patientsWithScreenings = await Promise.all(patients.map(async p => {
        const screening = await getLatestScreening(p.id);
        return { ...p, screening };
    }));

    list.innerHTML = patientsWithScreenings.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt)).map(p => {
        const riskClass = p.screening ? p.screening.riskLevel : '';
        const riskText = p.screening ? p.screening.riskLevel.toUpperCase() : 'N/A';
        return `
            <div class="patient-history-card" data-id="${p.id}">
                <div class="patient-avatar">${p.name[0]}</div>
                <div class="patient-info">
                    <h4>${p.name}</h4>
                    <p class="patient-meta">${p.age}y • ${p.gender} • ${formatDate(p.createdAt)}</p>
                </div>
                <span class="risk-badge ${riskClass}">${riskText}</span>
            </div>
        `;
    }).join('');
}

async function filterPatients(filter) {
    let patients = await getAllPatients();

    if (filter !== 'all') {
        const patientsWithScreenings = await Promise.all(patients.map(async p => {
            const screening = await getLatestScreening(p.id);
            return { ...p, screening };
        }));
        patients = patientsWithScreenings.filter(p => p.screening && p.screening.riskLevel === filter);
    }

    renderPatientList(patients);
}

async function searchPatients(query) {
    const patients = await getAllPatients();
    const filtered = patients.filter(p => p.name.toLowerCase().includes(query.toLowerCase()));
    renderPatientList(filtered);
}

// Utility functions
function adjustColor(hex, amount) {
    const num = parseInt(hex.replace('#', ''), 16);
    const r = Math.min(255, Math.max(0, (num >> 16) + amount));
    const g = Math.min(255, Math.max(0, ((num >> 8) & 0x00FF) + amount));
    const b = Math.min(255, Math.max(0, (num & 0x0000FF) + amount));
    return `#${(1 << 24 | r << 16 | g << 8 | b).toString(16).slice(1)}`;
}

function formatDate(dateStr) {
    const date = new Date(dateStr);
    return date.toLocaleDateString('en-IN', { day: 'numeric', month: 'short' });
}
