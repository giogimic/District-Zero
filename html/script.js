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

function showNotification(message, type = 'info', duration = 3000) {
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.textContent = message;
    
    notificationContainer.appendChild(notification);
    
    // Trigger reflow to enable animation
    notification.offsetHeight;
    notification.classList.add('show');
    
    setTimeout(() => {
        notification.classList.remove('show');
        setTimeout(() => {
            notification.remove();
        }, 300);
    }, duration);
}

// NUI Message Handler
window.addEventListener('message', (event) => {
    const data = event.data;
    
    switch (data.type) {
        case 'showUI':
            showUI(data.component);
            break;
        case 'hideUI':
            hideUI();
            break;
        case 'updateUI':
            updateUI(data.component, data.data);
            break;
        case 'notification':
            showNotification(data.message, data.notificationType, data.duration);
            break;
    }
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

function updateUI(component, data) {
    const container = document.getElementById(`${component}-container`);
    if (container) {
        // Dispatch custom event for component-specific updates
        const event = new CustomEvent(`${component}:update`, { detail: data });
        container.dispatchEvent(event);
    }
}

// NUI Callbacks
function sendNUICallback(name, data = {}) {
    fetch(`https://${GetParentResourceName()}/${name}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
    });
}

// Close UI on Escape
document.addEventListener('keyup', (event) => {
    if (event.key === 'Escape' && isUIOpen) {
        hideUI();
        sendNUICallback('closeUI');
    }
});

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

function getNotificationIcon(type) {
    const icons = {
        success: '✅',
        error: '❌',
        info: 'ℹ️',
        warning: '⚠️'
    };
    return icons[type] || 'ℹ️';
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
    sendNUICallback,
    formatNumber,
    formatTime,
    getFactionColor
}; 