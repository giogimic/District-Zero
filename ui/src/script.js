// Mission UI Elements
const missionUI = document.getElementById('mission-ui');
const missionTitle = document.getElementById('mission-title');
const missionTime = document.getElementById('mission-time');
const missionDesc = document.getElementById('mission-desc');
const objectivesList = document.getElementById('objectives-list');
const cashReward = document.getElementById('cash-reward');
const xpReward = document.getElementById('xp-reward');
const closeButton = document.getElementById('close-mission');

// Mission UI State
let currentMission = null;

// Main UI Script
let isUIOpen = false;

// Notification System
const notificationContainer = document.getElementById('notification-container');

// UI State Management
const state = {
    currentTab: 'abilities',
    notifications: [],
    settings: {
        notifications: true,
        blips: true,
        markers: true,
        minimap: true,
        debug: false,
        uiScale: 1,
        uiOpacity: 1
    }
};

// UI Elements
const elements = {
    tabs: document.querySelectorAll('.nav-item'),
    tabContents: document.querySelectorAll('.tab-content'),
    helpButton: document.getElementById('helpButton'),
    helpOverlay: document.getElementById('helpOverlay'),
    closeHelp: document.querySelector('.close-help'),
    notifications: document.getElementById('notifications')
};

// Tab Navigation
elements.tabs.forEach(tab => {
    tab.addEventListener('click', (e) => {
        e.preventDefault();
        const tabId = tab.dataset.tab;
        switchTab(tabId);
    });
});

function switchTab(tabId) {
    // Update active tab
    elements.tabs.forEach(tab => {
        tab.classList.toggle('active', tab.dataset.tab === tabId);
    });

    // Update active content
    elements.tabContents.forEach(content => {
        content.classList.toggle('active', content.id === tabId);
    });

    state.currentTab = tabId;
}

// Help System
elements.helpButton.addEventListener('click', () => {
    elements.helpOverlay.style.display = 'flex';
});

elements.closeHelp.addEventListener('click', () => {
    elements.helpOverlay.style.display = 'none';
});

// Notification System
function showNotification(message, type = 'info', duration = 3000) {
    if (!state.settings.notifications) return;

    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.innerHTML = `
        <i class="fas ${getNotificationIcon(type)}"></i>
        <span>${message}</span>
    `;

    elements.notifications.appendChild(notification);

    // Trigger animation
    setTimeout(() => {
        notification.classList.add('show');
    }, 100);

    // Remove notification
    setTimeout(() => {
        notification.classList.remove('show');
        setTimeout(() => {
            notification.remove();
        }, 300);
    }, duration);
}

function getNotificationIcon(type) {
    switch (type) {
        case 'success':
            return 'fa-check-circle';
        case 'error':
            return 'fa-exclamation-circle';
        case 'warning':
            return 'fa-exclamation-triangle';
        default:
            return 'fa-info-circle';
    }
}

// Settings Management
function updateSettings(newSettings) {
    state.settings = { ...state.settings, ...newSettings };
    document.documentElement.style.setProperty('--ui-scale', state.settings.uiScale);
    document.documentElement.style.setProperty('--ui-opacity', state.settings.uiOpacity);
}

// Event Listeners
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        if (elements.helpOverlay.style.display === 'flex') {
            elements.helpOverlay.style.display = 'none';
        }
    }
});

// NUI Message Handler
window.addEventListener('message', (event) => {
    const data = event.data;

    switch (data.action) {
        case 'toggleUI':
            document.body.style.display = data.show ? 'block' : 'none';
            break;

        case 'updateSettings':
            updateSettings(data.settings);
            break;

        case 'showNotification':
            showNotification(data.message, data.type, data.duration);
            break;

        case 'updateData':
            updateUI(data.data);
            break;
    }
});

// UI Update Functions
function updateUI(data) {
    switch (state.currentTab) {
        case 'abilities':
            updateAbilities(data.abilities);
            break;
        case 'districts':
            updateDistricts(data.districts);
            break;
        case 'missions':
            updateMissions(data.missions);
            break;
        case 'factions':
            updateFactions(data.factions);
            break;
        case 'stats':
            updateStats(data.stats);
            break;
    }
}

function updateAbilities(abilities) {
    const container = document.querySelector('.abilities-grid');
    if (!container) return;

    container.innerHTML = abilities.map(ability => `
        <div class="ability-card">
            <div class="ability-icon">
                <i class="fas ${ability.icon}"></i>
            </div>
            <h3>${ability.name}</h3>
            <p>${ability.description}</p>
            <div class="ability-info">
                <span class="cooldown"><i class="fas fa-clock"></i> ${ability.cooldown}</span>
                <span class="cost"><i class="fas fa-bolt"></i> ${ability.cost}</span>
            </div>
            <button class="ability-button" data-ability="${ability.id}">Activate</button>
        </div>
    `).join('');

    // Add event listeners to ability buttons
    container.querySelectorAll('.ability-button').forEach(button => {
        button.addEventListener('click', () => {
            const abilityId = button.dataset.ability;
            fetch(`https://${GetParentResourceName()}/useAbility`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ abilityId })
            });
        });
    });
}

// Initialize UI
document.addEventListener('DOMContentLoaded', () => {
    // Load saved settings
    const savedSettings = localStorage.getItem('districtZeroSettings');
    if (savedSettings) {
        updateSettings(JSON.parse(savedSettings));
    }

    // Show welcome notification
    showNotification('Welcome to District Zero! Press F8 for help.', 'info', 5000);
});

// Mission UI Functions
function showMission(mission) {
    currentMission = mission;
    
    // Update UI elements
    missionTitle.textContent = mission.label;
    missionDesc.textContent = mission.description;
    missionTime.textContent = '00:00';
    cashReward.textContent = formatMoney(mission.cashReward);
    xpReward.textContent = `${mission.xpReward} XP`;
    
    // Create objectives list
    objectivesList.innerHTML = '';
    mission.objectives.forEach((objective, index) => {
        const li = document.createElement('li');
        li.className = 'objective-item';
        li.innerHTML = `
            <span class="objective-icon">${getObjectiveIcon(objective.type)}</span>
            <span class="objective-text">${objective.label}</span>
            <span class="objective-count">${objective.count}</span>
        `;
        objectivesList.appendChild(li);
    });
    
    // Show UI
    missionUI.classList.remove('hidden');
}

function hideMission() {
    missionUI.classList.add('hidden');
    currentMission = null;
}

function updateTimer(time) {
    missionTime.textContent = time;
}

function updateObjective(index, remaining) {
    const objective = objectivesList.children[index];
    const countElement = objective.querySelector('.objective-count');
    
    countElement.textContent = remaining;
    
    if (remaining <= 0) {
        objective.classList.add('completed');
    }
}

// UI Management
function showUI(component) {
    const container = document.getElementById(`${component}-container`);
    if (container) {
        container.classList.remove('hidden');
        isUIOpen = true;
    }
}

function hideUI() {
    const containers = document.querySelectorAll('[id$="-container"]');
    containers.forEach(container => {
        container.classList.add('hidden');
    });
    isUIOpen = false;
}

// Helper Functions
function getObjectiveIcon(type) {
    const icons = {
        patrol: '🚔',
        arrest: '👮',
        search: '🔍',
        rob: '💰',
        escape: '🏃',
        hack: '💻'
    };
    return icons[type] || '📋';
}

function formatMoney(amount) {
    return '$' + amount.toLocaleString();
}

// Utility Functions
function formatNumber(number) {
    return new Intl.NumberFormat().format(number);
}

function formatTime(seconds) {
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`;
}

function getFactionColor(faction) {
    const colors = {
        criminal: '#ff4444',
        police: '#4444ff',
        civilian: '#44ff44'
    };
    return colors[faction] || '#ffffff';
}

// Export functions for use in other scripts
window.UI = {
    showNotification,
    formatNumber,
    formatTime,
    getFactionColor
}; 