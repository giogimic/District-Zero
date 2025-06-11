let settings = {
    notifications: true,
    blips: true,
    markers: true,
    minimap: true,
    debug: false,
    uiScale: 1,
    uiOpacity: 1,
    keybinds: {
        openUI: 'F6',
        openSettings: 'F7'
    }
};

// Load settings from localStorage
function loadSettings() {
    const savedSettings = localStorage.getItem('districtZeroSettings');
    if (savedSettings) {
        settings = JSON.parse(savedSettings);
        updateUI();
    }
}

// Save settings to localStorage
function saveSettings() {
    localStorage.setItem('districtZeroSettings', JSON.stringify(settings));
    fetch(`https://${GetParentResourceName()}/updateSettings`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(settings)
    });
}

// Update UI elements with current settings
function updateUI() {
    document.getElementById('notifications').checked = settings.notifications;
    document.getElementById('blips').checked = settings.blips;
    document.getElementById('markers').checked = settings.markers;
    document.getElementById('minimap').checked = settings.minimap;
    document.getElementById('debug').checked = settings.debug;
    document.getElementById('uiScale').value = settings.uiScale;
    document.getElementById('uiOpacity').value = settings.uiOpacity;
    document.getElementById('openUIKey').value = settings.keybinds.openUI;
    document.getElementById('openSettingsKey').value = settings.keybinds.openSettings;
}

// Event Listeners
document.addEventListener('DOMContentLoaded', () => {
    loadSettings();

    // Checkbox listeners
    document.getElementById('notifications').addEventListener('change', (e) => {
        settings.notifications = e.target.checked;
    });

    document.getElementById('blips').addEventListener('change', (e) => {
        settings.blips = e.target.checked;
    });

    document.getElementById('markers').addEventListener('change', (e) => {
        settings.markers = e.target.checked;
    });

    document.getElementById('minimap').addEventListener('change', (e) => {
        settings.minimap = e.target.checked;
    });

    document.getElementById('debug').addEventListener('change', (e) => {
        settings.debug = e.target.checked;
    });

    // Slider listeners
    document.getElementById('uiScale').addEventListener('input', (e) => {
        settings.uiScale = parseFloat(e.target.value);
        document.documentElement.style.setProperty('--ui-scale', settings.uiScale);
    });

    document.getElementById('uiOpacity').addEventListener('input', (e) => {
        settings.uiOpacity = parseFloat(e.target.value);
        document.documentElement.style.setProperty('--ui-opacity', settings.uiOpacity);
    });

    // Keybind listeners
    const bindButtons = document.querySelectorAll('.bind-button');
    bindButtons.forEach(button => {
        button.addEventListener('click', (e) => {
            const keyInput = document.getElementById(e.target.dataset.key);
            keyInput.value = 'Press any key...';
            
            function handleKeyPress(event) {
                event.preventDefault();
                const key = event.key.toUpperCase();
                keyInput.value = key;
                settings.keybinds[e.target.dataset.key] = key;
                document.removeEventListener('keydown', handleKeyPress);
            }
            
            document.addEventListener('keydown', handleKeyPress);
        });
    });

    // Save button
    document.getElementById('saveSettings').addEventListener('click', () => {
        saveSettings();
        showNotification('Settings saved successfully!');
    });

    // Reset button
    document.getElementById('resetSettings').addEventListener('click', () => {
        settings = {
            notifications: true,
            blips: true,
            markers: true,
            minimap: true,
            debug: false,
            uiScale: 1,
            uiOpacity: 1,
            keybinds: {
                openUI: 'F6',
                openSettings: 'F7'
            }
        };
        updateUI();
        saveSettings();
        showNotification('Settings reset to default!');
    });
});

// Notification system
function showNotification(message) {
    const notification = document.createElement('div');
    notification.className = 'notification';
    notification.textContent = message;
    document.body.appendChild(notification);

    setTimeout(() => {
        notification.classList.add('show');
    }, 100);

    setTimeout(() => {
        notification.classList.remove('show');
        setTimeout(() => {
            notification.remove();
        }, 300);
    }, 3000);
}

// Listen for messages from the game client
window.addEventListener('message', (event) => {
    const data = event.data;
    
    if (data.action === 'updateSettings') {
        settings = data.settings;
        updateUI();
    }
}); 