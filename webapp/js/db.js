// IndexedDB Service for offline storage
const DB_NAME = 'aasha_db';
const DB_VERSION = 1;
let db = null;

async function initDB() {
    return new Promise((resolve, reject) => {
        const request = indexedDB.open(DB_NAME, DB_VERSION);
        
        request.onerror = () => reject(request.error);
        request.onsuccess = () => {
            db = request.result;
            resolve(db);
        };
        
        request.onupgradeneeded = (event) => {
            const database = event.target.result;
            
            // Patients store
            if (!database.objectStoreNames.contains('patients')) {
                const patientStore = database.createObjectStore('patients', { keyPath: 'id' });
                patientStore.createIndex('name', 'name', { unique: false });
                patientStore.createIndex('createdAt', 'createdAt', { unique: false });
            }
            
            // Screenings store
            if (!database.objectStoreNames.contains('screenings')) {
                const screeningStore = database.createObjectStore('screenings', { keyPath: 'id' });
                screeningStore.createIndex('patientId', 'patientId', { unique: false });
                screeningStore.createIndex('riskLevel', 'riskLevel', { unique: false });
                screeningStore.createIndex('createdAt', 'createdAt', { unique: false });
            }
            
            // Settings store
            if (!database.objectStoreNames.contains('settings')) {
                database.createObjectStore('settings', { keyPath: 'key' });
            }
        };
    });
}

// Generic CRUD operations
async function dbAdd(storeName, data) {
    return new Promise((resolve, reject) => {
        const transaction = db.transaction(storeName, 'readwrite');
        const store = transaction.objectStore(storeName);
        const request = store.add(data);
        request.onsuccess = () => resolve(request.result);
        request.onerror = () => reject(request.error);
    });
}

async function dbPut(storeName, data) {
    return new Promise((resolve, reject) => {
        const transaction = db.transaction(storeName, 'readwrite');
        const store = transaction.objectStore(storeName);
        const request = store.put(data);
        request.onsuccess = () => resolve(request.result);
        request.onerror = () => reject(request.error);
    });
}

async function dbGet(storeName, id) {
    return new Promise((resolve, reject) => {
        const transaction = db.transaction(storeName, 'readonly');
        const store = transaction.objectStore(storeName);
        const request = store.get(id);
        request.onsuccess = () => resolve(request.result);
        request.onerror = () => reject(request.error);
    });
}

async function dbGetAll(storeName) {
    return new Promise((resolve, reject) => {
        const transaction = db.transaction(storeName, 'readonly');
        const store = transaction.objectStore(storeName);
        const request = store.getAll();
        request.onsuccess = () => resolve(request.result);
        request.onerror = () => reject(request.error);
    });
}

async function dbDelete(storeName, id) {
    return new Promise((resolve, reject) => {
        const transaction = db.transaction(storeName, 'readwrite');
        const store = transaction.objectStore(storeName);
        const request = store.delete(id);
        request.onsuccess = () => resolve();
        request.onerror = () => reject(request.error);
    });
}

async function dbCount(storeName) {
    return new Promise((resolve, reject) => {
        const transaction = db.transaction(storeName, 'readonly');
        const store = transaction.objectStore(storeName);
        const request = store.count();
        request.onsuccess = () => resolve(request.result);
        request.onerror = () => reject(request.error);
    });
}

// Patient-specific functions
async function savePatient(patient) {
    patient.id = patient.id || generateId();
    patient.createdAt = patient.createdAt || new Date().toISOString();
    patient.updatedAt = new Date().toISOString();
    return dbPut('patients', patient);
}

async function getPatient(id) {
    return dbGet('patients', id);
}

async function getAllPatients() {
    return dbGetAll('patients');
}

async function getTodayPatients() {
    const patients = await getAllPatients();
    const today = new Date().toDateString();
    return patients.filter(p => new Date(p.createdAt).toDateString() === today);
}

// Screening-specific functions
async function saveScreening(screening) {
    screening.id = screening.id || generateId();
    screening.createdAt = screening.createdAt || new Date().toISOString();
    return dbPut('screenings', screening);
}

async function getScreening(id) {
    return dbGet('screenings', id);
}

async function getPatientScreenings(patientId) {
    const screenings = await dbGetAll('screenings');
    return screenings.filter(s => s.patientId === patientId);
}

async function getLatestScreening(patientId) {
    const screenings = await getPatientScreenings(patientId);
    return screenings.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))[0];
}

// Settings
async function saveSetting(key, value) {
    return dbPut('settings', { key, value });
}

async function getSetting(key) {
    const result = await dbGet('settings', key);
    return result ? result.value : null;
}

// Utility
function generateId() {
    return Date.now().toString(36) + Math.random().toString(36).substr(2, 9);
}
