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
    uiOpacity: 1,
    keybinds: {
      openUI: 'F5',
      openSettings: 'F6',
      openMissions: 'F7',
      openFactions: 'F8',
    },
  },
};

// UI Elements
const elements = {
  tabs: document.querySelectorAll('.nav-item'),
  tabContents: document.querySelectorAll('.tab-content'),
  helpButton: document.getElementById('helpButton'),
  helpOverlay: document.getElementById('helpOverlay'),
  closeHelp: document.querySelector('.close-help'),
  notifications: document.getElementById('notifications'),
  closeButtons: document.querySelectorAll('.close-button'),
};

// Initialize UI
function init() {
  // Hide all UI elements by default
  hideAllUI();

  // Setup event listeners
  setupEventListeners();
  setupKeyBindings();

  // Listen for NUI messages
  window.addEventListener('message', handleNuiMessage);

  // Setup close buttons
  elements.closeButtons.forEach((button) => {
    button.addEventListener('click', () => {
      const container = button.closest('[id$="-container"]');
      if (container) {
        container.classList.add('hidden');
      }
    });
  });
}

// Hide All UI
function hideAllUI() {
  document.querySelectorAll('[id$="-container"]').forEach((container) => {
    container.classList.add('hidden');
  });
  isUIOpen = false;
}

// Setup Event Listeners
function setupEventListeners() {
  // Tab Navigation
  elements.tabs.forEach((tab) => {
    tab.addEventListener('click', (e) => {
      e.preventDefault();
      const tabId = tab.dataset.tab;
      switchTab(tabId);
    });
  });

  // Help System
  elements.helpButton.addEventListener('click', () => {
    elements.helpOverlay.style.display = 'flex';
  });

  elements.closeHelp.addEventListener('click', () => {
    elements.helpOverlay.style.display = 'none';
  });

  // Close on ESC
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      hideAllUI();
    }
  });
}

// Setup Key Bindings
function setupKeyBindings() {
  // Listen for key press events
  document.addEventListener('keydown', (e) => {
    const key = e.key.toUpperCase();

    // Check if key matches any keybind
    if (key === state.settings.keybinds.openUI) {
      toggleUI();
    } else if (key === state.settings.keybinds.openSettings) {
      toggleSettings();
    } else if (key === state.settings.keybinds.openMissions) {
      toggleMissions();
    } else if (key === state.settings.keybinds.openFactions) {
      toggleFactions();
    }
  });
}

// UI Toggle Functions
function toggleUI() {
  const container = document.getElementById('main-container');
  if (container) {
    container.classList.toggle('hidden');
    isUIOpen = !isUIOpen;
  }
}

function toggleSettings() {
  const container = document.getElementById('settings-container');
  if (container) {
    container.classList.toggle('hidden');
  }
}

function toggleMissions() {
  const container = document.getElementById('missions-container');
  if (container) {
    container.classList.toggle('hidden');
  }
}

function toggleFactions() {
  const container = document.getElementById('factions-container');
  if (container) {
    container.classList.toggle('hidden');
  }
}

// NUI Message Handler
window.addEventListener('message', (event) => {
  const data = event.data;

  switch (data.action) {
    case 'toggleUI':
      if (data.show) {
        showUI(data.component);
      } else {
        hideAllUI();
      }
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

    case 'closeAll':
      hideAllUI();
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
  containers.forEach((container) => {
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
    hack: '💻',
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
    civilian: '#44ff44',
  };
  return colors[faction] || '#ffffff';
}

// Export functions for use in other scripts
window.UI = {
  showNotification,
  formatNumber,
  formatTime,
  getFactionColor,
};

// Initialize
init();
